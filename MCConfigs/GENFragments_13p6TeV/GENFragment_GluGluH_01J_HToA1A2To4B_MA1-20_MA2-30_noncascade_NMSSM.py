
# source: https://cms-pdmv-prod.web.cern.ch/mcm/public/restapi/requests/get_fragment/SUS-Run3Summer22wmLHEGS-00104/0


#INPUTGRIDPACK=""
INPUTGRIDPACK="/afs/cern.ch/work/s/ssawant/private/htoa1a2/MCproduction/GEN/genproductions_scripts/bin/MadGraph5_aMCatNLO/generated_samples/GluGluH_01J_HToA1A2To4B_MA1-20_MA2-30_noncascade_NMSSM_el8_amd64_gcc10_CMSSW_12_4_8_tarball.tar.xz"
HIGGSPTMIN=150


import FWCore.ParameterSet.Config as cms


externalLHEProducer = cms.EDProducer("ExternalLHEProducer",
    #args = cms.vstring('/cvmfs/cms-griddata.cern.ch/phys_generator/gridpacks_tarball/pp/13p6TeV/madgraph/HToAAto4B/GluGluH_01J_HToAATo4B/GluGluH_01J_HToAATo4B_M-20_el8_amd64_gcc10_CMSSW_12_4_8_tarball.tar.xz'),
    args = cms.vstring(INPUTGRIDPACK),
    nEvents = cms.untracked.uint32(5000),
    numberOfParameters = cms.uint32(1),
    outputFile = cms.string('cmsgrid_final.lhe'),
    scriptName = cms.FileInPath('GeneratorInterface/LHEInterface/data/run_generic_tarball_cvmfs.sh'),
    generateConcurrently = cms.untracked.bool(False)
)

 
from Configuration.Generator.Pythia8CommonSettings_cfi import *
from Configuration.Generator.MCTunesRun3ECM13p6TeV.PythiaCP5Settings_cfi import *
from Configuration.Generator.PSweightsPythia.PythiaPSweightsSettings_cfi import *

generator = cms.EDFilter("Pythia8ConcurrentHadronizerFilter",
    maxEventsToPrint = cms.untracked.int32(1),
    pythiaPylistVerbosity = cms.untracked.int32(1),
    filterEfficiency = cms.untracked.double(1.0),
    pythiaHepMCVerbosity = cms.untracked.bool(False),
    comEnergy = cms.double(13600.),
    PythiaParameters = cms.PSet(
        pythia8CommonSettingsBlock,
        pythia8CP5SettingsBlock,
        pythia8PSweightsSettingsBlock,
        parameterSets = cms.vstring('pythia8CommonSettings',
                                    'pythia8CP5Settings',
                                    'pythia8PSweightsSettings',
                                    )
    )
)

ProductionFilterSequence = cms.Sequence(generator)