"""Check events numbers from AODs and DAODs from AMI and the files themselves.

"""
import argparse
from ROOT import TFile,TH1,TTree
import pyAMI.client
import pyAMI.atlas.api as AtlasAPI
from sendEmail import sendEmail
import json, os, re, time
from glob import glob

# Setup a few things that we only want to initialize once.
client = pyAMI.client.Client('atlas')
AtlasAPI.init()

def getAMIProv(sample):
    """This function includes all AMI interface components

    This function uses the pyAMI API to get all needed information
    from the database and returns the event counts in a dictionary.
    The provenance is all files that the dataset were produced from, or that
    were used to produce the dataset. The 'distance' determines how many steps
    away from the dataset the entry is. e.g. -1 is the file that was used to
    produce the dataset, and 1 is a file that was produced FROM the dataset.

    --sample should be the full dataset name as you would search for it in AMI
      with *NO* trailing /.
    """
    amiEvents = {}
    # Get the provenance from AMI
    sample = sample.rstrip('/') #Remove any trailing slashes
    sample = sample.split(':',1)[-1] # Remove anything before a ':' if its there.
    prov = AtlasAPI.get_dataset_prov(client, sample)
    # Loop over all of the datasets in the provenance
    for dataset in prov['node']:
        # Get nevents from the AOD that this sample was produced from
        if dataset['dataType'] == 'AOD':
            if dataset['distance'] == '-1': # The file imediately before the derivation
                amiEvents['AOD_AMI'] = int(dataset['events'])
        # Get the nEvents from the derivation sample.
        if dataset['dataType'] == 'DAOD_HIGG1D1':
            if dataset['distance'] == '0': # The actual sample. Any higher numbers are files made from this one.
                amiEvents['DAOD_AMI'] = int(dataset['events'])

    return amiEvents

def getROOTInfo(sample):
    """Get event number from the root files on eos.

    Get the root file and read all of the event number information from it.
    For MC samples this will just be one cutflow histo. For data there could be
    one histo for each run in the combined files. These need to have the numbers
    added for each one of the runs.
    Return as a dictionary of results.
    """
    # setup the output dictionary
    rootEvents = {}
    rootEvents['AOD_Bookkeeper'] = 0
    rootEvents['DxAOD_Bookkeeper'] = 0
    rootEvents['NevtsRunOverMxAOD'] = 0
    rootEvents['NevtsPassedPreCutflowMxAOD'] = 0  # Ambiguity cut in the cutflow

    rfile = TFile(sample)
    # loop over everything in the file and get cutflow histos
    for key in rfile.GetListOfKeys():
        name = key.GetName()
        if not "CutFlow" in name: continue #skip things that are not a cutflow histo
        if ("Dalitz" in name or "weighted" in name): continue #skip the Dalitz and weighted histos
        hist = key.ReadObj()
        # Get events from the Cutflow histogram and add them to the totals.
        # Adding to the totals are for data where there are histos for each run in one file.
        rootEvents['AOD_Bookkeeper'] += int(hist.GetBinContent(1))
        rootEvents['DxAOD_Bookkeeper'] += int(hist.GetBinContent(2))
        rootEvents['NevtsRunOverMxAOD'] += int(hist.GetBinContent(3))
        # Preselection events from the cutflow histogram.
        rootEvents['NevtsPassedPreCutflowMxAOD'] += int(hist.GetBinContent(10)) # Ambiguity cut in the cutflow

    # Now get the preselection events from the flags in the tree.
    tree = rfile.Get("CollectionTree")
    nEvtsPre = tree.GetEntries("HGamEventInfoAuxDyn.isPassedBasic && HGamEventInfoAuxDyn.isPassedPreselection")
    rootEvents['NevtsIsPassedPreFlagMxAOD'] = int(nEvtsPre)

    return rootEvents

def validColor(combInfo):
    """Compare the appropriate events numbers and return a color code.

    Compare event numbers from AMI and the MxAOD. Returns a color (e.g. "red")
    and an error string that will be used to color the row on the website. The color will be determined
    by the result of the comparison of event numbers between AMI and ROOT files.

    """
    colorCode = ""
    error = ""
    try:
        if not (combInfo['DAOD_AMI'] == combInfo['NevtsRunOverMxAOD']): colorCode = "red"
        if combInfo['DAOD_AMI'] > combInfo['NevtsRunOverMxAOD']:
            colorCode = "red"
            error = "Sample missing events in MxAOD"
        if not (combInfo['NevtsPassedPreCutflowMxAOD'] == combInfo['NevtsIsPassedPreFlagMxAOD']):
            colorCode = "red"
            error = "Cutflow histogram preselection and IsPassedPreselection flags dissagree."
    except:
        colorCode = "red"
        error = "Entries missing in combined info."

    return colorCode, error


def readInputFile(inFile):
    """Read the input file in and parse the text as a dictionary.

    This will read a file with the format:
    <sampleType> <Dataset Name>
    into a dictionary as {'sampleType' : 'Dataset Name'}
    It will skip lines begining with #
    """
    inputFiles = {}
    if not os.path.isfile(inFile):
        print "Input file, {0} does not exist".format(inFile)
        raise
    with open(inFile) as f:
        for line in f:
            if line.startswith('#'): continue #Skip comment lines
            if not line.strip(): continue #Skip empty lines
            (sample, DSname) = line.split()
            inputFiles[sample] = DSname

    return inputFiles

def makeEmail(args, errorSamples):
    """Make an email message and send it using the sendEmail.py module in this directory.

    Expects a dictionary with samples as keys and a list of errors as
    values. Loop over samples and add the errors to the message then send.
    """
    addrs = args.email
    subject = "Data Validation Script Result"
    message = "Data Validation Script Completed. Results below:\n"
    if not errorSamples: message += "No Errors detected!\n"
    for sample in errorSamples:
        message += "\nErrors for sample {0}:\n".format(sample)
        for error in errorSamples[sample]:
            message += "    -- {0}\n".format(error)

    sendEmail(addrs, subject, message)

def runMC(args):
    """Run over MC files.

    The directory structure is slightly different between MC and data so
    two different funtions are used. This one runs over MC. It gets all samples
    from the mc* folder, calls functions to get root and AMI data then writes to
    a file.

    TODO: Handle the cases where the sample name is actually a directory with
    multiple root files in it.
    """
    errorSamples = {} # keep track of samples with mismatches or errors
    jsonOutput = [] # Final Json output file.

    # Make the htag directory to hold the output.
    outHtagDir = "../data/"+args.htag
    if not os.path.exists(outHtagDir):
        if args.v: print "Output dir does not exist. Creating."
        os.makedirs(outHtagDir)

    if args.v: print "Out directory:",outHtagDir

    # Get the dictionary made from the input file
    inputMC = readInputFile(args.inputMC)

    # Get a list of all directories that start with mc. This should only return one.
    # NOTE: glob returns full file paths!! e.g. for h014 this command returns:  ['./eos/atlas/atlascerngroupdisk/phys-higgs/HSG1/MxAOD/h014/mc15c/']
    mxaodSamplesDir = glob(args.datasetDir+args.htag+'/mc*/')

    if args.v: print "MxAOD Samples Directories to run over:", mxaodSamplesDir

    # There should only be one MC directory for now. If later more are added will need to change the code a bit.
    if len(mxaodSamplesDir) > 1:
        print "There are multiple MC directories in this tag!!! This should not happen."
        raise

    mxaodSamples = glob(mxaodSamplesDir[0]+'*.root')
    # Some things in here can be directories containing multiple root files. Get a list of these.
    mxaod_multi_samples = glob(mxaodSamplesDir[0]+'*/')

    #loop over samples and get information
    for sample in mxaodSamples:
        # Deal with the dirs of root files later. Skip for now.
        if os.path.isdir(sample): continue 

        # get the sampleType from the path. e.g. /path/to/mc15a.Sherpa_ADDyy_MS3500_1800M.MxAOD.p2610.h013x.root
        # will return 'Sherpa_ADDyy_MS3500_1800M'
        sampleType = re.search('mc.*\.(.*)\.MxAOD.*',sample).group(1) #The short name of the sample
        if args.v: print "===>",sampleType
        # If we used the test arg, only run over that sample
        if args.test_sample and not (args.test_sample == sampleType): continue

        rootInfo = getROOTInfo(sample)

        amiInfo = {}
        if sampleType in inputMC:
            amiInfo = getAMIProv(inputMC[sampleType]) #needs AMI dataset name as input
        else:
            if not sampleType in errorSamples: errorSamples[sampleType] = []
            errorSamples[sampleType].append("Sample missing from the input file.")

        # Combine these dictionaries into a single dictionary to write out.
        combInfo = dict(rootInfo.items() + amiInfo.items())
        combInfo['sampleType'] = sampleType

        # If there are mismatches in the nEvents set the color to red. White otherwise.
        # Also returns error string to explain which thing failed.
        color, error = validColor(combInfo)
        combInfo["color"] = color

        # If there was a mismatch, put an error message in a dict to email later.
        if color == "red":
            if not sampleType in errorSamples: errorSamples[sampleType] = []
            errorSamples[sampleType].append(error)
            if args.v: print "   ---Error:",error

        # Append the dictionary to a list of samples
        jsonOutput.append(combInfo)
    pass ## end sample loop

    # email when done
    makeEmail(args, errorSamples)
    with open("../data/{0}/errors_MC.json".format(args.htag),'w') as errfile:
        json.dump(errorSamples, errfile, indent=2)
    #Output to file for use on website.
    with open("../data/{0}/ValidationTable_MC.json".format(args.htag),'w') as outfile:
        json.dump(jsonOutput, outfile, indent=2)

    ### End runMC() function

def runData(args):
    """Run over the data samples.

    For data we need to look at files inside of the folder /data15, /data16, and also the
    /runs folder inside each of those. This is differnt than what MC looks like so
    we need a different function. For the most part this is the same as the runMC() function.
    """
    print "Run Data not yet implemented. Skipping."
    pass


def validHTag(htag):
    """This is used in an argparse type to ensure that the htag argument is in the proper format.

    """
    try:
        return re.match("h[0-9][0-9][0-9]", htag).group(0)
    except:
        raise argparse.ArgumentTypeError("First argument must be an htag of the form h<number>. eg. h012")


if __name__=="__main__":
    startTime = time.time()
    parser = argparse.ArgumentParser()
    parser.add_argument("htag", type=validHTag, help="The htag to run over")
    #parser.add_argument("input", help="Input file to use. These are in the same format as the MxAOD sample input files.")
    parser.add_argument("-v", action='store_true', help="More verbose output.")
    parser.add_argument("-t", "--test-sample", help="Run only over this sample name to test. Wont write output to the website.")
    parser.add_argument("--mc", action='store_true', help="Run over MC samples only.")
    parser.add_argument("--data", action='store_true', help="Run over data samples only.")

    args = parser.parse_args()
    # set debug to true if t or v are are set. Check debug variable before verbose output.
    if args.test_sample:
        args.v = True

    # setup a few directories, global vars etc...
    args.email = ["rob.fletcher@cern.ch"] #email this address when done. Must be a list.
    args.datasetDir = "./eos/atlas/atlascerngroupdisk/phys-higgs/HSG1/MxAOD/" # assumes eos is mounted on the folder ./eos This should be done in setup.sh.
    if not glob(args.datasetDir): #make sure eos is mounted
        raise IOError("eos does not appear to be mounted. Did you run the setup script? (souce setup.sh)")

    # If neither mc or data options are given then do both
    # If one is set then then dont change anything.
    if not (args.mc or args.data):
        args.mc = True
        args.data = True

    # Check and get the appropriate input files. If the files do not exist raise an error.
    if args.mc:
        try:
            args.inputMC = glob("./InputFiles/mc_{0}.txt".format(args.htag))[0]
        except:
            print "MC input file does not exist. Input needs to be at './InputFiles/mc_{0}.txt'".format(args.htag)
            print "If you didnt want to run over MC use the --data option."
            raise Exception("Input file error.")
    if args.data:
        try:
            args.inputData = glob("./InputFiles/data_{0}.txt".format(args.htag))[0]
        except:
            print "Data input file does not exist. Input needs to be at './InputFiles/data_{0}.txt'".format(htag)
            print "If you didnt want to run over Data use the --mc option."
            raise Exception("Input file error.")

    #Run the samples that have args set to true.
    if args.mc:
        runMC(args)
    if args.data:
        runData(args)
    endTime = time.time()
    print "checkEvents.py -- Run Time: ", (endTime - startTime)
