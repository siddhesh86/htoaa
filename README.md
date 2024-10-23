# Production of large width H->aa samples

Clone the repository:
```
git clone -b MCGeneration  git@github.com:siddhesh86/htoaa.git
```

Set proxy every time before submitting HT condor jobs.
```
voms-proxy-init -voms cms -rfc -valid 192:00 --out ~/x509Proxy
```

## To run on cms-connect:
Edit generate_params_MCGeneration_HToAATo4B_M-x.sh to generate params_MCGeneration_HToAATo4B_M-x.txt with required sample parameters for MC sample generation.
Run generate_params_MCGeneration_HToAATo4B_M-x.sh to generate new params_MCGeneration_HToAATo4B_M-x.txt:
```
. generate_params_MCGeneration_HToAATo4B_M-x.sh
```

Edit condor_submit_MCGeneration_HToAATo4B_M-x_cmsconnect.sh if you want to change HTCondor job submission parameters.

To submit HTCondor jobs:
```
voms-proxy-init -voms cms -rfc -valid 192:00 --out ~/x509Proxy
condor_submit condor_submit_MCGeneration_HToAATo4B_M-x_cmsconnect.sh 
```



## To run on lxplus:
**MCGeneration_wrapper.sh** produce scripts for MC sample production and submit them to run on HT Condor. Make the appropirate changes at
[Set Higgs pT threshold point and sample file number range](https://github.com/siddhesh86/htoaa/blob/50d733bfe8790a526f168617b98b51b9e5b8ba4c/MCGeneration_wrapper.sh#L15-L29).


To run MCGeneration_wrapper.sh:
```
source MCGeneration_wrapper.sh
```

Note: Running MCGeneration_wrapper.sh with sample file numbers from already produced sample files will delete the corresponding HT Condor log files from the jobs. Hence run MCGeneration_wrapper.sh twice, for the first round to produce samples, and for the second time to clean up disk space by deleting log files for the produce samples.

## Generating Madgraph gridpacks for HToAATo4B signals:
```
cd /afs/cern.ch/work/s/ssawant/private/htoaa/MCproduction/HToAATo4B/MCGridpacks/genproductions/bin/MadGraph5_aMCatNLO
cmssw-el7
time ./gridpack_generation_HToAATo4B.sh 2>&1 | tee cout_tmp.txt
```


# References:
The followingMC configuration files taken from McM are used for MC production.
- 2018:
  - [SUSY_GluGluH_01J_HToAATo4B_Pt150 in RunIISummer20UL18](https://cms-pdmv-prod.web.cern.ch/mcm/chained_requests?prepid=HIG-chain_RunIISummer20UL18wmLHEGEN_flowRunIISummer20UL18SIM_flowRunIISummer20UL18DIGIPremix_flowRunIISummer20UL18HLT_flowRunIISummer20UL18RECO_flowRunIISummer20UL18MiniAODv2_flowRunIISummer20UL18NanoAODv9-01966&page=0&shown=15)
  - [SUSY_VBFH_HToAATo4B_Pt150 in RunIISummer20UL18](https://cms-pdmv-prod.web.cern.ch/mcm/chained_requests?contains=HIG-RunIISummer20UL18wmLHEGEN-02533&page=0&shown=15)
  - [SUSY_WH_WToAll_HToAATo4B_Pt150 in RunIISummer20UL18](https://cms-pdmv-prod.web.cern.ch/mcm/chained_requests?contains=HIG-RunIISummer20UL18wmLHEGEN-02555&page=0&shown=15)
  - [SUSY_ZH_ZToAll_HToAATo4B_Pt150 in RunIISummer20UL18](https://cms-pdmv-prod.web.cern.ch/mcm/chained_requests?contains=HIG-RunIISummer20UL18wmLHEGEN-02577&page=0&shown=15)
  - [SUSY_TTH_TTToAll_HToAATo4B_Pt150 in RunIISummer20UL18](https://cms-pdmv-prod.web.cern.ch/mcm/chained_requests?contains=HIG-RunIISummer20UL18wmLHEGEN-02599&page=0&shown=15)

- 2017:
  - [SUSY_GluGluH_01J_HToAATo4B_Pt150 in RunIISummer20UL17](https://cms-pdmv-prod.web.cern.ch/mcm/chained_requests?contains=HIG-RunIISummer20UL17wmLHEGEN-02463&page=0&shown=15)
- 2016:
  - [SUSY_GluGluH_01J_HToAATo4B_Pt150 in RunIISummer20UL16](https://cms-pdmv-prod.web.cern.ch/mcm/chained_requests?contains=HIG-RunIISummer20UL16wmLHEGEN-02538&page=0&shown=15)
- 2016APV:
  - [SUSY_GluGluH_01J_HToAATo4B_Pt150 in RunIISummer20UL16APV](https://cms-pdmv-prod.web.cern.ch/mcm/chained_requests?contains=HIG-RunIISummer20UL16wmLHEGENAPV-02022&page=0&shown=15)


