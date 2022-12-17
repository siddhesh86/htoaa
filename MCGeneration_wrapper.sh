#!/bin/bash


Dir_sourceCodes=$(pwd)
Dir_production='/afs/cern.ch/work/s/ssawant/private/htoaa/MCGeneration_tmp1' # without '/' in the end
#Dir_production='/home/siddhesh/Work/CMS/htoaa/htoaa/tmp'
Dir_store=${Dir_production}
NEvents=10
GENLevelEfficiency=$(bc -l <<< '0.0250' )
sampleName='SUSY_GluGluH_01J_HToAATo4B_Pt150_$SAMPLETAG_TuneCP5_13TeV_madgraph_pythia8'
ERA='RunIISummer20UL18'
FileNumber=0

echo "Dir_sourceCodes: ${Dir_sourceCodes} "
echo "Dir_production: ${Dir_production} "


if [ ! -d ${Dir_production} ]
then
    mkdir -p ${Dir_production}    
fi

for i in 1
do
    echo "i: ${i}"
    jobID="H_M125_a01_M25"

    sampleName_toUse=${sampleName//\$SAMPLETAG/$jobID}

    echo "sampleName_toUse: ${sampleName_toUse} "
    echo "NEvents:${NEvents},  GENLevelEfficiency: ${GENLevelEfficiency}"

    MCGenerationScript=${Dir_production}/MCGenerationScript_${jobID}.sh

    echo "MCGenerationScript: ${MCGenerationScript} "

    printf "#!/bin/bash \n\n" > ${MCGenerationScript}
    printf "cd ${Dir_production} \n" >> ${MCGenerationScript}
    

    # wmLHEGEN -------------------------------------------------------------------------
    DatasetType='wmLHEGEN'
    inputFile='input.root'
    #outputDir=${Dir_store}/${sampleName_toUse}/${ERA}/${DatasetType}
    outputFile=${Dir_store}/${sampleName_toUse}/${ERA}/${DatasetType}_${FileNumber}.root
    #NEvents_toUse=$((NEvents / GENLevelEfficiency))
    NEvents_toUse=$(bc -l <<<"scale=0; $NEvents / $GENLevelEfficiency")

    printf "\nprintf '\n\nRun source ${Dir_sourceCodes}/generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}  ${Dir_sourceCodes}  '  \n" >> ${MCGenerationScript}
    if [ ! -f ${outputFile} ]
    then
	printf "time source ${Dir_sourceCodes}/generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}  ${Dir_sourceCodes}   \n" >> ${MCGenerationScript}
    else
	printf "printf 'Output: ${outputFile} already exists!!! ' \n" >> ${MCGenerationScript}
    fi
    

    # SIM -------------------------------------------------------------------------
    DatasetType='SIM'
    inputFile=${outputFile}
    outputFile=${Dir_store}/${sampleName_toUse}/${ERA}/${DatasetType}_${FileNumber}.root
    NEvents_toUse=${NEvents} 

    printf "\nprintf '\n\nRun source ${Dir_sourceCodes}/generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}    '  \n" >> ${MCGenerationScript}
    if [ ! -f ${outputFile} ]
    then
	printf "time source ${Dir_sourceCodes}/generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}     \n" >> ${MCGenerationScript}
    else
	printf "printf 'Output: ${outputFile} already exists!!! ' \n" >> ${MCGenerationScript}
    fi
    

    # DIGIPremix -------------------------------------------------------------------------
    DatasetType='DIGIPremix'
    inputFile=${outputFile}
    outputFile=${Dir_store}/${sampleName_toUse}/${ERA}/${DatasetType}_${FileNumber}.root
    NEvents_toUse=${NEvents} 

    printf "\nprintf '\n\nRun source ${Dir_sourceCodes}/generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}    '  \n" >> ${MCGenerationScript}
    if [ ! -f ${outputFile} ]
    then
	printf "time source ${Dir_sourceCodes}/generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}     \n" >> ${MCGenerationScript}
    else
	printf "printf 'Output: ${outputFile} already exists!!! ' \n" >> ${MCGenerationScript}
    fi
    
	
    # HLT -------------------------------------------------------------------------
    DatasetType='HLT'
    inputFile=${outputFile}
    outputFile=${Dir_store}/${sampleName_toUse}/${ERA}/${DatasetType}_${FileNumber}.root
    NEvents_toUse=${NEvents} 

    printf "\nprintf 'R\n\nun source ${Dir_sourceCodes}/generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}    '  \n" >> ${MCGenerationScript}
    if [ ! -f ${outputFile} ]
    then
	printf "time source ${Dir_sourceCodes}/generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}     \n" >> ${MCGenerationScript}
    else
	printf "printf 'Output: ${outputFile} already exists!!! ' \n" >> ${MCGenerationScript}
    fi

    
    # RECO -------------------------------------------------------------------------
    DatasetType='RECO'
    inputFile=${outputFile}
    outputFile=${Dir_store}/${sampleName_toUse}/${ERA}/${DatasetType}_${FileNumber}.root
    NEvents_toUse=${NEvents} 

    printf "\nprintf '\n\nRun source ${Dir_sourceCodes}/generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}    '  \n" >> ${MCGenerationScript}
    if [ ! -f ${outputFile} ]
    then
	printf "time source ${Dir_sourceCodes}/generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}     \n" >> ${MCGenerationScript}
    else
	printf "printf 'Output: ${outputFile} already exists!!! ' \n" >> ${MCGenerationScript}
    fi

    
    # MiniAODv2 -------------------------------------------------------------------------
    DatasetType='MiniAODv2'
    inputFile=${outputFile}
    outputFile=${Dir_store}/${sampleName_toUse}/${ERA}/${DatasetType}_${FileNumber}.root
    NEvents_toUse=${NEvents} 

    printf "\nprintf '\n\nRun source ${Dir_sourceCodes}/generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}    '  \n" >> ${MCGenerationScript}
    if [ ! -f ${outputFile} ]
    then
	printf "time source ${Dir_sourceCodes}/generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}     \n" >> ${MCGenerationScript}
    else
	printf "printf 'Output: ${outputFile} already exists!!! ' \n" >> ${MCGenerationScript}
    fi

    
    # NanoAODv9 -------------------------------------------------------------------------
    DatasetType='NanoAODv9'
    inputFile=${outputFile}
    outputFile=${Dir_store}/${sampleName_toUse}/${ERA}/${DatasetType}_${FileNumber}.root
    NEvents_toUse=${NEvents} 

    printf "\nprintf '\n\nRun source ${Dir_sourceCodes}/generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}    '  \n" >> ${MCGenerationScript}
    if [ ! -f ${outputFile} ]
    then
	printf "time source ${Dir_sourceCodes}/generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}     \n" >> ${MCGenerationScript}
    else
	printf "printf 'Output: ${outputFile} already exists!!! ' \n" >> ${MCGenerationScript}
    fi

    printf "\nls \n" >> ${MCGenerationScript}

    printf "\n\nsource ${MCGenerationScript}"
    time source ${MCGenerationScript}
    
   


done
