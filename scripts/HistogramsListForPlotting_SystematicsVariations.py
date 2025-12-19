import os
import numpy as np
from collections import OrderedDict as OD

sXRange = "xAxisRange"; sYRange = "yAxisRange";
sXLabel = 'xAxisLabel'; sYLabel = 'yAxisLabel';
sXScale = 'xAxisScale';
sNRebin = "nRebin"
sHistosToOverlay = 'histosToOverlay'
sHistosToHadd = 'histosToHadd'
sIpFileNameNice = 'ipFileNameNice'
sHistName   = 'histogramName'
sScaleFactors = 'sScaleFactors'
sMakeRatioPlot = 'sMakeRatioPlot'
sOpDirSeperate = 'sOpDirSeperate'


sIpFiles = OD()

sIpFiles = OD([
    # (<file name to refer>, <file path+name>)
    #('SystVariations', '/eos/cms/store/user/ssawant/htoaa/analysis/20240809_gg0l_FullSyst/2018/analyze_htoaa_stage1.root')   
    #('SystVariations', '/eos/cms/store/user/ssawant/htoaa/analysis/20240809_gg0l_FullSyst/2018/analyze_htoaa_SUSY_GluGluH_01J_HToAATo4B_Pt150_M-30_TuneCP5_13TeV_madgraph_pythia8_0_0.root')   
    #('SystVariations', '/afs/cern.ch/work/s/ssawant/private/htoaa/analysis/testRun/analyze_htoaa_SUSY_GluGluH_01J_HToAATo4B_Pt150_M-20_TuneCP5_13TeV_madgraph_pythia8_0_0.root') 
    ('SystVariations', '/afs/cern.ch/work/s/ssawant/private/htoaa/analysis/testRun/analyze_htoaa_SUSY_WH_WToAll_HToAATo4B_Pt150_M-20_TuneCP5_13TeV_madgraph_pythia8_0_0.root') 

])
sAnaVersion = list(sIpFiles.keys())[0]
print(f"sAnaVersion: {sAnaVersion}")

#sOpDir  = '/eos/cms/store/user/ssawant/htoaa/analysis/testFullSyst/2018/gg0l/plots_20251015/%s' % (sAnaVersion)
sOpDir  = '/eos/cms/store/user/ssawant/htoaa/analysis/testFullSyst/2018/Vjj/plots_20251015/%s' % (sAnaVersion)

CATAGORIES = ["VjjIncl"] #["gg0lIncl"]
MCProcesses = ['WHtoaato4b_mA_20'] # ['ggHtoaato4b_mA_20']
YEARS = ['2018']
SYSTMATICS_gg0l = [
    'CMS_pileup_$YEAR',
    'CMS_pileup_$YEAR', 
    'CMS_eff_j_trigger_$YEAR', 
    #'CMS_eff_met_trigger_$YEAR', 
    #'CMS_eff_e_trigger_$YEAR', 
    #'CMS_eff_m_trigger_$YEAR', 
    'CMS_l1_ecal_prefiring_$YEAR', 

    'CMS_HEM_2018', 

    #'CMS_btag_fixedWP_comb_bc_$YEAR', 
    'CMS_btag_fixedWP_comb_bc_correlated', 
    'CMS_btag_fixedWP_comb_bc_uncorrelated_$YEAR', 
    #'CMS_eff_fj_ParticleNet_WZ_Nominal_$YEAR', 
    #'CMS_eff_fj_ParticleNet_Top_Nominal_$YEAR', 

    'CMS_scale_fj_$YEAR', 
    'CMS_res_fj_$YEAR', 
    'CMS_scale_j_$YEAR', 
    'CMS_res_j_$YEAR', 
    'CMS_scale_met_unclustered_energy_$YEAR', 

    'CMS_NPS25005_scale_fj_massH_$YEAR', 
    'CMS_NPS25005_res_fj_massH_$YEAR', 
    'CMS_NPS25005_scale_fj_massA_$YEAR', 
    'CMS_NPS25005_res_fj_massA_$YEAR', 

    #'higgs_pt_reweighting_ggH', 
    #'higgs_pt_reweighting_qqH', 
    #'higgs_pt_reweighting_WH', 
    #'higgs_pt_reweighting_ZH', 
    #'higgs_pt_reweighting_ttH', 
    'CMS_eff_fj_LundPlan_reweighting', 
    #'top_pt_reweighting', 
    'ps_isr', 'ps_fsr', 
    'QCDScale', 
    'pdf_99'
]
SYSTMATICS_Vjj = SYSTMATICS_gg0l + [
    'CMS_eff_fj_ParticleNet_WZ_Nominal_$YEAR', 
]
SYSTMATICS_tt0l = SYSTMATICS_gg0l + [
    'CMS_eff_fj_ParticleNet_Top_Nominal_$YEAR', 
]
SYSTMATICS_Zvv = SYSTMATICS_gg0l + [
    'CMS_eff_met_trigger_$YEAR', 
]
SYSTMATICS_Zvv.remove('CMS_eff_j_trigger_$YEAR')


histoNamesShorts_dict = {
    #'hLeadingFatJetMass_vs_massA_Hto4b_avg':                        'mass',
    #'hLeadingFatJetMSoftDrop_vs_massA_Hto4b_avg':                   'msoft',
    #'hLeadingFatJetParticleNet_massH_Hto4b_avg_vs_massA_Hto4b_avg': 'pnet',  
    #'hLeadingFatJetMSoftDrop':                   'msoft',  
    #'hLeadingFatJetPt': 'FatJetPt'
    'hLeadingFatJetMassH_v2b': 'PNetMassH',
    'hLeadingFatJetPNet_34massAa': 'PNetMassAa',
    'hLeadingFatJetPNet_34massAd': 'PNetMassAd',
    'hLeadingNonHto4bFatJetMSoftDrop': 'VMsoftdrop',
    
}



if not os.path.exists(sOpDir):
    os.makedirs(sOpDir)


histograms_dict = OD()

print(f"{CATAGORIES = }, \n{histograms_dict = }")

for category in CATAGORIES:
    if 'gg0l' in category:
        SYSTMATICS = SYSTMATICS_gg0l
    elif 'Vjj' in category:
        SYSTMATICS = SYSTMATICS_Vjj
    elif 'tt0l' in category:
        SYSTMATICS = SYSTMATICS_tt0l
    elif 'Zvv' in category:
        SYSTMATICS = SYSTMATICS_gg0l

    print(f"{category = }, \n{SYSTMATICS = }")

    for year in YEARS:
        print(f"{year = }")

        if '18' in year:
            SYSTMATICS.remove('CMS_l1_ecal_prefiring_$YEAR',)

        for MCProcess in MCProcesses:
            print(f"{MCProcess = }")

            if   'ggHtoaato4b' in MCProcess:
                SYSTMATICS.append('higgs_pt_reweighting_ggH')
            elif 'VBFHtoaato4b' in MCProcess:
                SYSTMATICS.append('higgs_pt_reweighting_qqH')
            elif 'WHtoaato4b' in MCProcess:
                SYSTMATICS.append('higgs_pt_reweighting_WH')
            elif 'ZHtoaato4b' in MCProcess:
                SYSTMATICS.append('higgs_pt_reweighting_ZH')
            elif 'ttHtoaato4b' in MCProcess:
                SYSTMATICS.append('higgs_pt_reweighting_ttH')


            for syst0 in SYSTMATICS:
                syst = syst0
                syst = syst.replace('$YEAR', year)
                print(f"{syst = }")    

                Xto4bWP = '40' if 'gg0l' in category else '60'

                for histo_name, histo_name_toSave in histoNamesShorts_dict.items():
                    histo_name_toUse = '%s_%s_%s' % (category, histo_name, syst)
                    print(f"{histo_name = }")    
                    xRange_toUse = None
                    sNRebin_toUse = 1
                    if histo_name == 'hLeadingFatJetMSoftDrop': 
                        xRange_toUse = [50, 170]
                        sNRebin_toUse = 4
                    if histo_name == 'hLeadingFatJetPt': 
                        xRange_toUse = [250, 800]
                        sNRebin_toUse = 4
                    if histo_name == 'hLeadingFatJetMassH_v2b': 
                        xRange_toUse = [60, 170]
                        sNRebin_toUse = 1                
                    if 'massA' in histo_name: 
                        xRange_toUse = [10, 70]
                        sNRebin_toUse = 20
                    


                    histograms_dict[histo_name_toUse] = {
                        sXLabel: '%s [GeV]'%(histo_name_toSave), sYLabel: 'A. U.',
                        sXRange: xRange_toUse, #sXScale: 'log_10',
                        sNRebin: sNRebin_toUse, 
                        sMakeRatioPlot: True,
                        sOpDirSeperate: '%s/%s' % (sOpDir, MCProcess),
                        sHistosToOverlay: OD([# ('h1', [{histoToOverlay1}]),  ('h2', [{histoToOverlay2}]), ('h3', [{histoTohadd3p1}, {histoTohadd3p2}, ...]), ('hi',[{}]), ...]
                            ("Nom", [
                                {sIpFileNameNice: sAnaVersion, sHistName: 'evt/%s/%s_%s_Xto4bv2_SBplusSRWP%s_Nom' % (MCProcess, histo_name, category, Xto4bWP)},
                            ]),
                            ("%sUp" % (syst), [
                                {sIpFileNameNice: sAnaVersion, sHistName: 'evt/%s/%s_%s_Xto4bv2_SBplusSRWP%s_%sUp' % (MCProcess, histo_name, category, Xto4bWP, syst)},
                            ]),
                            ("%sDown" % (syst), [
                                {sIpFileNameNice: sAnaVersion, sHistName: 'evt/%s/%s_%s_Xto4bv2_SBplusSRWP%s_%sDown' % (MCProcess, histo_name, category, Xto4bWP, syst)},
                            ]),
                        ])
                    }

