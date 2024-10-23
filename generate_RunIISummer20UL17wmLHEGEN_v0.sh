#!/bin/bash

inputFile=${1}
#outputDir=${2}
outputFile=${2}
nEvents=${3}
jobID=${4}
sourceCodeDir=${5}
#productionDir=${6}
randomSeed=${6}
prodmode=${7}
HiggsPtMin=${8}

jobName="${jobID}wmLHEGEN"

outputDir=$(echo ${outputFile} | sed 's|\(.*\)/.*|\1|')

printf "\n\ngenerate_RunIISummer20UL17wmLHEGEN.sh:: \nArguments: $@ \n"
printf "\ninputFile: ${inputFile} \n"
echo "outputDir: ${outputDir} "
echo "outputFile: ${outputFile}"
echo "nEvents: ${nEvents}"
echo "jobName: ${jobName} "
echo "sourceCodeDir: ${sourceCodeDir} "
#echo "productionDir: ${productionDir} "

pwd_=$(pwd)

echo 'pwd (generate_RunIISummer20UL17wmLHEGEN.sh) 0: '
pwd

inputDir=$(dirname "$inputFile")

# set absolute inputFile path instead of relative one
if [[ -z "$inputDir" || "$inputDir" == "." ]] ; then
    inputFileName=$(basename "$inputFile") 
    inputFile=${pwd_}/${inputFileName}
    printf "inputFile to use: ${inputFile} \n"
fi



# Binds for singularity containers
# Mount /afs, /eos, /cvmfs, /etc/grid-security for xrootd
export APPTAINER_BINDPATH='/afs,/cvmfs,/cvmfs/grid.cern.ch/etc/grid-security:/etc/grid-security,/eos,/etc/pki/ca-trust,/run/user,/var/run/user'

: '
cat <<'EndOfGenScriptFile' > ${jobName}_gen_script.sh
#!/bin/bash

echo "Running CMS GEN request script using cms-sw containers. Architecture: el9:x86_64"
python3.9 -m venv cms_gen_venv_HIG-RunIISummer20UL17wmLHEGEN-02463 && source ./cms_gen_venv_HIG-RunIISummer20UL17wmLHEGEN-02463/bin/activate

# Install the PdmV REST client
pip install git+https://github.com/cms-PdmV/mcm_scripts &> /dev/null

echo "Packages installed"
pip freeze
echo ""

# GEN Script begin
rm -f request_fragment_check.py
wget -q https://raw.githubusercontent.com/cms-sw/genproductions/master/bin/utils/request_fragment_check.py
chmod +x request_fragment_check.py

./request_fragment_check.py --bypass_status --prepid HIG-RunIISummer20UL17wmLHEGEN-02463

# End of CMS GEN script file: ${jobName}_gen_script.sh
EndOfGenScriptFile
chmod +x ${jobName}_gen_script.sh

# Run in singularity container
singularity run --home $PWD:$PWD /cvmfs/unpacked.cern.ch/registry.hub.docker.com/cmssw/el9:x86_64 $(echo $(pwd)/${jobName}_gen_script.sh)

GEN_ERR=$?
if [ $GEN_ERR -ne 0 ]; then
  echo "GEN Checking Script returned exit code $GEN_ERR which means there are $GEN_ERR errors"
  echo "Validation WILL NOT RUN"
  echo "Please correct errors in the request and run validation again"
  exit $GEN_ERR
fi
echo "Running VALIDATION. GEN Request Checking Script returned no errors"
# GEN Script end
'


# Download fragment from McM
#curl -s -k https://cms-pdmv-prod.web.cern.ch/mcm/public/restapi/requests/get_fragment/HIG-RunIISummer20UL17wmLHEGEN-02463 --retry 3 --create-dirs -o Configuration/GenProduction/python/HIG-RunIISummer20UL17wmLHEGEN-02463-fragment.py
#[ -s Configuration/GenProduction/python/HIG-RunIISummer20UL17wmLHEGEN-02463-fragment.py ] || exit $?;

echo 'pwd (generate_RunIISummer20UL17wmLHEGEN.sh) 1: '
pwd
echo 'ls (generate_RunIISummer20UL17wmLHEGEN.sh) 1: '
ls
if [ ! -d Configuration/GenProduction/python/ ]; then
    mkdir -p Configuration/GenProduction/python/
fi

# Copy fragment
#cp ${pwd_}/GENFragment_SUSY_GluGluH_01J_HToAATo4B.py Configuration/GenProduction/python/${jobName}-fragment.py
#cp ${sourceCodeDir}/GENFragment_SUSY_GluGluH_01J_HToAATo4B.py Configuration/GenProduction/python/${jobName}-fragment.py
cp ${sourceCodeDir}/GENFragment_${prodmode}.py Configuration/GenProduction/python/${jobName}-fragment.py

# replace input Gridpack file
#psed -i "s|INPUTGRIDPACK=''|INPUTGRIDPACK='$inputFile'|g" Configuration/GenProduction/python/${jobName}-fragment.py
sed -i "s|INPUTGRIDPACK=\"\"|INPUTGRIDPACK=\"${inputFile}\"|g" Configuration/GenProduction/python/${jobName}-fragment.py

# replace HiggsPtMin
sed -i "s|HIGGSPTMIN=150|HIGGSPTMIN=${HiggsPtMin}|g" Configuration/GenProduction/python/${jobName}-fragment.py

echo 'pwd (generate_RunIISummer20UL17wmLHEGEN.sh) 2: '
pwd
echo 'ls (generate_RunIISummer20UL17wmLHEGEN.sh) 2: '
ls
echo 'ls Configuration/GenProduction/python/ (generate_RunIISummer20UL17wmLHEGEN.sh) 2'
ls Configuration/GenProduction/python/

printf "\n\n (generate_RunIISummer20UL17wmLHEGEN.sh) 2: cat Configuration/GenProduction/python/${jobName}-fragment.py: "
cat Configuration/GenProduction/python/${jobName}-fragment.py
printf "\n\n"

# Check if fragment contais gridpack path ant that it is in cvmfs
if grep -q "gridpacks" Configuration/GenProduction/python/${jobName}-fragment.py; then
  if ! grep -q "/cvmfs/cms.cern.ch/phys_generator/gridpacks" Configuration/GenProduction/python/${jobName}-fragment.py; then
    echo "Gridpack inside fragment is not in cvmfs."
    exit -1
  fi
fi

# Dump actual test code to a HIG-RunIISummer20UL17wmLHEGEN-02463_test.sh file that can be run in Singularity
cat <<'EndOfTestFile' > ${jobName}_test.sh
#!/bin/bash

export SCRAM_ARCH=slc7_amd64_gcc700

source /cvmfs/cms.cern.ch/cmsset_default.sh
if [ -r CMSSW_10_6_27/src ] ; then
  echo release CMSSW_10_6_27 already exists
  rm -rf CMSSW_10_6_27
fi
scram p CMSSW CMSSW_10_6_27
cd CMSSW_10_6_27/src
eval `scram runtime -sh`

mv ../../Configuration .
scram b
cd ../..

# Maximum validation duration: 28800s
# Margin for validation duration: 30%
# Validation duration with margin: 28800 * (1 - 0.30) = 20160s
# Time per event for each sequence: 2.5000s
# Threads for each sequence: 1
# Time per event for single thread for each sequence: 1 * 2.5000s = 2.5000s
# Which adds up to 2.5000s per event
# Single core events that fit in validation duration: 20160s / 2.5000s = 8064
# Produced events limit in McM is 10000
# According to 0.0250 efficiency, validation should run 10000 / 0.0250 = 400000 events to reach the limit of 10000
# Take the minimum of 8064 and 400000, but more than 0 -> 8064
# It is estimated that this validation will produce: 8064 * 0.0250 = 201 events
#EVENTS=8064
EVENTS=${nEvents}

if [ ! -d ${outputDir} ]
then
   mkdir -p ${outputDir}
fi

echo 'pwd (generate_RunIISummer20UL17wmLHEGEN.sh) 3: '
pwd
echo 'ls (generate_RunIISummer20UL17wmLHEGEN.sh) 3: '
ls

# cmsDriver command
#cmsDriver.py Configuration/GenProduction/python/HIG-RunIISummer20UL17wmLHEGEN-02463-fragment.py --python_filename HIG-RunIISummer20UL17wmLHEGEN-02463_1_cfg.py --eventcontent RAWSIM,LHE --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN,LHE --fileout file:HIG-RunIISummer20UL17wmLHEGEN-02463.root --conditions 106X_mc2017_realistic_v6 --beamspot Realistic25ns13TeVEarly2017Collision --customise_commands process.source.numberEventsInLuminosityBlock="cms.untracked.uint32(4000)" --step LHE,GEN --geometry DB:Extended --era Run2_2017 --no_exec --mc -n $EVENTS || exit $? ;

echo "Run cmsDriver.py Configuration/GenProduction/python/${jobName}-fragment.py --python_filename ${jobName}_1_cfg.py --eventcontent RAWSIM,LHE --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN,LHE --fileout file:${outputFile} --conditions 106X_mc2017_realistic_v6 --beamspot Realistic25ns13TeVEarly2017Collision --customise_commands process.RandomNumberGeneratorService.externalLHEProducer.initialSeed=\"cms.untracked.uint32(${randomSeed})\" --step LHE,GEN --geometry DB:Extended --era Run2_2017 --no_exec --mc -n $EVENTS || exit $? ;"
cmsDriver.py Configuration/GenProduction/python/${jobName}-fragment.py --python_filename ${jobName}_1_cfg.py --eventcontent RAWSIM,LHE --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN,LHE --fileout file:${outputFile} --conditions 106X_mc2017_realistic_v6 --beamspot Realistic25ns13TeVEarly2017Collision --customise_commands process.RandomNumberGeneratorService.externalLHEProducer.initialSeed="cms.untracked.uint32(${randomSeed})" --step LHE,GEN --geometry DB:Extended --era Run2_2017 --no_exec --mc -n $EVENTS || exit $? ;

echo 'pwd (generate_RunIISummer20UL17wmLHEGEN.sh) 4: '
pwd
echo 'ls (generate_RunIISummer20UL17wmLHEGEN.sh) 4: '
ls


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

# End of ${jobName}_test.sh file
EndOfTestFile

# Make file executable
chmod +x ${jobName}_test.sh

if [ -e "/cvmfs/unpacked.cern.ch/registry.hub.docker.com/cmssw/el7:amd64" ]; then
  CONTAINER_NAME="el7:amd64"
elif [ -e "/cvmfs/unpacked.cern.ch/registry.hub.docker.com/cmssw/el7:x86_64" ]; then
  CONTAINER_NAME="el7:x86_64"
else
  echo "Could not find amd64 or x86_64 for el7"
  exit 1
fi
# Run in singularity container
export SINGULARITY_CACHEDIR="/tmp/$(whoami)/singularity"
singularity run --home $PWD:$PWD /cvmfs/unpacked.cern.ch/registry.hub.docker.com/cmssw/$CONTAINER_NAME $(echo $(pwd)/${jobName}_test.sh)
