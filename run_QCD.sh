#time python3 htoaa_Analysis_wCoffea.py /afs/cern.ch/work/s/ssawant/private/htoaa/analysis/20230223_tmp/analyze_htoaa_QCD_HT200to300_TuneCP5_13TeV-madgraphMLM-pythia8_0_0_1_config.json 2>&1 | tee cout_htoaa_Analysis_wCoffea_QCD_HT200to300_0.txt && time python3 htoaa_Analysis_wCoffea.py /afs/cern.ch/work/s/ssawant/private/htoaa/analysis/20230223_tmp/analyze_htoaa_QCD_HT200to300_BGenFilter_TuneCP5_13TeV-madgraph-pythia8_0_0_1_config.json 2>&1 | tee cout_htoaa_Analysis_wCoffea_QCD_HT200to300_BGenFilter_0.txt && time python3 htoaa_Analysis_wCoffea.py /afs/cern.ch/work/s/ssawant/private/htoaa/analysis/20230223_tmp/analyze_htoaa_QCD_bEnriched_HT200to300_TuneCP5_13TeV-madgraph-pythia8_0_0_1_config.json 2>&1 | tee cout_htoaa_Analysis_wCoffea_QCD_bEnriched_HT200to300_0.txt

time python3 htoaa_Analysis_wCoffea.py /afs/cern.ch/work/s/ssawant/private/htoaa/analysis/20230223_tmp/analyze_htoaa_QCD_HT200to300_TuneCP5_13TeV-madgraphMLM-pythia8_0_0_1_config.json 2>&1 | tee cout_htoaa_Analysis_wCoffea_QCD_HT200to300_0.txt
time python3 htoaa_Analysis_wCoffea.py /afs/cern.ch/work/s/ssawant/private/htoaa/analysis/20230223_tmp/analyze_htoaa_QCD_HT200to300_BGenFilter_TuneCP5_13TeV-madgraph-pythia8_0_0_1_config.json 2>&1 | tee cout_htoaa_Analysis_wCoffea_QCD_HT200to300_BGenFilter_0.txt
time python3 htoaa_Analysis_wCoffea.py /afs/cern.ch/work/s/ssawant/private/htoaa/analysis/20230223_tmp/analyze_htoaa_QCD_bEnriched_HT200to300_TuneCP5_13TeV-madgraph-pythia8_0_0_1_config.json 2>&1 | tee cout_htoaa_Analysis_wCoffea_QCD_bEnriched_HT200to300_0.txt

#python3 htoaa_Analysis_wCoffea.py /afs/cern.ch/work/s/ssawant/private/htoaa/analysis/20230223_tmp/analyze_htoaa_QCD_HT200to300_TuneCP5_13TeV-madgraphMLM-pythia8_0_0_1_config.json && python3 htoaa_Analysis_wCoffea.py /afs/cern.ch/work/s/ssawant/private/htoaa/analysis/20230223_tmp/analyze_htoaa_QCD_HT200to300_BGenFilter_TuneCP5_13TeV-madgraph-pythia8_0_0_1_config.json && python3 htoaa_Analysis_wCoffea.py /afs/cern.ch/work/s/ssawant/private/htoaa/analysis/20230223_tmp/analyze_htoaa_QCD_bEnriched_HT200to300_TuneCP5_13TeV-madgraph-pythia8_0_0_1_config.json

#pythonPath=$(which python3)
#printf "pythonPath: ${pythonPath} \n\n"
#time ${pythonPath=} htoaa_Analysis_wCoffea.py /afs/cern.ch/work/s/ssawant/private/htoaa/analysis/20230223_tmp/analyze_htoaa_QCD_bEnriched_HT200to300_TuneCP5_13TeV-madgraph-pythia8_0_0_1_config.json 2>&1 | tee cout_htoaa_Analysis_wCoffea_QCD_bEnriched_HT200to300_0.txt