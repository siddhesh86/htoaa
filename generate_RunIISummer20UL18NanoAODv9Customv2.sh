#!/bin/bash

#inputFile=${1}
inputFilesList=${1}
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
printf "\npwd: $(pwd) \nls:\n $(ls) \n git cms-addpkg SimDataFormats/JetMatching: \n"; 
git cms-addpkg SimDataFormats/JetMatching


#printf "\npwd: $(pwd) \nls:\n $(ls) \n git clone -b PNet_v2_2024_11_22_sig git@github.com:abrinke1/RecoBTag-Combined.git RecoBTag/Combined/data : \n"; 
#git clone https://github.com/cms-data/RecoBTag-Combined.git RecoBTag/Combined/data # git clone git@github.com:cms-data/RecoBTag-Combined.git RecoBTag/Combined/data
#git clone -b PNet_v2_2024_11_22_sig git@github.com:abrinke1/RecoBTag-Combined.git RecoBTag/Combined/data

printf "\npwd: $(pwd) \nls:\n $(ls) \n git clone -b PNet_v2_2024_11_22_sig https://siddhesh86:R%40diation10@github.com/abrinke1/RecoBTag-Combined.git RecoBTag/Combined/data : \n"; 
#git clone https://github.com/cms-data/RecoBTag-Combined.git RecoBTag/Combined/data # git clone git@github.com:cms-data/RecoBTag-Combined.git RecoBTag/Combined/data
#git clone -b PNet_v2_2024_11_22_sig https://github.com/abrinke1/RecoBTag-Combined.git RecoBTag/Combined/data
git clone -b PNet_v2_2024_11_22_sig https://siddhesh86:R%40diation10@github.com/abrinke1/RecoBTag-Combined.git RecoBTag/Combined/data


printf "\npwd: $(pwd) \nls:\n $(ls) \n git remote add abrinke1 https://gitlab.cern.ch/abrinke1/cmssw.git: \n"; 
git remote add abrinke1 https://gitlab.cern.ch/abrinke1/cmssw.git
printf "\npwd: $(pwd) \nls:\n $(ls) \n git checkout -b PNet_v2_2024_11_22_bkg: \n"; 
#git checkout -b HtoAA_PNet_Prod_v1_2023_10_06 # customNanoAOD v1
git checkout -b PNet_v2_2024_11_22_bkg
printf "\npwd: $(pwd) \nls:\n $(ls) \n git pull abrinke1 PNet_v2_2024_11_22_bkg: \n"; 
#git pull abrinke1 HtoAA_PNet_Prod_v1_2023_10_06 # customNanoAOD v1
git pull abrinke1 PNet_v2_2024_11_22_bkg

#printf "\npwd: $(pwd) \nls:\n $(ls) \n git clone -b PNet_v2_2024_11_22_sig git@github.com:abrinke1/PFNano.git PhysicsTools/PFNano : \n";
#git clone -b PNet_v2_2024_11_22_sig git@github.com:abrinke1/PFNano.git PhysicsTools/PFNano
#printf "\npwd: $(pwd) \nls:\n $(ls) \n git clone -b nanoPostProc_SS git@github.com:siddhesh86/nanoAOD-tools.git PhysicsTools/NanoAODTools : \n";
#git clone -b nanoPostProc_SS git@github.com:siddhesh86/nanoAOD-tools.git PhysicsTools/NanoAODTools

printf "\npwd: $(pwd) \nls:\n $(ls) \n git clone -b PNet_v2_2024_11_22_sig https://siddhesh86:R%40diation10@github.com/abrinke1/PFNano.git PhysicsTools/PFNano : \n";
git clone -b PNet_v2_2024_11_22_sig https://siddhesh86:R%40diation10@github.com/abrinke1/PFNano.git PhysicsTools/PFNano
printf "\npwd: $(pwd) \nls:\n $(ls) \n git clone -b nanoPostProc_SS https://siddhesh86:R%40diation10@github.com/siddhesh86/nanoAOD-tools.git PhysicsTools/NanoAODTools : \n";
git clone -b nanoPostProc_SS https://siddhesh86:R%40diation10@github.com/siddhesh86/nanoAOD-tools.git PhysicsTools/NanoAODTools

printf "\npwd: $(pwd) \nls:\n $(ls) \n scram b -j 6: \n"; 
scram b -j 6

cd $Dir0

printf "\npwd: $(pwd) \nls:\n $(ls) \n cp CMSSW_10_6_30/src/PhysicsTools/NanoAODTools/crab_haa4b_NanoAOD_2018_mc/Nano_Hto4bPlus_2018MC_cfg.py .: \n"; 
cp CMSSW_10_6_30/src/PhysicsTools/NanoAODTools/crab_haa4b_NanoAOD_2018_mc/Nano_Hto4bPlus_2018MC_cfg.py .
sed -i "s|fileNames = cms.untracked.vstring(in_files),|fileNames = cms.untracked.vstring(${inputFilesList}),|g" Nano_Hto4bPlus_2018MC_cfg.py
sed -i "s|PNet_v1.root|${outputFile}|g" Nano_Hto4bPlus_2018MC_cfg.py
printf "\npwd: $(pwd) \nls:\n $(ls) \n\n cat Nano_Hto4bPlus_2018MC_cfg.py: \n"; 
cat Nano_Hto4bPlus_2018MC_cfg.py
printf "\npwd: $(pwd) \nls:\n $(ls) \n\n cmsRun Nano_Hto4bPlus_2018MC_cfg.py: \n"; 
cmsRun Nano_Hto4bPlus_2018MC_cfg.py
printf "\npwd: $(pwd) \nls:\n $(ls) \n\n DONE cmsRun Nano_Hto4bPlus_2018MC_cfg.py **** \n"; 

printf "\npwd: $(pwd) \nls:\n $(ls) \n cp CMSSW_10_6_30/src/PhysicsTools/NanoAODTools/crab_haa4b_NanoAOD_2018_mc/Hto4b_postproc.py .: \n"; 
cp CMSSW_10_6_30/src/PhysicsTools/NanoAODTools/crab_haa4b_NanoAOD_2018_mc/Hto4b_postproc.py .
sed -i "s|PNet_v1.root|${outputFile}|g" Hto4b_postproc.py
sed -i "s|runLocally = False|runLocally = True|g" Hto4b_postproc.py
printf "\npwd: $(pwd) \nls:\n $(ls) \n\n cat Hto4b_postproc.py: \n"; 
cat Hto4b_postproc.py
printf "\npython Hto4b_postproc.py : \n"
python Hto4b_postproc.py
printf "\npwd: $(pwd) \nls:\n $(ls) \n\n
