#!/bin/bash

# source: https://cms-pdmv-prod.web.cern.ch/mcm/public/restapi/requests/get_test/pLHEGenSim_${SampleName}  WminusTo3Pi_TuneCP5_13p6TeV_powhegMINNLO-pythia8


# Binds for singularity containers
# Mount /afs, /eos, /cvmfs, /etc/grid-security for xrootd
export APPTAINER_BINDPATH='/afs,/cvmfs,/cvmfs/grid.cern.ch/etc/grid-security:/etc/grid-security,/eos,/etc/pki/ca-trust,/run/user,/var/run/user'


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

#SampleName=GluGluHJ_HTo4B                                                                                                                                                                                                                                     
#NEvents=10                                                                                                                                                                                                                                                    
#ipGenFragment=/afs/cern.ch/work/s/ssawant/private/htoa1a2/MCproduction/htoaa_b_MCGeneration/MCConfigs/GENFragments_13p6TeV/GENFragment_${SampleName}.py                                                                                                       
#ipLHE=/eos/cms/store/group/phys_susy/HToaaTo4b/LHE/SM_HTo4b_LO_13p6/2026_09_01/pp-ggH-4b-single.lhe                                                                                                                                                           
#opFile0=wmLHE_${SampleName}_0_nEvt_${NEvents}.root                                                                                                                                                                                                            
#opFile=pLHEGenDim_${SampleName}_nEvt_${NEvents}.root                                                                                                                                                                                                               

SampleName=${prodmode}                                                                                                                                                                                                                                    
NEvents=nEvents                                                                                                                                                                                                                                                    
ipGenFragment=./GENFragment_${SampleName}.py                                                                                                       
ipLHE=${inputFile}                                                                                                                                                           
#opFile0=wmLHE_${SampleName}_0_nEvt_${NEvents}.root                                                                                                                                                                                                            
opFile=${outputFile}                                                                                                                                                                                                               



# Download fragment from McM
#curl -s -k https://cms-pdmv-prod.web.cern.ch/mcm/public/restapi/requests/get_fragment/pLHEGenSim_${SampleName} --retry 3 --create-dirs -o Configuration/GenProduction/python/GENFragment_${SampleName}.py
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

# Dump actual test code to a pLHEGenSim_${SampleName}_test.sh file that can be run in Singularity
cat << EndOfTestFile > pLHEGenSim_${SampleName}_test.sh
#!/bin/bash

export SCRAM_ARCH=el8_amd64_gcc12

source /cvmfs/cms.cern.ch/cmsset_default.sh
echo \$HOSTNAME
if [ -r CMSSW_14_0_21/src ] ; then
  echo release CMSSW_14_0_21 already exists
else
  scram p CMSSW CMSSW_14_0_21
fi
cd CMSSW_14_0_21/src
eval \`scram runtime -sh\`

mv ../../Configuration .
scram b
cd ../..

# Maximum validation runtime: 57600s
# Minimum validation runtime: 600s
# Output events to run for the validation job (from application's setting): 100
# Event efficiency: Computed using the request efficiency and its error.
# Event efficiency: \`efficiency - (2 * efficiency_error)\`: \`1 - (2 * 0)\` = 1
# Input events: \`int(output_events / event_efficiency)\`: \`int(100 / 1)\` = 100
# Time per event (s): Computed adding all the time_per_event values on every sequence
# Time per event (s): 7.28
# Target input events: 100
# Target output events: 100
# This validation will be computed based on the target output events!

# Dynamically injected value from parent script
EVENTS=${NEvents}


# cmsDriver command
cmsDriver.py Configuration/GenProduction/python/GENFragment_${SampleName}.py --era Run3_2024 --customise Configuration/DataProcessing/Utils.addMonitoring --beamspot DBrealistic --step GEN,SIM --geometry DB:Extended --conditions 140X_mcRun3_2024_realistic_v26 --customise_commands process.source.numberEventsInLuminosityBlock="cms.untracked.uint32(100)" --datatier GEN-SIM,LHE --eventcontent RAWSIM,LHE --python_filename pLHEGenSim_${SampleName}_1_cfg.py --fileout file:${opFile} --filein file:${ipLHE} --number \${EVENTS} --number_out \${EVENTS} --no_exec --mc || exit \$? ;

# Run generated config
REPORT_NAME=pLHEGenSim_${SampleName}_report.xml
# Run the cmsRun
cmsRun -e -j \$REPORT_NAME pLHEGenSim_${SampleName}_1_cfg.py || exit \$? ;

# Parse values from pLHEGenSim_${SampleName}_report.xml report
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
echo "Validation report of pLHEGenSim_${SampleName} sequence 1/1"
echo "Processed events: \$processedEvents"
echo "Produced events: \$producedEvents"
echo "Threads: \$threads"
echo "Peak value RSS: \$peakValueRss MB"
echo "Peak value Vsize: \$peakValueVsize MB"
echo "Total size: \$totalSize MB"
echo "Total job time: \$totalJobTime s"
echo "Total CPU time: \$totalJobCPU s"
echo "Event throughput: \$eventThroughput"
echo "CPU efficiency: "\$(bc -l <<< "scale=2; (\$totalJobCPU * 100) / (\$threads * \$totalJobTime)")" %"
echo "Size per event: "\$(bc -l <<< "scale=4; (\$totalSize * 1024 / \$producedEvents)")" kB"
echo "Time per event: "\$(bc -l <<< "scale=4; (1 / \$eventThroughput)")" s"
echo "Filter efficiency percent: "\$(bc -l <<< "scale=8; (\$producedEvents * 100) / \$processedEvents")" %"
echo "Filter efficiency fraction: "\$(bc -l <<< "scale=10; (\$producedEvents) / \$processedEvents")

# End of pLHEGenSim_${SampleName}_test.sh file
EndOfTestFile

# Make file executable
chmod +x pLHEGenSim_${SampleName}_test.sh

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
singularity run --home $PWD:$PWD /cvmfs/unpacked.cern.ch/registry.hub.docker.com/cmssw/$CONTAINER_NAME $(echo $(pwd)/pLHEGenSim_${SampleName}_test.sh)
