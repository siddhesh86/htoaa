#!/bin/bash

######################################################################################
# Script to generate NanoAODv9 sample sourced from
# https://cms-pdmv.cern.ch/mcm/public/restapi/requests/get_test/HIG-RunIISummer20UL18NanoAODv9-02157
######################################################################################


inputFile=${1}
outputFile=${2}
nEvents=${3}
jobID=${4}


jobName="SUSY_GluGluH_01J_HToAATo4B_${jobID}_RunIISummer20UL18NanoAODv9"

outputDir=$(echo ${outputFile} | sed 's|\(.*\)/.*|\1|')

printf "\n\ngenerate_RunIISummer20ULNanoAODv9.sh:: \nArguments: $@ \n"
echo "inputFile: ${inputFile} "
echo "outputDir: ${outputDir} "
echo "outputFile: ${outputFile}"
echo "nEvents: ${nEvents}"
echo "jobName: ${jobName} "

pwd_=$(pwd)

echo 'pwd: '
pwd


export SCRAM_ARCH=slc7_amd64_gcc700

source /cvmfs/cms.cern.ch/cmsset_default.sh
if [ -r CMSSW_10_6_26/src ] ; then
  echo release CMSSW_10_6_26 already exists
else
  scram p CMSSW CMSSW_10_6_26
fi
cd CMSSW_10_6_26/src
eval `scram runtime -sh`

scram b
cd ../..

# Maximum validation duration: 28800s
# Margin for validation duration: 30%
# Validation duration with margin: 28800 * (1 - 0.30) = 20160s
# Time per event for each sequence: 0.4300s
# Threads for each sequence: 2
# Time per event for single thread for each sequence: 2 * 0.4300s = 0.8600s
# Which adds up to 0.8600s per event
# Single core events that fit in validation duration: 20160s / 0.8600s = 23441
# Produced events limit in McM is 10000
# According to 1.0000 efficiency, validation should run 10000 / 1.0000 = 10000 events to reach the limit of 10000
# Take the minimum of 23441 and 10000, but more than 0 -> 10000
# It is estimated that this validation will produce: 10000 * 1.0000 = 10000 events
#EVENTS=10000
EVENTS=${nEvents}

if [ ! -d ${outputDir} ]
then
   mkdir -p ${outputDir}
fi


# cmsDriver command
# cmsDriver.py  --python_filename HIG-RunIISummer20UL18NanoAODv9-02157_1_cfg.py --eventcontent NANOEDMAODSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier NANOAODSIM --fileout file:HIG-RunIISummer20UL18NanoAODv9-02157.root --conditions 106X_upgrade2018_realistic_v16_L1v1 --step NANO --filein "dbs:/SUSY_GluGluH_01J_HToAATo4B_Pt150_M-12_TuneCP5_13TeV_madgraph_pythia8/RunIISummer20UL18MiniAODv2-106X_upgrade2018_realistic_v16_L1v1-v1/MINIAODSIM" --era Run2_2018,run2_nanoAOD_106Xv2 --no_exec --mc -n $EVENTS || exit $? ;

cmsDriver.py  --python_filename ${jobName}_1_cfg.py --eventcontent NANOEDMAODSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier NANOAODSIM --fileout file:${outputFile} --conditions 106X_upgrade2018_realistic_v16_L1v1 --step NANO --filein file:${inputFile}  --era Run2_2018,run2_nanoAOD_106Xv2 --no_exec --mc -n $EVENTS || exit $? ;

# Run generated config
REPORT_NAME=${jobName}_report.xml
# Run the cmsRun
cmsRun -e -j $REPORT_NAME ${jobName}_1_cfg.py || exit $? ;

# Parse values from ${jobName}_report.xml report
processedEvents=$(grep -Po "(?<=<Metric Name=\"NumberEvents\" Value=\")(.*)(?=\"/>)" $REPORT_NAME | tail -n 1)
producedEvents=$(grep -Po "(?<=<TotalEvents>)(\d*)(?=</TotalEvents>)" $REPORT_NAME | tail -n 1)
threads=$(grep -Po "(?<=<Metric Name=\"NumberOfThreads\" Value=\")(.*)(?=\"/>)" $REPORT_NAME | tail -n 1)
peakValueRss=$(grep -Po "(?<=<Metric Name=\"PeakValueRss\" Value=\")(.*)(?=\"/>)" $REPORT_NAME | tail -n 1)
peakValueVsize=$(grep -Po "(?<=<Metric Name=\"PeakValueVsize\" Value=\")(.*)(?=\"/>)" $REPORT_NAME | tail -n 1)
totalSize=$(grep -Po "(?<=<Metric Name=\"Timing-tstoragefile-write-totalMegabytes\" Value=\")(.*)(?=\"/>)" $REPORT_NAME | tail -n 1)
totalSizeAlt=$(grep -Po "(?<=<Metric Name=\"Timing-file-write-totalMegabytes\" Value=\")(.*)(?=\"/>)" $REPORT_NAME | tail -n 1)
totalJobTime=$(grep -Po "(?<=<Metric Name=\"TotalJobTime\" Value=\")(.*)(?=\"/>)" $REPORT_NAME | tail -n 1)
totalJobCPU=$(grep -Po "(?<=<Metric Name=\"TotalJobCPU\" Value=\")(.*)(?=\"/>)" $REPORT_NAME | tail -n 1)
eventThroughput=$(grep -Po "(?<=<Metric Name=\"EventThroughput\" Value=\")(.*)(?=\"/>)" $REPORT_NAME | tail -n 1)
avgEventTime=$(grep -Po "(?<=<Metric Name=\"AvgEventTime\" Value=\")(.*)(?=\"/>)" $REPORT_NAME | tail -n 1)
if [ -z "$threads" ]; then
  echo "Could not find NumberOfThreads in report, defaulting to 1"
  threads=1
fi
if [ -z "$eventThroughput" ]; then
  eventThroughput=$(bc -l <<< "scale=4; 1 / ($avgEventTime / $threads)")
fi
if [ -z "$totalSize" ]; then
  totalSize=$totalSizeAlt
fi
if [ -z "$processedEvents" ]; then
  processedEvents=$EVENTS
fi
echo "Validation report of ${jobName} sequence 1/1"
echo "Processed events: $processedEvents"
echo "Produced events: $producedEvents"
echo "Threads: $threads"
echo "Peak value RSS: $peakValueRss MB"
echo "Peak value Vsize: $peakValueVsize MB"
echo "Total size: $totalSize MB"
echo "Total job time: $totalJobTime s"
echo "Total CPU time: $totalJobCPU s"
echo "Event throughput: $eventThroughput"
echo "CPU efficiency: "$(bc -l <<< "scale=2; ($totalJobCPU * 100) / ($threads * $totalJobTime)")" %"
echo "Size per event: "$(bc -l <<< "scale=4; ($totalSize * 1024 / $producedEvents)")" kB"
echo "Time per event: "$(bc -l <<< "scale=4; (1 / $eventThroughput)")" s"
echo "Filter efficiency percent: "$(bc -l <<< "scale=8; ($producedEvents * 100) / $processedEvents")" %"
echo "Filter efficiency fraction: "$(bc -l <<< "scale=10; ($producedEvents) / $processedEvents")
