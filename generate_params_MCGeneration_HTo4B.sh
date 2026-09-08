#!/bin/bash

### USERS settings ------------------------------------------------------------------------------------


prodmodes=(
    "GluGluHJ_HTo4B"
    #"WH_HTo4B"
)

#HiggsPtMinList=(150 250 350 450)
HiggsPtMinList=(150)

#Eras=("RunIISummer20UL18"
#	  "RunIISummer20UL17"
#	  "RunIISummer20UL16"
#	  "RunIISummer20UL16APV"
#       "Run3Summer22"
#)
Eras=("Run3Summer22")

MCSteps=(
    "LHEGenSim"
#    "DigiReco"
#    "MiniAOD"
#    "NanoAOD"
)

SampleNumber_First=0
SampleNumber_Last=0


### USERS settings ENDS --------------------------------------------------------------------------------


UserName=$(whoami)
XRootDRedirector="xrootd-cms.infn.it"
sFParams="params_MCGeneration_HTo4B.txt"

printf "\n rm ${sFParams} : \n"
rm ${sFParams}

NEvents=100000
## Data taking years
for ERA in "${Eras[@]}"
do
    
    if [[ "$ERA" == *"Run3"* ]]; then
        ECM="13p6" # 13p6 TeV
    else
        ECM="13" # 13p6 TeV
    fi

	## Loop over all Higgs production modes
	for prod in "${prodmodes[@]}"
	do

		## Loop over HiggsPtMinList
		for HiggsPtMin in "${HiggsPtMinList[@]}"
		do
            ## Loop over all Higgs production modes
            for MCStep in "${MCSteps[@]}"
            do

                for (( iSample=${SampleNumber_First}; iSample<=${SampleNumber_Last}; iSample++ ))
                do
                    sIpFile="xyz.root"
                    ## iSample=0: Generate MC events from .lhe file from Alexander Belyaev for GGH and WH production modes
                    if   [[ ${iSample} -eq 0  && ${HiggsPtMin} -eq 150  && "$MCStep" == "LHEGenSim"  ]]; then
                        if   [[ "$prod" == *"GluGluH"* ]]; then
                            sIpFile="root://${XRootDRedirector}//store/group/phys_susy/HToaaTo4b/LHE/SM_HTo4b_LO_13p6/2026_09_01/pp-ggH-4b-single.lhe"
                        elif [[ "$prod" == *"WH"* ]]; then
                            sIpFile="root://${XRootDRedirector}//store/group/phys_susy/HToaaTo4b/LHE/SM_HTo4b_LO_13p6/2026_09_01/pp-WH-W4b-single.lhe"
                        fi
                    else
                        MCStepLast=""
                        if  [[ "$MCStep" == *"DigiReco"* ]]; then
                            MCStepLast="LHEGenSim"
                        elif [[ "$MCStep" == *"MiniAOD"* ]]; then
                            MCStepLast="DigiReco"
                        elif [[ "$MCStep" == *"NanoAOD"* ]]; then
                            MCStepLast="MiniAOD"
                        fi
                        sIpFile="root://${XRootDRedirector}//store/group/phys_susy/HToaaTo4b/${MCStepLast}/${ERA}/${prod}_Pt${HiggsPtMin}_${ECM}TeV/${MCStep}_${iSample}.root"
                    fi
                    sOpFile="root://${XRootDRedirector}//store/group/phys_susy/HToaaTo4b/${MCStep}/${ERA}/${prod}_Pt${HiggsPtMin}_${ECM}TeV/${MCStep}_${iSample}.root"

                    printf "${prod}, ${HiggsPtMin}, ${ECM}, ${ERA}, ${MCStep}, ${NEvents}, ${iSample}, ${sIpFile}, ${sOpFile} ${UserName}\n" >> ${sFParams}

                done
            done
        done
	done
done
	    