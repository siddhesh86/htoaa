#!/bin/bash

inputFile=${1}
outputFile=${2}

githubUsername=siddhesh86

Dir0=$(pwd)
echo "Dir0: $Dir0"
printf "inputFile: ${inputFile} \n"
printf "outputFile: ${outputFile} \n"

printf "\npwd: $(pwd) \nls:\n $(ls) \n git config --global user.github ${githubUsername}: \n";
git config --global user.github ${githubUsername}
printf "\n git config --global user.name : \n"
git config --global user.name 'Siddhesh Sawant'
printf "\n git config --global user.email : \n"
git config --global user.email 'siddhesh.gopichand.sawant.cern.ch'
printf "\n git config --list: \n"
git config --list

export SCRAM_ARCH=slc7_amd64_gcc700
source /cvmfs/cms.cern.ch/cmsset_default.sh
printf "\npwd: $(pwd) \nls:\n $(ls) \n scram p CMSSW CMSSW_10_6_30: \n"; 
scram p CMSSW CMSSW_10_6_30
cd CMSSW_10_6_30/src
cmsenv
printf "\npwd: $(pwd) \nls:\n $(ls) \n scram b -j 6: \n"; 
scram b -j 6

printf "\npwd: $(pwd) \nls:\n $(ls) \n git cms-addpkg RecoBTag/Combined: \n"; 
git cms-addpkg RecoBTag/Combined
printf "\npwd: $(pwd) \nls:\n $(ls) \n git cms-addpkg RecoBTag/ONNXRuntime: \n"; 
git cms-addpkg RecoBTag/ONNXRuntime
printf "\npwd: $(pwd) \nls:\n $(ls) \n git cms-addpkg PhysicsTools/NanoAOD: \n"; 
git cms-addpkg PhysicsTools/NanoAOD
printf "\npwd: $(pwd) \nls:\n $(ls) \n git cms-addpkg PhysicsTools/PatAlgos: \n"; 
git cms-addpkg PhysicsTools/PatAlgos
printf "\npwd: $(pwd) \nls:\n $(ls) \n git cms-addpkg DataFormats/PatCandidates: \n"; 
git cms-addpkg DataFormats/PatCandidates
printf "\npwd: $(pwd) \nls:\n $(ls) \n git cms-addpkg CommonTools/RecoAlgos: \n"; 
git cms-addpkg CommonTools/RecoAlgos

printf "\npwd: $(pwd) \nls:\n $(ls) \n git clone https://github.com/cms-data/RecoBTag-Combined.git RecoBTag/Combined/data : \n"; 
git clone https://github.com/cms-data/RecoBTag-Combined.git RecoBTag/Combined/data # git clone git@github.com:cms-data/RecoBTag-Combined.git RecoBTag/Combined/data

printf "\npwd: $(pwd) \nls:\n $(ls) \n git remote add abrinke1 https://gitlab.cern.ch/abrinke1/cmssw.git: \n"; 
git remote add abrinke1 https://gitlab.cern.ch/abrinke1/cmssw.git
printf "\npwd: $(pwd) \nls:\n $(ls) \n git checkout -b HtoAA_PNet_Prod_v1_2023_10_06: \n"; 
git checkout -b HtoAA_PNet_Prod_v1_2023_10_06
printf "\npwd: $(pwd) \nls:\n $(ls) \n git pull abrinke1 HtoAA_PNet_Prod_v1_2023_10_06: \n"; 
git pull abrinke1 HtoAA_PNet_Prod_v1_2023_10_06

cd RecoBTag/Combined/data/
printf "\npwd: $(pwd) \nls:\n $(ls) \n git remote add abrinke1 https://github.com/abrinke1/RecoBTag-Combined.git : \n"; 
git remote add abrinke1 https://github.com/abrinke1/RecoBTag-Combined.git #git remote add abrinke1 git@github.com:abrinke1/RecoBTag-Combined.git
printf "\npwd: $(pwd) \nls:\n $(ls) \n git checkout -b HtoAA_PNet_Prod_v1_2023_10_06_slim: \n"; 
git checkout -b HtoAA_PNet_Prod_v1_2023_10_06_slim
printf "\npwd: $(pwd) \nls:\n $(ls) \n git pull abrinke1 HtoAA_PNet_Prod_v1_2023_10_06_slim: \n"; 
git pull abrinke1 HtoAA_PNet_Prod_v1_2023_10_06_slim
cd -

printf "\npwd: $(pwd) \nls:\n $(ls) \n scram b -j 6: \n"; 
scram b -j 6

printf "\npwd: $(pwd) \nls:\n $(ls) \n mv unwanted large files: \n"; 
mkdir ../../crab_big_files
mv RecoBTag/Combined/data/.git/objects/pack/pack*.pack ../../crab_big_files/
mkdir -p ../../crab_big_files/CMSSW_10_6_30/ParticleNetAK8/General/V01/
mkdir -p ../../crab_big_files/CMSSW_10_6_30/ParticleNetAK8/MD-2prong/V01/
mkdir -p ../../crab_big_files/CMSSW_10_6_30/ParticleNetAK8/MassRegression/V01/
mv RecoBTag/Combined/data/ParticleNetAK8/General/V01/modelfile ../../crab_big_files/CMSSW_10_6_30/ParticleNetAK8/General/V01/
mv RecoBTag/Combined/data/ParticleNetAK8/MD-2prong/V01/modelfile ../../crab_big_files/CMSSW_10_6_30/ParticleNetAK8/MD-2prong/V01/
mv RecoBTag/Combined/data/ParticleNetAK8/MassRegression/V01/modelfile ../../crab_big_files/CMSSW_10_6_30/ParticleNetAK8/MassRegression/V01/

cd $Dir0

printf "\npwd: $(pwd) \nls:\n $(ls) \n cp CMSSW_10_6_30/src/PhysicsTools/NanoAOD/test/Nano_MC_addHto4bPlus_crab_cfg.py .: \n"; 
#wget https://gitlab.cern.ch/abrinke1/cmssw/-/raw/HtoAA_PNet_Prod_v1_2023_10_06/PhysicsTools/NanoAOD/test/Nano_MC_addHto4bPlus_crab_cfg.py
cp CMSSW_10_6_30/src/PhysicsTools/NanoAOD/test/Nano_MC_addHto4bPlus_crab_cfg.py .
sed -i "s|DUMMY|file:${inputFile}|g" Nano_MC_addHto4bPlus_crab_cfg.py
sed -i "s|PNet_v1.root|${outputFile}|g" Nano_MC_addHto4bPlus_crab_cfg.py

sed -i "s|Run2_2018|Run2_2016|g" Nano_MC_addHto4bPlus_crab_cfg.py
sed -i "s|106X_upgrade2018_realistic_v16_L1v1|106X_mcRun2_asymptotic_v17|g" Nano_MC_addHto4bPlus_crab_cfg.py

printf "\npwd: $(pwd) \nls:\n $(ls) \n\n cat Nano_MC_addHto4bPlus_crab_cfg.py: \n"; 
cat Nano_MC_addHto4bPlus_crab_cfg.py
printf "\npwd: $(pwd) \nls:\n $(ls) \n\n cmsRun Nano_MC_addHto4bPlus_crab_cfg.py: \n"; 
cmsRun Nano_MC_addHto4bPlus_crab_cfg.py
printf "\npwd: $(pwd) \nls:\n $(ls) \n\n DONE cmsRun Nano_MC_addHto4bPlus_crab_cfg.py **** \n"; 

