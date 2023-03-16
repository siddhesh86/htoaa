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
Dir_logs='/afs/cern.ch/work/s/ssawant/private/htoaa/MCGeneration/tmp8' # without '/' in the end
Dir_production=${Dir_logs}  
Dir_store='/eos/cms/store/user/ssawant/mc'  # ${Dir_production}

HiggsPtMin=350 # 150 250 350
sampleTag='mH-70_mA-12_wH-70_wA-70' 
MadgraphCardName="SUSY_GluGluH_01J_HToAATo4B_Pt${HiggsPtMin}_${sampleTag}"
sampleName="SUSY_GluGluH_01J_HToAATo4B_Pt${HiggsPtMin}_${sampleTag}_TuneCP5_13TeV_madgraph_pythia8"
ERA='RunIISummer20UL18'

#Dir_MadgraphPkg_afs='/afs/cern.ch/work/s/ssawant/private/htoaa/MCproduction/HToAATo4B/MCGridpacks/genproductions/bin/MadGraph5_aMCatNLO'
#Dir_MadgraphCards='cards/production/13TeV/HToAATo4B' # without '/' in the end
MadgraphGridpackSample='/eos/cms/store/user/ssawant/mc/SUSY_GluGluH_01J_HToAATo4B_mH-70_mA-12_wH-70_wA-70_0_slc7_amd64_gcc10_CMSSW_12_4_8_tarball.tar.xz'


SampleNumber_First=0 #2
SampleNumber_Last=149 #99 #99 
NEvents_0=${NEvents}
# 150:
# 2 - 206

# 250:
# 2 - 99

# 350:
# 2 - 149

RunningMode="Condor"  # "Condor", "local"

MinFileSize=1000000 # 1 MB
MinFileSize_NanoAOD=0    # 100 events:  3127381 ( 3 MB)  3000000.  200 events:  3417131  (3.3 MB)  3300000
MinFileSize_MiniAOD=0   # 100 events: 11178117 (11 MB) 11000000.  200 events: 20442773  (20 MB)  19000000

MinFileSize_NanoAOD_nEvents100=3000000
MinFileSize_MiniAOD_nEvents100=11000000

MinFileSize_NanoAOD_nEvents200=3300000
MinFileSize_MiniAOD_nEvents200=19000000

MinFileSize_NanoAOD_nEvents300=3500000
MinFileSize_MiniAOD_nEvents300=28000000

MinFileSize_NanoAOD_nEvents400=3700000
MinFileSize_MiniAOD_nEvents400=37000000

MinFileSize_NanoAOD_nEvents500=4100000
MinFileSize_MiniAOD_nEvents500=48000000
##--------------------------------------------------------------------------------------------------------
NEventsAll=-1

# run Madgraph: /afs/cern.ch/work/s/ssawant/private/htoaa/MCproduction/HToAATo4B/MCGridpacks/genproductions/bin/MadGraph5_aMCatNLO
# 

echo "Dir_sourceCodes: ${Dir_sourceCodes} "
echo "Dir_production: ${Dir_production} "

Dir_production_0=${Dir_production}
Dir_logs_0=${Dir_logs}

if [ ! -d ${Dir_production} ]
then
    mkdir -p ${Dir_production}    
fi

if [ ! -d ${Dir_store} ]
then
    mkdir -p ${Dir_store}    
fi

if [ ! -d ${Dir_logs} ]
then
    mkdir -p ${Dir_logs}    
fi

#for i in 1
#for iSample in {${SampleNumber_First}..${SampleNumber_Last}}
for (( iSample=${SampleNumber_First}; iSample<=${SampleNumber_Last}; iSample++ ))
do
    printf "\niSample: ${iSample} \n"
    #break
    #continue
    Dir_MadgraphPkg="*-*"

    RandomNumberSeed=$(bc -l <<<"scale=0; ($HiggsPtMin * 100000) + $iSample ")
    
    GENLevelEfficiency=$(bc -l <<< '0.0250' )
    if   [ ${HiggsPtMin} -eq 150 ]; then
	GENLevelEfficiency=$(bc -l <<< '0.0250' )
    elif [ ${HiggsPtMin} -eq 250 ]; then
	GENLevelEfficiency=$(bc -l <<< '0.0077' )
    elif [ ${HiggsPtMin} -eq 350 ]; then
	GENLevelEfficiency=$(bc -l <<< '0.0030' )
    fi
	

    NEvents_wmLHE=4000 
    if [ ${iSample} -le 99999 ]; then
	NEvents=100
    #elif [[(${iSample} -ge 3000 && ${iSample} -le 3099)]]; then
    fi

    if [ ${HiggsPtMin} -eq 350 ]; then
	if [ ${iSample} -le 99999 ]; then
	    NEvents=40
	fi	
    fi

    NEvents_wmLHE=$(bc -l <<<"scale=0; $NEvents / $GENLevelEfficiency")
    
    Dir_MadgraphPkg=${Dir_MadgraphPkg_afs}
    Dir_production_0=${Dir_logs_0}
    
    
    if   [ ${NEvents} -eq 100  ]; then
	MinFileSize_NanoAOD=${MinFileSize_NanoAOD_nEvents100}
	MinFileSize_MiniAOD=${MinFileSize_MiniAOD_nEvents100}
    elif [ ${NEvents} -eq 200  ]; then
	MinFileSize_NanoAOD=${MinFileSize_NanoAOD_nEvents200}
	MinFileSize_MiniAOD=${MinFileSize_MiniAOD_nEvents200}    
    elif [ ${NEvents} -eq 300  ]; then
	MinFileSize_NanoAOD=${MinFileSize_NanoAOD_nEvents300}
	MinFileSize_MiniAOD=${MinFileSize_MiniAOD_nEvents300}    
    elif [ ${NEvents} -eq 400  ]; then
	MinFileSize_NanoAOD=${MinFileSize_NanoAOD_nEvents400}
	MinFileSize_MiniAOD=${MinFileSize_MiniAOD_nEvents400}    
    elif [ ${NEvents} -eq 500  ]; then
	MinFileSize_NanoAOD=${MinFileSize_NanoAOD_nEvents500}
	MinFileSize_MiniAOD=${MinFileSize_MiniAOD_nEvents500}
    else
	MinFileSize_NanoAOD=${MinFileSize}
	MinFileSize_MiniAOD=${MinFileSize}	
    fi


   
    
    jobID=${MadgraphCardName}_${iSample}

    MadgraphCardName_toUse=${MadgraphCardName}_${iSample}
    sampleName_toUse=${sampleName}
    Dir_production=${Dir_production_0}/${jobID}
    Dir_logs=${Dir_logs_0}/${jobID}
    
    if [ ! -d ${Dir_production} ]; then
	mkdir -p ${Dir_production}
    fi
    if [ ! -d ${Dir_logs} ]; then
	mkdir -p ${Dir_logs}
    fi

    #gridpackFile=${Dir_store}/${sampleName_toUse}/${ERA}/MadgraphGridpack_${iSample}_slc7_amd64_gcc10_CMSSW_12_4_8_tarball.tar.xz # relocated path
    gridpackFile=${MadgraphGridpackSample}
    wmLHEGENFile=${Dir_store}/${sampleName_toUse}/${ERA}/wmLHEGEN_${iSample}.root
    SIMFile=${Dir_store}/${sampleName_toUse}/${ERA}/SIM_${iSample}.root
    DIGIPremixFile=${Dir_store}/${sampleName_toUse}/${ERA}/DIGIPremix_${iSample}.root
    HLTFile=${Dir_store}/${sampleName_toUse}/${ERA}/HLT_${iSample}.root
    RECOFile=${Dir_store}/${sampleName_toUse}/${ERA}/RECO_${iSample}.root
    MiniAODFile=${Dir_store}/${sampleName_toUse}/${ERA}/MiniAODv2_${iSample}.root
    NanoAODFile=${Dir_store}/${sampleName_toUse}/${ERA}/NanoAODv9_${iSample}.root
    
    sampleChain=(${gridpackFile} ${wmLHEGENFile} ${SIMFile} ${DIGIPremixFile} ${HLTFile} ${RECOFile} ${MiniAODFile} ${NanoAODFile})
    #sampleChain=(${wmLHEGENFile} ${SIMFile} ${DIGIPremixFile} ${HLTFile} ${RECOFile} ${MiniAODFile} ${NanoAODFile})

    filesToDeleteAtEnd="${Dir_production}/CMSSW* ${Dir_production}/*_report.xml ${Dir_store}/${sampleName_toUse}/${ERA}/wmLHEGEN_${iSample}_inLHE.root  ${SIMFile} ${DIGIPremixFile} ${HLTFile} ${RECOFile}  "
    
    # HTCondor job submission files --
    CondorExecScript=${Dir_logs}/CondorExec_${jobID}.sh
    CondorSubmitScript=${Dir_logs}/CondorSubmit_${jobID}.sh
    CondorLog=${Dir_logs}/Condor_${jobID}.log
    CondorOutput=${Dir_logs}/Condor_${jobID}.out
    CondorError=${Dir_logs}/Condor_${jobID}.error
    
    
    cd ${Dir_sourceCodes}
    echo "pwd (MCGeneration_wrapper.sh) 0, iSample ${iSample}"
    pwd

    echo "jobID: ${jobID} "
    #echo "MadgraphCardName_toUse: ${MadgraphCardName_toUse} "
    echo "sampleName_toUse: ${sampleName_toUse}   RandomNumberSeed: ${RandomNumberSeed} "
    printf "NEvents: ${NEvents},  GENLevelEfficiency: ${GENLevelEfficiency},  NEvents_Madgraph: ${NEvents_Madgraph}, NEvents_wmLHE: ${NEvents_wmLHE},   MinFileSize_NanoAOD: ${MinFileSize_NanoAOD},  MinFileSize_MiniAOD: ${MinFileSize_MiniAOD} \n"
    printf " Dir_production: ${Dir_production}, \n Dir_logs: ${Dir_logs} \n"


    

    # If NanoAOD file exists then job ran successfully -------------------------
    #if [ -f ${NanoAODFile} ] && [ $(stat -c%s ${NanoAODFile}) -gt ${MinFileSize} ]; then
    if [ -f ${NanoAODFile} ] && [ $(stat -c%s ${NanoAODFile}) -gt ${MinFileSize_NanoAOD} ] &&  [ -f ${MiniAODFile} ] && [ $(stat -c%s ${MiniAODFile}) -gt ${MinFileSize_MiniAOD} ]; then
	#printf "printf \"\nOutput: ${NanoAODFile} already exists!!! \" \n" >> ${MCGenerationScript}
	printf "Output already exists!!!: \n${MiniAODFile}  (size $(stat -c%s ${MiniAODFile})) \n${NanoAODFile}  (size $(stat -c%s ${NanoAODFile})) \n"
	printf "rm -rf ${filesToDeleteAtEnd} ${Dir_production} \n\n"
	rm -rf ${filesToDeleteAtEnd} ${Dir_production}
	continue
    fi
    # --------------------------------------------------------------------------



    
    # check last sample file produced
    sample_lastGeneratedFile=""
    idx_sample_lastGeneratedFile=-1
    for iSampleStep in ${!sampleChain[@]}; do
	#printf "iSampleStep : ${iSampleStep} \n"
	if [ -f ${sampleChain[$iSampleStep]} ] && [ $(stat -c%s ${sampleChain[$iSampleStep]}) -gt ${MinFileSize} ]; then
	    idx_sample_lastGeneratedFile=${iSampleStep}
	    sample_lastGeneratedFile=${sampleChain[$iSampleStep]}	    
	fi
    done
    if [[ ! -z ${sample_lastGeneratedFile} ]]; then
	printf " \t sample_lastGeneratedFile[${idx_sample_lastGeneratedFile}]: ${sampleChain[$idx_sample_lastGeneratedFile]}  (size $(stat -c%s ${sample_lastGeneratedFile})) \n"
    fi
    
    # check whether the status of submitted HTCondor job -----------------------
    if [ $RunningMode == "Condor" ]; then
	isJobRunning=0

	if [ -f ${CondorLog} ]; then
	    # Check last 2 lines of log file
	    if  tail -n 2 ${CondorLog} | grep -q "Job terminated"; then
		# Job terminated of its own accord at 2023-01-31T11:55:43Z.
		isJobRunning=0


		# Input file at any step is currupt: delete ${sample_lastGeneratedFile} ---
		# file ///eos/cms/store/user/ssawant/mc/SUSY_GluGluH_01J_HToAATo4B_Pt150_mH-70_mA-12_wH-70_wA-70_TuneCP5_13TeV_madgraph_pythia8/RunIISummer20UL18/SIM_226.root probably not closed, trying to recover
		condition_1_1=$(tail -n 3 ${CondorError} | grep  "probably not closed, trying to recover")
		# [a] Input file file:/eos/cms/store/user/ssawant/mc/SUSY_GluGluH_01J_HToAATo4B_Pt150_mH-70_mA-12_wH-70_wA-70_TuneCP5_13TeV_madgraph_pythia8/RunIISummer20UL18/HLT_985.root could not be opened.
		condition_1_2=$(tail -n 3 ${CondorError} | grep  "could not be opened.")
		# This is either not an edm ROOT file or is one that has been corrupted. 
		condition_1_3=$(tail -n 3 ${CondorError} | grep  "not an edm ROOT file")
		# An exception of category 'ExternalLHEProducer' occurred while
		condition_1_4=$(tail -n 200 ${CondorError} | grep  "An exception of category 'ExternalLHEProducer'")
		# what():  An exception of category 'FileFlushError' occurred while
		condition_1_5=$(tail -n 200 ${CondorError} | grep  "'FileFlushError'")
		condition_1_6=$(tail -n 200 ${CondorError} | grep  "'FileReadError'" )
		condition_1_7=$(tail -n 200 ${CondorError} | grep  "End Fatal Exception" )		
		
		if [[ ! -z ${condition_1_1} ]] || [[ ! -z ${condition_1_2} ]] || [[ ! -z ${condition_1_3} ]] || [[ ! -z ${condition_1_4} ]] || [[ ! -z ${condition_1_5} ]] || [[ ! -z ${condition_1_6} ]] || [[ ! -z ${condition_1_7} ]]; then
		    condition_2_1=$(tail -n 3 ${CondorError} | grep  "${sample_lastGeneratedFile}")
		    condition_2_2=$(tail -n 200 ${CondorError} | grep  "End Fatal Exception" )

		    printf "condition_1_1: >>${condition_1_1}<< \n"
		    printf "condition_1_2: >>${condition_1_2}<< \n"
		    printf "condition_1_3: >>${condition_1_3}<< \n"
		    printf "condition_1_4: >>${condition_1_4}<< \n"
		    printf "condition_1_5: >>${condition_1_5}<< \n"
		    printf "condition_1_6: >>${condition_1_6}<< \n"
		    printf "condition_1_7: >>${condition_1_7}<< \n"
 		    if [[ ! -z ${condition_2_1} ]] || [[ ! -z ${condition_2_2} ]]; then
			printf "\ncondition_2_1: >>${condition_2_1}<< \n"
			printf "condition_2_2: >>${condition_2_2}<< \n"
			# delete last produced sample as the file might be currupt
			if [[ "${sample_lastGeneratedFile}" != "${gridpackFile}" ]]; then
			    printf "\n ERROR: Input file seems currupt... \t Deleting the last produced sample file ${sample_lastGeneratedFile} (size $(stat -c%s ${sample_lastGeneratedFile})). \n"
			    printf "sample_lastGeneratedFile: ${sample_lastGeneratedFile} \ngridpackFile: ${gridpackFile} \n"
			    rm ${sample_lastGeneratedFile}
			fi
		    fi
		fi
		    
	    elif tail -n 2 ${CondorLog} | grep -q "Job removed"; then
		# Job removed by SYSTEM_PERIODIC_REMOVE due to wall time exceeded allowed max.
		isJobRunning=0

		# delete last produced sample as the file might be currupt
		printf "\n ERROR: 'Job removed by SYSTEM_PERIODIC_REMOVE'. \t Deleting the last produced sample file ${sample_lastGeneratedFile} (size $(stat -c%s ${sample_lastGeneratedFile})). \n"
		rm ${sample_lastGeneratedFile}

	    elif tail -n 2 ${CondorLog} | grep -q "condor_rm"; then
		# Job was removed by condor_rm command:
		# 09 (645228.000.000) 02/09 11:58:21 Job was aborted.
		# via condor_rm (by user ssawant)
		isJobRunning=0
	    else
		isJobRunning=1
	    fi

	    if [[ $isJobRunning -eq 1 ]]; then
		printf "isJobRunning: ${isJobRunning}. \t\t Job ${iSample} is already running.. \n"
		continue
	    fi
	    printf "isJobRunning: ${isJobRunning}. \t\t Job ${iSample} is NOT running. Resubmit condor job.. \n"	    
	fi
    fi
    # --------------------------------------------------------------------------

    if [ ! -d ${Dir_store}/${sampleName_toUse}/${ERA} ]; then
	mkdir -p ${Dir_store}/${sampleName_toUse}/${ERA}
    fi
    
    
    MCGenerationScript=${Dir_production}/MCGenerationScript_${jobID}.sh
    filesToDeleteAtEnd="${Dir_production}/*_report.xml"
    runJob=0

    echo "MCGenerationScript: ${MCGenerationScript} "
    printf "#!/bin/bash \n\n" > ${MCGenerationScript}
    printf "cd ${Dir_production} \n\n" >> ${MCGenerationScript}



    printf "cd ${Dir_production} \n\n" >> ${MCGenerationScript}

    # wmLHEGEN -------------------------------------------------------------------------
    DatasetType='wmLHEGEN'
    inputFile=${gridpackFile} # 'input.root'
    #outputDir=${Dir_store}/${sampleName_toUse}/${ERA}/${DatasetType}
    outputFile=${wmLHEGENFile}  # ${Dir_store}/${sampleName_toUse}/${ERA}/${DatasetType}_${iSample}.root
    #NEvents_toUse=$((NEvents / GENLevelEfficiency))
    #NEvents_toUse=$(bc -l <<<"scale=0; $NEvents / $GENLevelEfficiency")
    NEvents_toUse=${NEvents_wmLHE}
    filesToDeleteAtEnd="${filesToDeleteAtEnd}  ${Dir_store}/${sampleName_toUse}/${ERA}/${DatasetType}_${iSample}_inLHE.root"

    printf "\nprintf \"\\\nRun source ${Dir_sourceCodes}/generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}  ${Dir_sourceCodes}   ${RandomNumberSeed}  ${HiggsPtMin} \\\n \"  \n" >> ${MCGenerationScript}
    if [ -f ${outputFile} ] && [ $(stat -c%s ${outputFile}) -gt ${MinFileSize} ]; then
	printf "printf '\nOutput: ${outputFile} already exists!!! ' \n" >> ${MCGenerationScript}
    else
	runJob=1
	printf "rm -rf ${Dir_production}/CMSSW* ${Dir_production}/lheevent \n" >> ${MCGenerationScript}
	
	#printf "time source ${Dir_sourceCodes}/generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}  ${Dir_sourceCodes}   \n" >> ${MCGenerationScript} RandomNumberSeed 
	printf "time . ${Dir_sourceCodes}/generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}  ${Dir_sourceCodes}   ${RandomNumberSeed}  ${HiggsPtMin}  \n" >> ${MCGenerationScript}

	printf "\nprintf \"\\\n***Done source ${Dir_sourceCodes}/generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}  ${Dir_sourceCodes}  ${RandomNumberSeed}  ${HiggsPtMin}  \"  \n" >> ${MCGenerationScript}
	printf "printf \"rm -rf ${Dir_production}/CMSSW*  ${Dir_production}/lheevent \\\n \" \n" >> ${MCGenerationScript}
	printf "rm -rf ${Dir_production}/CMSSW*  ${Dir_production}/lheevent \n" >> ${MCGenerationScript}	
    fi
    

    # SIM -------------------------------------------------------------------------
    DatasetType='SIM'
    inputFile=${wmLHEGENFile}
    outputFile=${SIMFile}  # ${Dir_store}/${sampleName_toUse}/${ERA}/${DatasetType}_${iSample}.root
    #NEvents_toUse=${NEvents}
    NEvents_toUse=${NEventsAll}
    filesToDeleteAtEnd="${filesToDeleteAtEnd}  ${outputFile}"

    printf "\nprintf \"\\\nRun source ${Dir_sourceCodes}/generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}    \"  \n" >> ${MCGenerationScript}
    if [ -f ${outputFile} ] && [ $(stat -c%s ${outputFile}) -gt ${MinFileSize} ]; then
	printf "printf '\nOutput: ${outputFile} already exists!!! ' \n" >> ${MCGenerationScript}
    else
	runJob=1
	printf "rm -rf ${Dir_production}/CMSSW*  \n" >> ${MCGenerationScript}
	
	#printf "time source ${Dir_sourceCodes}/generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}     \n" >> ${MCGenerationScript}
	printf "time . ${Dir_sourceCodes}/generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}     \n" >> ${MCGenerationScript}

	printf "\nprintf \"\\\n***Done source ${Dir_sourceCodes}/generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}  ${Dir_sourceCodes}  \"  \n" >> ${MCGenerationScript}
	printf "printf \"rm -rf ${Dir_production}/CMSSW*   \\\n \" \n" >> ${MCGenerationScript}
	printf "rm -rf ${Dir_production}/CMSSW*   \n" >> ${MCGenerationScript}	
    fi
    

    # DIGIPremix -------------------------------------------------------------------------
    DatasetType='DIGIPremix'
    inputFile=${SIMFile}
    outputFile=${DIGIPremixFile}  # ${Dir_store}/${sampleName_toUse}/${ERA}/${DatasetType}_${iSample}.root
    #NEvents_toUse=${NEvents} 
    NEvents_toUse=${NEventsAll}
    filesToDeleteAtEnd="${filesToDeleteAtEnd}  ${outputFile}"

    printf "\nprintf \"\\\nRun source ${Dir_sourceCodes}/generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}    \"  \n" >> ${MCGenerationScript}
    if [ -f ${outputFile} ] && [ $(stat -c%s ${outputFile}) -gt ${MinFileSize} ]; then
	printf "printf '\nOutput: ${outputFile} already exists!!! ' \n" >> ${MCGenerationScript}
    else
	runJob=1
	printf "rm -rf ${Dir_production}/CMSSW*  \n" >> ${MCGenerationScript}
	
	#printf "time source ${Dir_sourceCodes}/generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}     \n" >> ${MCGenerationScript}
	printf "time . ${Dir_sourceCodes}/generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}     \n" >> ${MCGenerationScript}

	printf "\nprintf \"\\\n***Done source ${Dir_sourceCodes}/generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}  ${Dir_sourceCodes}  \"  \n" >> ${MCGenerationScript}
	printf "printf \"rm -rf ${Dir_production}/CMSSW*   \\\n \" \n" >> ${MCGenerationScript}
	printf "rm -rf ${Dir_production}/CMSSW*   \n" >> ${MCGenerationScript}	
    fi
    
	
    # HLT -------------------------------------------------------------------------
    DatasetType='HLT'
    inputFile=${DIGIPremixFile}
    outputFile=${HLTFile}  # ${Dir_store}/${sampleName_toUse}/${ERA}/${DatasetType}_${iSample}.root
    #NEvents_toUse=${NEvents} 
    NEvents_toUse=${NEventsAll}
    filesToDeleteAtEnd="${filesToDeleteAtEnd}  ${outputFile}"

    printf "\nprintf \"\\\nRun source ${Dir_sourceCodes}/generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}    \"  \n" >> ${MCGenerationScript}
    if [ -f ${outputFile} ] && [ $(stat -c%s ${outputFile}) -gt ${MinFileSize} ]; then
	printf "printf '\nOutput: ${outputFile} already exists!!! ' \n" >> ${MCGenerationScript}
    else
	runJob=1
	printf "rm -rf ${Dir_production}/CMSSW*  \n" >> ${MCGenerationScript}
	
	#printf "time source ${Dir_sourceCodes}/generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}     \n" >> ${MCGenerationScript}
	printf "time . ${Dir_sourceCodes}/generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}     \n" >> ${MCGenerationScript}

	printf "\nprintf \"\\\n***Done source ${Dir_sourceCodes}/generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}  ${Dir_sourceCodes}  \"  \n" >> ${MCGenerationScript}
	printf "printf \"rm -rf ${Dir_production}/CMSSW*   \\\n \" \n" >> ${MCGenerationScript}
	printf "rm -rf ${Dir_production}/CMSSW*   \n" >> ${MCGenerationScript}	
    fi

    
    # RECO -------------------------------------------------------------------------
    DatasetType='RECO'
    inputFile=${HLTFile}
    outputFile=${RECOFile}  # ${Dir_store}/${sampleName_toUse}/${ERA}/${DatasetType}_${iSample}.root
    #NEvents_toUse=${NEvents} 
    NEvents_toUse=${NEventsAll}
    filesToDeleteAtEnd="${filesToDeleteAtEnd}  ${outputFile}"

    printf "\nprintf \"\nRun source ${Dir_sourceCodes}/generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}    \"  \n" >> ${MCGenerationScript}
    if [ -f ${outputFile} ] && [ $(stat -c%s ${outputFile}) -gt ${MinFileSize} ]; then
	printf "printf '\nOutput: ${outputFile} already exists!!! ' \n" >> ${MCGenerationScript}
    else
	runJob=1
	printf "rm -rf ${Dir_production}/CMSSW*  \n" >> ${MCGenerationScript}
	
	#printf "time source ${Dir_sourceCodes}/generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}     \n" >> ${MCGenerationScript}
	printf "time . ${Dir_sourceCodes}/generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}     \n" >> ${MCGenerationScript}

	printf "\nprintf \"\\\n***Done source ${Dir_sourceCodes}/generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}  ${Dir_sourceCodes}  \"  \n" >> ${MCGenerationScript}
	printf "printf \"rm -rf ${Dir_production}/CMSSW*   \\\n \" \n" >> ${MCGenerationScript}
	printf "rm -rf ${Dir_production}/CMSSW*   \n" >> ${MCGenerationScript}	
    fi

    
    # MiniAODv2 -------------------------------------------------------------------------
    DatasetType='MiniAODv2'
    inputFile=${RECOFile}
    outputFile=${MiniAODFile}  # ${Dir_store}/${sampleName_toUse}/${ERA}/${DatasetType}_${iSample}.root
    #NEvents_toUse=${NEvents} 
    NEvents_toUse=${NEventsAll} 

    printf "\nprintf \"\nRun source ${Dir_sourceCodes}/generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}    \"  \n" >> ${MCGenerationScript}
    if [ -f ${outputFile} ] && [ $(stat -c%s ${outputFile}) -gt ${MinFileSize} ]; then
	printf "printf '\nOutput: ${outputFile} already exists!!! ' \n" >> ${MCGenerationScript}
    else
	runJob=1
	printf "rm -rf ${Dir_production}/CMSSW*  \n" >> ${MCGenerationScript}
	
	#printf "time source ${Dir_sourceCodes}/generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}     \n" >> ${MCGenerationScript}
	printf "time . ${Dir_sourceCodes}/generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}     \n" >> ${MCGenerationScript}

	printf "\nprintf \"\\\n***Done source ${Dir_sourceCodes}/generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}  ${Dir_sourceCodes}  \"  \n" >> ${MCGenerationScript}
	printf "printf \"rm -rf ${Dir_production}/CMSSW*   \\\n \" \n" >> ${MCGenerationScript}
	printf "rm -rf ${Dir_production}/CMSSW*   \n" >> ${MCGenerationScript}	
    fi

    
    # NanoAODv9 -------------------------------------------------------------------------
    DatasetType='NanoAODv9'
    inputFile=${MiniAODFile}
    outputFile=${NanoAODFile}  # ${Dir_store}/${sampleName_toUse}/${ERA}/${DatasetType}_${iSample}.root
    #NEvents_toUse=${NEvents} 
    NEvents_toUse=${NEventsAll} 

    printf "\nprintf \"\nRun source ${Dir_sourceCodes}/generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}    \"  \n" >> ${MCGenerationScript}
    if [ -f ${outputFile} ] && [ $(stat -c%s ${outputFile}) -gt ${MinFileSize} ]; then
	printf "printf '\nOutput: ${outputFile} already exists!!! ' \n" >> ${MCGenerationScript}
    else
	runJob=1
	printf "rm -rf ${Dir_production}/CMSSW*  \n" >> ${MCGenerationScript}
	
	#printf "time source ${Dir_sourceCodes}/generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}     \n" >> ${MCGenerationScript}
	printf "time . ${Dir_sourceCodes}/generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}     \n" >> ${MCGenerationScript}

	printf "\nprintf \"\\\n***Done source ${Dir_sourceCodes}/generate_${ERA}${DatasetType}.sh  ${inputFile}  ${outputFile}  ${NEvents_toUse}  ${jobID}  ${Dir_sourceCodes}  \"  \n" >> ${MCGenerationScript}
	printf "printf \"rm -rf ${Dir_production}/CMSSW*   \\\n \" \n" >> ${MCGenerationScript}
	printf "rm -rf ${Dir_production}/CMSSW*   \n" >> ${MCGenerationScript}

	printf "printf \"rm -rf ${filesToDeleteAtEnd}   \\\n \" \n" >> ${MCGenerationScript}
	printf "rm -rf ${filesToDeleteAtEnd}   \n" >> ${MCGenerationScript}

	printf "\nprintf \"\\\n***Done ALL ********************  \"  \n" >> ${MCGenerationScript}
    fi

    printf "\nls \n" >> ${MCGenerationScript}

    printf "\n\nsource ${MCGenerationScript}\n"
    #time source ${MCGenerationScript}
    chmod a+x ${MCGenerationScript}

    # HTCondor files ----------------------------------------------------------------------------    
    printf "CondorExecScript: ${CondorExecScript}\n"
    printf "#!/bin/bash   \n\n" >  ${CondorExecScript}	
    printf "export VO_CMS_SW_DIR=/cvmfs/cms.cern.ch  \n" >> ${CondorExecScript}
    #printf "export SCRAM_ARCH=slc6_amd64_gcc700 \n" >> ${CondorExecScript}
    printf "export SCRAM_ARCH=slc7_amd64_gcc10 \n" >> ${CondorExecScript}
    printf "source /cvmfs/cms.cern.ch/cmsset_default.sh \n" >> ${CondorExecScript}
    printf "export X509_USER_PROXY=/afs/cern.ch/user/s/ssawant/x509up_u108989  \n\n" >> ${CondorExecScript}
    printf "export X509_USER_PROXY=\$1 \n" >> ${CondorExecScript}
    printf "export EOS_MGM_URL=root://eoscms.cern.ch \n" >> ${CondorExecScript}
    printf "voms-proxy-info -all \n" >> ${CondorExecScript}
    printf "voms-proxy-info -all -file \$1 \n" >> ${CondorExecScript}

    printf "cd ${Dir_production} \n" >> ${CondorExecScript}
    printf "eval \n" >> ${CondorExecScript}
    printf "printf \" tokens: \\\n \"  \n" >> ${CondorExecScript}
    printf "tokens  \n" >> ${CondorExecScript}
    printf "printf \" klist -f: \\\n \"  \n" >> ${CondorExecScript}
    printf "klist -f  \n" >> ${CondorExecScript}
    #printf "time source ${MCGenerationScript} \n\n" >> ${CondorExecScript}
    printf "time . ${MCGenerationScript} \n\n" >> ${CondorExecScript}
    printf "printf \"\\\n\\\n${MCGenerationScript} execution completed... \" \n" >> ${CondorExecScript}
    chmod a+x ${CondorExecScript}

    # HTCondor JobFlavor
    # espresso     = 20 minutes
    # microcentury = 1 hour
    # longlunch    = 2 hours
    # workday      = 8 hours
    # tomorrow     = 1 day
    # testmatch    = 3 days
    # nextweek     = 1 week

    # job run time for different steps
    # Madgraph	        real	112m21.326s	2hr
    # wmLHE		real	254m29.866s	4hr
    # SIM		real	72m44.071s	1hr
    # DIGI		real	11m56.162s	
    # HLT		real	6m24.796s
    # RECO		real	21m11.963s
    # MiniAOD 	        real	5m0.712s
    # Total time: 4 + 4 + 1.5 + 1 = 11 hr

    # 200 event job
    # Madgraph	        real	131m43.877s	2hr 20m
    # wmLHE		real	357m27.488s	6hr
    # SIM		real	141m46.958s	2hr 30m
    # DIGI		real	14m22.956s	20m
    # HLT		real	11m2.017s	20m
    # Reco		real	39m23.552s	1hr
    # MiniAOD		real	5m5.146s	10m
    # Total time: 2.5 + 6 + 3 + 1 + 1 + 0.5 = 14 hr

    # 300 event job
    # Madgraph          real	18m34.003s      2 hr 30m
    # wmLHE             real	403m33.500s     7 hr
    # SIM               real	118m52.933s     3 hr
    # Digi              real	17m28.732s      30min
    # HLT               real	8m40.763s       15 min
    # Reco              real	34m58.526s      1 hr
    # MiniAOD           real	5m21.839s       30 min
    # NanoAOD                                   15 min
    # Total time: 2.5 + 7 + 3 + 1 + 1 + 1 = 16 hr

    # 300 event job with 300*effi Madgraph events
    # Madgraph          real    85m13.071s     2 hr 30m
    # wmLHE             real    475m39.493s    9 hr
    # SIM               real    131m42.487s    3 hr
    # Digi              real    20m31.491s     30 m
    # HLT               real    10m39.125s     15 m
    # Reco              real    43m39.736s     1 he
    # MiniAOD           real    7m13.081s      30m
    # Total time: 2.5 + 9 + 3 + 1 + 1 + 1 = 18 hr

    
    printf "CondorSubmitScript: ${CondorSubmitScript} \n"
    printf "universe = vanilla \n" >  ${CondorSubmitScript}
    printf "X509_USER_PROXY=/afs/cern.ch/user/s/ssawant/x509up_u108989 \n" >>  ${CondorSubmitScript}
    printf "arguments = \$(X509_USER_PROXY) \n" >>  ${CondorSubmitScript}
    printf "executable = ${CondorExecScript}  \n" >>  ${CondorSubmitScript}
    printf "getenv = TRUE \n" >>  ${CondorSubmitScript}
    printf "log = ${CondorLog} \n" >>  ${CondorSubmitScript}
    printf "output = ${CondorOutput} \n" >>  ${CondorSubmitScript}
    printf "error = ${CondorError} \n" >>  ${CondorSubmitScript}
    printf "notification = never \n" >>  ${CondorSubmitScript}
    #printf "should_transfer_files = YES \n" >>  ${CondorSubmitScript}
    printf "should_transfer_files = IF_NEEDED \n" >>  ${CondorSubmitScript}
    printf "when_to_transfer_output = ON_EXIT \n" >>  ${CondorSubmitScript}
    #printf "+JobFlavour = \"workday\" \n" >>  ${CondorSubmitScript}
    #printf "+MaxRuntime = jobRunTime  \n" >>  ${CondorSubmitScript}
    #printf "+JobFlavour = \"${jobFlavour}\" \n" >>  ${CondorSubmitScript}
    
    jobRunTimeInHr=30
    jobFlavour="tomorrow"
    
    if [ ${NEvents} -le 401  ]; then
	jobFlavour="tomorrow"
	if [[ $idx_sample_lastGeneratedFile -eq 1 ]]; then
	    # last  GeneratedFile is wmLHE 
	    jobFlavour="workday"
	elif  [[ $idx_sample_lastGeneratedFile -ge 2 ]]; then
	    # last  GeneratedFile is SIM or next ones
	    jobFlavour="longlunch"
	fi
	printf "+JobFlavour = \"${jobFlavour}\" \n" >>  ${CondorSubmitScript}
	
    elif [ ${NEvents} -le 601  ]; then
	if   [[ $idx_sample_lastGeneratedFile -eq -1 ]]; then
	    # no file is generated
	    jobRunTimeInHr=30
	elif  [[ $idx_sample_lastGeneratedFile -eq 0 ]]; then
	    # last  GeneratedFile is Madgraph 
	    jobRunTimeInHr=24
	elif  [[ $idx_sample_lastGeneratedFile -eq 1 ]]; then
	    # last  GeneratedFile is wmLHE 
	    jobRunTimeInHr=10
	elif  [[ $idx_sample_lastGeneratedFile -ge 2 ]]; then
	    # last  GeneratedFile is SIM or next ones
	    jobRunTimeInHr=8
	elif  [[ $idx_sample_lastGeneratedFile -ge 5 ]]; then
	    # last  GeneratedFile is RECO or next ones
	    jobRunTimeInHr=2
	fi
	jobRunTime=$(( ${jobRunTimeInHr} * 60 * 60 ))
	printf "jobRunTime: ${jobRunTime} (${jobRunTimeInHr} hr) \n"
	printf "+MaxRuntime = ${jobRunTime}  \n" >>  ${CondorSubmitScript}
    fi

    # By default, a job will get one slot of a CPU core, 2gb of memory and 20gb of disk space. Memory: 2gb / core limit
    if  [[ $idx_sample_lastGeneratedFile -le 1 ]]; then
	printf "RequestCpus = 2 \n" >>  ${CondorSubmitScript}
    fi

    #printf "output_destination = root://eosuser.cern.ch//eos/user/b/bejones/condor/xfer/$(ClusterId)/ \n" >>  ${CondorSubmitScript}
    #printf "output_destination = root://eosuser.cern.ch/${Dir_store}/${sampleName_toUse}/${ERA}/  \n" >>  ${CondorSubmitScript}
    #printf "MY.XRDCP_CREATE_DIR = True \n" >>  ${CondorSubmitScript}
    
    printf "queue \n" >>  ${CondorSubmitScript}
    printf "\n" >>  ${CondorSubmitScript}
    chmod a+x ${CondorSubmitScript}
    # -------------------------------------------------------------------------------------------
    

    if [[ $runJob -eq 0 ]]; then
	printf "printf \"\\\n \\\n Nothing to run. All output files exists.   \\\n \" \n" >> ${MCGenerationScript}
    else
	if [ $RunningMode != "Condor" ]; then
	    #time . ${MCGenerationScript}
	    time . ${CondorExecScript}
	else
	    # Submit job on HTCondor
	    printf "condor_submit ${CondorSubmitScript}\n"
	    condor_submit ${CondorSubmitScript}
	fi
    fi
    
   


done
