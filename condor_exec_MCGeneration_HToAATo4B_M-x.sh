#!/bin/bash

# SUSY_GluGluH_01J_HToAATo4B_Pt150_M-12_TuneCP5_13TeV_madgraph_pythia8

# https://indico.cern.ch/event/533066/contributions/2210981/attachments/1293986/1928541/CMSSW_tips.pdf
# xrdcp -f  tmp.txt root://xrootd-cms.infn.it:1094//eos/cms/store/user/ssawant/mc/tmp/tmp.txt

echo "condor_exec_MCGeneration_HToAATo4B_M-x.sh execution started"
echo "Print all input arguments: $@"

prodmode=$1
HiggsPtMin=$2
mA=$3
ERA=$4
NEvents=$5
iSample=$6
XRootDRedirector=$7
MadgraphGridpackSample_EosFileName=$8
#OpDir=$7


### Settings -----------------------------------------------------------------------------------------------------------
jobID="Pt${HiggsPtMin}_M-${mA}"                         # jobID is used for internal job processing and not used in dataset name.
SampleGeneratorDetails="TuneCP5_13TeV_madgraph_pythia8" # GENERATOR details that will be included in 'sample's name'.
xrdcpPort="1094"                                        # For e.g. xrdcp -f  tmp.txt root://xrootd-cms.infn.it:1094//eos/cms/store/user/ssawant/mc/tmp/tmp.txt

Dir_sourceCodes=$(pwd)                                  # GEN-fragment.py and other sample-generation-config files are transferred to 'pwd' by HT-Condor 
RandomNumberSeed=$RANDOM                                # Ramdom seed for sample generation

# GEN-filter efficiency
GENLevelEfficiency=$(bc -l <<< '0.0570' )
if   [ ${HiggsPtMin} -eq 150 ]; then
    GENLevelEfficiency=$(bc -l <<< '0.057' )
fi

NEvents_wmLHE=$(bc -l <<<"scale=0; $NEvents / $GENLevelEfficiency")
NEventsAll=-1

## Input file:
# Madgraph input file full path
# root://xrootd-cms.infn.it///store/user/ssawant/mc/SUSY_GluGluH_01J_HToAATo4B_M-47.5_el9_amd64_gcc11_CMSSW_13_2_9_tarball.tar.xz
MadgraphGridpackSample="root://${XRootDRedirector}/${MadgraphGridpackSample_EosFileName}"
MadgraphGridpackSample_local=./$(basename $MadgraphGridpackSample_EosFileName)

## Output file: local
# Sample data names
wmLHEGENFile=./${prodmode}_Pt${HiggsPtMin}_M-${mA}_${iSample}_nEvents${NEvents}_wmLHEGEN.root
wmLHEGEN_inLHE_File=./${prodmode}_Pt${HiggsPtMin}_M-${mA}_${iSample}_nEvents${NEvents}_wmLHEGEN_inLHE.root
SIMFile=./${prodmode}_Pt${HiggsPtMin}_M-${mA}_${iSample}_nEvents${NEvents}_SIM.root
DIGIPremixFile=./${prodmode}_Pt${HiggsPtMin}_M-${mA}_${iSample}_nEvents${NEvents}_DIGIPremix.root
HLTFile=./${prodmode}_Pt${HiggsPtMin}_M-${mA}_${iSample}_nEvents${NEvents}_HLT.root
RECOFile=./${prodmode}_Pt${HiggsPtMin}_M-${mA}_${iSample}_nEvents${NEvents}_RECO.root
MiniAODFile=./${prodmode}_Pt${HiggsPtMin}_M-${mA}_${iSample}_nEvents${NEvents}_MiniAODv2.root
#NanoAODFile=./${prodmode}_Pt${HiggsPtMin}_M-${mA}_${iSample}_nEvents${NEvents}_NanoAODv9.root

## Output file: Final
# xrdcp command: For e.g.:  xrdcp -f  tmp.txt root://xrootd-cms.infn.it:1094//eos/cms/store/user/ssawant/mc/tmp/tmp.txt
# xrdcp output dir: For e.g.: root://xrootd-cms.infn.it:1094//eos/cms/store/user/ssawant/mc/SUSY_GluGluH_01J_HToAATo4B_Pt150_M-47.5_TuneCP5_13TeV_madgraph_pythia8/RunIISummer20UL18
XRootDHostAndPort="root://${XRootDRedirector}:${xrdcpPort}"
OpDir_base=$(dirname $$MadgraphGridpackSample_EosFileName)
if [[ ${OpDir_base} == "/store/*" ]]; then
    OpDir_base="/eos/cms${OpDir_base}"
fi
OpDir="${OpDir_base}/${prodmode}_Pt${HiggsPtMin}_M-${mA}_${SampleGeneratorDetails}/${ERA}" 
MiniAODFile_Final_FileName=${OpDir}/MiniAODv2_${iSample}_nEvents${NEvents}.root
### -------------------------------------------------------------------------------------------------------------------


echo "argument prodmode: ${prodmode} "
echo "argument HiggsPtMin: $HiggsPtMin "
echo "argument mA: $mA "
echo "argument NEvents: $NEvents "
echo "argument iSample: $iSample "
printf "\nMadgraphGridpackSample: ${MadgraphGridpackSample} \n"
printf "MiniAODFile_Final: ${MiniAODFile_Final_FileName} \n"

echo "jobID 0: ${jobID}"
jobID="${jobID/./p}"
echo "jobID 1: ${jobID}"


echo "pwd: "
pwd
echo "ls -ltrh: "
ls -ltrh
echo "time xrdcp ${MadgraphGridpackSample} ${MadgraphGridpackSample_local} "
time xrdcp ${MadgraphGridpackSample} ${MadgraphGridpackSample_local}
echo "ls -ltrh after: "
ls -ltrh



# wmLHEGEN -------------------------------------------------------------------------
DatasetType='wmLHEGEN'
inputFile=${MadgraphGridpackSample_local}
outputFile=${wmLHEGENFile}
NEvents_toUse=${NEvents_wmLHE}

printf "\nRun source generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}  ${Dir_sourceCodes}   ${RandomNumberSeed}  ${HiggsPtMin} \n"
time . generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}  ${Dir_sourceCodes}   ${RandomNumberSeed}  ${HiggsPtMin}
printf "\n***Done source generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}  ${Dir_sourceCodes}  ${RandomNumberSeed}  ${HiggsPtMin} \n"
printf "ls -ltrh after ${DatasetType} step: \n"; ls -ltrh
printf "rm -rf CMSSW*  lheevent \n"
rm -rf CMSSW*  lheevent


# SIM -------------------------------------------------------------------------
DatasetType='SIM'
inputFile=${wmLHEGENFile}
outputFile=${SIMFile}
NEvents_toUse=${NEventsAll}

printf "\n\nRun source generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID} \n"
time . generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID} 
printf "\n***Done source generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}   \n"
printf "ls -ltrh after ${DatasetType} step: \n"; ls -ltrh
printf "\nrm -rf CMSSW* \n"
rm -rf CMSSW*

printf "rm -rf ${MadgraphGridpackSample_local} \n"
rm -rf ${MadgraphGridpackSample_local}


# DIGIPremix -------------------------------------------------------------------------
DatasetType='DIGIPremix'
inputFile=${SIMFile}
outputFile=${DIGIPremixFile}
NEvents_toUse=${NEventsAll}

printf "\n\nRun source generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID} \n"
time . generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}
printf "\n***Done source generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}  \n"
printf "ls -ltrh after ${DatasetType} step: \n"; ls -ltrh
printf "rm -rf CMSSW* \n"
rm -rf CMSSW* 

printf "rm -rf ${wmLHEGEN_inLHE_File} \n"
rm -rf ${wmLHEGEN_inLHE_File}
printf "rm -rf ${wmLHEGENFile} \n"
rm -rf ${wmLHEGENFile}



# HLT -------------------------------------------------------------------------
DatasetType='HLT'
inputFile=${DIGIPremixFile}
outputFile=${HLTFile}
NEvents_toUse=${NEventsAll}

printf "\n\nRun source . generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID} \n"
time . generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}
printf "\n***Done source generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID} \n" 
printf "ls -ltrh after ${DatasetType} step: \n"; ls -ltrh
printf "rm -rf CMSSW* \n"
rm -rf CMSSW*

printf "rm -rf ${SIMFile}: \n"
rm -rf ${SIMFile}




# RECO -------------------------------------------------------------------------
DatasetType='RECO'
inputFile=${HLTFile}
outputFile=${RECOFile}
NEvents_toUse=${NEventsAll}

printf "\n\nRun source generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID} \n"
time . generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}
printf "\n***Done source generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID} \n"
printf "ls -ltrh after ${DatasetType} step: \n"; ls -ltrh
printf "rm -rf CMSSW* \n"
rm -rf CMSSW* 

printf "rm -rf ${DIGIPremixFile} \n"
rm -rf ${DIGIPremixFile} 



# MiniAODv2 -------------------------------------------------------------------------
DatasetType='MiniAODv2'
inputFile=${RECOFile}
outputFile=${MiniAODFile}
NEvents_toUse=${NEventsAll}

printf "\n\nRun time . generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID} \n"
time . generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}
printf "\n***Done time . generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID} \n"
printf "ls -ltrh after ${DatasetType} step: \n"; ls -ltrh
printf "rm -rf CMSSW* \n"
rm -rf CMSSW* 

printf "rm -rf ${HLTFile} \n"
rm -rf ${HLTFile}
printf "rm -rf ${RECOFile} \n"
rm -rf ${RECOFile}

# NanoAODv9 -------------------------------------------------------------------------
#DatasetType='NanoAODv9'
#inputFile=${MiniAODFile}
#outputFile=${NanoAODFile}
#NEvents_toUse=${NEventsAll}

#printf "\n\nRun time . generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID} \n"
#time . generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID} 
#printf "\n***Done time . generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID} \n"
#printf "rm -rf CMSSW* \n"
#rm -rf CMSSW*


printf "\n\n***Done running all MC sample production steps. \n"
printf "ls -ltrh after all MC sample production steps: \n"
ls -ltrh

## Copy output file
# https://indico.cern.ch/event/533066/contributions/2210981/attachments/1293986/1928541/CMSSW_tips.pdf
# xrdcp -f  tmp.txt root://xrootd-cms.infn.it:1094//eos/cms/store/user/ssawant/mc/tmp/tmp.txt
printf "time xrdcp -f ${MiniAODFile} ${XRootDHostAndPort}/${MiniAODFile_Final_FileName} : \n"
time xrdcp -f ${MiniAODFile} ${XRootDHostAndPort}/${MiniAODFile_Final_FileName} 

# ls output file at final destination
printf "time xrdfs ${XRootDHostAndPort} ls -l ${MiniAODFile_Final_FileName} : \n"
time xrdfs ${XRootDHostAndPort} ls -l ${MiniAODFile_Final_FileName}

echo "rm ${MadgraphGridpackSample_local}: "
rm ${MadgraphGridpackSample_local}

echo "ls -ltrh at the end: "
ls -ltrh

echo "condor_exec_MCGeneration_HToAATo4B_M-x.sh done"
