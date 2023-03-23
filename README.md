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
[Set path to output log files](https://github.com/siddhesh86/htoaa/blob/af77e9deb492fd84b6de29a794ffb09b9be2ffb1/MCGeneration_wrapper.sh#L13-L32),
[Set proxy path](https://github.com/siddhesh86/htoaa/blob/af77e9deb492fd84b6de29a794ffb09b9be2ffb1/MCGeneration_wrapper.sh#L543) and 
[Set proxy path](https://github.com/siddhesh86/htoaa/blob/af77e9deb492fd84b6de29a794ffb09b9be2ffb1/MCGeneration_wrapper.sh#L626).



To run MCGeneration_wrapper.sh:
```
source MCGeneration_wrapper.sh
```