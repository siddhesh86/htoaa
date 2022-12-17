import FWCore.ParameterSet.Config as cms

# link to cards:
# https://github.com/cms-sw/genproductions/pull/2891

externalLHEProducer = cms.EDProducer("ExternalLHEProducer",
    args = cms.vstring('/cvmfs/cms.cern.ch/phys_generator/gridpacks/UL/13TeV/madgraph/V5_2.6.5/SUSY_GluGluH_01J_HToAATo4B_M-12/v1/SUSY_GluGluH_01J_HToAATo4B_M-12_slc7_amd64_gcc700_CMSSW_10_6_19_tarball.tar.xz'),
    nEvents = cms.untracked.uint32(5000),
    numberOfParameters = cms.uint32(1),
    outputFile = cms.string('cmsgrid_final.lhe'),
    scriptName = cms.FileInPath('GeneratorInterface/LHEInterface/data/run_generic_tarball_cvmfs.sh')
)

 
import FWCore.ParameterSet.Config as cms
from Configuration.Generator.Pythia8CommonSettings_cfi import *
from Configuration.Generator.MCTunes2017.PythiaCP5Settings_cfi import *
from Configuration.Generator.PSweightsPythia.PythiaPSweightsSettings_cfi import *

generator = cms.EDFilter("Pythia8HadronizerFilter",
    maxEventsToPrint = cms.untracked.int32(1),
    pythiaPylistVerbosity = cms.untracked.int32(1),
    #filterEfficiency = cms.untracked.double(1.0),
    pythiaHepMCVerbosity = cms.untracked.bool(False),
    comEnergy = cms.double(13000.),
    PythiaParameters = cms.PSet(
        pythia8CommonSettingsBlock,
        pythia8CP5SettingsBlock,
        pythia8PSweightsSettingsBlock,
        processParameters = cms.vstring(
            'JetMatching:setMad = off',
            'JetMatching:scheme = 1',
            'JetMatching:merge = on',
            'JetMatching:jetAlgorithm = 2',
            'JetMatching:etaJetMax = 5.',
            'JetMatching:coneRadius = 1.',
            'JetMatching:slowJetPower = 1',
            'JetMatching:qCut = 40.',  ## This is the actual merging scale
            'JetMatching:nQmatch = 4', ## 4 for 4-flavour scheme (no matching of b-quarks)
            'JetMatching:nJetMax = 1', ## Number of partons in born matrix element for highest multiplicity
            'JetMatching:doShowerKt = off', ## Off for MLM matching, turn on for shower-kT matching
        ),
        parameterSets = cms.vstring('pythia8CommonSettings',
                                    'pythia8CP5Settings',
                                    'pythia8PSweightsSettings',
                                    'processParameters',
                                    )
    )
)

## Access list of generator-level particles
genParticlesForFilter = cms.EDProducer("GenParticleProducer",
  saveBarCodes = cms.untracked.bool(True),
  src = cms.InputTag("generator","unsmeared"),
  abortOnUnknownPDGCode = cms.untracked.bool(False)
)

## Select final state Higgs
genSelectorH = cms.EDFilter("GenParticleSelector",
    cut = cms.string('pdgId() == 25 && status() == 62'),
    filter = cms.bool(True),
    src = cms.InputTag("genParticlesForFilter")
)

## Select only Higgs with pT > 150 GeV
highPtHs = cms.EDFilter("EtaPtMinCandViewSelector",
    etaMax = cms.double(10.0),
    etaMin = cms.double(-10.0),
    filter = cms.bool(True),
    ptMin = cms.double(150.0),
    src = cms.InputTag("genSelectorH")
)

## Create filter for high-pT Higgs
selectedHighPtHiggsCandFilter = cms.EDFilter("CandViewCountFilter",
    minNumber = cms.uint32(1),
    src = cms.InputTag("highPtHs")
)

ProductionFilterSequence = cms.Sequence(generator * (genParticlesForFilter + genSelectorH + highPtHs + selectedHighPtHiggsCandFilter))

