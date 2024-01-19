Universe = vanilla

Proxy_filename=x509up_u108989
#X509_USER_PROXY=/afs/cern.ch/user/s/ssawant/$(Proxy_filename)
X509_USER_PROXY=/home/ssawant/$(Proxy_filename)

Executable = condor_exec_MCGeneration_HToAATo4B_M-x.sh
#Arguments = $(X509_USER_PROXY) $(prodmode) $(HiggsPtMin) $(mA) $(DatasetERA) $(nEvents) $(iSample) $(XRootDRedirector) $(ipFile)
Arguments = $(Proxy_filename) $(prodmode) $(HiggsPtMin) $(mA) $(DatasetERA) $(nEvents) $(iSample) $(XRootDRedirector) $(ipFile) 


transfer_input_files = $(X509_USER_PROXY), GENFragment_SUSY_GluGluH_01J_HToAATo4B.py, generate_RunIISummer20UL18wmLHEGEN.sh, generate_RunIISummer20UL18SIM.sh, generate_RunIISummer20UL18DIGIPremix.sh, generate_RunIISummer20UL18HLT.sh, generate_RunIISummer20UL18RECO.sh, generate_RunIISummer20UL18MiniAODv2.sh, generate_RunIISummer20UL18NanoAODv9.sh 
should_transfer_files = YES
when_to_transfer_output = ON_EXIT

#x509userproxy=$(X509_USER_PROXY)
#use_x509userproxy = true

Error = log/condor_MCGeneration_$(prodmode)_Pt$(HiggsPtMin)_M-$(mA)_$(iSample)_nEvents$(nEvents).err
Output = log/condor_MCGeneration_$(prodmode)_Pt$(HiggsPtMin)_M-$(mA)_$(iSample)_nEvents$(nEvents).out 
Log = log/condor_MCGeneration_$(prodmode)_Pt$(HiggsPtMin)_M-$(mA)_$(iSample)_nEvents$(nEvents).log 

# Use "rhel6", "rhel7" or "any" for RedHat6, RedHat7, or any of them, respectively.
#+REQUIRED_OS = "rhel7"
#+REQUIRED_OS = "any"
Requirements = HAS_SINGULARITY == True
#+SingularityImage = "/cvmfs/singularity.opensciencegrid.org/opensciencegrid/osgvo-el6:latest"
+SingularityImage = "/cvmfs/singularity.opensciencegrid.org/opensciencegrid/osgvo-el7:latest"

# +ProjectName is the name of the project reported to the OSG accounting system 
+ProjectName="cms.org.baylor"

# 7200 # 2*60*60
#+MaxRuntime = 7200
# 8*60*60 = 28800
+MaxRuntime = 28800
# 86400 # 24*60*60 
#+MaxRuntime = 86400 

Queue prodmode, HiggsPtMin, mA, DatasetERA, nEvents, iSample, XRootDRedirector, ipFile from params_MCGeneration_HToAATo4B_M-x.txt
