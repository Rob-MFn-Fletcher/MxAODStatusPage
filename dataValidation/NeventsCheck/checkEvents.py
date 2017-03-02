"""Check events numbers from AODs and DAODs from AMI and the files themselves.

"""
import argparse
from ROOT import TFile,TH1,TTree,gROOT
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

    It is also possible to pass this function the name of folder that contains
    root files. This happens for the base data dir and some MC samples. If the
    sample passed in is a dir it builds a list of all files in the dir and loops
    over each of them adding the information from each to the totals.

    Return as a dictionary of results.
    """
    # setup the output dictionary
    rootEvents = {}
    rootEvents['AOD_Bookkeeper'] = 0
    rootEvents['DxAOD_Bookkeeper'] = 0
    rootEvents['NevtsRunOverMxAOD'] = 0
    rootEvents['NevtsPassedPreCutflowMxAOD'] = 0  # Ambiguity cut in the cutflow
    rootEvents['NevtsIsPassedPreFlagMxAOD'] = 0

    fileList = []

    #if the sample passed to this function is a directory, there will be a few
    # root files inside. Need to run over all of these and combine the results.
    if os.path.isdir(sample):
        fileList = glob(sample+'/*.root')
    else:
        fileList.append(sample)

    for f in fileList:
        rfile = TFile(f)
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
        rootEvents['NevtsIsPassedPreFlagMxAOD'] += int(nEvtsPre)
        rfile.Close()

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
        if combInfo['DxAOD_Bookkeeper'] != combInfo['DAOD_AMI']:
            colorCode = "red"
            error = "AMI and Bookkeeper dissagree for DxAOD"
    except:
        colorCode = "red"
        error = "Entries missing in combined info. AMI command might not have returned anything."

    return colorCode, error


def readInputFile(inFile):
    """Read the input file in and parse the text as a dictionary.

    This will read a file with the format:
    <sampleType> <Dataset Name>
    into a dictionary as {'sampleType' : 'Dataset Name'}
    It will skip lines begining with #

    Data file are a bit different. They have the format:
    periodXXXX <Dataset Name>
    We have to extract the run number from the dataset name
    and then construct the dictionary as runNumber:DSName
    so it can easily be searched later.
    """
    inputFiles = {}
    if not os.path.isfile(inFile):
        print "Input file, {0} does not exist".format(inFile)
        raise
    with open(inFile) as f:
        for line in f:
            if line.startswith('#'): continue #Skip comment lines
            if not line.strip(): continue #Skip empty lines
            if line.startswith('period'): #Handle the data file format
                year = re.search('period20([0-9][0-9])', line).group(1)
                period = 'data'+year
                if not period in inputFiles:
                    inputFiles[period] = {} # Split 2015 and 2016 up into two dicts.
                runNumber = re.search('.*TeV\.(.*)\.physics_Main.*',line).group(1) #The short name of the sample
                (sample, DSname) = line.split()
                inputFiles[period][runNumber] = DSname
            else: #Handle the MC file format
                try:
                    (sample, DSname) = line.split()
                except:
                    sample = line.rstrip()
                    DSname = ''

                inputFiles[sample] = DSname

    return inputFiles

def makeEmail(args,directory, errorSamples, missingSamples):
    """Make an email message and send it using the sendEmail.py module in this directory.

    Expects a dictionary with samples as keys and a list of errors as
    values. Loop over samples and add the errors to the message then send.
    """
    addrs = args.email
    subject = "Data Validation Script Result for "+args.htag+":"+directory
    message = "Data Validation Script Completed for {0}:{1}. Results below:\n".format(directory, args.htag)
    message += "\nSamples Missing from eos:\n"
    for sample in missingSamples:
        message += "  -{0}\n".format(sample)
    message += "\n---== Detailed Results: ==---\n"
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
    # Get the dictionary made from the input file

    # Get a list of all directories that start with mc. This should only return one.
    # NOTE: glob returns full file paths!! e.g. for h014 this command returns:  ['./eos/atlas/atlascerngroupdisk/phys-higgs/HSG1/MxAOD/h014/mc15c/']
    mxaodSamplesDir = glob(args.datasetDir+args.htag+'/mc*/')
    mxaodSamplesDir += glob(args.datasetDir+args.htag+'/*Sys/')

    if args.v: print "MxAOD Samples Directories to run over:", mxaodSamplesDir

    for mcDir in mxaodSamplesDir:
        inputMC = readInputFile(args.inputMC)

        jsonOutput = [] # Final Json output file.
        errorSamples = {} # keep track of samples with mismatches or errors
        missingSamples = []

        mcDirName = mcDir.split('/')[-2] #mc15c, PhotonSys, etc...
        if args.v: print "Running of directory:", mcDir

        # If we are not overwriting everything then open the json files and load
        # them into memory. This will be used to check if we have run over a sample
        # before.
        if not args.overwrite:
            with open("../data/{0}/ValidationTable_{1}.json".format(args.htag, mcDirName),'r') as outfile:
                jsonOutput = json.load(outfile) # Final Json output file.
            with open("../data/{0}/errors_{1}.json".format(args.htag, mcDirName),'r') as errfile:
                errorSamples = json.load(errfile) # keep track of samples with mismatches or errors

        # Truncate and open the files again so we can write a fresh json doc out.
        outfile = open("../data/{0}/ValidationTable_{1}.json".format(args.htag, mcDirName),'w')
        errfile = open("../data/{0}/errors_{1}.json".format(args.htag, mcDirName),'w')

        mxaodSamples = glob(mcDir+'/*.root')
        # Some things in here can be directories containing multiple root files. Get a list of these.
        mxaod_multi_samples = glob(mcDir+'/*/')


        # Build a list of the short sample names that are on eos to check against the input file
        eosSamples=[]
        for samplePath in mxaodSamples:
            eosSamples.append(re.search('mc.*\.(.*)\.MxAOD.*',samplePath).group(1))#The short name of the sample

        # look in the proper input file. Im not a super huge fan of doing it this way
        # but we only need the sys inputs for this check.
        if mcDirName == 'PhotonSys':
            inputCheck = readInputFile(args.inputPhotonSys)
        if mcDirName == 'PhotonAllSys':
            inputCheck = readInputFile(args.inputPhotonAllSys)
        if mcDirName == 'LeptonMETSys':
            inputCheck = readInputFile(args.inputLeptonMETSys)
        if mcDirName == 'JetSys':
            inputCheck = readInputFile(args.inputJetSys)
        if mcDirName == 'FlavorSys':
            inputCheck = readInputFile(args.inputFlavorSys)
        if mcDirName == 'FlavorAllSys':
            inputCheck = readInputFile(args.inputFlavorAllSys)
        if mcDirName == 'mc15c':
            inputCheck = inputMC
        # Do the check for all inputs existing on eos and write to the error log if not.
        for inputSample in inputCheck:
            if not inputSample in eosSamples:
                if not inputSample in errorSamples: errorSamples[inputSample] = []
                if args.v: print inputSample, " -- Missing from eos"
                errorSamples[inputSample].append("Sample in input file is missing from eos.")
                missingSamples.append(inputSample)
        pass # End of eos file checking.

        sampleNum = 0
        #loop over samples and get information
        for sample in mxaodSamples:
            sampleNum += 1
            sampleStart = time.time()

            # get the sampleType from the path. e.g. /path/to/mc15a.Sherpa_ADDyy_MS3500_1800M.MxAOD.p2610.h013x.root
            # will return 'Sherpa_ADDyy_MS3500_1800M'
            sampleType = re.search('mc.*\.(.*)\.MxAOD.*',sample).group(1) #The short name of the sample
            if args.v: print "===>",sampleType, "({0}/{1})".format(sampleNum, len(mxaodSamples))
            # If we used the test arg, only run over that sample
            if args.test_sample and not (args.test_sample == sampleType): continue

            # Check if the sample already exists in the output dictionary. If it does skip the sample.
            if any(entry['sampleType']==sampleType for entry in jsonOutput):
                if args.v: print "   --- Sample found in output. Skipping..."
                continue

            rootStart = time.time()
            rootInfo = getROOTInfo(sample)
            rootEnd = time.time()
            #if args.v: print "   --- getROOTInfo ran in", rootEnd - rootStart, "seconds."

            amiStart = time.time()
            amiInfo = {}
            if sampleType in inputMC:
                amiInfo = getAMIProv(inputMC[sampleType]) #needs AMI dataset name as input
            else:
                if not sampleType in errorSamples: errorSamples[sampleType] = []
                errorSamples[sampleType].append("Sample missing from the input file.")
            amiEnd = time.time()
            #if args.v: print "   --- getAMIProv ran in", amiEnd - amiStart, "seconds."

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

            sampleEnd = time.time()
            if args.v: print "   --- sample loop ran in", sampleEnd - sampleStart, "seconds."
        pass ## end sample loop

        # email when done
        makeEmail(args, mcDirName, errorSamples, missingSamples)
        #Output error and sample info to file for use on website.
        json.dump(errorSamples, errfile, indent=2)
        json.dump(jsonOutput, outfile, indent=2)

        pass ## End of dataDir loop
    ### End runMC() function

def runData(args):
    """Run over the data samples.

    For data we need to look at files inside of the folder /data15, /data16, and also the
    /runs folder inside each of those. This is differnt than what MC looks like so
    we need a different function. For the most part this is the same as the runMC() function.

    NOTE: There is a lot of code duplication here. Work on combining this with runMC() into a single
    function. Might make the code a lot more messy though since data needs to calculate totals. If
    it would end up impacting readablility do not do it. Someone is going to have to learn this code
    eventually.
    """

    # Get the dictionary made from the input file. Since the data is a bit different than the MC we need to reorganize a bit.
    inputData = readInputFile(args.inputData)

    # Get the JSON file of previous output so we run only over new files.
    #jsonFile = open("../data/{0}/ValidationTable_{1}.json".format(args.htag, dataDirName),'w')

    # Get a list of all directories that start with data. This should return data15, data16 and data16_iTS. We dont want this last one.
    mxaodSamplesDir = glob(args.datasetDir+args.htag+'/data*/')


    if args.v: print "MxAOD Samples Directories to run over:", mxaodSamplesDir

    for dataDir in mxaodSamplesDir:

        errorSamples = {} # keep track of samples with mismatches or errors
        jsonOutput = [] # Final Json output file.
        missingSamples = []

        dataDirName = dataDir.split('/')[-2] # data15, data16 or the iTS direcotry
        if args.v: print "Running over data directory:", dataDirName

        # If we are not overwriting everything then open the json files and load
        # them into memory. This will be used to check if we have run over a sample
        # before.
        if not args.overwrite:
            with open("../data/{0}/ValidationTable_{1}.json".format(args.htag, dataDirName),'r') as outfile:
                jsonOutput = json.load(outfile) # Final Json output file.
            with open("../data/{0}/errors_{1}.json".format(args.htag, dataDirName),'r') as outfile:
                errorSamples = json.load(efffile) # keep track of samples with mismatches or errors

        # Truncate and open the files again so we can write a fresh json doc out.
        outfile = open("../data/{0}/ValidationTable_{1}.json".format(args.htag, dataDirName),'w')
        errfile = open("../data/{0}/errors_{1}.json".format(args.htag, dataDirName),'w')

        mxaodSamples = glob(dataDir+'/runs/*.root')
        # Some things in here can be directories containing multiple root files. Get a list of these.
        mxaod_multi_samples = glob(dataDir+'/runs/*/')

        #Check that everything in the input file is found on eos.
        #Get List of short names from files in the directories.
        dataDirName_striped = dataDirName.rstrip('_iTS') # The data16_iTS directory should use the data16 entry in the input file.

        eosSamples = []
        for samplePath in mxaodSamples:
            eosSamples.append(re.search('data.*\.(.*)\.physics_Main\.MxAOD.*',samplePath).group(1))#The short name of the sample

        # Do the check for all inputs existing on eos and write to the error log if not.
        for inputSample in inputData[dataDirName_striped]:
            if not inputSample in eosSamples:
                if not inputSample in errorSamples: errorSamples[inputSample] = []
                errorSamples[inputSample].append("Sample in input file is missing from eos.")
                missingSamples.append(inputSample)

        # Add the base dir containing the split up root files for the total dataset.
        # I put this here because we dont want to do the above eos check on these.
        # they will not be in the input file since they are combinations of runs.
        mxaodSamples.append(dataDir)

        #need to find the 'Total' entry in the JSON if it exists and delete it. The totals should Always
        #be updated, since any files added should change the totals.
        for i in range(len(jsonOutput)):
            if jsonOutput[i]['sampleType'] == 'Merged':
                jsonOutput.pop(i)

        # Running totals for all files in the dir. Used to compare to the totals in the base dir files.
        xAODAMITotal = 0
        DxAODAMITotal = 0
        xAODBookkeeperTotal = 0
        DxAODBookkeeperTotal = 0
        NevtsRunOverMxAODTotal = 0
        NevtsPassedPreCutflowMxAODTotal = 0  # Ambiguity cut in the cutflow
        NevtsIsPassedPreFlagMxAODTotal = 0

        sampleNum = 0
        #loop over samples and get information
        for sample in mxaodSamples:
            sampleNum += 1
            # get the sampleType from the path. e.g. /path/to/mc15a.Sherpa_ADDyy_MS3500_1800M.MxAOD.p2610.h013x.root
            # will return 'Sherpa_ADDyy_MS3500_1800M'
            if sample == dataDir: sampleType = 'Merged' #use the label 'Total' for the data samples in the base dir.
            else: sampleType = re.search('data.*\.(.*)\.physics_Main\.MxAOD.*',sample).group(1) #The short name of the sample

            if not sampleType:
                print "!!=> SampleType is empty!!!! No valid name found in", sample
            if args.v: print "===>",dataDirName+":"+sampleType, "({0}/{1})".format(sampleNum, len(mxaodSamples))
            # If we used the test arg, only run over that sample
            if args.test_sample and not (args.test_sample == sampleType): continue


            # Check if the sample already exists in the output dictionary. If it does skip the sample.
            if any(entry['sampleType']==sampleType for entry in jsonOutput):
                if args.v: print "   --- Sample found in output. Skipping..."
                continue

            rootInfo = getROOTInfo(sample)

            amiInfo = {}
            totalInfo = {}
            if sampleType in inputData[dataDirName_striped]:
                amiInfo = getAMIProv(inputData[dataDirName_striped][sampleType]) #needs AMI dataset name as input
                #Add to the running total of all tracked numbers.
                xAODAMITotal += amiInfo['AOD_AMI']
                DxAODAMITotal += amiInfo['DAOD_AMI']
                xAODBookkeeperTotal += rootInfo['AOD_Bookkeeper']
                DxAODBookkeeperTotal += rootInfo['DxAOD_Bookkeeper']
                NevtsRunOverMxAODTotal += rootInfo['NevtsRunOverMxAOD']
                NevtsPassedPreCutflowMxAODTotal += rootInfo['NevtsPassedPreCutflowMxAOD']  # Ambiguity cut in the cutflow
                NevtsIsPassedPreFlagMxAODTotal += rootInfo['NevtsIsPassedPreFlagMxAOD']

            elif sampleType == 'Merged':
                amiInfo['AOD_AMI'] = xAODAMITotal # running Totals from all other files
                amiInfo['DAOD_AMI'] = DxAODAMITotal
                #Merged row to be added for the merged files
                totalInfo['AOD_AMI'] = xAODAMITotal
                totalInfo['DAOD_AMI'] = DxAODAMITotal
                totalInfo['AOD_Bookkeeper'] = xAODBookkeeperTotal
                totalInfo['DxAOD_Bookkeeper'] = DxAODBookkeeperTotal
                totalInfo['NevtsRunOverMxAOD'] = NevtsRunOverMxAODTotal
                totalInfo['NevtsPassedPreCutflowMxAOD'] = NevtsPassedPreCutflowMxAODTotal  # Ambiguity cut in the cutflow
                totalInfo['NevtsIsPassedPreFlagMxAOD'] = NevtsIsPassedPreFlagMxAODTotal
                totalInfo['sampleType'] = 'Total'
                totalInfo['color'] = ''
                jsonOutput.append(totalInfo)
            else:
                if not sampleType in errorSamples: errorSamples[sampleType] = []
                errorSamples[sampleType].append("Sample in eos is missing from the input file.")

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

        # email when done.
        makeEmail(args,dataDirName, errorSamples, missingSamples)
        #Output to file for use on website.
        json.dump(errorSamples, errfile, indent=2)
        json.dump(jsonOutput, outfile, indent=2)

        pass ## End of dataDir loop

    ###  End of runData() function

def validHTag(htag):
    """This is used in an argparse type to ensure that the htag argument is in the proper format.

    """
    try:
        return re.match("^h[0-9][0-9][0-9][a-z]?$", htag).group(0)
    except:
        raise argparse.ArgumentTypeError("First argument must be an htag of the form h<number>. eg. h012 or h014b")


if __name__=="__main__":
    startTime = time.time()
    parser = argparse.ArgumentParser()
    parser.add_argument("htag", type=validHTag, help="The htag to run over")
    parser.add_argument("-v", action='store_true', help="More verbose output.")
    parser.add_argument("-q", action='store_true', help="Less Root output.")
    parser.add_argument("-o","--overwrite", action='store_true', help="Overwrite json output. This will rerun all samples instead of skipping previeously run ones.")
    parser.add_argument("-t", "--test-sample", help="Run only over this sample name to test. Wont write output to the website.")
    parser.add_argument("--mc", action='store_true', help="Run over MC samples only.")
    parser.add_argument("--data", action='store_true', help="Run over data samples only.")
    parser.add_argument("--email", nargs='+',dest='add_email', help="Additional email adresses to send logs to. Space separated list. MUST COME LAST")

    args = parser.parse_args()
    # set debug to true if t or v are are set. Check debug variable before verbose output.
    if args.test_sample:
        args.v = True

    # Quiet root output
    if args.q: gROOT.ProcessLine("gErrorIgnoreLevel = kFatal;")

    # setup a few directories, global vars etc...
    #args.email = ["rob.fletcher@cern.ch","chris.meyer@cern.ch","jared.vasquez@cern.ch"] #email this address when done. Must be a list.
    args.email = ["rob.fletcher@cern.ch"] #email this address when done. Must be a list.
    if args.add_email:
        args.email += args.add_email
    if args.v: print "Email address to send report:", args.email

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
            if args.v: print "Using MC input file: ", args.inputMC
        except:
            print "MC input file does not exist. Input needs to be at './InputFiles/mc_{0}.txt'".format(args.htag)
            print "If you didnt want to run over MC use the --data option."
            raise Exception("Input file error.")
    if args.mc:
        try:
            args.inputPhotonSys = glob("./InputFiles/PhotonSys_{0}.txt".format(args.htag))[0]
            if args.v: print "Using PhotonSys input file: ", args.inputPhotonSys
            args.inputJetSys = glob("./InputFiles/JetSys_{0}.txt".format(args.htag))[0]
            if args.v: print "Using JetSys input file: ", args.inputJetSys
            args.inputLeptonMETSys = glob("./InputFiles/LeptonMETSys_{0}.txt".format(args.htag))[0]
            if args.v: print "Using LeptonMETSys input file: ", args.inputLeptonMETSys
            args.inputFlavorSys = glob("./InputFiles/FlavorSys_{0}.txt".format(args.htag))[0]
            if args.v: print "Using FlavorSys input file: ", args.inputFlavorSys
            args.inputPhotonAllSys = glob("./InputFiles/PhotonAllSys_{0}.txt".format(args.htag))[0]
            if args.v: print "Using PhotonAllSys input file: ", args.inputPhotonAllSys
            args.inputFlavorAllSys = glob("./InputFiles/FlavorAllSys_{0}.txt".format(args.htag))[0]
            if args.v: print "Using FlavorAllSys input file: ", args.inputFlavorAllSys
        except:
            print "Systematic input file does not exist. Input needs to be at './InputFiles/<sys Name>_{0}.txt'".format(args.htag)
            print "If you didnt want to run over MC use the --data option."
            raise Exception("Input file error.")

    if args.data:
        try:
            args.inputData = glob("./InputFiles/data_{0}.txt".format(args.htag))[0]
            if args.v: print "Using input file: ", args.inputData
        except:
            print "Data input file does not exist. Input needs to be at './InputFiles/data_{0}.txt'".format(args.htag)
            print "If you didnt want to run over Data use the --mc option."
            raise Exception("Input file error.")

    # Make the htag directory to hold the output.
    outHtagDir = "../data/"+args.htag
    if not os.path.exists(outHtagDir):
        if args.v: print "Output dir does not exist. Creating."
        os.makedirs(outHtagDir)

    if args.v: print "Out directory:",outHtagDir

    #Run the samples that have args set to true.
    if args.mc:
        runMC(args)
        pass
    if args.data:
        runData(args)
        pass
    endTime = time.time()
    totalSeconds = endTime - startTime
    m, s = divmod(totalSeconds, 60)
    h, m = divmod(m, 60)
    print "checkevents.py --- Run Time: %d:%02d:%02d" % (h, m, s)
