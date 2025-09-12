#!/bin/bash

## SUSY_GluGluH_01J_HToAATo4B_Pt450_mH-70_mA-12_wH-70_wA-10: 28.2 mins/event

# SUSY_GluGluH_01J_HToAATo4B_Pt150_M-12_TuneCP5_13TeV_madgraph_pythia8

# https://indico.cern.ch/event/533066/contributions/2210981/attachments/1293986/1928541/CMSSW_tips.pdf
# xrdcp -f  tmp.txt root://xrootd-cms.infn.it:1094//eos/cms/store/user/ssawant/mc/tmp/tmp.txt

echo "condor_exec_NanoAODReproc_HToAATo4B_M-x.sh execution started"
echo "hostname: "
hostname
echo "date: "
date
echo "pwd : "
pwd
echo "Print all input arguments: $@"

Dir_SourceCode_0="/afs/cern.ch/work/s/ssawant/private/htoaa/htoaa"

RandomNumber=$RANDOM
Dir_1="dir_${RandomNumber}"
printf "\n mkdir ${Dir_1} : \n"
mkdir ${Dir_1}
printf "\n cd ${Dir_1} : \n"
cd ${Dir_1}
printf "\n cp ../* . : \n"
cp ../* .
printf "\n cp -r ${Dir_SourceCode_0}/* . : \n"
cp -r ${Dir_SourceCode_0}/* .
printf "\n pwd : \n"
pwd

export VO_CMS_SW_DIR=/cvmfs/cms.cern.ch
#export SCRAM_ARCH=slc7_amd64_gcc10
source /cvmfs/cms.cern.ch/cmsset_default.sh
export HOME=$(pwd) # HOME environment variable is not set by default, so set it as pwd. It is needed for DAS query
#source /afs/cern.ch/user/s/ssawant/.bashrc


#export X509_USER_PROXY=/afs/cern.ch/user/s/ssawant/x509up_u108989
export X509_USER_PROXY=$1
printf "\nvoms-proxy-info -all: \n"
voms-proxy-info -all
printf "\nvoms-proxy-info -all -file $X509_USER_PROXY : \n"
voms-proxy-info -all -file $X509_USER_PROXY

printf "\n printenv : \n"
printenv

# Check if DAS query works fine
echo "dasgoclient --version : "
dasgoclient --version
#echo "dasgoclient --query=\"dataset=/ZeroBias*/*Run2022C*/*\" -verbose 2: "
#dasgoclient --query="dataset=/ZeroBias*/*Run2022C*/*" -verbose 2
echo "dasgoclient --query=\"dataset=/ZeroBias*/*Run2022C*/*\" : "
dasgoclient --query="dataset=/ZeroBias*/*Run2022C*/*" 

# Set input variables :
printf "Print all input arguments: $@"
prodmode=$2
HiggsPtMin=$3
mA=$4
wA=$5
ERA=$6
NEvents=$7
iSample=$8
fMiniAODs=$9
#XRootDRedirector=$9
#MadgraphGridpackSample_EosFileName=${10}

printf "\n ls ${fMiniAODs}: $(ls $fMiniAODs) \n"
fMiniAODs=$(basename $fMiniAODs)
printf "\n ls ${fMiniAODs}: $(ls $fMiniAODs) \n"


### Settings -----------------------------------------------------------------------------------------------------------
# sample name e.g. SUSY_TTH_TTToAll_HToAATo4B_Pt150_M-12_TuneCP5_13TeV_madgraph_pythia8
#jobID="Pt${HiggsPtMin}_M-${mA}"                         # jobID is used for internal job processing and not used in dataset name.
jobID="${prodmode}_Pt${HiggsPtMin}_M-${mA}_${ERA}"                         # jobID is used for internal job processing and not used in dataset name.
SampleGeneratorDetails="TuneCP5_13TeV_madgraph_pythia8" # GENERATOR details that will be included in 'sample's name'.
xrdcpPort="1094"                                        # For e.g. xrdcp -f  tmp.txt root://xrootd-cms.infn.it:1094//eos/cms/store/user/ssawant/mc/tmp/tmp.txt


Dir_baseLocal=$(pwd)
Dir_sourceCodes=$(pwd)                                  # GEN-fragment.py and other sample-generation-config files are transferred to 'pwd' by HT-Condor 
RandomNumberSeed=$RANDOM                                # Ramdom seed for sample generation


NEventsAll=-1

EraYear=2018
## ERA: RunIISummer20UL18, RunIISummer20UL17, RunIISummer20UL16, RunIISummer20UL16APV
if   [[ ${ERA} == *"16"*  && ${ERA} == *"APV"* ]]; then 
    EraYear="2016APV"
elif [[ ${ERA} == *"16"* ]]; then 
    EraYear="2016"
elif [[ ${ERA} == *"17"* ]]; then
    EraYear=2017
elif [[ ${ERA} == *"18"* ]]; then
    EraYear=2018
fi

#fIpMiniAODSamples="miniAOD_files/miniAODs_SUSY_GluGluH_01J_HToAATo4B_Pt150_M-57.5_2018.txt"
#fIpMiniAODSamples="miniAOD_files/miniAODs_${prodmode}_Pt${HiggsPtMin}_M-${mA}_${EraYear}.txt"
fIpMiniAODSamples=${fMiniAODs} #"miniAOD_files/test.txt"

## Input file:
XRootDRedirector="xrootd-cms.infn.it"
MadgraphGridpackSample_EosFileName="xyz.tar.xz"
if (( $(echo "$wA < 0.5" |bc -l) )); then 
    # for e.g. /store/user/ssawant/mc/SUSY_VBFH_HToAATo4B_M-47.5_slc7_amd64_gcc10_CMSSW_12_4_8_tarball.tar.xz
    MadgraphGridpackSample_EosFileName="/store/user/ssawant/mc/${prodmode}_M-${mA}_slc7_amd64_gcc10_CMSSW_12_4_8_tarball.tar.xz"
else
    # for e.g. /store/user/ssawant/mc/SUSY_GluGluH_01J_HToAATo4B_mH-70_mA-12_wH-70_wA-70_0_slc7_amd64_gcc10_CMSSW_12_4_8_tarball.tar.xz
    MadgraphGridpackSample_EosFileName="/store/user/ssawant/mc/${prodmode}_mH-70_mA-${mA}_wH-70_wA-${wA}_0_slc7_amd64_gcc10_CMSSW_12_4_8_tarball.tar.xz"
fi

# Madgraph input file full path
# root://xrootd-cms.infn.it///store/user/ssawant/mc/SUSY_GluGluH_01J_HToAATo4B_M-47.5_el9_amd64_gcc11_CMSSW_13_2_9_tarball.tar.xz
MadgraphGridpackSample="root://${XRootDRedirector}/${MadgraphGridpackSample_EosFileName}"
MadgraphGridpackSample_local=${Dir_baseLocal}/$(basename $MadgraphGridpackSample_EosFileName)

## Output file: local
# Sample data names
SampleProcessName="${prodmode}_Pt${HiggsPtMin}_M-${mA}"
if (( $(echo "$wA > 1" | bc -l) )); then
    SampleProcessName="${prodmode}_Pt${HiggsPtMin}_mH-70_mA-${mA}_wH-70_wA-${wA}"
fi

wmLHEGENFile=${Dir_baseLocal}/${SampleProcessName}_${iSample}_nEvents${NEvents}_wmLHEGEN.root
wmLHEGEN_inLHE_File=${Dir_baseLocal}/${SampleProcessName}_${iSample}_nEvents${NEvents}_wmLHEGEN_inLHE.root
SIMFile=${Dir_baseLocal}/${SampleProcessName}_${iSample}_nEvents${NEvents}_SIM.root
DIGIPremixFile=${Dir_baseLocal}/${SampleProcessName}_${iSample}_nEvents${NEvents}_DIGIPremix.root
HLTFile=${Dir_baseLocal}/${SampleProcessName}_${iSample}_nEvents${NEvents}_HLT.root
RECOFile=${Dir_baseLocal}/${SampleProcessName}_${iSample}_nEvents${NEvents}_RECO.root
MiniAODFile=${Dir_baseLocal}/${SampleProcessName}_${iSample}_nEvents${NEvents}_MiniAODv2.root
NanoAODFile0=${Dir_baseLocal}/${SampleProcessName}_${iSample}_nEvents${NEvents}_NanoAODv9.root
NanoAODFile=${Dir_baseLocal}/${SampleProcessName}_${iSample}_nEvents${NEvents}_NanoAODv9_Skim.root

## Output file: Final
# xrdcp command: For e.g.:  xrdcp -f  tmp.txt root://xrootd-cms.infn.it:1094//eos/cms/store/user/ssawant/mc/tmp/tmp.txt
# xrdcp output dir: For e.g.: root://xrootd-cms.infn.it:1094//eos/cms/store/user/ssawant/mc/SUSY_GluGluH_01J_HToAATo4B_Pt150_M-47.5_TuneCP5_13TeV_madgraph_pythia8/RunIISummer20UL18
XRootDHostAndPort="root://${XRootDRedirector}:${xrdcpPort}"
XRootDHostAndPort1="root://eosuser.cern.ch"
#OpDir_base=$(dirname $MadgraphGridpackSample_EosFileName)
#if [[ ${OpDir_base} == "/store/"* ]]; then
#    OpDir_base="/eos/cms${OpDir_base}"
#fi
#OpDir="${OpDir_base}/${SampleProcessName}_${SampleGeneratorDetails}/${ERA}" 
#MiniAODFile_Final_FileName=${OpDir}/MiniAODv2_${iSample}_nEvents${NEvents}.root
#NanoAODFile_Final_FileName=${OpDir}/NanoAODv9Custom_${iSample}_nEvents${NEvents}.root
OpSubdirNum=$(printf "%04d" $((${iSample} / 100)) )
# /eos/cms/store/group/phys_susy/HToaaTo4b/MiniAOD/2018/MC/SUSY_GluGluH_01J_HToAATo4B_Pt150_M-10.0_TuneCP5_13TeV_madgraph_pythia8/RunIISummer20UL18/0017/MiniAODv2_1701_nEvents500.root
MiniAODFile_Final_FileName=/eos/cms/store/group/phys_susy/HToaaTo4b/MiniAOD/${EraYear}/MC/${SampleProcessName}_${SampleGeneratorDetails}/${ERA}/${OpSubdirNum}/MiniAODv2_${iSample}_nEvents${NEvents}.root
# customNanoAOD /eos/cms/store/group/phys_susy/HToaaTo4b/NanoAOD/2018/MC/PNet_v1_2023_10_06/SUSY_GluGluH_01J_HToAATo4B_Pt150_M-10.0_TuneCP5_13TeV_madgraph_pythia8/r1/20240202_000000/0002/NanoAODv9Custom_203_nEvents500.root
#NanoAODFile_Final_FileName=/eos/cms/store/group/phys_susy/HToaaTo4b/NanoAOD/${EraYear}/MC/PNet_v1_2023_10_06/${SampleProcessName}_${SampleGeneratorDetails}/r1/20240202_000000/${OpSubdirNum}/NanoAODv9Custom_${iSample}_nEvents${NEvents}.root
# Central NanoAOD /eos/cms/store/group/phys_susy/HToaaTo4b/NanoAOD/2018/MC/SUSY_GluGluH_01J_HToAATo4B_Pt150_M-12_TuneCP5_13TeV_madgraph_pythia8/RunIISummer20UL18NanoAODv9/08905042-1C08-314E-8753-61FFF45D1F2A.root
# /eos/cms/store/group/phys_susy/HToaaTo4b/NanoAOD/2018/MC/PNet_v2_2024_11_22/SUSY_GluGluH_01J_HToAATo4B_Pt150_M-60_TuneCP5_13TeV_madgraph_pythia8/r1/241123_175526/0000
#NanoAODFile_Final_FileName0=/eos/cms/store/group/phys_susy/HToaaTo4b/NanoAOD/${EraYear}/MC/PNet_v2_2024_11_22/${SampleProcessName}_${SampleGeneratorDetails}/r1/20250510_000000/${OpSubdirNum}/PNet_v1_${iSample}.root
#NanoAODFile_Final_FileName=/eos/cms/store/group/phys_susy/HToaaTo4b/NanoAOD/${EraYear}/MC/PNet_v2_2024_11_22/${SampleProcessName}_${SampleGeneratorDetails}/r1/20250510_000000/${OpSubdirNum}/PNet_v1_${iSample}_Skim.root
NanoAODFile_Final_FileName0=/eos/cms/store/user/ssawant/tmp/HToaaTo4b/NanoAOD/${EraYear}/MC/${SampleProcessName}_${SampleGeneratorDetails}/r1/20250510_000000/${OpSubdirNum}/PNet_v1_${iSample}.root
NanoAODFile_Final_FileName=/eos/cms/store/user/ssawant/tmp/HToaaTo4b/NanoAOD/${EraYear}/MC/${SampleProcessName}_${SampleGeneratorDetails}/r1/20250510_000000/${OpSubdirNum}/PNet_v1_${iSample}_Skim.root
### -------------------------------------------------------------------------------------------------------------------


echo "argument prodmode: ${prodmode} "
echo "argument HiggsPtMin: $HiggsPtMin "
echo "argument mA: $mA "
echo "argument NEvents: $NEvents "
echo "argument iSample: $iSample "
printf "\nMadgraphGridpackSample: ${MadgraphGridpackSample} \n"
printf "MadgraphGridpackSample_EosFileName: ${MadgraphGridpackSample_EosFileName} \n"
#printf "(dirname $MadgraphGridpackSample_EosFileName)"
printf "OpDir_base: ${OpDir_base} \n"
printf "OpDir: ${OpDir} \n"
printf "ERA: ${ERA} \n"
printf "EraYear: ${EraYear} \n"
printf "MiniAODFile_Final: ${MiniAODFile_Final_FileName} \n"
printf "{XRootDHostAndPort}/{MiniAODFile_Final_FileName}: ${XRootDHostAndPort}/${MiniAODFile_Final_FileName} \n"
printf "NanoAODFile_Final_FileName: ${NanoAODFile_Final_FileName} \n"

echo "jobID 0: ${jobID}"
jobID="${jobID/./p}"
echo "jobID 1: ${jobID}"


echo "pwd: "
pwd
echo "ls -ltrh: "
ls -ltrh

# Read MiniAOD samples from input file ----------------------------------------------
printf "Reading MiniAOD samples from file ${fIpMiniAODSamples} \n"
NanoAODStep_inputFilesList="["
while IFS= read -r line; do
    echo "Text read from file: $line"
    FileNameEOS=$line
    FileNameEOS=${FileNameEOS/"/eos/cms"/}
    FileNameEOS="root://${XRootDRedirector}/${FileNameEOS}"
    FileName_local=${Dir_baseLocal}/$(basename $FileNameEOS)
    # xrdcp miniAOD 
    echo "time xrdcp ${FileNameEOS} ${FileName_local} "
    time xrdcp ${FileNameEOS} ${FileName_local}

    NanoAODStep_inputFilesList="${NanoAODStep_inputFilesList}'file:${FileName_local}',"
done < ${fIpMiniAODSamples}
NanoAODStep_inputFilesList="${NanoAODStep_inputFilesList::-1}"
NanoAODStep_inputFilesList="${NanoAODStep_inputFilesList}]"
printf "Done with reading MiniAOD samples \n"
printf "NanoAODStep_inputFilesList: >>>${NanoAODStep_inputFilesList}<<<"


# NanoAODv9 -------------------------------------------------------------------------
#DatasetType='NanoAODv9'
#inputFile='file:/eos/cms/store/group/phys_susy/HToaaTo4b/MiniAOD/2018/MC/SUSY_GluGluH_01J_HToAATo4B_Pt150_M-11.5_TuneCP5_13TeV_madgraph_pythia8/RunIISummer20UL18/0018/MiniAODv2_1898_nEvents500.root' #${MiniAODFile}
#outputFile=${NanoAODFile}
#NEvents_toUse=${NEventsAll}

#printf "\n\nRun time . generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID} \n"
#time . generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID} 
#printf "\n***Done time . generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID} \n"
#printf "rm -rf CMSSW* \n"
#rm -rf CMSSW*

# NanoAODv9Custom -------------------------------------------------------------------------
#DatasetType='NanoAODv9Customv2p1'
DatasetType='NanoAODv9Customv2'
inputFile=${NanoAODStep_inputFilesList} #${MiniAODFile}
outputFile=${NanoAODFile0}

NEvents_toUse=${NEventsAll}
#generate_RunIISummer20UL18NanoAODv9Customv2
printf "\n\nRun time . generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${EraYear}  \n"
time . generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${EraYear}
printf "\n***Done time . generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${EraYear}  \n"
printf "rm -rf CMSSW* \n"
rm -rf CMSSW*





printf "\n\n***Done running all MC sample production steps. \n"
printf "ls -ltrh after all MC sample production steps: \n"
ls -ltrh

printf "\n\n ls -ltrh ${MiniAODFile} ${NanoAODFile0} ${NanoAODFile} after all MC sample production steps: \n"
ls -ltrh ${MiniAODFile} ${NanoAODFile0} ${NanoAODFile}

## Copy NanoAOD0 file
if [ -f ${NanoAODFile0} ]; then
    printf "\n\n xrdcp -f -v ${NanoAODFile0} ${XRootDHostAndPort1}/${NanoAODFile_Final_FileName0} :\n"
    # run xrdcp command until it succeeds
    try=1
    xrdcpSucceed=1
    until xrdcp -f -v ${NanoAODFile0} ${XRootDHostAndPort1}/${NanoAODFile_Final_FileName0}
    do
        try=$((try+1))
        if [ $try -ge 100 ]; then
            xrdcpSucceed=0
            printf "try=${try} reached maximum limit. Give up xrdcp (1) .... \n"
            break
        fi
        printf "xrdcp (1) failed. Try again: try ${try}\n"
        sleep 10
    done
    printf "xrdcp (1) done in try ${try} with xrdcpSucceed = ${xrdcpSucceed} *** \n"

    # Try another xrdcp command
    if [ $xrdcpSucceed -eq 0 ]; then
        # gfal-copy -f tmp.txt root://eosuser.cern.ch//eos/cms/store/user/ssawant/mc/SUSY_GluGluH_01J_HToAATo4B_Pt150_M-47.5_TuneCP5_13TeV_madgraph_pythia8/tmp.txt
        printf "\n\n gfal-copy -f ${NanoAODFile0} ${XRootDHostAndPort1}/${NanoAODFile_Final_FileName0} :\n"
        try=1
        xrdcpSucceed=1
        until gfal-copy -f ${NanoAODFile0} ${XRootDHostAndPort1}/${NanoAODFile_Final_FileName0}
        do
            try=$((try+1))
            if [ $try -ge 100 ]; then
                xrdcpSucceed=0
                printf "try=${try} reached maximum limit. Give up xrdcp (2) .... \n"
                break
            fi
            printf "xrdcp (2) failed. Try again: try ${try}\n"
            sleep 10
        done
        printf "xrdcp (2) done in try ${try} with xrdcpSucceed = ${xrdcpSucceed} *** \n"
    fi

    # Try xrdcp another command
    if [ $xrdcpSucceed -eq 0 ]; then
        # xrdcp -f  tmp.txt root://xrootd-cms.infn.it:1094//eos/cms/store/user/ssawant/mc/tmp/tmp.txt
        printf "\n\n xrdcp -f -v ${NanoAODFile0} ${XRootDHostAndPort}/${NanoAODFile_Final_FileName0} : \n"
        try=1
        xrdcpSucceed=1
        until xrdcp -f -v ${NanoAODFile0} ${XRootDHostAndPort}/${NanoAODFile_Final_FileName0}
        do
            try=$((try+1))
            if [ $try -ge 100 ]; then
                xrdcpSucceed=0
                printf "try=${try} reached maximum limit. Give up xrdcp (3) .... \n"
                break
            fi
            printf "xrdcp (3) failed. Try again: try ${try}\n"
            sleep 10
        done
        printf "xrdcp (3) done in try ${try} with xrdcpSucceed = ${xrdcpSucceed} *** \n"
    fi

    if [ $xrdcpSucceed -eq 1 ]; then
        printf "rm ${NanoAODFile0} : \n"
        rm ${NanoAODFile0}    
    else
        # xrdcp failed:
        # mv Nanoaod to condor_base directory so that the minoaod is copied to condor_submission directory
        printf "\n mv ${NanoAODFile0} ../ : \n"
        mv ${NanoAODFile0} ../
    fi
fi


## Copy NanoAOD file
if [ -f ${NanoAODFile} ]; then
    printf "\n\n xrdcp -f -v ${NanoAODFile} ${XRootDHostAndPort1}/${NanoAODFile_Final_FileName} :\n"
    # run xrdcp command until it succeeds
    try=1
    xrdcpSucceed=1
    until xrdcp -f -v ${NanoAODFile} ${XRootDHostAndPort1}/${NanoAODFile_Final_FileName}
    do
        try=$((try+1))
        if [ $try -ge 100 ]; then
            xrdcpSucceed=0
            printf "try=${try} reached maximum limit. Give up xrdcp (1) .... \n"
            break
        fi
        printf "xrdcp (1) failed. Try again: try ${try}\n"
        sleep 10
    done
    printf "xrdcp (1) done in try ${try} with xrdcpSucceed = ${xrdcpSucceed} *** \n"

    # Try another xrdcp command
    if [ $xrdcpSucceed -eq 0 ]; then
        # gfal-copy -f tmp.txt root://eosuser.cern.ch//eos/cms/store/user/ssawant/mc/SUSY_GluGluH_01J_HToAATo4B_Pt150_M-47.5_TuneCP5_13TeV_madgraph_pythia8/tmp.txt
        printf "\n\n gfal-copy -f ${NanoAODFile} ${XRootDHostAndPort1}/${NanoAODFile_Final_FileName} :\n"
        try=1
        xrdcpSucceed=1
        until gfal-copy -f ${NanoAODFile} ${XRootDHostAndPort1}/${NanoAODFile_Final_FileName}
        do
            try=$((try+1))
            if [ $try -ge 100 ]; then
                xrdcpSucceed=0
                printf "try=${try} reached maximum limit. Give up xrdcp (2) .... \n"
                break
            fi
            printf "xrdcp (2) failed. Try again: try ${try}\n"
            sleep 10
        done
        printf "xrdcp (2) done in try ${try} with xrdcpSucceed = ${xrdcpSucceed} *** \n"
    fi

    # Try xrdcp another command
    if [ $xrdcpSucceed -eq 0 ]; then
        # xrdcp -f  tmp.txt root://xrootd-cms.infn.it:1094//eos/cms/store/user/ssawant/mc/tmp/tmp.txt
        printf "\n\n xrdcp -f -v ${NanoAODFile} ${XRootDHostAndPort}/${NanoAODFile_Final_FileName} : \n"
        try=1
        xrdcpSucceed=1
        until xrdcp -f -v ${NanoAODFile} ${XRootDHostAndPort}/${NanoAODFile_Final_FileName}
        do
            try=$((try+1))
            if [ $try -ge 100 ]; then
                xrdcpSucceed=0
                printf "try=${try} reached maximum limit. Give up xrdcp (3) .... \n"
                break
            fi
            printf "xrdcp (3) failed. Try again: try ${try}\n"
            sleep 10
        done
        printf "xrdcp (3) done in try ${try} with xrdcpSucceed = ${xrdcpSucceed} *** \n"
    fi

    if [ $xrdcpSucceed -eq 1 ]; then
        printf "rm ${NanoAODFile} : \n"
        rm ${NanoAODFile}    
    else
        # xrdcp failed:
        # mv Nanoaod to condor_base directory so that the minoaod is copied to condor_submission directory
        printf "\n mv ${NanoAODFile} ../ : \n"
        mv ${NanoAODFile} ../
    fi
fi



echo "ls -ltrh at the end: "
ls -ltrh

printf "\n cd .. : \n"
cd ..



echo "condor_exec_MCGeneration_HToAATo4B_M-x.sh done"
echo "date: "
date
