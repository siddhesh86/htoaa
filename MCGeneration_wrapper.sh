#!/bin/bash

# Instructions:
# Set up Madgraph working directory following https://twiki.cern.ch/twiki/bin/viewauth/CMS/QuickGuideMadGraph5aMCatNLO#Quick_tutorial_on_how_to_produce
#    git clone https://github.com/cms-sw/genproductions.git
#    cd genproductions/bin/MadGraph5_aMCatNLO/
#    Store this path in 'Dir_MadgraphPkg' variable below.
#
# Run command: (submit from a fresh terminal. Condor job submission from existing screen session did not recognise 'condor_submit' command.)
# $ time ./MCGeneration_wrapper.sh


## Settings: Change as per need ------------------------------------------------------------------------
Dir_sourceCodes=$(pwd)
Dir_production='/afs/cern.ch/work/s/ssawant/private/htoaa/MCGeneration/tmp3' # without '/' in the end
Dir_store='/eos/cms/store/user/ssawant/mc'  # ${Dir_production}
NEvents=100
GENLevelEfficiency=$(bc -l <<< '0.0250' )

sampleTag='mH-125_mA-50_wH-55_wA-40'
MadgraphCardName="SUSY_GluGluH_01J_HToAATo4B_${sampleTag}"
sampleName="SUSY_GluGluH_01J_HToAATo4B_Pt150_${sampleTag}_TuneCP5_13TeV_madgraph_pythia8"
ERA='RunIISummer20UL18'
#InputGridpackFile='/cvmfs/cms.cern.ch/phys_generator/gridpacks/UL/13TeV/madgraph/V5_2.6.5/SUSY_GluGluH_01J_HToAATo4B_M-50/v1/SUSY_GluGluH_01J_HToAATo4B_M-50_slc7_amd64_gcc700_CMSSW_10_6_19_tarball.tar.xz'
Dir_MadgraphPkg='/afs/cern.ch/work/s/ssawant/private/htoaa/MCproduction/HToAATo4B/MCGridpacks/genproductions/bin/MadGraph5_aMCatNLO'
Dir_MadgraphCards='cards/production/13TeV/HToAATo4B' # without '/' in the end
gridpackFile=${Dir_MadgraphPkg}/


#FileNumber=0

SampleNumber_First=5
SampleNumber_Last=7 # 55

RunningMode="Condor"

MinFileSize=1000000 # 1 MB
##--------------------------------------------------------------------------------------------------------

# run Madgraph: /afs/cern.ch/work/s/ssawant/private/htoaa/MCproduction/HToAATo4B/MCGridpacks/genproductions/bin/MadGraph5_aMCatNLO
# 

echo "Dir_sourceCodes: ${Dir_sourceCodes} "
echo "Dir_production: ${Dir_production} "


if [ ! -d ${Dir_production} ]
then
    mkdir -p ${Dir_production}    
fi

if [ ! -d ${Dir_store} ]
then
    mkdir -p ${Dir_store}    
fi

#for i in 1
#for iSample in {${SampleNumber_First}..${SampleNumber_Last}}
for (( iSample=${SampleNumber_First}; iSample<=${SampleNumber_Last}; iSample++ ))
do
    echo "iSample: ${iSample}"
    #break
    #continue
    

    jobID=${MadgraphCardName}_${iSample}

    MadgraphCardName_toUse=${MadgraphCardName}_${iSample}
    #sampleName_toUse=${sampleName//\$SAMPLETAG/$jobID}
    sampleName_toUse=${sampleName}
    

    echo "jobID: ${jobID} "
    echo "MadgraphCardName_toUse: ${MadgraphCardName_toUse} "
    echo "sampleName_toUse: ${sampleName_toUse} "
    echo "NEvents:${NEvents},  GENLevelEfficiency: ${GENLevelEfficiency}"

    MCGenerationScript=${Dir_production}/MCGenerationScript_${jobID}.sh

    echo "MCGenerationScript: ${MCGenerationScript} "

    printf "#!/bin/bash \n\n" > ${MCGenerationScript}
    printf "cd ${Dir_production} \n\n" >> ${MCGenerationScript}

    # Madgraph gridpack ----------------------------------------------------------------
    DatasetType='MadgraphGridpack'
    gridpackFile_0=${Dir_MadgraphPkg}/${MadgraphCardName_toUse}_slc7_amd64_gcc10_CMSSW_12_4_8_tarball.tar.xz # Default path
    gridpackFile=${Dir_store}/${sampleName_toUse}/${ERA}/${DatasetType}_${iSample}_slc7_amd64_gcc10_CMSSW_12_4_8_tarball.tar.xz # relocated path

    if [ ! -d ${Dir_store}/${sampleName_toUse}/${ERA} ]; then
	mkdir -p ${Dir_store}/${sampleName_toUse}/${ERA}
    fi


    if [ -f ${gridpackFile} ] && [ $(stat -c%s ${gridpackFile}) -gt ${MinFileSize} ]; then
	printf "printf '\nOutput: ${gridpackFile} already exists!!! ' \n" >> ${MCGenerationScript}
    else
	printf "cd ${Dir_MadgraphPkg} \n" >> ${MCGenerationScript}
	printf "mkdir -p ${Dir_MadgraphCards}/${MadgraphCardName_toUse} \n" >> ${MCGenerationScript}

	printf "cp ${Dir_sourceCodes}/madgraphCards/${MadgraphCardName}_customizecards.dat  ${Dir_MadgraphCards}/${MadgraphCardName_toUse}/${MadgraphCardName_toUse}_customizecards.dat \n" >> ${MCGenerationScript}
	printf "cp ${Dir_sourceCodes}/madgraphCards/${MadgraphCardName}_extramodels.dat     ${Dir_MadgraphCards}/${MadgraphCardName_toUse}/${MadgraphCardName_toUse}_extramodels.dat    \n" >> ${MCGenerationScript}
	printf "cp ${Dir_sourceCodes}/madgraphCards/${MadgraphCardName}_proc_card.dat       ${Dir_MadgraphCards}/${MadgraphCardName_toUse}/${MadgraphCardName_toUse}_proc_card.dat      \n" >> ${MCGenerationScript}
	printf "cp ${Dir_sourceCodes}/madgraphCards/${MadgraphCardName}_run_card.dat        ${Dir_MadgraphCards}/${MadgraphCardName_toUse}/${MadgraphCardName_toUse}_run_card.dat       \n" >> ${MCGenerationScript}
	# Rename MadgraphCard output name
	printf "sed -i \"s/${MadgraphCardName}/${MadgraphCardName_toUse}/g\"   ${Dir_MadgraphCards}/${MadgraphCardName_toUse}/${MadgraphCardName_toUse}_proc_card.dat \n\n" >> ${MCGenerationScript}
    
	#printf "time ./gridpack_generation.sh ${MadgraphCardName_toUse} ${Dir_MadgraphCards}/${MadgraphCardName_toUse}  \n\n" >> ${MCGenerationScript}
	printf "time . gridpack_generation.sh ${MadgraphCardName_toUse} ${Dir_MadgraphCards}/${MadgraphCardName_toUse}  \n\n" >> ${MCGenerationScript}

	# output file: gridpackFile_0
	printf "if [ ! -f ${gridpackFile_0} ] \n" >> ${MCGenerationScript}
	printf "then \n" >> ${MCGenerationScript}
	printf "    printf '${gridpackFile_0} did not produce... \t\t **** ERROR **** \n' \n" >> ${MCGenerationScript}
	printf "    exit 1 \n" >> ${MCGenerationScript}
	printf "fi \n" >> ${MCGenerationScript}

	# mv gridpackFile_0 to gridpackFile
	printf "printf \"mv ${gridpackFile_0} ${gridpackFile} \\n \" \n" >> ${MCGenerationScript}
	printf "mv ${gridpackFile_0} ${gridpackFile} \n" >> ${MCGenerationScript}
    fi


    #printf "exit 1 \n" >> ${MCGenerationScript}




    printf "cd ${Dir_production} \n\n" >> ${MCGenerationScript}

    # wmLHEGEN -------------------------------------------------------------------------
    DatasetType='wmLHEGEN'
    inputFile=${gridpackFile} # 'input.root'
    #outputDir=${Dir_store}/${sampleName_toUse}/${ERA}/${DatasetType}
    outputFile=${Dir_store}/${sampleName_toUse}/${ERA}/${DatasetType}_${iSample}.root
    #NEvents_toUse=$((NEvents / GENLevelEfficiency))
    NEvents_toUse=$(bc -l <<<"scale=0; $NEvents / $GENLevelEfficiency")

    printf "\nprintf '\nRun source ${Dir_sourceCodes}/generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}  ${Dir_sourceCodes}  '  \n" >> ${MCGenerationScript}
    if [ -f ${outputFile} ] && [ $(stat -c%s ${outputFile}) -gt ${MinFileSize} ]; then
	printf "printf '\nOutput: ${outputFile} already exists!!! ' \n" >> ${MCGenerationScript}
    else
	#printf "time source ${Dir_sourceCodes}/generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}  ${Dir_sourceCodes}   \n" >> ${MCGenerationScript}
	printf "time . ${Dir_sourceCodes}/generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}  ${Dir_sourceCodes}   \n" >> ${MCGenerationScript}
    fi
    

    # SIM -------------------------------------------------------------------------
    DatasetType='SIM'
    inputFile=${outputFile}
    outputFile=${Dir_store}/${sampleName_toUse}/${ERA}/${DatasetType}_${iSample}.root
    NEvents_toUse=${NEvents} 

    printf "\nprintf '\nRun source ${Dir_sourceCodes}/generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}    '  \n" >> ${MCGenerationScript}
    if [ -f ${outputFile} ] && [ $(stat -c%s ${outputFile}) -gt ${MinFileSize} ]; then
	printf "printf '\nOutput: ${outputFile} already exists!!! ' \n" >> ${MCGenerationScript}
    else
	#printf "time source ${Dir_sourceCodes}/generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}     \n" >> ${MCGenerationScript}
	printf "time . ${Dir_sourceCodes}/generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}     \n" >> ${MCGenerationScript}
    fi
    

    # DIGIPremix -------------------------------------------------------------------------
    DatasetType='DIGIPremix'
    inputFile=${outputFile}
    outputFile=${Dir_store}/${sampleName_toUse}/${ERA}/${DatasetType}_${iSample}.root
    NEvents_toUse=${NEvents} 

    printf "\nprintf '\nRun source ${Dir_sourceCodes}/generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}    '  \n" >> ${MCGenerationScript}
    if [ -f ${outputFile} ] && [ $(stat -c%s ${outputFile}) -gt ${MinFileSize} ]; then
	printf "printf '\nOutput: ${outputFile} already exists!!! ' \n" >> ${MCGenerationScript}
    else
	#printf "time source ${Dir_sourceCodes}/generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}     \n" >> ${MCGenerationScript}
	printf "time . ${Dir_sourceCodes}/generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}     \n" >> ${MCGenerationScript}
    fi
    
	
    # HLT -------------------------------------------------------------------------
    DatasetType='HLT'
    inputFile=${outputFile}
    outputFile=${Dir_store}/${sampleName_toUse}/${ERA}/${DatasetType}_${iSample}.root
    NEvents_toUse=${NEvents} 

    printf "\nprintf '\nRun source ${Dir_sourceCodes}/generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}    '  \n" >> ${MCGenerationScript}
    if [ -f ${outputFile} ] && [ $(stat -c%s ${outputFile}) -gt ${MinFileSize} ]; then
	printf "printf '\nOutput: ${outputFile} already exists!!! ' \n" >> ${MCGenerationScript}
    else
	#printf "time source ${Dir_sourceCodes}/generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}     \n" >> ${MCGenerationScript}
	printf "time . ${Dir_sourceCodes}/generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}     \n" >> ${MCGenerationScript}
    fi

    
    # RECO -------------------------------------------------------------------------
    DatasetType='RECO'
    inputFile=${outputFile}
    outputFile=${Dir_store}/${sampleName_toUse}/${ERA}/${DatasetType}_${iSample}.root
    NEvents_toUse=${NEvents} 

    printf "\nprintf '\nRun source ${Dir_sourceCodes}/generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}    '  \n" >> ${MCGenerationScript}
    if [ -f ${outputFile} ] && [ $(stat -c%s ${outputFile}) -gt ${MinFileSize} ]; then
	printf "printf '\nOutput: ${outputFile} already exists!!! ' \n" >> ${MCGenerationScript}
    else
	#printf "time source ${Dir_sourceCodes}/generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}     \n" >> ${MCGenerationScript}
	printf "time . ${Dir_sourceCodes}/generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}     \n" >> ${MCGenerationScript}
    fi

    
    # MiniAODv2 -------------------------------------------------------------------------
    DatasetType='MiniAODv2'
    inputFile=${outputFile}
    outputFile=${Dir_store}/${sampleName_toUse}/${ERA}/${DatasetType}_${iSample}.root
    NEvents_toUse=${NEvents} 

    printf "\nprintf '\nRun source ${Dir_sourceCodes}/generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}    '  \n" >> ${MCGenerationScript}
    if [ -f ${outputFile} ] && [ $(stat -c%s ${outputFile}) -gt ${MinFileSize} ]; then
	printf "printf '\nOutput: ${outputFile} already exists!!! ' \n" >> ${MCGenerationScript}
    else
	#printf "time source ${Dir_sourceCodes}/generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}     \n" >> ${MCGenerationScript}
	printf "time . ${Dir_sourceCodes}/generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}     \n" >> ${MCGenerationScript}
    fi

    
    # NanoAODv9 -------------------------------------------------------------------------
    DatasetType='NanoAODv9'
    inputFile=${outputFile}
    outputFile=${Dir_store}/${sampleName_toUse}/${ERA}/${DatasetType}_${iSample}.root
    NEvents_toUse=${NEvents} 

    printf "\nprintf '\nRun source ${Dir_sourceCodes}/generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}    '  \n" >> ${MCGenerationScript}
    if [ -f ${outputFile} ] && [ $(stat -c%s ${outputFile}) -gt ${MinFileSize} ]; then
	printf "printf '\nOutput: ${outputFile} already exists!!! ' \n" >> ${MCGenerationScript}
    else
	#printf "time source ${Dir_sourceCodes}/generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}     \n" >> ${MCGenerationScript}
	printf "time . ${Dir_sourceCodes}/generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}     \n" >> ${MCGenerationScript}
    fi

    printf "\nls \n" >> ${MCGenerationScript}

    printf "\n\nsource ${MCGenerationScript}"
    #time source ${MCGenerationScript}
    chmod a+x ${MCGenerationScript}


    if [ $RunningMode != "Condor" ]; then
	time . ${MCGenerationScript}
    else
	# Submit job on HTCondor
	CondorExecScript=${Dir_production}/CondorExec_${jobID}.sh
	CondorSubmitScript=${Dir_production}/CondorSubmit_${jobID}.sh
	CondorLog=${Dir_production}/Condor_${jobID}.log
	CondorOutput=${Dir_production}/Condor_${jobID}.out
	CondorError=${Dir_production}/Condor_${jobID}.error

	printf "\nCondorExecScript: ${CondorExecScript}"
	printf "#!/bin/bash   \n\n" >  ${CondorExecScript}	
	printf "export VO_CMS_SW_DIR=/cvmfs/cms.cern.ch  \n" >> ${CondorExecScript}
	#printf "export SCRAM_ARCH=slc6_amd64_gcc700 \n" >> ${CondorExecScript}
	printf "export SCRAM_ARCH=slc7_amd64_gcc10 \n" >> ${CondorExecScript}
	printf "source /cvmfs/cms.cern.ch/cmsset_default.sh \n" >> ${CondorExecScript}
	printf "export X509_USER_PROXY=/afs/cern.ch/user/s/ssawant/x509up_u108989  \n\n" >> ${CondorExecScript}
	printf "cd ${Dir_production} \n" >> ${CondorExecScript}
	printf "eval \n" >> ${CondorExecScript}
	#printf "time source ${MCGenerationScript} \n\n" >> ${CondorExecScript}
	printf "time . ${MCGenerationScript} \n\n" >> ${CondorExecScript}
	printf "printf \"\n\n${MCGenerationScript} execution completed... \" \n" >> ${CondorExecScript}
	chmod a+x ${CondorExecScript}

	printf "\nCondorSubmitScript: ${CondorSubmitScript}"
	printf "universe = vanilla \n" >  ${CondorSubmitScript}
	printf "executable = ${CondorExecScript}  \n" >>  ${CondorSubmitScript}
	printf "getenv = TRUE \n" >>  ${CondorSubmitScript}
	printf "log = ${CondorLog} \n" >>  ${CondorSubmitScript}
	printf "output = ${CondorOutput} \n" >>  ${CondorSubmitScript}
	printf "error = ${CondorError} \n" >>  ${CondorSubmitScript}
	printf "notification = never \n" >>  ${CondorSubmitScript}
	printf "should_transfer_files = YES \n" >>  ${CondorSubmitScript}
	printf "when_to_transfer_output = ON_EXIT \n" >>  ${CondorSubmitScript}
	printf "+JobFlavour = \"workday\" \n" >>  ${CondorSubmitScript}
	printf "queue \n" >>  ${CondorSubmitScript}
	printf "\n" >>  ${CondorSubmitScript}
	chmod a+x ${CondorSubmitScript}

	printf "\ncondor_submit ${CondorSubmitScript}\n"
	condor_submit ${CondorSubmitScript}
    fi
    
   


done
