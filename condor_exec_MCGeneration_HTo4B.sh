#!/bin/bash


## Setting input variables ------------------------------------------
export X509_USER_PROXY=$1
prodmode=$2
HiggsPtMin=$3
ERA=$4
NEvents=$5
iSample=$6
IpFile=$7

printf "prodmode: ${prodmode} \n"
printf "HiggsPtMin: ${HiggsPtMin} \n"
printf "ERA: ${ERA} \n"
#printf "MCStep: ${MCStep} \n"
printf "NEvents: ${NEvents} \n"
printf "iSample: ${iSample} \n"
#printf "XRootDRedirector: ${XRootDRedirector} \n"
printf "IpFile: ${IpFile} \n"
#printf "OpFile: ${OpFile} \n"

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
elif   [[ ${ERA} == *"22"*  && ${ERA} == *"EE"* ]]; then 
    EraYear="2022EE"
elif [[ ${ERA} == *"22"* ]]; then 
    EraYear="2022"
elif   [[ ${ERA} == *"23"*  && ${ERA} == *"BPix"* ]]; then 
    EraYear="2023BPix"
elif [[ ${ERA} == *"23"* ]]; then 
    EraYear="2023"
elif [[ ${ERA} == *"24"* ]]; then
    EraYear="2024"
elif [[ ${ERA} == *"25"* ]]; then
    EraYear="2025"
elif [[ ${ERA} == *"26"* ]]; then
    EraYear="2026"
fi
printf "EraYear: ${EraYear} \n"

## Testing initial setup -------------------------------------------
echo "condor_exec_MCGeneration_HToAATo4B_M-x.sh execution started"
echo "hostname: "
hostname
echo "uname -a: "
uname -a
echo "date: "
date
echo "pwd : "
pwd
echo "Print all input arguments: $@"

RandomNumber=$RANDOM
Dir_1="dir_${RandomNumber}"
printf "\n mkdir ${Dir_1} : \n"
mkdir ${Dir_1}
printf "\n cd ${Dir_1} : \n"
cd ${Dir_1}
printf "\n cp ../* . : \n"
cp ../* .
printf "\n pwd : \n"
pwd

export VO_CMS_SW_DIR=/cvmfs/cms.cern.ch
#export SCRAM_ARCH=slc7_amd64_gcc10
source /cvmfs/cms.cern.ch/cmsset_default.sh
export HOME=$(pwd) # HOME environment variable is not set by default, so set it as pwd. It is needed for DAS query

printf "\nvoms-proxy-info -all: \n"
voms-proxy-info -all
printf "\nvoms-proxy-info -all -file $X509_USER_PROXY : \n"
voms-proxy-info -all -file $X509_USER_PROXY

: '
printf "\n printenv : \n"
printenv

# Check if DAS query works fine
echo "dasgoclient --version : "
dasgoclient --version
#echo "dasgoclient --query=\"dataset=/ZeroBias*/*Run2022C*/*\" -verbose 2: "
#dasgoclient --query="dataset=/ZeroBias*/*Run2022C*/*" -verbose 2
echo "dasgoclient --query=\"dataset=/ZeroBias*/*Run2022C*/*\" : "
dasgoclient --query="dataset=/ZeroBias*/*Run2022C*/*" 
'


## Setting local variables ------------------------------------------

Dir_baseLocal=$(pwd)
Dir_sourceCodes=$(pwd)                                  # GEN-fragment.py and other sample-generation-config files are transferred to 'pwd' by HT-Condor 
RandomNumberSeed=$RANDOM                                # Ramdom seed for sample generation

# Sample data names
SampleProcessName="${prodmode}_Pt${HiggsPtMin}"
jobID="${SampleProcessName}_${iSample}" 
SampleGeneratorDetails="TuneCP5_13TeV_CalcHEP_pythia8" # GENERATOR details that will be included in 'sample's name'.

xrdcpPort="1094"                                        # For e.g. xrdcp -f  tmp.txt root://xrootd-cms.infn.it:1094//eos/cms/store/user/ssawant/mc/tmp/tmp.txt
XRootDRedirector="xrootd-cms.infn.it"
# xrdcp command: For e.g.:  xrdcp -f  tmp.txt root://xrootd-cms.infn.it:1094//eos/cms/store/user/ssawant/mc/tmp/tmp.txt
# xrdcp output dir: For e.g.: root://xrootd-cms.infn.it:1094//eos/cms/store/user/ssawant/mc/SUSY_GluGluH_01J_HToAATo4B_Pt150_M-47.5_TuneCP5_13TeV_madgraph_pythia8/RunIISummer20UL18
XRootDHostAndPort="root://${XRootDRedirector}:${xrdcpPort}"
XRootDHostAndPort1="root://eosuser.cern.ch"

OpSubdirNum=$(printf "%04d" $((${iSample} / 100)) )
# /eos/cms/store/group/phys_susy/HToaaTo4b/MiniAOD/2018/MC/SUSY_GluGluH_01J_HToAATo4B_Pt150_M-10.0_TuneCP5_13TeV_madgraph_pythia8/RunIISummer20UL18/0017/MiniAODv2_1701_nEvents500.root
MiniAODFile_EOS=/eos/cms/store/group/phys_susy/HToaaTo4b/MiniAOD/${EraYear}/MC/${SampleProcessName}_${SampleGeneratorDetails}/${ERA}/2026_09_01/${OpSubdirNum}/MiniAODv6_${iSample}_nEvents${NEvents}.root
#MiniAODFile_EOS=/eos/cms/store/user/ssawant/test/HToaaTo4b/MiniAOD/${EraYear}/MC/${SampleProcessName}_${SampleGeneratorDetails}/${ERA}/2026_09_01/${OpSubdirNum}/MiniAODv6_${iSample}_nEvents${NEvents}.root
# customNanoAOD /eos/cms/store/group/phys_susy/HToaaTo4b/NanoAOD/2018/MC/PNet_v1_2023_10_06/SUSY_GluGluH_01J_HToAATo4B_Pt150_M-10.0_TuneCP5_13TeV_madgraph_pythia8/r1/20240202_000000/0002/NanoAODv9Custom_203_nEvents500.root
#NanoAODFile_EOS=/eos/cms/store/group/phys_susy/HToaaTo4b/NanoAOD/${EraYear}/MC/PNet_v1_2023_10_06/${SampleProcessName}_${SampleGeneratorDetails}/r1/20240202_000000/${OpSubdirNum}/NanoAODv9Custom_${iSample}_nEvents${NEvents}.root
# Central NanoAOD /eos/cms/store/group/phys_susy/HToaaTo4b/NanoAOD/2018/MC/SUSY_GluGluH_01J_HToAATo4B_Pt150_M-12_TuneCP5_13TeV_madgraph_pythia8/RunIISummer20UL18NanoAODv9/08905042-1C08-314E-8753-61FFF45D1F2A.root
NanoAODFile_EOS=/eos/cms/store/group/phys_susy/HToaaTo4b/NanoAOD/${EraYear}/MC/${SampleProcessName}_${SampleGeneratorDetails}/${ERA}NanoAODv15/2026_09_01/${OpSubdirNum}/NanoAODv15_${iSample}_nEvents${NEvents}.root
#NanoAODFile_EOS=/eos/cms/store/user/ssawant/test/HToaaTo4b/NanoAOD/${EraYear}/MC/${SampleProcessName}_${SampleGeneratorDetails}/${ERA}NanoAODv15/2026_09_01/${OpSubdirNum}/NanoAODv15_${iSample}_nEvents${NEvents}.root


IpFile_EOS_wRedirector="root://${XRootDRedirector}/${IpFile}"
IpFileExtension="${IpFile##*.}"
LHEFile_local=${Dir_baseLocal}/${SampleProcessName}_${iSample}_nEvents${NEvents}_LHE.${IpFileExtension}
pLHEGENSIMFile_local=${Dir_baseLocal}/${SampleProcessName}_${iSample}_nEvents${NEvents}_pLHEGENSIM.root
DRPremixFile_local=${Dir_baseLocal}/${SampleProcessName}_${iSample}_nEvents${NEvents}_DRPremix.root
MiniAODFile_local=${Dir_baseLocal}/${SampleProcessName}_${iSample}_nEvents${NEvents}_MiniAOD.root
NanoAODFile_local=${Dir_baseLocal}/${SampleProcessName}_${iSample}_nEvents${NEvents}_NanoAOD.root




### Execution partstarts ----------------------
echo "argument prodmode: ${prodmode} "
echo "argument HiggsPtMin: $HiggsPtMin "
echo "argument NEvents: $NEvents "
echo "argument iSample: $iSample "
printf "ERA: ${ERA} \n"
printf "EraYear: ${EraYear} \n"
printf "MiniAODFile_Final: ${OpFile} \n"
printf "{XRootDHostAndPort}/{MiniAODFile_EOS}: ${XRootDHostAndPort}/${OpFile} \n"
printf "NanoAODFile_EOS: ${NanoAODFile_EOS} \n"

echo "jobID 0: ${jobID}"
jobID="${jobID/./p}"
echo "jobID 1: ${jobID}"

## Copy input file to local directory
echo "pwd: "
pwd
echo "ls -ltrh: xrdcp ipFile"
ls -ltrh
echo "time xrdcp ${IpFile_EOS_wRedirector} ${LHEFile_local} "
time xrdcp ${IpFile_EOS_wRedirector} ${LHEFile_local}
echo "ls -ltrh after: "
ls -ltrh

## Run MC generation configs
# pLHEGENSIM -------------------------------------------------------------------------
DatasetType='pLHEGENSIM'
inputFile=${LHEFile_local}
outputFile=${pLHEGENSIMFile_local}
NEvents_toUse=${NEvents}

printf "\nRun source generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}  ${Dir_sourceCodes}   ${RandomNumberSeed}  ${prodmode}  ${HiggsPtMin} \n"
time . generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}  ${Dir_sourceCodes}   ${RandomNumberSeed}  ${prodmode}  ${HiggsPtMin}
printf "\n***Done source generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}  ${Dir_sourceCodes}  ${RandomNumberSeed}  ${prodmode}  ${HiggsPtMin} \n"
printf "ls -ltrh after ${DatasetType} step: \n"; ls -ltrh
printf "rm -rf CMSSW*  lheevent \n"
rm -rf CMSSW*  lheevent


# DRPremix -------------------------------------------------------------------------
DatasetType='DRPremix'
inputFile=${pLHEGENSIMFile_local}
outputFile=${DRPremixFile_local}
NEvents_toUse=${NEvents}

printf "\n\nRun source generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID} \n"
time . generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID} 
printf "\n***Done source generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}   \n"
printf "ls -ltrh after ${DatasetType} step: \n"; ls -ltrh
printf "\nrm -rf CMSSW* \n"
rm -rf CMSSW*

printf "rm -rf ${LHEFile_local} \n"
rm -rf ${LHEFile_local}

# MiniAOD -------------------------------------------------------------------------
DatasetType='MiniAOD'
inputFile=${DRPremixFile_local}
outputFile=${MiniAODFile_local}
NEvents_toUse=${NEvents}

printf "\n\nRun source generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID} \n"
time . generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID} 
printf "\n***Done source generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}   \n"
printf "ls -ltrh after ${DatasetType} step: \n"; ls -ltrh
printf "\nrm -rf CMSSW* \n"
rm -rf CMSSW*

printf "rm -rf ${pLHEGENSIMFile_local} \n"
rm -rf ${pLHEGENSIMFile_local}

# NanoAOD -------------------------------------------------------------------------
DatasetType='NanoAOD'
inputFile=${MiniAODFile_local}
outputFile=${NanoAODFile_local}
NEvents_toUse=${NEvents}

printf "\n\nRun source generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID} \n"
time . generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID} 
printf "\n***Done source generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}   \n"
printf "ls -ltrh after ${DatasetType} step: \n"; ls -ltrh
printf "\nrm -rf CMSSW* \n"
rm -rf CMSSW*

printf "rm -rf ${DRPremixFile_local} \n"
rm -rf ${DRPremixFile_local}

printf "\n\n***Done running a MC sample production step. \n"
printf "ls -ltrh after a MC sample production step: \n"
ls -ltrh

printf "\n\n ls -ltrh ${MiniAODFile_local} ${NanoAODFile_local} after all MC sample production steps: \n"
ls -ltrh ${MiniAODFile_local} ${NanoAODFile_local}


## Copy output file
if [ -f ${MiniAODFile_local} ]; then
    # https://indico.cern.ch/event/533066/contributions/2210981/attachments/1293986/1928541/CMSSW_tips.pdf
    # xrdcp -f -v  tmp.txt root://eosuser.cern.ch//eos/cms/store/user/ssawant/mc/SUSY_GluGluH_01J_HToAATo4B_Pt150_M-47.5_TuneCP5_13TeV_madgraph_pythia8/tmp1.txt
    printf "\n\n xrdcp -f -v ${MiniAODFile_local} ${XRootDHostAndPort1}/${MiniAODFile_EOS} :\n"
    # run xrdcp command until it succeeds
    try=1
    xrdcpSucceed=1
    until xrdcp -f -v ${MiniAODFile_local} ${XRootDHostAndPort1}/${MiniAODFile_EOS}
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
        printf "\n\n gfal-copy -f ${MiniAODFile_local} ${XRootDHostAndPort1}/${MiniAODFile_EOS} :\n"
        try=1
        xrdcpSucceed=1
        until gfal-copy -f ${MiniAODFile_local} ${XRootDHostAndPort1}/${MiniAODFile_EOS}
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
        printf "\n\n xrdcp -f -v ${MiniAODFile_local} ${XRootDHostAndPort}/${MiniAODFile_EOS} : \n"
        try=1
        xrdcpSucceed=1
        until xrdcp -f -v ${MiniAODFile_local} ${XRootDHostAndPort}/${MiniAODFile_EOS}
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


    echo "rm ${MadgraphGridpackSample_local}: "
    rm ${MadgraphGridpackSample_local}
        
    echo "rm ${prodmode}*.py ${prodmode}*.xml \n"
    rm ${prodmode}*.py ${prodmode}*.xml

    if [ $xrdcpSucceed -eq 1 ]; then
        printf "rm ${MiniAODFile_local} : \n"
        rm ${MiniAODFile_local}    
    else
        # xrdcp failed:
        # mv Miniaod to condor_base directory so that the minoaod is copied to condor_submission directory
        printf "\n mv ${MiniAODFile_local} ../ : \n"
        mv ${MiniAODFilel} ../
    fi
fi

## Copy NanoAOD file
if [ -f ${NanoAODFile_local} ]; then
    printf "\n\n xrdcp -f -v ${NanoAODFile_local} ${XRootDHostAndPort1}/${NanoAODFile_EOS} :\n"
    # run xrdcp command until it succeeds
    try=1
    xrdcpSucceed=1
    until xrdcp -f -v ${NanoAODFile_local} ${XRootDHostAndPort1}/${NanoAODFile_EOS}
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
        printf "\n\n gfal-copy -f ${NanoAODFile_local} ${XRootDHostAndPort1}/${NanoAODFile_EOS} :\n"
        try=1
        xrdcpSucceed=1
        until gfal-copy -f ${NanoAODFile_local} ${XRootDHostAndPort1}/${NanoAODFile_EOS}
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
        printf "\n\n xrdcp -f -v ${NanoAODFile_local} ${XRootDHostAndPort}/${NanoAODFile_EOS} : \n"
        try=1
        xrdcpSucceed=1
        until xrdcp -f -v ${NanoAODFile_local} ${XRootDHostAndPort}/${NanoAODFile_EOS}
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
        printf "rm ${NanoAODFile_local} : \n"
        rm ${NanoAODFile_local}    
    else
        # xrdcp failed:
        # mv Nanoaod to condor_base directory so that the minoaod is copied to condor_submission directory
        printf "\n mv ${NanoAODFile_local} ../ : \n"
        mv ${NanoAODFilel} ../
    fi
fi



echo "ls -ltrh at the end: "
ls -ltrh

printf "\n cd .. : \n"
cd ..











### Copy output file to lxplus-eos area ---------------------------------
## Copy output file
if [ -f ${OpFile_local} ]; then
    # https://indico.cern.ch/event/533066/contributions/2210981/attachments/1293986/1928541/CMSSW_tips.pdf
    # xrdcp -f -v  tmp.txt root://eosuser.cern.ch//eos/cms/store/user/ssawant/mc/SUSY_GluGluH_01J_HToAATo4B_Pt150_M-47.5_TuneCP5_13TeV_madgraph_pythia8/tmp1.txt
    printf "\n\n xrdcp -f -v ${OpFile_local} ${XRootDHostAndPort1}/${OpFile} :\n"
    # run xrdcp command until it succeeds
    try=1
    xrdcpSucceed=1
    until xrdcp -f -v ${OpFile_local} ${XRootDHostAndPort1}/${OpFile}
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
        printf "\n\n gfal-copy -f ${OpFile_local} ${XRootDHostAndPort1}/${OpFile} :\n"
        try=1
        xrdcpSucceed=1
        until gfal-copy -f ${OpFile_local} ${XRootDHostAndPort1}/${OpFile}
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
        printf "\n\n xrdcp -f -v ${OpFile_local} ${XRootDHostAndPort}/${OpFile} : \n"
        try=1
        xrdcpSucceed=1
        until xrdcp -f -v ${OpFile_local} ${XRootDHostAndPort}/${OpFile}
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


        
    echo "rm ${prodmode}*.py ${prodmode}*.xml \n"
    rm ${prodmode}*.py ${prodmode}*.xml

    if [ $xrdcpSucceed -eq 1 ]; then
        printf "rm ${OpFile_local} : \n"
        rm ${OpFile_local}    
    else
        # xrdcp failed:
        # mv Miniaod to condor_base directory so that the minoaod is copied to condor_submission directory
        printf "\n mv ${OpFile_local} ../ : \n"
        mv ${OpFile_local} ../
    fi
fi



echo "ls -ltrh at the end: "
ls -ltrh

printf "\n cd .. : \n"
cd ..
echo "pwd: At the end"
pwd
echo "ls -ltrh: "
ls -ltrh 



echo "condor_exec_MCGeneration_HTo4B.sh done"
echo "date: "
date