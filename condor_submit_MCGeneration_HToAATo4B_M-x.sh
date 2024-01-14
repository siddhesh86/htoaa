Universe = vanilla
Executable = condor_exec_MCGeneration_HToAATo4B_M-x.sh
Arguments = $(prodmode) $(HiggsPtMin) $(mA) $(DatasetERA) $(nEvents) $(iSample) $(XRootDRedirector) $(ipFile) 

Error = log/condor_MCGeneration_$(prodmode)_Pt$(HiggsPtMin)_M-$(mA)_$(iSample)_nEvents$(nEvents).err
Output = log/condor_MCGeneration_$(prodmode)_Pt$(HiggsPtMin)_M-$(mA)_$(iSample)_nEvents$(nEvents).out 
Log = log/condor_MCGeneration_$(prodmode)_Pt$(HiggsPtMin)_M-$(mA)_$(iSample)_nEvents$(nEvents).log 

transfer_input_files = GENFragment_SUSY_GluGluH_01J_HToAATo4B.py, generate_RunIISummer20UL18wmLHEGEN.sh, generate_RunIISummer20UL18SIM.sh, generate_RunIISummer20UL18DIGIPremix.sh, generate_RunIISummer20UL18HLT.sh, generate_RunIISummer20UL18RECO.sh, generate_RunIISummer20UL18MiniAODv2.sh, generate_RunIISummer20UL18NanoAODv9.sh 
should_transfer_files = YES
when_to_transfer_output = ON_EXIT

use_x509userproxy = true


Queue prodmode, HiggsPtMin, mA, DatasetERA, nEvents, iSample, XRootDRedirector, ipFile from params_MCGeneration_HToAATo4B_M-x.txt
