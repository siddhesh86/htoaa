#!/bin/bash

Eras=("2016postVFP" "2017" "2018") #("2016preVFP" "2016postVFP" "2017" "2018")
Cats=("Zvv") #("gg0l" "Vjj" "tt0l" "Zvv")
SourceDir=/eos/cms/store/user/ssawant/htoaa/analysis/20251015_DatacardsFullSyst
DestinationDir=/eos/cms/store/user/ssawant/htoaa/analysis/20260206_DatacardsFullSystSigs_1

for Era in "${Eras[@]}"
do
    for Cat in "${Cats[@]}"
    do
        if [[ ${Cat} == *"gg0l"* ]]; then
    	    Subcats=("gg0lHi"  "gg0lLo")
        elif [[ ${Cat} == *"Vjj"* ]]; then
    	    Subcats=("VjjHi"  "VjjLo")
        elif [[ ${Cat} == *"tt0l"* ]]; then
    	    Subcats=("tt0l0b"  "tt0l1b")
        elif [[ ${Cat} == *"Zvv"* ]]; then
    	    Subcats=("ZvvHi"  "ZvvLo")
        fi

        for Subcat in "${Subcats[@]}"
        do
            Dir0=${SourceDir}/${Era}/${Cat}/2DAlphabet_inputFiles/${Subcat}
            Dir1=${DestinationDir}/${Era}/${Cat}/2DAlphabet_inputFiles_combined/${Subcat}
            Dir1p0=${DestinationDir}/${Era}/${Cat}/2DAlphabet_inputFiles/${Subcat}
            

            Dir1_dirName=$(dirname ${Dir1})
            if [[ ! -d "${Dir1_dirName}" ]]; then
                #echo "mkdir -p ${Dir1_dirName}"
                mkdir -p ${Dir1_dirName}
            fi

            echo "cp -r ${Dir0} ${Dir1} "
            cp -r ${Dir0} ${Dir1} 
            #echo "ls ${Dir1}/*Htoaato4b_mA*.root"
            rm ${Dir1}/*Htoaato4b_mA*.root
            cp ${Dir1p0}/*Htoaato4b_mA*.root ${Dir1}/

        done
    done
done
