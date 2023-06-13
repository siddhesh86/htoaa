# htoaa Analysis Framework using Coffea

## Seting up environment using conda
1. Install 'conda' on your system/lxplus. Suggestion: Follow https://docs.anaconda.com/anaconda/install/linux/

2. Once conda is installed, set up conda environment named ' myCondaEnv' to install the required software libraries/packages using
   ```
   conda env create --name myCondaEnv  --file environment_lxplus.yml 
   ```
3. Activate conda envirnment every time you login into your system/lxplus
   ```
   conda activate myCondaEnv 
   ```


## Set proxy when you open a new terminal on lxplus or after every few days
```
voms-proxy-init --rfc --voms cms -valid 192:00 --out ~/x509up_u108989
```

## Analysis steps

### Prepare samples' list with all details (Samples_2018UL.csv)
Add/update dataset name and cross-sections for all samples in 'samplesList_prepare.py'.\
To run:
```
python3 samplesList_prepare.py -era <era>\
cp Samples_2018UL_v0.json Samples_2018UL.json
```
Add commandline option '-updateCrossSections' to update cross-section value in the existing sample list.


### Calculate sumEvents
Calculate sumEvents as number of events with positive generator weight minus number of events with negative weight.\
In htoaa_Samples.py, set 'QCDInclMode = 0'.\ 
Run:
```
python3 htoaa_Wrapper.py -analyze countSumEventsInSample.py -era <era> -v <version name> 
```
It runs jobs in HT Condor, and produces final output hadd root file.
Set path of the output hadd root file in 'samplesList_update.py' and run
```
python3 samplesList_update.py -era <era>
```
This updates samples' full detail list with sumEvents. Now samples' full detail list (Samples_2018UL.csv) is ready for the further analysis. Now on the previous analysis steps need not to run again.



### Calculate HT reweight SFs for QCD_bGenFilter sample
In scripts/CopyHistos.py, update 'sIpFile' to point to the latest analyze_htoaa_stage1.root file. \
Run to copy the required histograms into a seperate file stored in data/:
```
cd scripts/
python3 CopyHistos.py
```
Calculate HT reweights for QCD_bGen sample:
```
cd corrections/
python3 cal_HTRewght_QCDbGen.py -era <era>
```
Copy "HTRewgt" SFs printed on the terminal into "Corrections" variable in htoaa_Settings.py file.



### Calculate lumi-scale for MC samples stitch with reweighting overlapping phase space
Calculate lumi-scale for MC samples stitch with reweighting overlapping phase space, instead of removing overlapping phase space.\
In htoaa_Samples.py, set 'QCDInclMode = 2' to use QCD_Incl_madgraph-PSWeights sample for QCD_Incl.\
Run:
```
python3 calculateLumiscale.py -era <era>
```
 



### Running analysis
'htoaa_Analysis_GGFMode.py' is a central analysis macro to run the GGF htoaa analysis. It takes input and output file name and other settings in input through config.json file. Command to run on individual config.json file:
```
python3 htoaa_Analysis_wCoffea.py <config>.json
```

'htoaa_Wrapper.py' prepares the config.json files for differnt data/MC samples and run with htoaa_Analysis_GGFMode.py in parallel HT Condor jobs.
Command to run htoaa analysis macro on data and MC samples:
```
python3 htoaa_Wrapper.py -analyze htoaa_Analysis_GGFMode.py -era <era> -run_mode condor -v <version name>  -xrdcpIpAftNResub 0
```


## Description of files
**htoaa_Settings.py**: File listing main analysis options.

**htoaa_CommonTools.py**: Common functions used to run the analysis

**htoaa_Samples.py**: List of data and MC samples to run for the analysis.

**Samples_2018UL.csv**: Dictionary of all data and MC samples with NanoAOD files, cross-section etc listed for each sample.

**samplesList_prepare.py**: Prepare 'Samples_2018UL.csv' from needed samples using CMS-DAS (Data Aggregation System) tool.