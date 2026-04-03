#!/bin/bash

Eras=("2016preVFP") #("2016preVFP" "2016postVFP" "2017" "2018")
Cats=("gg0l" "Vjj" "tt0l" "Zvv") #("gg0l" "Vjj" "tt0l" "Zvv")
SourceDir1="/eos/cms/store/user/ssawant/htoaa/analysis/20260206_DatacardsFullSystSigs_1"
SourceDir2="/eos/cms/store/user/ssawant/htoaa/analysis/20260322_DatacardsFullSyst_3BuggyMAs"
BuggySigMAs=("21p5" "32p5" "57p5")
DestinationDir="/eos/cms/store/user/ssawant/htoaa/analysis/20260206_DatacardsFullSystSigs_1"

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
            DirSrc1=${SourceDir1}/${Era}/${Cat}/2DAlphabet_inputFiles_combined/${Subcat}
            DirSrc2=${SourceDir2}/${Era}/${Cat}/2DAlphabet_inputFiles/${Subcat}

            DirDst=${DestinationDir}/${Era}/${Cat}/2DAlphabet_inputFiles_combined_v2/${Subcat}

            echo "DirSrc1: ${DirSrc1}"
            echo "DirSrc2: ${DirSrc2}"
            echo "DirDst:  ${DirDst}"
            


            DirDst_dirName=$(dirname ${DirDst})
            if [[ ! -d "${DirDst_dirName}" ]]; then
                #echo "mkdir -p ${Dir1_dirName}"
                mkdir -p ${DirDst_dirName}
            fi

            echo "cp -r ${DirSrc1} ${DirDst} "
            cp -r ${DirSrc1} ${DirDst}

            for BuggySigMA in "${BuggySigMAs[@]}"
            do
                echo "ls ${DirDst}/*Htoaato4b_mA_${BuggySigMA}_*.root"
                rm ${DirDst}/*Htoaato4b_mA_${BuggySigMA}_*.root

                echo "cp ${DirSrc2}/*Htoaato4b_mA_${BuggySigMA}_*.root ${DirDst}/ "
                cp ${DirSrc2}/*Htoaato4b_mA_${BuggySigMA}_*.root ${DirDst}/ 

            done 

            echo

        done
    done
done
