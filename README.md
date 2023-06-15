# Production of large width H->aa samples

Clone the repository:
```
git clone -b MCGeneration  git@github.com:siddhesh86/htoaa.git
```

Set proxy every time before submitting HT condor jobs.
```
voms-proxy-init --rfc --voms cms -valid 192:00
cp /tmp/x509up_u108989 ~/
```

**MCGeneration_wrapper.sh** produce scripts for MC sample production and submit them to run on HT Condor. Make the appropirate changes at
[Set Higgs pT threshold point and sample file number range](https://github.com/siddhesh86/htoaa/blob/50d733bfe8790a526f168617b98b51b9e5b8ba4c/MCGeneration_wrapper.sh#L15-L29).


To run MCGeneration_wrapper.sh:
```
source MCGeneration_wrapper.sh
```

Note: Running MCGeneration_wrapper.sh with sample file numbers from already produced sample files will delete the corresponding HT Condor log files from the jobs. Hence run MCGeneration_wrapper.sh twice, for the first round to produce samples, and for the second time to clean up disk space by deleting log files for the produce samples.