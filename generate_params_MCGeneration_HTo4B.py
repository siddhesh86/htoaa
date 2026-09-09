import os
import getpass
import subprocess

### USERS settings ------------------------------------------------------------------------------------

prodmodes = [
    "GluGluHJ_HTo4B"
    # "WH_HTo4B"
]

# HiggsPtMinList = [150, 250, 350, 450]
HiggsPtMinList = [150]

# Uncomment MCSteps and Eras you want to run
Eras = [
#     "RunIISummer20UL18",
#     "RunIISummer20UL17",
#     "RunIISummer20UL16",
#     "RunIISummer20UL16APV",
#     "Run3Summer22",
    "Run3Summer24"
]


SampleNumber_First = 0 # 0 to 99
SampleNumber_Last  = 0  # 0 to 99

NEvents = 10 # 1000 maximum
### USERS settings ENDS --------------------------------------------------------------------------------



def xrootd_file_exists_cli(redirector, file_path):
    """
    Checks file existence by querying the system's native xrdfs command line tool.
    """
    url = f"root://{redirector}"
    
    # Running 'xrdfs root://server stat /path/to/file'
    # stdout/stderr are redirected to DEVNULL to keep output clean
    cmd = ["xrdfs", url, "stat", file_path]
    
    result = subprocess.run(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    
    # A return code of 0 means the file exists and is accessible
    return result.returncode == 0







UserName = getpass.getuser()
XRootDRedirector = "xrootd-cms.infn.it"
sFParams = "params_MCGeneration_HTo4B.txt"


if os.path.exists(sFParams):
    print(f"\nrm {sFParams}  ")
    os.remove(sFParams)


# Open file in append mode to match the behavior of '>>'
with open(sFParams, "a") as f:
    ## Data taking years and corresponding MCSteps to run
    #for ERA, MCSteps in MCStrepsToRun_perEra.items():  
    for ERA in Eras:
        
        if "Run3" in ERA:
            ECM = "13p6"  # 13p6 TeV
        else:
            ECM = "13"    # 13 TeV

        # Set EraYear: 2016AVF, 2016, 2017....
        EraYear = "2018"
        ## ERA: RunIISummer20UL18, RunIISummer20UL17, RunIISummer20UL16, RunIISummer20UL16APV
        if "16" in ERA and "APV" in ERA:
            EraYear = "2016APV"
        elif "16" in ERA:
            EraYear = "2016"
        elif "17" in ERA:
            EraYear = "2017"
        elif "18" in ERA:
            EraYear = "2018"
        elif "22" in ERA and "EE" in ERA:
            EraYear = "2022EE"
        elif "22" in ERA:
            EraYear = "2022"
        elif "23" in ERA and "BPix" in ERA:
            EraYear = "2023BPix"
        elif "23" in ERA:
            EraYear = "2023"
        elif "24" in ERA:
            EraYear = "2024"
        elif "25" in ERA:
            EraYear = "2025"
        elif "26" in ERA:
            EraYear = "2026"

        ## Loop over all Higgs production modes
        for prod in prodmodes:

            ## Loop over HiggsPtMinList
            for HiggsPtMin in HiggsPtMinList:
                


                # Python's range is exclusive of the end index, so add 1 to match '<=' loop
                for iSample in range(SampleNumber_First, SampleNumber_Last + 1):
                    sIpFile = ""
                    
                    ## iSample=0: Generate MC events from .lhe file
                    if HiggsPtMin == 150:
                        if "GluGluH" in prod:
                            #sIpFile = f"/store/group/phys_susy/HToaaTo4b/LHE/SM_HTo4b_LO_13p6/2026_09_01/pp-ggH-4b-single.lhe"
                            sIpFile = f"/eos/cms/store/group/phys_susy/HToaaTo4b/LHE/SM_HTo4b_LO_13p6/2026_09_01/vSplit/pp-ggH-4b/pp-ggH-4b-single_{iSample}.lhe"
                        elif "WH" in prod:
                            #sIpFile = f"/store/group/phys_susy/HToaaTo4b/LHE/SM_HTo4b_LO_13p6/2026_09_01/pp-WH-W4b-single.lhe"
                            sIpFile = f"/eos/cms/store/group/phys_susy/HToaaTo4b/LHE/SM_HTo4b_LO_13p6/2026_09_01/vSplit/pp-WH-W4b/pp-WH-W4b-single_{iSample}.lhe"

                    # Check if input file exists
                    if sIpFile:
                        if not xrootd_file_exists_cli(XRootDRedirector, sIpFile):
                            print(f"{XRootDRedirector}: {sIpFile} file does not exists! Skipping this job... \t\t\t **** ERROR ****")
                            continue

                    # Write formatted string to the file
                    f.write(f"{prod}, {HiggsPtMin}, {ECM}, {ERA}, {NEvents}, {iSample}, {sIpFile}, {UserName}\n")
