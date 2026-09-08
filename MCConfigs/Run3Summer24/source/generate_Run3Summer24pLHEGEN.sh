#!/bin/bash

# source: https://cms-pdmv-prod.web.cern.ch/mcm/public/restapi/requests/get_test/SMP-RunIII2024Summer24pLHEGS-00001  WminusTo3Pi_TuneCP5_13p6TeV_powhegMINNLO-pythia8


# Binds for singularity containers
# Mount /afs, /eos, /cvmfs, /etc/grid-security for xrootd
export APPTAINER_BINDPATH='/afs,/cvmfs,/cvmfs/grid.cern.ch/etc/grid-security:/etc/grid-security,/eos,/etc/pki/ca-trust,/run/user,/var/run/user'

cat <<'EndOfGenScriptFile' > SMP-RunIII2024Summer24pLHEGS-00001_gen_script.sh
#!/bin/bash

echo "Running CMS GEN request script using cms-sw containers. Architecture: el9:x86_64"
python3 -m venv cms_gen_venv_SMP-RunIII2024Summer24pLHEGS-00001 && source ./cms_gen_venv_SMP-RunIII2024Summer24pLHEGS-00001/bin/activate

# Install the PdmV REST client
pip install pdmv-http-client>=2.1.0 &> /dev/null

echo "Packages installed"
pip freeze
echo ""

# GEN Script begin
rm -f request_fragment_check.py
wget -q https://gitlab.cern.ch/cms-gen/genproductions_scripts/-/raw/master/bin/utils/request_fragment_check.py
chmod +x request_fragment_check.py

./request_fragment_check.py --bypass_status --prepid SMP-RunIII2024Summer24pLHEGS-00001

# End of CMS GEN script file: SMP-RunIII2024Summer24pLHEGS-00001_gen_script.sh
EndOfGenScriptFile
chmod +x SMP-RunIII2024Summer24pLHEGS-00001_gen_script.sh

# Run in singularity container
singularity run --home $PWD:$PWD /cvmfs/unpacked.cern.ch/registry.hub.docker.com/cmssw/el9:x86_64 $(echo $(pwd)/SMP-RunIII2024Summer24pLHEGS-00001_gen_script.sh)

GEN_ERR=$?
if [ $GEN_ERR -ne 0 ]; then
  echo "GEN Checking Script returned exit code $GEN_ERR which means there are $GEN_ERR errors"
  echo "Validation WILL NOT RUN"
  echo "Please correct errors in the request and run validation again"
  exit $GEN_ERR
fi
echo "Running VALIDATION. GEN Request Checking Script returned no errors"
# GEN Script end

# Download fragment from McM
curl -s -k https://cms-pdmv-prod.web.cern.ch/mcm/public/restapi/requests/get_fragment/SMP-RunIII2024Summer24pLHEGS-00001 --retry 3 --create-dirs -o Configuration/GenProduction/python/SMP-RunIII2024Summer24pLHEGS-00001-fragment.py
[ -s Configuration/GenProduction/python/SMP-RunIII2024Summer24pLHEGS-00001-fragment.py ] || exit $?;

# Check if fragment contais gridpack path ant that it is in cvmfs
if grep -q "gridpacks" Configuration/GenProduction/python/SMP-RunIII2024Summer24pLHEGS-00001-fragment.py; then
  if ! grep -q -e "/cvmfs/cms.cern.ch/phys_generator/gridpacks" -e "/cvmfs/cms-griddata.cern.ch/phys_generator/gridpacks_tarball" Configuration/GenProduction/python/SMP-RunIII2024Summer24pLHEGS-00001-fragment.py; then
    echo "Gridpack inside fragment is not in cvmfs."
    exit -1
  fi
fi

# Dump actual test code to a SMP-RunIII2024Summer24pLHEGS-00001_test.sh file that can be run in Singularity
cat <<'EndOfTestFile' > SMP-RunIII2024Summer24pLHEGS-00001_test.sh
#!/bin/bash

export SCRAM_ARCH=el8_amd64_gcc12

source /cvmfs/cms.cern.ch/cmsset_default.sh
echo $HOSTNAME
if [ -r CMSSW_14_0_21/src ] ; then
  echo release CMSSW_14_0_21 already exists
else
  scram p CMSSW CMSSW_14_0_21
fi
cd CMSSW_14_0_21/src
eval `scram runtime -sh`

mv ../../Configuration .
scram b
cd ../..

# Maximum validation runtime: 57600s
# Minimum validation runtime: 600s
# Output events to run for the validation job (from application's setting): 100
# Event efficiency: Computed using the request efficiency and its error.
# Event efficiency: `efficiency - (2 * efficiency_error)`: `1 - (2 * 0)` = 1
# Input events: `int(output_events / event_efficiency)`: `int(100 / 1)` = 100
# Time per event (s): Computed adding all the time_per_event values on every sequence
# Time per event (s): 7.28
# Target input events: 100
# Target output events: 100
# This validation will be computed based on the target output events!
EVENTS=100


# cmsDriver command
cmsDriver.py Configuration/GenProduction/python/SMP-RunIII2024Summer24pLHEGS-00001-fragment.py --era Run3_2024 --customise Configuration/DataProcessing/Utils.addMonitoring --beamspot DBrealistic --step GEN,SIM --geometry DB:Extended --conditions 140X_mcRun3_2024_realistic_v26 --customise_commands process.source.numberEventsInLuminosityBlock="cms.untracked.uint32(100)" --datatier GEN-SIM,LHE --eventcontent RAWSIM,LHE --python_filename SMP-RunIII2024Summer24pLHEGS-00001_1_cfg.py --fileout file:SMP-RunIII2024Summer24pLHEGS-00001.root --filein "lhe:20174" --number 100 --number_out 100 --no_exec --mc || exit $? ;

# Run generated config
REPORT_NAME=SMP-RunIII2024Summer24pLHEGS-00001_report.xml
# Run the cmsRun
cmsRun -e -j $REPORT_NAME SMP-RunIII2024Summer24pLHEGS-00001_1_cfg.py || exit $? ;

# Parse values from SMP-RunIII2024Summer24pLHEGS-00001_report.xml report
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
echo "Validation report of SMP-RunIII2024Summer24pLHEGS-00001 sequence 1/1"
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

# End of SMP-RunIII2024Summer24pLHEGS-00001_test.sh file
EndOfTestFile

# Make file executable
chmod +x SMP-RunIII2024Summer24pLHEGS-00001_test.sh

if [ -e "/cvmfs/unpacked.cern.ch/registry.hub.docker.com/cmssw/el8:amd64" ]; then
  CONTAINER_NAME="el8:amd64"
elif [ -e "/cvmfs/unpacked.cern.ch/registry.hub.docker.com/cmssw/el8:x86_64" ]; then
  CONTAINER_NAME="el8:x86_64"
else
  echo "Could not find amd64 or x86_64 for el8"
  exit 1
fi
# Run in singularity container
export SINGULARITY_CACHEDIR="/tmp/$(whoami)/singularity"
singularity run --home $PWD:$PWD /cvmfs/unpacked.cern.ch/registry.hub.docker.com/cmssw/$CONTAINER_NAME $(echo $(pwd)/SMP-RunIII2024Summer24pLHEGS-00001_test.sh)
