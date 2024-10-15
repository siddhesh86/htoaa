#!/bin/bash

## Higgs production mode
prodmodes=("SUSY_GluGluH_01J_HToAATo4B")
#           "SUSY_GluGluH_1J_HToAATo4B_HT100"
#           "SUSY_VBFH_HToAATo4B"
#           "SUSY_WH_WToAll_HToAATo4B"
#           "SUSY_ZH_ZToAll_HToAATo4B"
#           "SUSY_TTH_TTToAll_HToAATo4B")

#HiggsPtMin=150 # 150 250 350
#HiggsPtMinList=(150) #(150 250 350 450)
#HiggsPtMinList=(150 250 350 450)

## "a" boson mass points
#mApoints=(12 15 20 25 30 35 40 45 50 55 60)
#mApoints=(8.5 9.0 9.5 10.0 10.5 11.0 11.5 12.5 13.0 13.5 14.0 16.0 17.0 18.5 21.5 23.0 27.5 32.5 37.5 42.5 47.5 52.5 57.5 62.5)
#mApoints=(47.5)
#mApoints=(32.5)
#mApoints=(52.5)
#mApoints=(8.5 9.0 9.5 10.0 10.5 11.0 11.5 12.5 13.0 13.5 14.0 16.0 17.0 18.5 21.5 23.0 27.5 37.5 42.5 57.5 62.5) #(32.5) #(52.5)
# compensating failed jobs
#mApoints=(47.5 52.5 57.5 62.5)

#wA=0 # for narrow width signal samples <<<<<<<<<< IMPORTANT <<<<<<<<<<<<<<

# set first (SampleNumber_First) to last (SampleNumber_Last) MC sample file numbers to be produced in this round of submission/execution.
#SampleNumber_First=1400 #700
#SampleNumber_Last=1899

# compensating failed jobs
#mApoints=(47.5 52.5 57.5 62.5)
#SampleNumber_First=1900
#SampleNumber_Last=2099
#mApoints=(37.5 42.5 47.5 52.5 57.5 62.5)
#SampleNumber_First=2100
#SampleNumber_Last=2299
#mApoints=(18.5 21.5 23.0 27.5 32.5 37.5 42.5 47.5 52.5 57.5 62.5)
#SampleNumber_First=2300
#SampleNumber_Last=2499
#mApoints=(42.5)
#SampleNumber_First=2500
#SampleNumber_Last=2549

## Largewidth samples
#mApoints=(12)
#wA=10
#SampleNumber_First=100
#SampleNumber_Last=1099
#HiggsPtMinList=(350) #(150 250 350 450)
#SampleNumber_First=1100
#SampleNumber_Last=2299
#HiggsPtMinList=(450) #(150 250 350 450)
#SampleNumber_First=1100
#SampleNumber_Last=5499

## Largewidth samples
mApoints=(12)
wA=70
#HiggsPtMinList=(350)
#SampleNumber_First=2000 # 0
#SampleNumber_Last=2499 # 1999
HiggsPtMinList=(450)
SampleNumber_First=8000 # 0
SampleNumber_Last=8499 # 7999

ERA="RunIISummer20UL18"
#NEvents=500 # NEvents set as per HiggsPtMin below
#NEvents=10


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
	    
