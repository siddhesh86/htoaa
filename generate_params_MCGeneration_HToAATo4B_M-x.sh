#!/bin/bash

### USERS settings ------------------------------------------------------------------------------------

## Higgs production mode
prodmodes=("SUSY_GluGluH_01J_HToAATo4B"
           "SUSY_VBFH_HToAATo4B"
           "SUSY_WH_WToAll_HToAATo4B"
           "SUSY_ZH_ZToAll_HToAATo4B"
           "SUSY_TTH_TTToAll_HToAATo4B")
#prodmodes=("SUSY_VBFH_HToAATo4B")

#HiggsPtMinList=(150 250 350 450)
HiggsPtMinList=(150)

## "a" boson mass points
#mApoints=(12 15 20 25 30 35 40 45 50 55 60)
#mApoints=(8.5 9.0 9.5 10.0 10.5 11.0 11.5 12.5 13.0 13.5 14.0 16.0 17.0 18.5 21.5 23.0 27.5 32.5 37.5 42.5 47.5 52.5 57.5 62.5)
mApoints=(47.5)

# Decay width of a-boson
wA=0 # 0 for narrow A width sample. 10 or 70 for broader A width samples. <<<<<<<<<< IMPORTANT <<<<<<<<<<<<<<

# set first (SampleNumber_First) to last (SampleNumber_Last) MC sample file numbers to be produced in this round of submission/execution.
SampleNumber_First=1
SampleNumber_Last=1


## Dataset ERA
ERA="RunIISummer20UL18" # Options: RunIISummer20UL18
#NEvents=500 # NEvents set as per HiggsPtMin below
#NEvents=10

### USERS settings ENDS --------------------------------------------------------------------------------

### Information
# GEN-filter efficiency: 
#     0.057 for SUSY_GluGluH_01J_HToAATo4B_Pt150
#     0.173 for SUSY_VBFH_HToAATo4B_Pt150
#     0.132 for SUSY_WH_WToAll_HToAATo4B_Pt150
#     0.129 for SUSY_ZH_ZToAll_HToAATo4B_Pt150
#     0.285 for SUSY_TTH_TTToAll_HToAATo4B_Pt150




XRootDRedirector="xrootd-cms.infn.it"
sFParams="params_MCGeneration_HToAATo4B_M-x.txt"

printf "\n rm ${sFParams} : \n"
rm ${sFParams}

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

		NEvents=10

	    for (( iSample=${SampleNumber_First}; iSample<=${SampleNumber_Last}; iSample++ ))
	    do
		if (( $(echo "$wA < 0.5" |bc -l) )); then 
		    ## Narrow width signal samples
		    # /store/user/ssawant/mc/SUSY_GluGluH_01J_HToAATo4B_M-47.5_el9_amd64_gcc11_CMSSW_13_2_9_tarball.tar.xz
		    #sIpFile="/store/user/ssawant/mc/${prod}_M-${mp}_el9_amd64_gcc11_CMSSW_13_2_9_tarball.tar.xz"
		    # /eos/cms/store/user/ssawant/mc/SUSY_GluGluH_01J_HToAATo4B_M-47.5_slc7_amd64_gcc10_CMSSW_12_4_8_tarball.tar.xz
		    sIpFile="/store/user/ssawant/mc/${prod}_M-${mA}_slc7_amd64_gcc10_CMSSW_12_4_8_tarball.tar.xz"
		    printf "${prod}, ${HiggsPtMin}, ${mA}, ${wA}, ${ERA}, ${NEvents}, ${iSample}, ${XRootDRedirector}, ${sIpFile}\n" >> ${sFParams}
		else
		    ## Broader width signal samples
		    # /eos/cms/store/user/ssawant/mc/SUSY_GluGluH_01J_HToAATo4B_mH-70_mA-12_wH-70_wA-10_0_slc7_amd64_gcc10_CMSSW_12_4_8_tarball.tar.xz
		    sIpFile="/store/user/ssawant/mc/${prod}_mH-70_mA-${mA}_wH-70_wA-${wA}_0_slc7_amd64_gcc10_CMSSW_12_4_8_tarball.tar.xz"
		    printf "${prod}, ${HiggsPtMin}, ${mA}, ${wA}, ${ERA}, ${NEvents}, ${iSample}, ${XRootDRedirector}, ${sIpFile}\n" >> ${sFParams}
		    
		fi
	    done
	done
    done
done
	    
