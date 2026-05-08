import os
import sys
import numpy as np
from collections import OrderedDict as OD
import copy

sys.path.append( os.path.abspath('../') )
print(f"{os.path.abspath('../') = }")

from htoaa_Settings import *
from htoaa_Samples  import *


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
sOpSubdir = 'sOpSubdir'




sIpFiles = OD([
    # (<file name to refer>, <file path+name>)
    ('2016preVFP_gg0l',  '/eos/cms/store/user/ssawant/htoaa/analysis/20260404_UnblindingChecksStep3p1/2016preVFP/gg0l/analyze_htoaa_stage1.root'),
    ('2016postVFP_gg0l', '/eos/cms/store/user/ssawant/htoaa/analysis/20260404_UnblindingChecksStep3p1/2016postVFP/gg0l/analyze_htoaa_stage1.root'),
    ('2017_gg0l',        '/eos/cms/store/user/ssawant/htoaa/analysis/20260404_UnblindingChecksStep3p1/2017/gg0l/analyze_htoaa_stage1.root'),
    ('2018_gg0l',        '/eos/cms/store/user/ssawant/htoaa/analysis/20260404_UnblindingChecksStep3p1/2018/gg0l/analyze_htoaa_stage1.root'),
    
    ('2016preVFP_Vjj',  '/eos/cms/store/user/ssawant/htoaa/analysis/20260404_UnblindingChecksStep3p1/2016preVFP/Vjj/analyze_htoaa_stage1.root'),
    ('2016postVFP_Vjj', '/eos/cms/store/user/ssawant/htoaa/analysis/20260404_UnblindingChecksStep3p1/2016postVFP/Vjj/analyze_htoaa_stage1.root'),
    ('2017_Vjj',        '/eos/cms/store/user/ssawant/htoaa/analysis/20260404_UnblindingChecksStep3p1/2017/Vjj/analyze_htoaa_stage1.root'),
    ('2018_Vjj',        '/eos/cms/store/user/ssawant/htoaa/analysis/20260404_UnblindingChecksStep3p1/2018/Vjj/analyze_htoaa_stage1.root'),

    ('2016preVFP_Zvv',  '/eos/cms/store/user/ssawant/htoaa/analysis/20260404_UnblindingChecksStep3p1/2016preVFP/Zvv/analyze_htoaa_stage1.root'),
    ('2016postVFP_Zvv', '/eos/cms/store/user/ssawant/htoaa/analysis/20260404_UnblindingChecksStep3p1/2016postVFP/Zvv/analyze_htoaa_stage1.root'),
    ('2017_Zvv',        '/eos/cms/store/user/ssawant/htoaa/analysis/20260404_UnblindingChecksStep3p1/2017/Zvv/analyze_htoaa_stage1.root'),
    ('2018_Zvv',        '/eos/cms/store/user/ssawant/htoaa/analysis/20260404_UnblindingChecksStep3p1/2018/Zvv/analyze_htoaa_stage1.root'),

    ('2016preVFP_tt0l',  '/eos/cms/store/user/ssawant/htoaa/analysis/20260404_UnblindingChecksStep3p1/2016preVFP/tt0l/analyze_htoaa_stage1.root'),
    ('2016postVFP_tt0l', '/eos/cms/store/user/ssawant/htoaa/analysis/20260404_UnblindingChecksStep3p1/2016postVFP/tt0l/analyze_htoaa_stage1.root'),
    ('2017_tt0l',        '/eos/cms/store/user/ssawant/htoaa/analysis/20260404_UnblindingChecksStep3p1/2017/tt0l/analyze_htoaa_stage1.root'),
    ('2018_tt0l',        '/eos/cms/store/user/ssawant/htoaa/analysis/20260404_UnblindingChecksStep3p1/2018/tt0l/analyze_htoaa_stage1.root'),

      
])
sAnaVersion = 'UnblindingChecksStep3p1_B'
print(f"sAnaVersion: {sAnaVersion}")

#sOpDir  = '/home/siddhesh/Work/CMS/htoaa/analysis/20230324_QCD_HT100to200/plots'
sOpDir  = '/eos/cms/store/user/ssawant/htoaa/analysis/20260404_UnblindingChecksStep3p1/Run2/plots/%s' % (sAnaVersion)

'''
histograms_dict = OD([
    #("hLeadingPtGenBquark_pt_all", {sXLabel: 'Leading FatJet mass [GeV]', sYLabel: 'Events', sXRange: [0, 200]}),


    ("2016_gg0lLo", {
        sXLabel: 'pT(Higgs candidate AK8 jet) [GeV]', sYLabel: 'Events',
        sXRange: [180, 1000], #sXScale: 'log_10',
        sNRebin: 4, 
        sHistosToOverlay: OD([# ('h1', [{histoToOverlay1}]),  ('h2', [{histoToOverlay2}]), ('h3', [{histoTohadd3p1}, {histoTohadd3p2}, ...]), ('hi',[{}]), ...]
            ("mA15_SR", [
                {sIpFileNameNice: '2016preVFP_gg0l', sHistName: 'evt/JetHT_Run2016B-ver2_HIPM/hLeadingFatJetPt_gg0lLo_Xto4bv2_SRWP40_mA15_SR_noweight'},
                
            ])
        ]),

    }),



   
    
])

'''

def get_EraName_forInputFile(DatasetName): # DatasetName: JetHT_Run2016B-ver2_HIPM
    EraName_forInputFile = ''
    if DatasetName in Samples2016preVFP:  EraName_forInputFile = '2016preVFP'
    if DatasetName in Samples2016postVFP: EraName_forInputFile = '2016postVFP'
    if DatasetName in Samples2017:        EraName_forInputFile = '2017'
    if DatasetName in Samples2018:        EraName_forInputFile = '2018'  
    print(f"get_EraName_forInputFile({DatasetName}): {EraName_forInputFile = }")
    return EraName_forInputFile



mA_regions_unblindingChkStp3p1_dict = {
    'gg0lLo': ['mA15'],
    'gg0lHi': ['mA18p5', 'mA55', ],
    'VjjLo': ['mA23'],  # VjjLo, tt0l0b
    'VjjHi': ['mA45to55'],    
    'LepHi': ['mA42to48'],# ZvvHi, tt0l1b
}

Subcategories_unblindingChkStp3p1 = ['gg0lLo', 'gg0lHi', 'VjjLo', 'VjjHi', 'ZvvHi', 'tt0l0b', 'tt0l1b'] # ['gg0lLo', 'VjjLo']
Eras_unblindingChkStp3p1 = ['2016', '2017', '2018']


histogram_stage0_dict_0 = OD()
histogram_stage0_dict_0['LeadingFatJetPt'] = {sXLabel: 'pT(Higgs candidate AK8 jet) [GeV]', sYLabel: 'Events', sXRange: [180, 1000], sNRebin: 20} 
histogram_stage0_dict_0['LeadingFatJetEta'] = {sXLabel: 'eta(Higgs candidate AK8 jet)', sYLabel: 'Events', sXRange: [-3, 3], sNRebin: 4} 
histogram_stage0_dict_0['LeadingFatJetPhi'] = {sXLabel: 'phi(Higgs candidate AK8 jet)', sYLabel: 'Events', sNRebin: 12} 
histogram_stage0_dict_0['LeadingFatJetMass'] = {sXLabel: 'mass(Higgs candidate AK8 jet) [GeV]', sYLabel: 'Events', sXRange: [50, 200], sNRebin: 4} 
histogram_stage0_dict_0['LeadingFatJetMSoftDrop'] = {sXLabel: 'soft drop mass(Higgs candidate AK8 jet) [GeV]', sYLabel: 'Events', sXRange: [50, 200], sNRebin: 4} 
histogram_stage0_dict_0['LeadingFatJetMassH_v2b'] = {sXLabel: 'PNet X4b mass(Higgs candidate AK8 jet) [GeV]', sYLabel: 'Events', sXRange: [50, 200], sNRebin: 4} 
histogram_stage0_dict_0['LeadingFatJetPNet_34massAa'] = {sXLabel: 'a mass (PNet X4b) [GeV]', sYLabel: 'Events', sXRange: [0, 70], sNRebin: 20} 
histogram_stage0_dict_0['LeadingFatJetPNet_X4b_v2ab_Haa4b_score'] = {sXLabel: 'PNet X4b score', sYLabel: 'Events', sXRange: [0.8, 1], sNRebin: 10} 
histogram_stage0_dict_0['LeadingFatJetParticleNetMD_XbbOverQCD'] = {sXLabel: 'PNet Xbb score', sYLabel: 'Events', sXRange: [0.75, 1], sNRebin: 1} 

histogram_stage0_dict_0['RunNumber'] = {sXLabel: 'Run number', sYLabel: 'Events', sNRebin: 10, } 
histogram_stage0_dict_0['PV_npvsGood'] = {sXLabel: 'PU', sYLabel: 'Events', sXRange: [10,60], sNRebin: 5} 






histograms_dict = OD()


for Subcategory_unblindingChkStp3p1 in Subcategories_unblindingChkStp3p1: 
    if 'gg0l' in Subcategory_unblindingChkStp3p1: Cat_ = 'gg0l'
    if 'Vjj'  in Subcategory_unblindingChkStp3p1: Cat_ = 'Vjj'
    if 'Zvv'  in Subcategory_unblindingChkStp3p1: Cat_ = 'Zvv'
    if 'tt0l' in Subcategory_unblindingChkStp3p1: Cat_ = 'tt0l'

    if 'gg0l' in Subcategory_unblindingChkStp3p1: WP = '40'
    if 'Vjj'  in Subcategory_unblindingChkStp3p1: WP = '60'
    if 'Zvv'  in Subcategory_unblindingChkStp3p1: WP = '60'
    if 'tt0l' in Subcategory_unblindingChkStp3p1: WP = '60'
    Subcategory_unblindingChkStp3p1_0 = Subcategory_unblindingChkStp3p1 #
    if Subcategory_unblindingChkStp3p1 == 'tt0l0b': Subcategory_unblindingChkStp3p1_0 = 'tt0l_1TFJ_0BOutsideSelFJ'
    if Subcategory_unblindingChkStp3p1 == 'tt0l1b': Subcategory_unblindingChkStp3p1_0 = 'tt0l_1TFJ_ge1BOutsideSelFJ'
    
    histogram_stage0_dict = copy.deepcopy(histogram_stage0_dict_0)
    if 'Vjj'  in Subcategory_unblindingChkStp3p1: 
        histogram_stage0_dict['LeadingNonHto4bFatJetPt'] = {sXLabel: 'pT(non-Higgs candidate AK8 jet) [GeV]', sYLabel: 'Events', sXRange: [180, 1000], sNRebin: 20} 
        histogram_stage0_dict['LeadingNonHto4bFatJetEta'] = {sXLabel: 'eta(non-Higgs candidate AK8 jet)', sYLabel: 'Events', sXRange: [-3, 3], sNRebin: 4} 
        histogram_stage0_dict['LeadingNonHto4bFatJetPhi'] = {sXLabel: 'phi(non-Higgs candidate AK8 jet)', sYLabel: 'Events', sNRebin: 12} 
        histogram_stage0_dict['LeadingNonHto4bFatJetMass'] = {sXLabel: 'mass(Higgs candidate AK8 jet) [GeV]', sYLabel: 'Events', sXRange: [50, 200], sNRebin: 4} 
        histogram_stage0_dict['LeadingNonHto4bFatJetMSoftDrop'] = {sXLabel: 'soft drop mass(Higgs candidate AK8 jet) [GeV]', sYLabel: 'Events', sXRange: [50, 200], sNRebin: 4} 
        histogram_stage0_dict['LeadingNonHto4bFatJetPNet_WZvsQCD'] = {sXLabel: 'PNet WZvsQCD score (non-Higgs AK8 jet)', sYLabel: 'Events', sXRange: [0.9, 1], sNRebin: 6} 
        histogram_stage0_dict['LeadingNonHto4bTopFatJetPNet_TvsQCD'] = {sXLabel: 'PNet TvsQCD score (non-Higgs AK8 jet)', sYLabel: 'Events', sXRange: [0., 1], sNRebin: 10} 
        histogram_stage0_dict['dPhi_LeadingFJ_LeadingNonHto4bFJ'] = {sXLabel: '#delta phi(Higgs, non-Higgs AK8 jets)', sYLabel: 'Events', sNRebin: 20} 

        histogram_stage0_dict['MET_pT'] = {sXLabel: 'Missing pT [GeV]', sYLabel: 'Events', sXRange: [0, 1000], sNRebin: 20} 

    if 'tt0l'  in Subcategory_unblindingChkStp3p1: 
        histogram_stage0_dict['LeadingNonHto4bFatJetPt'] = {sXLabel: 'pT(non-Higgs candidate AK8 jet) [GeV]', sYLabel: 'Events', sXRange: [180, 1000], sNRebin: 20} 
        histogram_stage0_dict['LeadingNonHto4bFatJetEta'] = {sXLabel: 'eta(non-Higgs candidate AK8 jet)', sYLabel: 'Events', sXRange: [-3, 3], sNRebin: 4} 
        histogram_stage0_dict['LeadingNonHto4bFatJetPhi'] = {sXLabel: 'phi(non-Higgs candidate AK8 jet)', sYLabel: 'Events', sNRebin: 12} 
        histogram_stage0_dict['LeadingNonHto4bFatJetMass'] = {sXLabel: 'mass(Higgs candidate AK8 jet) [GeV]', sYLabel: 'Events', sXRange: [50, 200], sNRebin: 4} 
        histogram_stage0_dict['LeadingNonHto4bFatJetMSoftDrop'] = {sXLabel: 'soft drop mass(Higgs candidate AK8 jet) [GeV]', sYLabel: 'Events', sXRange: [50, 200], sNRebin: 4} 
        histogram_stage0_dict['LeadingNonHto4bVFatJetPNet_WZvsQCD'] = {sXLabel: 'PNet WZvsQCD score (non-Higgs AK8 jet)', sYLabel: 'Events', sXRange: [0.5, 1], sNRebin: 6} 
        histogram_stage0_dict['LeadingNonHto4bFatJetPNet_TvsQCD'] = {sXLabel: 'PNet TvsQCD score (non-Higgs AK8 jet)', sYLabel: 'Events', sXRange: [0.9, 1], sNRebin: 10} 
        
        histogram_stage0_dict['MET_pT'] = {sXLabel: 'Missing pT [GeV]', sYLabel: 'Events', sXRange: [0, 1000], sNRebin: 20} 

    if 'Zvv'  in Subcategory_unblindingChkStp3p1:         
        histogram_stage0_dict['MET_pT'] = {sXLabel: 'Missing pT [GeV]', sYLabel: 'Events', sXRange: [0, 1000], sNRebin: 20} 
        histogram_stage0_dict['METPhi'] = {sXLabel: 'MET phi', sYLabel: 'Events', sNRebin: 12} 
        


    mA_regions_cat_toUse = ''
    if Subcategory_unblindingChkStp3p1 == 'gg0lLo': mA_regions_cat_toUse = 'gg0lLo'
    if Subcategory_unblindingChkStp3p1 == 'gg0lHi': mA_regions_cat_toUse = 'gg0lHi'
    if Subcategory_unblindingChkStp3p1 == 'VjjLo':  mA_regions_cat_toUse = 'VjjLo'
    if Subcategory_unblindingChkStp3p1 == 'tt0l0b': mA_regions_cat_toUse = 'VjjLo'
    if Subcategory_unblindingChkStp3p1 == 'VjjHi':  mA_regions_cat_toUse = 'VjjHi'
    if Subcategory_unblindingChkStp3p1 == 'ZvvHi':  mA_regions_cat_toUse = 'LepHi'
    if Subcategory_unblindingChkStp3p1 == 'tt0l1b': mA_regions_cat_toUse = 'LepHi'
    
    
    mA_regions_unblindingChkStp3p1 = mA_regions_unblindingChkStp3p1_dict[mA_regions_cat_toUse]

    for Era_unblindingChkStp3p1 in Eras_unblindingChkStp3p1:
        Eras_toRun_list = []
        if '2016' in Era_unblindingChkStp3p1: Eras_toRun_list = ['2016preVFP', '2016postVFP']
        if '2017' in Era_unblindingChkStp3p1: Eras_toRun_list = ['2017']
        if '2018' in Era_unblindingChkStp3p1: Eras_toRun_list = ['2018']

        if Cat_ == 'Zvv': Datasets_toRun_list = ['MET']
        else:             Datasets_toRun_list = ['JetHT', 'BTagCSV']    
        if ((Cat_ != 'Zvv') and ('2018' in Era_unblindingChkStp3p1)): Datasets_toRun_list = ['JetHT']

        DatasetNames = []
        for DatasetName in Datasets_toRun_list:
            for Era in Eras_toRun_list:
                for Subera in YearsAndEras_dict[Era]:
                    DatasetNames.append('%s_Run%s%s' % (DatasetName, Era_unblindingChkStp3p1,Subera))

        print(f"{DatasetNames = }")
            


        for mA_region in mA_regions_unblindingChkStp3p1:

            for histogramName_stage0, histogramDetails_stage0 in histogram_stage0_dict.items():
            
                sHistVarName = histogramName_stage0
                sHistoName_ = "%s_%s_%s_%s"%(sHistVarName, Era_unblindingChkStp3p1, Subcategory_unblindingChkStp3p1, mA_region)
                subDir_toUse = '/%s/%s' % (Era_unblindingChkStp3p1, Subcategory_unblindingChkStp3p1)
                '''
                histograms_dict[sHistoName_] = {
                    sXLabel: histogramDetails_stage0[sXLabel], sYLabel: histogramDetails_stage0[sYLabel],
                    sXRange: histogramDetails_stage0[sXRange], #sXScale: 'log_10',
                    sNRebin: histogramDetails_stage0[sNRebin], 
                    sOpSubdir: subDir_toUse,
                    sHistosToOverlay: OD()
                    #sHistosToOverlay: OD([# ('h1', [{histoToOverlay1}]),  ('h2', [{histoToOverlay2}]), ('h3', [{histoTohadd3p1}, {histoTohadd3p2}, ...]), ('hi',[{}]), ...]
                    #    ("mA15_SR", [
                    #        {sIpFileNameNice: '2016preVFP_gg0l', sHistName: 'evt/JetHT_Run2016B-ver2_HIPM/hLeadingFatJetPt_gg0lLo_Xto4bv2_SRWP40_%s_SR_noweight'%(mA_region)},
                    #        
                    #    ])
                    #]),

                }
                '''
                histograms_dict[sHistoName_] = {
                    sOpSubdir: subDir_toUse,
                    sHistosToOverlay: OD()
                }
                for var_ in [sXLabel, sYLabel, sXRange, sNRebin, ]:
                    if var_ in histogramDetails_stage0: histograms_dict[sHistoName_][var_] = histogramDetails_stage0[var_]


                # sHistosToOverlay 1: SR
                sSubhistoName = '%s_SR'%(mA_region)
                histograms_dict[sHistoName_][sHistosToOverlay][sSubhistoName] = []
                for DatasetName in DatasetNames:
                    Name_for_sIpFileNameNice = '%s_%s' % (get_EraName_forInputFile(DatasetName), Cat_)
                    histograms_dict[sHistoName_][sHistosToOverlay][sSubhistoName].append(
                        {sIpFileNameNice: Name_for_sIpFileNameNice, sHistName: 'evt/%s/h%s_%s_Xto4bv2_SRWP%s_%s_SR_noweight'%(DatasetName, sHistVarName,Subcategory_unblindingChkStp3p1_0,WP,mA_region)},
                    )

                # sHistosToOverlay 2: SBmH
                sSubhistoName = '%s_SBmH'%(mA_region)
                histograms_dict[sHistoName_][sHistosToOverlay][sSubhistoName] = []
                for DatasetName in DatasetNames:
                    Name_for_sIpFileNameNice = '%s_%s' % (get_EraName_forInputFile(DatasetName), Cat_)
                    histograms_dict[sHistoName_][sHistosToOverlay][sSubhistoName].append(
                        {sIpFileNameNice: Name_for_sIpFileNameNice, sHistName: 'evt/%s/h%s_%s_Xto4bv2_SRWP%s_%s_SBmHLo_noweight'%(DatasetName, sHistVarName,Subcategory_unblindingChkStp3p1_0,WP,mA_region)},
                    )
                    histograms_dict[sHistoName_][sHistosToOverlay][sSubhistoName].append(
                        {sIpFileNameNice: Name_for_sIpFileNameNice, sHistName: 'evt/%s/h%s_%s_Xto4bv2_SRWP%s_%s_SBmHHi_noweight'%(DatasetName, sHistVarName,Subcategory_unblindingChkStp3p1_0,WP,mA_region)},
                    )

                # sHistosToOverlay 2: SBmA
                sSubhistoName = '%s_SBmA'%(mA_region)
                histograms_dict[sHistoName_][sHistosToOverlay][sSubhistoName] = []
                for DatasetName in DatasetNames:
                    Name_for_sIpFileNameNice = '%s_%s' % (get_EraName_forInputFile(DatasetName), Cat_)
                    histograms_dict[sHistoName_][sHistosToOverlay][sSubhistoName].append(
                        {sIpFileNameNice: Name_for_sIpFileNameNice, sHistName: 'evt/%s/h%s_%s_Xto4bv2_SRWP%s_%s_SBmALo_noweight'%(DatasetName, sHistVarName,Subcategory_unblindingChkStp3p1_0,WP,mA_region)},
                    )
                    histograms_dict[sHistoName_][sHistosToOverlay][sSubhistoName].append(
                        {sIpFileNameNice: Name_for_sIpFileNameNice, sHistName: 'evt/%s/h%s_%s_Xto4bv2_SRWP%s_%s_SBmAHi_noweight'%(DatasetName, sHistVarName,Subcategory_unblindingChkStp3p1_0,WP,mA_region)},
                    )



            

            
            








