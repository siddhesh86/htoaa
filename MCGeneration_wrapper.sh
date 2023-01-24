#!/bin/bash


Dir_sourceCodes=$(pwd)
Dir_production='/afs/cern.ch/work/s/ssawant/private/htoaa/MCGeneration_tmp5p1' # without '/' in the end
#Dir_production='/home/siddhesh/Work/CMS/htoaa/htoaa/tmp'
Dir_store=${Dir_production}
NEvents=100
GENLevelEfficiency=$(bc -l <<< '0.0250' )
sampleName='SUSY_GluGluH_01J_HToAATo4B_Pt150_$SAMPLETAG_TuneCP5_13TeV_madgraph_pythia8'
ERA='RunIISummer20UL18'
FileNumber=0
#InputGridpackFile='/cvmfs/cms.cern.ch/phys_generator/gridpacks/UL/13TeV/madgraph/V5_2.6.5/SUSY_GluGluH_01J_HToAATo4B_M-50/v1/SUSY_GluGluH_01J_HToAATo4B_M-50_slc7_amd64_gcc700_CMSSW_10_6_19_tarball.tar.xz'
InputGridpackFile='/afs/cern.ch/work/s/ssawant/private/htoaa/MCproduction/HToAATo4B/MCGridpacks/genproductions/bin/MadGraph5_aMCatNLO/SUSY_GluGluH_01J_HToAATo4B_mA-50_wH-40_wA-30_slc7_amd64_gcc10_CMSSW_12_4_8_tarball.tar.xz'

echo "Dir_sourceCodes: ${Dir_sourceCodes} "
echo "Dir_production: ${Dir_production} "


if [ ! -d ${Dir_production} ]
then
    mkdir -p ${Dir_production}    
fi

for i in 1
do
    echo "i: ${i}"
    jobID="mH-125_mA-50_wH-40_wA-30" # "H_M125_a01_M50"

    sampleName_toUse=${sampleName//\$SAMPLETAG/$jobID}

    echo "sampleName_toUse: ${sampleName_toUse} "
    echo "NEvents:${NEvents},  GENLevelEfficiency: ${GENLevelEfficiency}"

    MCGenerationScript=${Dir_production}/MCGenerationScript_${jobID}.sh

    echo "MCGenerationScript: ${MCGenerationScript} "

    printf "#!/bin/bash \n\n" > ${MCGenerationScript}
    printf "cd ${Dir_production} \n" >> ${MCGenerationScript}
    

    # wmLHEGEN -------------------------------------------------------------------------
    DatasetType='wmLHEGEN'
    inputFile=${InputGridpackFile} # 'input.root'
    #outputDir=${Dir_store}/${sampleName_toUse}/${ERA}/${DatasetType}
    outputFile=${Dir_store}/${sampleName_toUse}/${ERA}/${DatasetType}_${FileNumber}.root
    #NEvents_toUse=$((NEvents / GENLevelEfficiency))
    NEvents_toUse=$(bc -l <<<"scale=0; $NEvents / $GENLevelEfficiency")

    printf "\nprintf '\n\nRun source ${Dir_sourceCodes}/generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}  ${Dir_sourceCodes}  '  \n" >> ${MCGenerationScript}
    if [ ! -f ${outputFile} ]
    then
	printf "time source ${Dir_sourceCodes}/generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}  ${Dir_sourceCodes}   \n" >> ${MCGenerationScript}
    else
	printf "printf '\nOutput: ${outputFile} already exists!!! ' \n" >> ${MCGenerationScript}
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
	printf "printf '\nOutput: ${outputFile} already exists!!! ' \n" >> ${MCGenerationScript}
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
	printf "printf '\nOutput: ${outputFile} already exists!!! ' \n" >> ${MCGenerationScript}
    fi
    
	
    # HLT -------------------------------------------------------------------------
    DatasetType='HLT'
    inputFile=${outputFile}
    outputFile=${Dir_store}/${sampleName_toUse}/${ERA}/${DatasetType}_${FileNumber}.root
    NEvents_toUse=${NEvents} 

    printf "\nprintf '\n\nRun source ${Dir_sourceCodes}/generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}    '  \n" >> ${MCGenerationScript}
    if [ ! -f ${outputFile} ]
    then
	printf "time source ${Dir_sourceCodes}/generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}     \n" >> ${MCGenerationScript}
    else
	printf "printf '\nOutput: ${outputFile} already exists!!! ' \n" >> ${MCGenerationScript}
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
	printf "printf '\nOutput: ${outputFile} already exists!!! ' \n" >> ${MCGenerationScript}
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
	printf "printf '\nOutput: ${outputFile} already exists!!! ' \n" >> ${MCGenerationScript}
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
	printf "printf '\nOutput: ${outputFile} already exists!!! ' \n" >> ${MCGenerationScript}
    fi

    printf "\nls \n" >> ${MCGenerationScript}

    printf "\n\nsource ${MCGenerationScript}"
    time source ${MCGenerationScript}
    
   


done
