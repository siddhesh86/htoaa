Universe = vanilla

Proxy_filename=x509Proxy
#UserName=$(whoami)

ConfigGEN=GENFragment_$(prodmode).py
ConfigWmLHEGEN=generate_$(DatasetERA)wmLHEGEN.sh
ConfigSIM=generate_$(DatasetERA)SIM.sh
ConfigDIGIPremix=generate_$(DatasetERA)DIGIPremix.sh
ConfigHLT=generate_$(DatasetERA)HLT.sh
ConfigRECO=generate_$(DatasetERA)RECO.sh
ConfigMiniAOD=generate_$(DatasetERA)MiniAODv2.sh
ConfigNanoAOD=generate_$(DatasetERA)NanoAODv9.sh
ConfigNanoAODCustom=generate_$(DatasetERA)NanoAODv9Custom.sh


#X509_USER_PROXY=/afs/cern.ch/user/s/ssawant/$(Proxy_filename)
#X509_USER_PROXY=/home/ssawant/$(Proxy_filename)
X509_USER_PROXY=/home/$(UserName)/$(Proxy_filename)

Executable = condor_exec_MCGeneration_HToAATo4B_M-x.sh
#Arguments = $(X509_USER_PROXY) $(prodmode) $(HiggsPtMin) $(mA) $(DatasetERA) $(nEvents) $(iSample) $(XRootDRedirector) $(ipFile)
Arguments = $(Proxy_filename) $(prodmode) $(HiggsPtMin) $(mA) $(wA) $(DatasetERA) $(nEvents) $(iSample) 


transfer_input_files = $(X509_USER_PROXY), $(ConfigGEN), $(ConfigWmLHEGEN), $(ConfigSIM), $(ConfigDIGIPremix), $(ConfigHLT), $(ConfigRECO), $(ConfigMiniAOD), $(ConfigNanoAOD), $(ConfigNanoAODCustom)  
should_transfer_files = YES
when_to_transfer_output = ON_EXIT

#output_destination = root://eosuser.cern.ch//eos/user/b/bejones/condor/xfer/$(ClusterId)/
#MY.XRDCP_CREATE_DIR = True

#x509userproxy=$(X509_USER_PROXY)
#use_x509userproxy = true

Error = log/condor_MCGeneration_$(prodmode)_Pt$(HiggsPtMin)_mA-$(mA)_wA-$(wA)_$(DatasetERA)_$(iSample)_nEvents$(nEvents).err
Output = log/condor_MCGeneration_$(prodmode)_Pt$(HiggsPtMin)_mA-$(mA)_wA-$(wA)_$(DatasetERA)_$(iSample)_nEvents$(nEvents).out 
Log = log/condor_MCGeneration_$(prodmode)_Pt$(HiggsPtMin)_mA-$(mA)_wA-$(wA)_$(DatasetERA)_$(iSample)_nEvents$(nEvents).log 

# Use "rhel6", "rhel7" or "any" for RedHat6, RedHat7, or any of them, respectively.
#+REQUIRED_OS = "rhel7"
#+REQUIRED_OS = "any"
Requirements = HAS_SINGULARITY == True
#+SingularityImage = "/cvmfs/singularity.opensciencegrid.org/opensciencegrid/osgvo-el6:latest"
+SingularityImage = "/cvmfs/singularity.opensciencegrid.org/opensciencegrid/osgvo-el7:latest"

# +ProjectName is the name of the project reported to the OSG accounting system 
+ProjectName="cms.org.baylor"

# Global Pool parameters
#+DESIRED_Sites = "T3_US_Colorado,T2_US_Caltech,T2_US_Florida,T2_US_MIT,T2_US_Nebraska,T2_US_Vanderbilt,T2_US_Wisconsin,T2_CH_CERN,T1_US_FNAL"
# Original
#+DESIRED_Sites = "T3_US_Colorado,T2_US_Caltech,T2_US_Florida,T2_US_MIT,T2_US_Nebraska,T2_US_Purdue,T2_US_UCSD,T2_US_Vanderbilt,T2_US_Wisconsin,T2_CH_CERN,T1_US_FNAL"
# From TTZToQQ
#+DESIRED_Sites = "T2_CH_CERN,T1_DE_KIT,T2_UK_SGrid_RALPP"

## Specify CPU,Memory and Disk
## Default units if not specified: 2gb of memory and 20gb of disk space. 2gb / core 
## Disk: Kb, Memory:Mb
RequestMemory = 15600
RequestCpus = 8

# 7200 # 2*60*60
#+MaxRuntime = 7200
# 8*60*60 = 28800
#+MaxRuntime = 28800
# 86400 # 24*60*60 
+MaxRuntime = 86400 

#Queue prodmode, HiggsPtMin, mA, wA, DatasetERA, nEvents, iSample, XRootDRedirector, ipFile, UserName from params_MCGeneration_HToAATo4B_M-x.txt
Queue prodmode, HiggsPtMin, mA, wA, DatasetERA, nEvents, iSample, UserName from params_MCGeneration_HToAATo4B_M-x.txt
