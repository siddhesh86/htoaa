#!/bin/bash

# Binds for singularity containers
# Mount /afs, /eos, /cvmfs, /etc/grid-security for xrootd
export APPTAINER_BINDPATH='/afs,/cvmfs,/cvmfs/grid.cern.ch/etc/grid-security:/etc/grid-security,/eos,/etc/pki/ca-trust,/run/user,/var/run/user'

SampleName=GluGluH_01J_HToA1A2To4B_MA1-20_MA2-30_noncascade_TRSM_PtH150ToInf
NEvents=10000
ipGenFragment=/afs/cern.ch/work/s/ssawant/private/htoa1a2/MCproduction/htoaa_b_MCGeneration/MCConfigs/GENFragments_13p6TeV/GENFragment_${SampleName}.py
opFile=wmLHE_${SampleName}_nEvt_${NEvents}.root


# Download fragment from McM
#curl -s -k https://cms-pdmv-prod.web.cern.ch/mcm/public/restapi/requests/get_fragment/wmLHE_${SampleName} --retry 3 --create-dirs -o Configuration/GenProduction/python/GENFragment_${SampleName}.py
#[ -s Configuration/GenProduction/python/GENFragment_${SampleName}.py ] || exit $?;
mkdir -p Configuration/GenProduction/python
cp ${ipGenFragment} Configuration/GenProduction/python/GENFragment_${SampleName}.py

# Check if fragment contais gridpack path ant that it is in cvmfs
if grep -q "gridpacks" Configuration/GenProduction/python/GENFragment_${SampleName}.py; then
  if ! grep -q -e "/cvmfs/cms.cern.ch/phys_generator/gridpacks" -e "/cvmfs/cms-griddata.cern.ch/phys_generator/gridpacks_tarball" Configuration/GenProduction/python/GENFragment_${SampleName}.py; then
    echo "Gridpack inside fragment is not in cvmfs."
    exit -1
  fi
fi

# Dump actual test code to a wmLHE_${SampleName}_run.sh file that can be run in Singularity
cat <<EndOfTestFile > wmLHE_${SampleName}_run.sh
#!/bin/bash

export SCRAM_ARCH=el8_amd64_gcc10

source /cvmfs/cms.cern.ch/cmsset_default.sh
echo \$HOSTNAME
if [ -r CMSSW_12_4_24/src ] ; then
  echo release CMSSW_12_4_24 already exists
else
  scram p CMSSW CMSSW_12_4_24
fi
cd CMSSW_12_4_24/src
eval \`scram runtime -sh\`

echo "pwd 0 " \$pwd
pwd

mv ../../Configuration .
scram b
cd ../..

#EVENTS=100
EVENTS=$NEvents

# Random seed between 1 and 100 for externalLHEProducer
SEED=\$((\$(date +%s) % 100 + 1))

echo "pwd 1" \$pwd
pwd

# cmsDriver command
cmsDriver.py Configuration/GenProduction/python/GENFragment_${SampleName}.py --era Run3 --customise Configuration/DataProcessing/Utils.addMonitoring --beamspot Realistic25ns13p6TeVEarly2022Collision --step LHE,GEN,SIM --geometry DB:Extended --conditions 124X_mcRun3_2022_realistic_v12 --customise_commands process.RandomNumberGeneratorService.externalLHEProducer.initialSeed="int(\${SEED})"\\\\nprocess.source.numberEventsInLuminosityBlock="cms.untracked.uint32(100)" --datatier GEN-SIM,LHE --eventcontent RAWSIM,LHE --python_filename wmLHE_${SampleName}_1_cfg.py --fileout file:${opFile} --number \${EVENTS} --number_out \${EVENTS} --no_exec --mc || exit $? ;

# Run generated config
REPORT_NAME=wmLHE_${SampleName}_report.xml
# Run the cmsRun
cmsRun -e -j \$REPORT_NAME wmLHE_${SampleName}_1_cfg.py || exit \$? ;

# Parse values from wmLHE_${SampleName}_report.xml report
processedEvents=\$(grep -Po "(?<=<Metric Name=\"NumberEvents\" Value=\")(.*)(?=\"/>)" \$REPORT_NAME | tail -n 1)
producedEvents=\$(grep -Po "(?<=<TotalEvents>)(\d*)(?=</TotalEvents>)" \$REPORT_NAME | tail -n 1)
threads=\$(grep -Po "(?<=<Metric Name=\"NumberOfThreads\" Value=\")(.*)(?=\"/>)" \$REPORT_NAME | tail -n 1)
peakValueRss=\$(grep -Po "(?<=<Metric Name=\"PeakValueRss\" Value=\")(.*)(?=\"/>)" \$REPORT_NAME | tail -n 1)
peakValueVsize=\$(grep -Po "(?<=<Metric Name=\"PeakValueVsize\" Value=\")(.*)(?=\"/>)" \$REPORT_NAME | tail -n 1)
totalSize=\$(grep -Po "(?<=<Metric Name=\"Timing-tstoragefile-write-totalMegabytes\" Value=\")(.*)(?=\"/>)" \$REPORT_NAME | tail -n 1)
totalSizeAlt=\$(grep -Po "(?<=<Metric Name=\"Timing-file-write-totalMegabytes\" Value=\")(.*)(?=\"/>)" \$REPORT_NAME | tail -n 1)
totalJobTime=\$(grep -Po "(?<=<Metric Name=\"TotalJobTime\" Value=\")(.*)(?=\"/>)" \$REPORT_NAME | tail -n 1)
totalJobCPU=\$(grep -Po "(?<=<Metric Name=\"TotalJobCPU\" Value=\")(.*)(?=\"/>)" \$REPORT_NAME | tail -n 1)
eventThroughput=\$(grep -Po "(?<=<Metric Name=\"EventThroughput\" Value=\")(.*)(?=\"/>)" \$REPORT_NAME | tail -n 1)
avgEventTime=\$(grep -Po "(?<=<Metric Name=\"AvgEventTime\" Value=\")(.*)(?=\"/>)" \$REPORT_NAME | tail -n 1)
if [ -z "\$threads" ]; then
  echo "Could not find NumberOfThreads in report, defaulting to 1"
  threads=1
fi
if [ -z "\$eventThroughput" ]; then
  eventThroughput=\$(bc -l <<< "scale=4; 1 / (\$avgEventTime / \$threads)")
fi
if [ -z "\$totalSize" ]; then
  totalSize=\$totalSizeAlt
fi
if [ -z "\$processedEvents" ]; then
  processedEvents=\$EVENTS
fi
echo "Validation report of wmLHE_${SampleName} sequence 1/1"
echo "Processed events: \$processedEvents"
echo "Produced events: \$producedEvents"
echo "Threads: \$threads"
echo "Peak value RSS: \$peakValueRss MB"
echo "Peak value Vsize: \$peakValueVsize MB"
echo "Total size:\$totalSize MB"
echo "Total job time: \$totalJobTime s"
echo "Total CPU time: \$totalJobCPU s"
echo "Event throughput: \$eventThroughput"
echo "CPU efficiency: "\$(bc -l <<< "scale=2; (\$totalJobCPU * 100) / (\$threads * \$totalJobTime)")" %"
echo "Size per event: "\$(bc -l <<< "scale=4; (\$totalSize * 1024 / \$producedEvents)")" kB"
echo "Time per event: "\$(bc -l <<< "scale=4; (1 / \$eventThroughput)")" s"
echo "Filter efficiency percent: "\$(bc -l <<< "scale=8; (\$producedEvents * 100) / \$processedEvents")" %"
echo "Filter efficiency fraction: "\$(bc -l <<< "scale=10; (\$producedEvents) / \$processedEvents")

# End of wmLHE_${SampleName}_run.sh file
EndOfTestFile

# Make file executable
chmod +x wmLHE_${SampleName}_run.sh

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
singularity run --home $PWD:$PWD /cvmfs/unpacked.cern.ch/registry.hub.docker.com/cmssw/$CONTAINER_NAME $(echo $(pwd)/wmLHE_${SampleName}_run.sh)
