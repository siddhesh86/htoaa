# Production of large width H->aa samples

Clone the repository:
```
git clone -b MCGeneration  git@github.com:siddhesh86/htoaa.git
```

Set proxy every time before submitting HT condor jobs.
```
voms-proxy-init --rfc --voms cms -valid 192:00
```

**MCGeneration_wrapper.sh** produce scripts for MC sample production and submit them to run on HT Condor. Make the appropirate changes at the begining in MCGeneration_wrapper.sh file.
To run MCGeneration_wrapper.sh:
```
source MCGeneration_wrapper.sh
```