#!/bin/bash

## Higgs production mode
prodmodes=("SUSY_GluGluH_01J_HToAATo4B")
#           "SUSY_GluGluH_1J_HToAATo4B_HT100"
#           "SUSY_VBFH_HToAATo4B"
#           "SUSY_WH_WToAll_HToAATo4B"
#           "SUSY_ZH_ZToAll_HToAATo4B"
#           "SUSY_TTH_TTToAll_HToAATo4B")

HiggsPtMin=150 # 150 250 350

## "a" boson mass points
#masspoints=(12 15 20 25 30 35 40 45 50 55 60)
#masspoints=(8.5 9.0 9.5 10.0 10.5 11.0 11.5 12.5 13.0 13.5 14.0 16.0 17.0 18.5 21.5 23.0 27.5 32.5 37.5 42.5 47.5 52.5 57.5 62.5)
#masspoints=(47.5)
#masspoints=(32.5)
#masspoints=(52.5)
#masspoints=(8.5 9.0 9.5 10.0 10.5 11.0 11.5 12.5 13.0 13.5 14.0 16.0 17.0 18.5 21.5 23.0 27.5 37.5 42.5 57.5 62.5) #(32.5) #(52.5)
# compensating failed jobs
#masspoints=(47.5 52.5 57.5 62.5)

ERA="RunIISummer20UL18"
NEvents=500
#NEvents=10

# set first (SampleNumber_First) to last (SampleNumber_Last) MC sample file numbers to be produced in this round of submission/execution.
#SampleNumber_First=1400 #700
#SampleNumber_Last=1899

# compensating failed jobs
#masspoints=(47.5 52.5 57.5 62.5)
#SampleNumber_First=1900
#SampleNumber_Last=2099
#masspoints=(37.5 42.5 47.5 52.5 57.5 62.5)
#SampleNumber_First=2100
#SampleNumber_Last=2299
masspoints=(18.5 21.5 23.0 27.5 32.5 37.5 42.5 47.5 52.5 57.5 62.5)
SampleNumber_First=2300
SampleNumber_Last=2499

XRootDRedirector="xrootd-cms.infn.it"

sFParams="params_MCGeneration_HToAATo4B_M-x.txt"

printf "\n rm ${sFParams} : \n"
rm ${sFParams}

## Loop over all Higgs production modes
for prod in "${prodmodes[@]}"
do
    ## Loop over all "a" boson mass points
    for mp in "${masspoints[@]}"
    do

	for (( iSample=${SampleNumber_First}; iSample<=${SampleNumber_Last}; iSample++ ))
	do
	    # /store/user/ssawant/mc/SUSY_GluGluH_01J_HToAATo4B_M-47.5_el9_amd64_gcc11_CMSSW_13_2_9_tarball.tar.xz
	    #sIpFile="/store/user/ssawant/mc/${prod}_M-${mp}_el9_amd64_gcc11_CMSSW_13_2_9_tarball.tar.xz"
	    # /eos/cms/store/user/ssawant/mc/SUSY_GluGluH_01J_HToAATo4B_M-47.5_slc7_amd64_gcc10_CMSSW_12_4_8_tarball.tar.xz
	    sIpFile="/store/user/ssawant/mc/${prod}_M-${mp}_slc7_amd64_gcc10_CMSSW_12_4_8_tarball.tar.xz"
	    printf "${prod}, ${HiggsPtMin}, ${mp}, ${ERA}, ${NEvents}, ${iSample}, ${XRootDRedirector}, ${sIpFile}\n" >> ${sFParams}
	    
	done
    done
done
	    
