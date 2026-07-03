import os
import sys
import awkward as ak
import hist
from coffea import processor
from coffea.nanoevents import NanoAODSchema
from coffea.lookup_tools import extractor
import correctionlib
import uproot 


class MuonProcessor(processor.ProcessorABC):
    def __init__(self): #def __init__(self, sf_path: str):
        #self.corrections = correctionlib.CorrectionSet.from_file(sf_path)
        #self.muon_sf = self.corrections["muon_sf"]
        pass

    def process(self, events):
        dataset = events.metadata["dataset"]

        # Create histogram with category axis
        h_mass = hist.Hist.new.StrCat([], growth=True, name="dataset").Reg(
            60, 60, 120, name="mass", label="mμμ [GeV]"
        ).Weight()


        '''
        ext = extractor()
        # several histograms can be imported at once using wildcards (*)
        ext.add_weight_sets(["testSF2d scalefactors_Tight_Electron data_tmp/testSF2d.histo.root"])
        ext.finalize()

        evaluator = ext.make_evaluator()

        print("available evaluator keys:")
        for key in evaluator.keys():
            print("\t", key)
        print("testSF2d:", evaluator["testSF2d"])
        print("type of testSF2d:", type(evaluator["testSF2d"]))
        '''


        # select OS dimuons
        muons = events.Muon[events.Muon.tightId]
        dimuons = ak.combinations(muons, 2, fields=["lead", "trail"])
        dimuons = dimuons[dimuons.lead.charge != dimuons.trail.charge]

        # correctionlib returns per-muon weights; take product per event
        #sf_lead = self.muon_sf.evaluate(dimuons.lead.eta, dimuons.lead.pt)
        #sf_trail = self.muon_sf.evaluate(dimuons.trail.eta, dimuons.trail.pt)
        #event_weight = sf_lead * sf_trail
        

        mass = (dimuons.lead + dimuons.trail).mass
        mass = ak.firsts(mass)
        mask_ = ~ak.is_none(mass)
        mass = mass[mask_]
        event_weight = ak.full_like(mass, 0.5)
        print(f"{dataset = }"); sys.stdout.flush()
        print(f"{muons = }"); sys.stdout.flush()
        print(f"{dimuons = }"); sys.stdout.flush()
        print(f"{mask_ = }"); sys.stdout.flush()
        print(f"{mass = }"); sys.stdout.flush()
        print(f"{event_weight = }"); sys.stdout.flush()
        print(f"{len(events) = }"); sys.stdout.flush()
        print(f"{len(events[mask_]) = }"); sys.stdout.flush()
        

        h_mass.fill(
            dataset=dataset,
            mass=mass,
            weight=event_weight,
        )

        return {
            dataset: {
                "mass": h_mass,
                "events": len(events),
                "events_selected": len(events[mask_]),
            }
        }

    def postprocess(self, accumulator):
        return accumulator




class MyAnalyzer(processor.ProcessorABC):
    def __init__(self):
        # Define the histogram axes
        dataset_axis = hist.axis.StrCategory(name="dataset", label="", categories=[], growth=True)
        mass_axis = hist.axis.Regular(name="mass", label="$m_{\mu\mu}$ [GeV]", bins=50, start=20, stop=120)
        
        # Initialize dictionary accumulator for outputs
        self.output = processor.dict_accumulator({
            'mass': hist.Hist(dataset_axis, mass_axis),
            'cutflow': processor.defaultdict_accumulator(int)
        })

    def process(self, events):
        dataset = events.metadata['dataset']
        muons = events.Muon
        
        # Select events with exactly two oppositely charged muons
        cut = (ak.num(muons) == 2) & (ak.sum(muons.charge, axis=1) == 0)
        selected_muons = muons[cut]
        
        # Compute invariant mass of the dimuon system
        dimuon_mass = (selected_muons[:, 0] + selected_muons[:, 1]).mass
        
        # Fill histograms and track event counts
        output = self.output.identity()
        output['mass'].fill(dataset=dataset, mass=dimuon_mass)
        output['cutflow']['all events'] = ak.size(events, axis=0)
        
        return output

    def postprocess(self, accumulator):
        return accumulator




if __name__ == '__main__':
    print("htoaa_Analysis:: main: {}".format(sys.argv)); sys.stdout.flush()

    fileset = {
        "DYJets": {
            "files": {"/eos/cms/store/group/phys_susy/HToaaTo4b/NanoAOD/2018/MC/PNet_v2_2024_11_22/DYJetsToLL_M-50_HT-400to600_TuneCP5_PSweights_13TeV-madgraphMLM-pythia8/r2/PNet_v1_Skim_0.root": "Events"},
            "metadata": {"is_mc": True},
        },
        "Data": {
            "files": {"/eos/cms/store/group/phys_susy/HToaaTo4b/NanoAOD/2018/data/PNet_v2_2024_11_22/JetHT/r1_Run2018D/PNet_v1_Skim_0_0.root": "Events"},
            "metadata": {"is_mc": False},
        },
    }
    sOutputFile = 'tmp_.root'

    runner = processor.Runner(
        executor=processor.IterativeExecutor(),
        schema=NanoAODSchema,
        savemetrics=True,
    )

    #result, metrics = runner(fileset, processor_instance=MyAnalyzer())
    result, metrics = runner(fileset, processor_instance=MuonProcessor())

    print(f"\n\n {result = }")
    print(f"\n\n {metrics = }")

    print(f"{sOutputFile = }")
    with uproot.recreate(sOutputFile) as fOut:

        for process in result:
            for objName, obj in result[process].items():
                print(f"{process = }, {objName = }, {obj = }, {type(obj) = }, {isinstance(obj, hist.hist.Hist) = }")

                if isinstance(obj, hist.hist.Hist):
                    #print(f"{obj.}")
                    h = obj.integrate('dataset', process)

                    fOut['%s_%s' % (objName, process)] = h

    