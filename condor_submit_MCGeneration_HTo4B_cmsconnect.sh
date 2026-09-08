Universe = vanilla

Proxy_filename=x509Proxy

ConfigGEN=MCConfigs/GENFragments_$(ECM)TeV/GENFragment_$(prodmode).py
ConfigMCStep=MCConfigs/$(DatasetERA)/generate_$(DatasetERA)$(MCStep).sh

X509_USER_PROXY=/home/$(UserName)/$(Proxy_filename)

Executable = condor_exec_MCGeneration_HTo4B.sh
Arguments = $(Proxy_filename) $(prodmode) $(HiggsPtMin) $(DatasetERA) $(MCStep) $(nEvents) $(iSample) $(XRootDRedirector) $(ipFile) $(opFile)


transfer_input_files = $(X509_USER_PROXY), $(ConfigGEN), $(ConfigMCStep)  
should_transfer_files = YES
when_to_transfer_output = ON_EXIT
#transfer_output_files   = pLHEGenSim_GluGluHJ_HTo4B_1_cfg.py, pLHEGenSim_GluGluHJ_HTo4B_report.xml

Error = log/condor_MCGeneration_$(prodmode)_Pt$(HiggsPtMin)_$(DatasetERA)_$(iSample)_$(MCStep)_nEvents$(nEvents).err
Output = log/condor_MCGeneration_$(prodmode)_Pt$(HiggsPtMin)_$(DatasetERA)_$(iSample)_$(MCStep)_nEvents$(nEvents).out 
Log = log/condor_MCGeneration_$(prodmode)_Pt$(HiggsPtMin)_$(DatasetERA)_$(iSample)_$(MCStep)_nEvents$(nEvents).log 


# +ProjectName is the name of the project reported to the OSG accounting system 
+ProjectName="cms.org.baylor"

# Global Pool parameters
#+DESIRED_Sites = "T3_US_Colorado,T2_US_Caltech,T2_US_Florida,T2_US_MIT,T2_US_Nebraska,T2_US_Vanderbilt,T2_US_Wisconsin,T2_CH_CERN,T1_US_FNAL"
# Original
#+DESIRED_Sites = "T3_US_Colorado,T2_US_Caltech,T2_US_Florida,T2_US_MIT,T2_US_Nebraska,T2_US_Purdue,T2_US_UCSD,T2_US_Vanderbilt,T2_US_Wisconsin,T2_CH_CERN,T1_US_FNAL"

## Specify CPU,Memory and Disk
## Default units if not specified: 2gb of memory and 20gb of disk space. 2gb / core 
## Disk: Kb, Memory:Mb
RequestMemory = 15600
RequestCpus = 8

# 7200 # 2*60*60
+MaxRuntime = 7200
# 8*60*60 = 28800
#+MaxRuntime = 28800
# 86400 # 24*60*60 
#+MaxRuntime = 86400 

Queue prodmode, HiggsPtMin, ECM, DatasetERA, MCStep, nEvents, iSample, XRootDRedirector, ipFile, opFile, UserName from params_MCGeneration_HTo4B.txt
