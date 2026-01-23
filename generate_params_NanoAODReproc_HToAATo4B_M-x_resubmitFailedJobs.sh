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
Eras=("RunIISummer20UL17")


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

	nMiniAODSets_Yearwise=0
	nNanoAODSets_Yearwise=0

	## Loop over all Higgs production modes
	for prod in "${prodmodes[@]}"
	do

		nMiniAODSets_YearAndProdModewise=0
		nNanoAODSets_YearAndProdModewise=0

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

				SampleProcessName="${prod}_Pt${HiggsPtMin}_M-${mA}"
				if (( $(echo "$wA > 1" | bc -l) )); then
					SampleProcessName="${prod}_Pt${HiggsPtMin}_mH-70_mA-${mA}_wH-70_wA-${wA}"
				fi
				SampleGeneratorDetails="TuneCP5_13TeV_madgraph_pythia8" # GENERATOR details that will be included in 'sample's name'.
				#OpSubdirNum=$(printf "%04d" $((${iSample} / 100)) )
				NanoAODFile_Final_FileNames=/eos/cms/store/group/phys_susy/HToaaTo4b/NanoAOD/${EraYear}/MC/PNet_v2_2024_11_22/${SampleProcessName}_${SampleGeneratorDetails}/r1/20260121_000000/*/PNet_v1_*_Skim.root
				nNanoAODlistSets=$(ls ${NanoAODFile_Final_FileNames} | wc -l)
				#printf "nMiniAODlistSets: ${nMiniAODlistSets},   \t\t ${nNanoAODlistSets} / ${nMiniAODlistSets} \n"
				printf "${SampleProcessName}, \t ${EraYear}  \t\t ${nNanoAODlistSets} / ${nMiniAODlistSets} \n"

				nMiniAODSets_Yearwise=$((nMiniAODSets_Yearwise + nMiniAODlistSets))
				nNanoAODSets_Yearwise=$((nNanoAODSets_Yearwise + nNanoAODlistSets))
				
				nMiniAODSets_YearAndProdModewise=$((nMiniAODSets_YearAndProdModewise + nMiniAODlistSets))
				nNanoAODSets_YearAndProdModewise=$((nNanoAODSets_YearAndProdModewise + nNanoAODlistSets))

				

				#for iMiniAOD_set 
				for (( iSample=0; iSample<${nMiniAODlistSets}; iSample++ ))
				do
					#fMiniAODlist="miniAOD_files/miniAODs_${prod}_Pt${HiggsPtMin}_M-${mA}_${EraYear}.txt"
					fMiniAODlist="miniAOD_files_1/miniAODs_${prod}_Pt${HiggsPtMin}_M-${mA}_${EraYear}_${iSample}.txt"

					OpSubdirNum=$(printf "%04d" $((${iSample} / 100)) )
					NanoAODFile_Final_FileName=/eos/cms/store/group/phys_susy/HToaaTo4b/NanoAOD/${EraYear}/MC/PNet_v2_2024_11_22/${SampleProcessName}_${SampleGeneratorDetails}/r1/20260121_000000/${OpSubdirNum}/PNet_v1_${iSample}_Skim.root
					
					#printf "iSample: ${iSample} ${fMiniAODlist} \n${NanoAODFile_Final_FileName} \n\n"

					if [ ! -f "$NanoAODFile_Final_FileName" ]; then
						#printf "iSample: ${iSample} ${fMiniAODlist} \n${NanoAODFile_Final_FileName} \n\n"
						printf "${prod}, ${HiggsPtMin}, ${mA}, ${wA}, ${ERA}, ${NEvents}, ${iSample}, ${UserName}, ${fMiniAODlist}\n" >> ${sFParams}
					fi
				done

				
			done
			#printf "\n"
		done
		#printf "\n"
		printf "${EraYear}, ${prod}: ${nNanoAODSets_YearAndProdModewise} / ${nMiniAODSets_YearAndProdModewise} \n\n"
	done

	printf "${EraYear}: ${nNanoAODSets_Yearwise} / ${nMiniAODSets_Yearwise} \n\n"
done
	    
