#!/bin/bash

#inputFile=${1}
inputFilesList=${1}
outputFile=${2}  
EraYear=${3}

printf "\n\ngenerate_RunIISummer20UL18NanoAODv9Customv2p1.sh:: ${inputFilesList}, ${outputFile}, ${EraYear} \n"

githubUsername=siddhesh86

Dir0=$(pwd)
Dir_CMSSWSrc="/afs/cern.ch/work/s/ssawant/private/htoaa/NanoAODProduction_wPNetHToAATo4B/haa4b_NanoAODv2/r2/CMSSW_10_6_30/src" # change it to CMSSW area you used to re-process NanoAODv2

echo "Dir0: $Dir0"
printf "Dir_CMSSWSrc: ${Dir_CMSSWSrc} \n"
printf "inputFilesList: ${inputFilesList} \n"
printf "outputFile: ${outputFile} \n"

printf " \n"
cd $Dir_CMSSWSrc
printf "cmsenv \n"
cmsenv


printf " \n"
cd $Dir0

printf "\npwd: $(pwd) \nls:\n $(ls) \n cp ${Dir_CMSSWSrc}/PhysicsTools/NanoAODTools/crab_haa4b_NanoAOD_${EraYear}_mc/Nano_Hto4bPlus_${EraYear}MC_cfg.py .: \n"; 
cp ${Dir_CMSSWSrc}/PhysicsTools/NanoAODTools/crab_haa4b_NanoAOD_${EraYear}_mc/Nano_Hto4bPlus_${EraYear}MC_cfg.py .
sed -i "s|fileNames = cms.untracked.vstring(in_files),|fileNames = cms.untracked.vstring(${inputFilesList}),|g" Nano_Hto4bPlus_${EraYear}MC_cfg.py
sed -i "s|PNet_v1.root|${outputFile}|g" Nano_Hto4bPlus_${EraYear}MC_cfg.py
sed -i "s|input = cms.untracked.int32(MAX_EVT)|input = cms.untracked.int32(-1)|g" Nano_Hto4bPlus_${EraYear}MC_cfg.py
printf "\npwd: $(pwd) \nls:\n $(ls) \n\n cat Nano_Hto4bPlus_${EraYear}MC_cfg.py: \n"; 
cat Nano_Hto4bPlus_${EraYear}MC_cfg.py
printf "\npwd: $(pwd) \nls:\n $(ls) \n\n cmsRun Nano_Hto4bPlus_${EraYear}MC_cfg.py: \n"; 
cmsRun Nano_Hto4bPlus_${EraYear}MC_cfg.py
printf "\npwd: $(pwd) \nls:\n $(ls) \n\n DONE cmsRun Nano_Hto4bPlus_${EraYear}MC_cfg.py **** \n"; 

printf "\npwd: $(pwd) \nls:\n $(ls) \n cp ${Dir_CMSSWSrc}/PhysicsTools/NanoAODTools/crab_haa4b_NanoAOD_${EraYear}_mc/Hto4b_postproc.py .: \n"; 
cp ${Dir_CMSSWSrc}/PhysicsTools/NanoAODTools/crab_haa4b_NanoAOD_${EraYear}_mc/Hto4b_postproc.py .
sed -i "s|PNet_v1.root|${outputFile}|g" Hto4b_postproc.py
sed -i "s|runLocally = False|runLocally = True|g" Hto4b_postproc.py
printf "\npwd: $(pwd) \nls:\n $(ls) \n\n cat Hto4b_postproc.py: \n"; 
cat Hto4b_postproc.py
printf "\npython Hto4b_postproc.py : \n"
python Hto4b_postproc.py
printf "\npwd: $(pwd) \nls:\n $(ls) \n\n

