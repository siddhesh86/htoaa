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
Eras=("RunIISummer20UL18")

# set first (SampleNumber_First) to last (SampleNumber_Last) MC sample file numbers to be produced in this round of submission/execution.
SampleNumber_First=0
SampleNumber_Last=0


	  
### USERS settings ENDS --------------------------------------------------------------------------------

### Information
# GEN-filter efficiency: 
#     0.057 for SUSY_GluGluH_01J_HToAATo4B_Pt150
#     0.173 for SUSY_VBFH_HToAATo4B_Pt150
#     0.132 for SUSY_WH_WToAll_HToAATo4B_Pt150
#     0.129 for SUSY_ZH_ZToAll_HToAATo4B_Pt150
#     0.285 for SUSY_TTH_TTToAll_HToAATo4B_Pt150


UserName=$(whoami)
XRootDRedirector="xrootd-cms.infn.it"
sFParams="params_MCGeneration_HToAATo4B_M-x.txt"

printf "\n rm ${sFParams} : \n"
rm ${sFParams}

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

			NEvents=500
			if   [ ${HiggsPtMin} -eq 150 ]; then
				NEvents=500
			elif [ ${HiggsPtMin} -eq 250 ]; then
				NEvents=180 #200
			elif [ ${HiggsPtMin} -eq 350 ]; then
				NEvents=90
			elif [ ${HiggsPtMin} -eq 450 ]; then
				NEvents=30        
			fi

			#NEvents=10 # for test purpose

			# miniAOD_files/miniAODs_SUSY_GluGluH_01J_HToAATo4B_Pt150_M-11.5_2018.txt
			#fMiniAODlist="miniAOD_files/miniAODs_${prod}_Pt${HiggsPtMin}_M-${mA}_${EraYear}.txt" 
			fMiniAODlistSets="miniAOD_files_1/miniAODs_${prod}_Pt${HiggsPtMin}_M-${mA}_${EraYear}_*.txt" 

			nMiniAODlistSets=$(ls ${fMiniAODlistSets} | wc -l)
			printf "nMiniAODlistSets: ${nMiniAODlistSets} \n"
			

			#for iMiniAOD_set 
			for (( iSample=0; iSample<${nMiniAODlistSets}; iSample++ ))
			do
				#fMiniAODlist="miniAOD_files/miniAODs_${prod}_Pt${HiggsPtMin}_M-${mA}_${EraYear}.txt"
				fMiniAODlist="miniAOD_files_1/miniAODs_${prod}_Pt${HiggsPtMin}_M-${mA}_${EraYear}_${iSample}.txt"
				printf "iSample: ${iSample} ${fMiniAODlist} \n"

				printf "${prod}, ${HiggsPtMin}, ${mA}, ${wA}, ${ERA}, ${NEvents}, ${iSample}, ${UserName} ${fMiniAODlist}\n" >> ${sFParams}
			done

			
		done
		done
	done
done
	    
