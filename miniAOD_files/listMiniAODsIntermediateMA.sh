#!/bin/bash

### USERS settings ------------------------------------------------------------------------------------

## Higgs production mode
prodmodes=("SUSY_GluGluH_01J_HToAATo4B"
           "SUSY_VBFH_HToAATo4B"
           "SUSY_WH_WToAll_HToAATo4B"
           "SUSY_ZH_ZToAll_HToAATo4B"
           "SUSY_TTH_TTToAll_HToAATo4B")
#prodmodes=("SUSY_TTH_TTToAll_HToAATo4B")
#prodmodes=("SUSY_GluGluH_01J_HToAATo4B")

#HiggsPtMinList=(150 250 350 450)
HiggsPtMinList=(150)

## "a" boson mass points
#mApoints=(12 15 20 25 30 35 40 45 50 55 60)
#mApoints=(8.5 9.0 9.5 10.0 10.5 11.0 11.5 12.5 13.0 13.5 14.0 16.0 17.0 18.5 21.5 23.0 27.5 32.5 37.5 42.5 47.5 52.5 57.5 62.5)
mApoints=(11.0 11.5 12.5 13.0 13.5 14.0 16.0 17.0 18.5 21.5 23.0 27.5 32.5 37.5 42.5 47.5 52.5 57.5 62.5)
#mApoints=(47.5)

# Decay width of a-boson
wA=0 # 0 for narrow A width sample. 10 or 70 for broader A width samples. 

## Dataset ERA
#ERA="RunIISummer20UL17" # Options: "RunIISummer20UL18", "RunIISummer20UL17", "RunIISummer20UL16", "RunIISummer20UL16APV"
#Eras=("RunIISummer20UL18"
#	  "RunIISummer20UL17"
#	  "RunIISummer20UL16"
#	  "RunIISummer20UL16APV")
#Eras=("RunIISummer20UL18")
#Eras=("RunIISummer20UL17")
Eras=("RunIISummer20UL17"
	  "RunIISummer20UL16"
	  "RunIISummer20UL16APV")

fListMiniAODsIntermediateMA="miniAODs"

### USERS settings ENDS --------------------------------------------------------------------------------

## Data taking years
for ERA in "${Eras[@]}"
do

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

	## Loop over all Higgs production modes
	for prod in "${prodmodes[@]}"
	do
		## Loop over all "a" boson mass points
		for mA in "${mApoints[@]}"
		do

            ## Loop over HiggsPtMinList
            for HiggsPtMin in "${HiggsPtMinList[@]}"
            do

                # /eos/cms/store/group/phys_susy/HToaaTo4b/MiniAOD/2018/MC/SUSY_GluGluH_01J_HToAATo4B_Pt150_M-11.5_TuneCP5_13TeV_madgraph_pythia8/RunIISummer20UL18/0018/MiniAODv2_1898_nEvents500.root
                miniAOD_files="/eos/cms/store/group/phys_susy/HToaaTo4b/MiniAOD/${EraYear}/MC/${prod}_Pt${HiggsPtMin}_M-${mA}_TuneCP5_13TeV_madgraph_pythia8/${ERA}/*/MiniAODv2_*.root"
                printf " ls ${miniAOD_files} : "
                ls ${miniAOD_files} > "miniAODs_${prod}_Pt${HiggsPtMin}_M-${mA}_${EraYear}.txt"
                ls ${miniAOD_files} | wc -l
                printf "\n"


            done
		done
	done
done
