#!/bin/bash


## Setting input variables ------------------------------------------
export X509_USER_PROXY=$1
prodmode=$2
HiggsPtMin=$3
ERA=$4
MCStep=$5
NEvents=$6
iSample=$7
XRootDRedirector=$8
IpFile=$9
OpFile=$10



## Testing initial setup -------------------------------------------
echo "condor_exec_MCGeneration_HToAATo4B_M-x.sh execution started"
echo "hostname: "
hostname
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

printf "\n printenv : \n"
printenv

# Check if DAS query works fine
echo "dasgoclient --version : "
dasgoclient --version
#echo "dasgoclient --query=\"dataset=/ZeroBias*/*Run2022C*/*\" -verbose 2: "
#dasgoclient --query="dataset=/ZeroBias*/*Run2022C*/*" -verbose 2
echo "dasgoclient --query=\"dataset=/ZeroBias*/*Run2022C*/*\" : "
dasgoclient --query="dataset=/ZeroBias*/*Run2022C*/*" 



## Setting local variables ------------------------------------------

Dir_baseLocal=$(pwd)
Dir_sourceCodes=$(pwd)                                  # GEN-fragment.py and other sample-generation-config files are transferred to 'pwd' by HT-Condor 
RandomNumberSeed=$RANDOM                                # Ramdom seed for sample generation

# Sample data names
SampleProcessName="${prodmode}_Pt${HiggsPtMin}"
jobID="${SampleProcessName}_${iSample}" 

IpFileExtension="${IpFile##*.}"
IpFile_local=${Dir_baseLocal}/ip_${SampleProcessName}_${iSample}_nEvents${NEvents}.${IpFileExtension}
OpFile_local=${Dir_baseLocal}/op_${SampleProcessName}_${iSample}_nEvents${NEvents}.root

xrdcpPort="1094"                                        # For e.g. xrdcp -f  tmp.txt root://xrootd-cms.infn.it:1094//eos/cms/store/user/ssawant/mc/tmp/tmp.txt
XRootDRedirector="xrootd-cms.infn.it"
# xrdcp command: For e.g.:  xrdcp -f  tmp.txt root://xrootd-cms.infn.it:1094//eos/cms/store/user/ssawant/mc/tmp/tmp.txt
# xrdcp output dir: For e.g.: root://xrootd-cms.infn.it:1094//eos/cms/store/user/ssawant/mc/SUSY_GluGluH_01J_HToAATo4B_Pt150_M-47.5_TuneCP5_13TeV_madgraph_pythia8/RunIISummer20UL18
XRootDHostAndPort="root://${XRootDRedirector}:${xrdcpPort}"
XRootDHostAndPort1="root://eosuser.cern.ch"

IpFile_EOS_wRedirector="root://${XRootDRedirector}/${IpFile}"

### Execution partstarts ----------------------
echo "argument prodmode: ${prodmode} "
echo "argument HiggsPtMin: $HiggsPtMin "
echo "argument NEvents: $NEvents "
echo "argument iSample: $iSample "
printf "ERA: ${ERA} \n"
printf "EraYear: ${EraYear} \n"
printf "MiniAODFile_Final: ${OpFile} \n"
printf "{XRootDHostAndPort}/{MiniAODFile_Final_FileName}: ${XRootDHostAndPort}/${OpFile} \n"
printf "NanoAODFile_Final_FileName: ${NanoAODFile_Final_FileName} \n"

echo "jobID 0: ${jobID}"
jobID="${jobID/./p}"
echo "jobID 1: ${jobID}"

## Copy input file to local directory
echo "pwd: "
pwd
echo "ls -ltrh: xrdcp ipFile"
ls -ltrh
echo "time xrdcp ${IpFile_EOS_wRedirector} ${IpFile_local} "
time xrdcp ${IpFile_EOS_wRedirector} ${IpFile_local}
echo "ls -ltrh after: "
ls -ltrh

## Run MCConfig
DatasetType=${MCStep}
inputFile=${IpFile_local}
outputFile=${OpFile_local}
NEvents_toUse=${NEvents}

printf "\nRun source generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}  ${Dir_sourceCodes}   ${RandomNumberSeed}  ${prodmode}  ${HiggsPtMin} \n"
time . generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}  ${Dir_sourceCodes}   ${RandomNumberSeed}  ${prodmode}  ${HiggsPtMin}
printf "\n***Done source generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}  ${Dir_sourceCodes}  ${RandomNumberSeed}  ${prodmode}  ${HiggsPtMin} \n"
printf "ls -ltrh after ${DatasetType} step: \n"; ls -ltrh
printf "rm -rf CMSSW*  lheevent \n"
rm -rf CMSSW*  lheevent

printf "\n\n***Done running a MC sample production step. \n"
printf "ls -ltrh after a MC sample production step: \n"
ls -ltrh

printf "\n\n ls -ltrh ${OpFile_local}  after a MC sample production steps: \n"
ls -ltrh ${OpFile_local} 

cp pLHEGenSim_GluGluHJ_HTo4B_1_cfg.py ../ 
cp pLHEGenSim_GluGluHJ_HTo4B_report.xml ../

printf "xrdcp -f -v pLHEGenSim_GluGluHJ_HTo4B_1_cfg.py ${XRootDHostAndPort1}//eos/cms/store/user/ssawant/test/ \n"
xrdcp -f -v pLHEGenSim_GluGluHJ_HTo4B_1_cfg.py ${XRootDHostAndPort1}//eos/cms/store/user/ssawant/test/
printf "xrdcp -f -v pLHEGenSim_GluGluHJ_HTo4B_report.xml ${XRootDHostAndPort1}//eos/cms/store/user/ssawant/test/ \n"
xrdcp -f -v pLHEGenSim_GluGluHJ_HTo4B_report.xml ${XRootDHostAndPort1}//eos/cms/store/user/ssawant/test/



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
