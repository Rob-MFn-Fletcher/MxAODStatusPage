import argparse
from ROOT import TFile,TH1
import pyAMI.client
import pyAMI.atlas.api as AtlasAPI
from sendEmail import sendEmail
import json
import os
import re
from glob import glob

def getAMIProv():
    """This function includes all AMI interface components

    This function uses the pyAMI API to get all needed information
    from the database and returns the event counts in a dictionary.
    """
    amiEvents = None
    return amiEvents

def getROOTInfo():
    """Get event number from the root files on eos.

    Get the root file and read all of the event number information from it.
    Return as a dictionary of results.
    """
    rootEvents = None
    return rootEvents

def validColor(combInfo):
    """Compare the appropriate events numbers and return a color code.

    Compare event numbers from AMI and the MxAOD. Returns a color (e.g. "red")
    that will be used to color the row on the website. The color will be determined
    by the result of the comparison of event numbers between AMI and ROOT files.

    """
    colorCode = "red"
    return colorCode

def readInputFile(inFile):
    """Read the input file in and parse the text as a dictionary.

    This will read a file with the format:
    <sampleType> <Dataset Name>
    into a dictionary as {'sampleType' : 'Dataset Name'}
    It will skip lines begining with #
    """
    inputFiles = {}
    if not os.path.isfile(inFile):
        print "Input file, %s does not exist".format(inFile)
        raise
    with open(inFile) as f:
        for line in f:
            if line.startswith('#'): continue #Skip comment lines
            (sample, DSname) = line.split()
            inputFiles[sample] = DSname

    return inputFiles


def runMC(args):
    """Run over MC files.

    The directory structure is slightly different between MC and data so
    two different funtions are used. This one runs over MC. It gets all samples
    from the mc* folder, calls functions to get root and AMI data then writes to
    a file.
    """
    # Make the htag directory to hold the output.
    outHtagDir = "../data/"+args.htag
    if not os.path.exists(outHtagDir):
        os.makedirs(outHtagDir)

    if agrs.v: print "Out directory:",outHtagDir

    # Get a list of all directories that start with mc. This should only return one.
    # NOTE: glob returns full file paths!! e.g. for h014 this command returns:  ['./eos/atlas/atlascerngroupdisk/phys-higgs/HSG1/MxAOD/h014/mc15c/']
    mxoadSamplesDir = glob(args.datasetDir+args.htag+'/mc*/')

    if args.v: print "MxAOD Samples Directories to run over:", mxaodSamplesDir

    # There should only be one MC directory for now. If later more are added will need to change the code a bit.
    if len(mxaodSamplesDir) > 1:
        print "There are multiple MC directories in this tag!!! This should not happen."
        raise

    mxaodSamples = glob(mxaodSamplesDir[0]+'*.root')
    # Some things in here can be directories containing multiple root files. Get a list of these.
    mxaod_multi_samples = glob(mxaodSamplesDir[0]+'*/')

    #loop over samples and get information
    jsonMCOutput = []
    for sample in mxaodSamples:
        # Deal with the dirs of root files later. Skip for now.
        if sample in mxaod_multi_samples:
            continue

        rootInfo = getROOTInfo(sample)
        amiInfo = getAMIProv(sample)

        # Combine these dictionaries into a single dictionary to write out.
        combInfo = dict(rootInfo.items() + amiInfo.items())

        color = validColor(combInfo)
        combInfo["color"] = color

        # Append the dictionary to a list of samples
        jsonMCSamplesOutput.append(combInfo)
    pass ## end sample loop

    #Output to file for use on website.
    json.dump(jsonMCSamplesOutput, "../data/%s/ValidationTable_MC.txt".format(args.htag))

    ### End runMC() function

def validHTag(htag):
    """This is used in an argparse type to ensure that the htag argument is in the proper format.

    """
    try:
        return re.match("h[0-9][0-9][0-9]", htag).group(0)
    except:
        raise argparse.ArgumentTypeError("First argument must be an htag of the form h<number>. eg. h012")


if __name__=="__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("htag", type=validHTag, help="The htag to run over")
    parser.add_argument("input", required=True, help="Input file to use. These are in the same format as the MxAOD sample input files.")
    parser.add_argument("-v", action='store_true', help="More verbose output.")
    parser.add_argument("-t", "--test-sample", help="Run only over this sample name to test. Wont write output to the website.")
    parser.add_argument("--mc", action='store_true', help="Run over MC samples only.")
    parser.add_argument("--data", action='store_true', help="Run over data samples only.")

    args = parser.parse_args()
    # set debug to true if t or v are are set. Check debug variable before verbose output.
    if args.t:
        args.v = True

    # setup a few directories, global vars etc...
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
        args.inputMC = glob("InputFiles/mc_%s.txt".format(args.htag))
        if not args.inputMC:
            print "MC input file does not exist. Input needs to be at './InputFiles/mc_%s.txt'".format(htag)
            print "If you didnt want to run over MC use the --data option."
            raise
    if args.data:
        args.inputData = glob("InputFiles/data_%s.txt".format(htag))
        if not args.inputMC:
            print "Data input file does not exist. Input needs to be at './InputFiles/data_%s.txt'".format(htag)
            print "If you didnt want to run over Data use the --mc option."
            raise

    #Run the samples that have args set to true.
    if args.mc:
        runMC(args)
    if args.data:
        runData(args)
