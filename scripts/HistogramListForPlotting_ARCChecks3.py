import os
import sys
import numpy as np
from collections import OrderedDict as OD

#sys.path.insert(1, '../') # to import file from other directory (../ in this case)
sys.path.append( os.path.abspath('../') )
print(f"{os.path.abspath('../') = }")

from htoaa_Settings import *



sXRange = "xAxisRange"; sYRange = "yAxisRange";
sXLabel = 'xAxisLabel'; sYLabel = 'yAxisLabel';
sXScale = 'xAxisScale';
sNRebin = "nRebin"; sNRebinX = sNRebin;
sHistosToOverlay = 'histosToOverlay'
sHistosToHadd = 'histosToHadd'
sIpFileNameNice = 'ipFileNameNice'
sHistName   = 'histogramName'
sScaleFactors = 'sScaleFactors'
sMakeRatioPlot = 'sMakeRatioPlot'
sOpDirSeperate = 'sOpDirSeperate'

sAnaDir = '/eos/cms/store/user/ssawant/htoaa/analysis/20260527_DataMC_MsdGt10'
Dataset = 'Run2'
CAT = 'gg0l' # 'gg0l'  'Vjj'  'Zvv'  'tt0l'
sAnaVersion = ''
sOpDir  = '%s/%s/%s/plots_ARCCheck3' % (sAnaDir,Dataset, CAT)


subCats = []
if   'gg0l'     in CAT:
    subCats = ["gg0lIncl", "gg0lHi", "gg0lLo"]
elif 'VBF'      in CAT:    
    subCats = ["VBFHi", "VBFLo"]
elif 'Vjj'      in CAT:    
    subCats = ["VjjIncl", "VjjHi", "VjjLo", ]
elif 'Zvv'      in CAT:    
    subCats = ["ZvvIncl", "ZvvHi", "ZvvLo"]
elif 'tt0l'      in CAT:    
    subCats = ["tt0l_1TFJ_ge0BOutsideSelFJ", "tt0l_1TFJ_0BOutsideSelFJ", "tt0l_1TFJ_ge1BOutsideSelFJ"]




# Year, Era are set internally to one of the following: '2016preVFP', '2016postVFP', '2017', '2018'
YearsAll_list = [Era_2016preVFP, Era_2016postVFP, Era_2017, Era_2018]

YearsToRun_dict = {}
if Dataset==Era_Run2: # make Run2 data-mc plots
    YearsToRun_dict[Era_Run2] = YearsAll_list
    Years = YearsAll_list
elif Dataset=='All': # make Run2 and individual 4 years data-mc plots
    YearsToRun_dict[Era_Run2] = YearsAll_list
    for Year_ in YearsAll_list:
        YearsToRun_dict[Year_] = [Year_]
    Years = YearsAll_list
else: # make individual year's data-mc plots
    Years = []
    for Year_ in YearsAll_list:
        if Year_ != Dataset: continue
        YearsToRun_dict[Year_] = [Year_]   
        Years.append(Year_)

print(f"{YearsToRun_dict = }, \n{Years = }")

DataObs_DirName_dict = {}
luminosity_total_dict = {}
for DatasetName_, YearsToRun_list_ in YearsToRun_dict.items():
    luminosity_total_ = 0.0
    for Year_ in YearsToRun_list_:
        if 'Zvv'       in CAT:
            ExpDatasetNames = ['MET']
            HLT_toUse       = 'Trg_Combo_MET'
        elif 'trigEffi'       in CAT:
            ExpDatasetNames = ['SingleMuon']
            HLT_toUse       = 'Trg_Combo_Mu'
        else:
            ExpDatasetNames = ['JetHT']
            HLT_toUse       = 'Trg_Combo_AK4AK8Jet_HT_VBF'
            if Year_ != '2018':
                ExpDatasetNames.append( 'BTagCSV' )
        DataObs_DirName_list_i_ = ['%s_Run%s%s' % (ExpDatasetName, Year_[:4],EraInYear) for ExpDatasetName in ExpDatasetNames for EraInYear in YearsAndEras_dict[Year_]]
        if Year_ not in DataObs_DirName_dict: DataObs_DirName_dict[Year_] = DataObs_DirName_list_i_
        luminosity_total_ += Luminosities_TotalPerYear[Year_][HLT_toUse][0]
    luminosity_total_dict[DatasetName_] = luminosity_total_




MCBkg_dict = {
    'QCD': ["QCD_bEnr", "QCD_BGen", "QCD_Incl"],
    r't$\bar{t}$+jets': ["TT0l", "TT1l", "TT2l"],
    #'Wlv': ["Wlv"],
    'V+jets': ["Zqq", "Zvv", "Zll", "Wqq", "Wlv", ],
    'Other': ["STop_t", "STbar_t", "ST_s_0l", "ST_s_1l", "STop_tW_Incl", "STbar_tW_Incl",
              "ZZ", "WZ", "WW", 
              "ttZ", "ttW", "tZq",   "ZZZ", "WZZ", "WWZ", "WWW",
              'GluGluHToBB_Pt-200ToInf', 'VBFH_dipoleRecoilOn', 'WplusHToBBQQ', 'WplusHToBBLNu', 'WminusHToBBQQ', 'WminusHToBBLNu', 'ZHToBBX', 'ttHToBB'
              ],
    #'': [],
}

MAs = ['12p0', '15p0', '20p0', '25p0', '30p0',   '35p0', '40p0', '45p0', '50p0', '55p0',    '60p0' ] 
SigProcesses = []
if   'gg0l'     in CAT:
    SigProcesses = ["ggHtoaato4b"]
elif 'VBF'      in CAT:    
    SigProcesses = ["VBFHtoaato4"]
elif 'Vjj'      in CAT:    
    SigProcesses = ["WHtoaato4b", "ZHtoaato4b" ]
elif 'Zvv'      in CAT:    
    SigProcesses = ["ZHtoaato4b"]
elif 'tt0l'      in CAT:    
    SigProcesses = ["ttHtoaato4b"]




## Read input files
sIpFiles = {}
for Era in Years:
    sIpFiles[Era] = '%s/%s/%s/analyze_htoaa_stage1.root' % (sAnaDir, Era, CAT) # 20250612_gg0lDataMC_1, 20250613_gg0lDataMC_1, 20250617_gg0lDataMC, 20250617_gg0lDataMC_1




histogramNames_dict = OD([
    ("hLeadingFatJetPt", {sXLabel: r'$p_{T}$(Higgs candidate AK8 jet) [GeV]', sYLabel: 'Events', sXRange: [180, 1000], sNRebinX: 4 }),
    #("hLeadingFatJetEta", {sXLabel: r'$\eta$(Higgs candidate AK8 jet)', sYLabel: 'Events', sXRange: [-3.5, 3.5], sNRebinX: 2 }),
    #("hLeadingFatJetPhi", {sXLabel: r'$\phi$(Higgs candidate AK8 jet)', sYLabel: 'Events', sXRange: [-3.14, 3.14], sNRebinX: 2 }),
    ("hLeadingFatJetMass", {sXLabel: r'PF Mass(Higgs candidate AK8 jet) [GeV]', sYLabel: 'Events', sXRange: [0, 200], sNRebinX: 1}),
    #("hLeadingFatJetMSoftDrop", {sXLabel: r'Mass$_{Soft\, drop}$(Higgs candidate AK8 jet) [GeV]', sYLabel: 'Events', sXRange: [0, 240], sNRebinX: 1 }),

    #("hLeadingFatJetPNet_X4b_v2ab_Haa4b_score", {sXLabel: r'$X\to 4b$ tagger score(Higgs candidate AK8 jet)', sYLabel: 'Events', sXRange: [0, 1], sNRebinX: 50 }),    
    #("hLeadingFatJetPNet_X4b_v2ab_Haa34b_score", {sXLabel: r'$X\to 3,4b$ tagger score(Higgs candidate AK8 jet)', sYLabel: 'Events', sXRange: [0, 1], sNRebinX: 50 }),
    
    ("hLeadingFatJetMassH_v2b", {sXLabel: r'Mass$_{PNet\, X\to 4b}$(Higgs candidate AK8 jet) [GeV]', sYLabel: 'Events', sXRange: [0, 200], sNRebinX: 1}),

    ("hLeadingFatJetPNet_34massAa", {sXLabel: r'Mass$_{version\, a}$(a)  [GeV]', sYLabel: 'Events', sXRange: [5, 70], sNRebinX: 20}),
    #("hLeadingFatJetPNet_34massAd", {sXLabel: r'Mass$_{version\, d}$(a)  [GeV]', sYLabel: 'Events', sXRange: [5, 70], sNRebinX: 20}),

    #("", {sXLabel: '', sYLabel: 'Events'}),
])
'''
histogramNames_dict = OD([
    ("hLeadingFatJetPt", {sXLabel: r'$p_{T}$(Higgs candidate AK8 jet) [GeV]', sYLabel: 'Events', sXRange: [180, 1000], sNRebinX: 4 }),
])
'''

selectionTags_dict = {}
for X4bTaggerRegion in ['SR', 'SB']:
    sWP_ = '40' if 'gg0l' in CAT else '60'
    selectionTag = 'Xto4bv2_%sWP%s' % (X4bTaggerRegion,sWP_)
    for sMHWidow in ['mHInclusive', 'mHHiggs']:
        selectionTag = 'Xto4bv2_%sWP%s_%s' % (X4bTaggerRegion,sWP_, sMHWidow)
        selectionTagName = '%s_%s' % (X4bTaggerRegion, sMHWidow)
        selectionTags_dict[selectionTagName] = selectionTag


msdSelections_dict = OD([
    ('Msd < 20', '_MsdLt20'),
    ('Msd > 20', '_MsdGt20'),        
])




# ----------------------------------------------------------------------------------
histograms_dict = OD([])


# Data   -------------------------------------------------------------------
for subCat in subCats:
    for selectionTagNameShort, selectionTagName in selectionTags_dict.items():
        for histgramName0, histogramName_dict in histogramNames_dict.items():
            systematic = 'noweight'
            histgramName = '%s/%s_%s_Data' % (subCat, histgramName0,selectionTagNameShort)
            histograms_dict[histgramName] = {
                sXLabel: histogramName_dict[sXLabel],
                sYLabel: histogramName_dict[sYLabel],
                sXRange: histogramName_dict[sXRange],
                sNRebinX: histogramName_dict[sNRebinX],     
            }

            histograms_dict[histgramName][sHistosToOverlay] = OD([])

            for msdSelectionNameShort, msdSelectionName in msdSelections_dict.items():
                selectionTag_toUse = '%s%s_%s' % (subCat,msdSelectionName, selectionTagName)
                histograms_dict[histgramName][sHistosToOverlay][msdSelectionNameShort] = []

                for sDatasetName, YearsToRun_list in YearsToRun_dict.items():
                    for Year_ in YearsToRun_list:
                        DataObs_DirName_list = DataObs_DirName_dict[Year_]
                        for DataObs_DirName in DataObs_DirName_list:
                            histo_name_toUse = '%s_%s' % (histgramName0, selectionTag_toUse)
                            histo_name_toUse_full = 'evt/%s/%s_%s' % (DataObs_DirName, histo_name_toUse, systematic)
                            
                            histograms_dict[histgramName][sHistosToOverlay][msdSelectionNameShort].append({
                                sIpFileNameNice: Year_,
                                sHistName: histo_name_toUse_full,
                            })


# MC   -------------------------------------------------------------------
for subCat in subCats:
    for selectionTagNameShort, selectionTagName in selectionTags_dict.items():
        for histgramName0, histogramName_dict in histogramNames_dict.items():
            systematic = 'Nom'
            histgramName = '%s/%s_%s_MCBkg' % (subCat, histgramName0,selectionTagNameShort)
            histograms_dict[histgramName] = {
                sXLabel: histogramName_dict[sXLabel],
                sYLabel: histogramName_dict[sYLabel],
                sXRange: histogramName_dict[sXRange],
                sNRebinX: histogramName_dict[sNRebinX],     
            }

            histograms_dict[histgramName][sHistosToOverlay] = OD([])

            for msdSelectionNameShort, msdSelectionName in msdSelections_dict.items():
                selectionTag_toUse = '%s%s_%s' % (subCat,msdSelectionName, selectionTagName)
                histograms_dict[histgramName][sHistosToOverlay][msdSelectionNameShort] = []

                for i_, (MCBkgNameShort, MCBkg_list) in enumerate(MCBkg_dict.items()):
                    for dataset in MCBkg_list:
                        histo_name_toUse = '%s_%s' % (histgramName0, selectionTag_toUse)
                        histo_name_toUse_full = 'evt/%s/%s_%s' % (dataset, histo_name_toUse, systematic)
                        for sDatasetName, YearsToRun_list in YearsToRun_dict.items():
                            for Year_ in YearsToRun_list:
                                histograms_dict[histgramName][sHistosToOverlay][msdSelectionNameShort].append({
                                    sIpFileNameNice: Year_,
                                    sHistName: histo_name_toUse_full,
                                })


# Sig   -------------------------------------------------------------------
for subCat in subCats:
    for selectionTagNameShort, selectionTagName in selectionTags_dict.items():
        for histgramName0, histogramName_dict in histogramNames_dict.items():
            systematic = 'Nom'
            histgramName = '%s/%s_%s_MCSig' % (subCat, histgramName0,selectionTagNameShort)
            histograms_dict[histgramName] = {
                sXLabel: histogramName_dict[sXLabel],
                sYLabel: histogramName_dict[sYLabel],
                sXRange: histogramName_dict[sXRange],
                sNRebinX: histogramName_dict[sNRebinX],     
            }

            histograms_dict[histgramName][sHistosToOverlay] = OD([])
            kScaleFactors_dict = {}

            for msdSelectionNameShort, msdSelectionName in msdSelections_dict.items():
                selectionTag_toUse = '%s%s_%s' % (subCat,msdSelectionName, selectionTagName)
                histograms_dict[histgramName][sHistosToOverlay][msdSelectionNameShort] = []
                kScaleFactors_dict[msdSelectionNameShort] = 1./len(MAs)

                for SigProcess in SigProcesses:
                    for MA in MAs:
                        dataset = '%s_mA_%s' % (SigProcess, MA)
                        histo_name_toUse = '%s_%s' % (histgramName0, selectionTag_toUse)
                        histo_name_toUse_full = 'evt/%s/%s_%s' % (dataset, histo_name_toUse, systematic)
                        for sDatasetName, YearsToRun_list in YearsToRun_dict.items():
                            for Year_ in YearsToRun_list:
                                histograms_dict[histgramName][sHistosToOverlay][msdSelectionNameShort].append({
                                    sIpFileNameNice: Year_,
                                    sHistName: histo_name_toUse_full,
                                })                    

            histograms_dict[histgramName][sScaleFactors] = kScaleFactors_dict









































'''
# Data -------------------------------------------------------------------
for subCat in subCats:
    for histgramName0, histogramName_dict in histogramNames_dict.items():
        systematic = 'noweight'
        histgramName = '%s/%s_Data' % (subCat, histgramName0)
        histograms_dict[histgramName] = {
            sXLabel: histogramName_dict[sXLabel],
            sYLabel: histogramName_dict[sYLabel],
            sXRange: histogramName_dict[sXRange],
            sNRebinX: histogramName_dict[sNRebinX],     
        }

        histograms_dict[histgramName][sHistosToOverlay] = OD([])
        for X4bTaggerRegion in ['SR', 'SB']:
            sWP_ = '40' if 'gg0l' in CAT else '60'
            selectionTag = '%s_Xto4bv2_%sWP%s' % (subCat,X4bTaggerRegion,sWP_)
            histograms_dict[histgramName][sHistosToOverlay][X4bTaggerRegion] = []
            
            for sDatasetName, YearsToRun_list in YearsToRun_dict.items():
                for Year_ in YearsToRun_list:
                    DataObs_DirName_list = DataObs_DirName_dict[Year_]
                    for DataObs_DirName in DataObs_DirName_list:
                        histo_name_toUse = '%s_%s' % (histgramName0, selectionTag)
                        histo_name_toUse_full = 'evt/%s/%s_%s' % (DataObs_DirName, histo_name_toUse, systematic)
                           
                        histograms_dict[histgramName][sHistosToOverlay][X4bTaggerRegion].append({
                            sIpFileNameNice: Year_,
                            sHistName: histo_name_toUse_full,
                        })
'''

'''
# MC   -------------------------------------------------------------------
for subCat in subCats:
    for histgramName0, histogramName_dict in histogramNames_dict.items():
        systematic = 'Nom'
        histgramName = '%s/%s_MCBkg' % (subCat, histgramName0)
        histograms_dict[histgramName] = {
            sXLabel: histogramName_dict[sXLabel],
            sYLabel: histogramName_dict[sYLabel],
            sXRange: histogramName_dict[sXRange],
            sNRebinX: histogramName_dict[sNRebinX],     
        }

        histograms_dict[histgramName][sHistosToOverlay] = OD([])
        for X4bTaggerRegion in ['SR', 'SB']:
            sWP_ = '40' if 'gg0l' in CAT else '60'
            selectionTag = '%s_Xto4bv2_%sWP%s' % (subCat,X4bTaggerRegion,sWP_)
            histograms_dict[histgramName][sHistosToOverlay][X4bTaggerRegion] = []

            for i_, (MCBkgNameShort, MCBkg_list) in enumerate(MCBkg_dict.items()):
                for dataset in MCBkg_list:
                    histo_name_toUse = '%s_%s' % (histgramName0, selectionTag)
                    histo_name_toUse_full = 'evt/%s/%s_%s' % (dataset, histo_name_toUse, systematic)
                    for sDatasetName, YearsToRun_list in YearsToRun_dict.items():
                        for Year_ in YearsToRun_list:
                            histograms_dict[histgramName][sHistosToOverlay][X4bTaggerRegion].append({
                                sIpFileNameNice: Year_,
                                sHistName: histo_name_toUse_full,
                            })

'''
'''
# Sig   -------------------------------------------------------------------
for subCat in subCats:
    for histgramName0, histogramName_dict in histogramNames_dict.items():
        systematic = 'Nom'
        histgramName = '%s/%s_MCSig' % (subCat, histgramName0)
        histograms_dict[histgramName] = {
            sXLabel: histogramName_dict[sXLabel],
            sYLabel: histogramName_dict[sYLabel],
            sXRange: histogramName_dict[sXRange],
            sNRebinX: histogramName_dict[sNRebinX],     
        }

        histograms_dict[histgramName][sHistosToOverlay] = OD([])
        kScaleFactors_dict = {}
        for X4bTaggerRegion in ['SR', 'SB']:
            sWP_ = '40' if 'gg0l' in CAT else '60'
            selectionTag = '%s_Xto4bv2_%sWP%s' % (subCat,X4bTaggerRegion,sWP_)
            histograms_dict[histgramName][sHistosToOverlay][X4bTaggerRegion] = []
            kScaleFactors_dict[X4bTaggerRegion] = 1./len(MAs)

            for SigProcess in SigProcesses:
                for MA in MAs:
                    dataset = '%s_mA_%s' % (SigProcess, MA)
                    histo_name_toUse = '%s_%s' % (histgramName0, selectionTag)
                    histo_name_toUse_full = 'evt/%s/%s_%s' % (dataset, histo_name_toUse, systematic)
                    for sDatasetName, YearsToRun_list in YearsToRun_dict.items():
                        for Year_ in YearsToRun_list:
                            histograms_dict[histgramName][sHistosToOverlay][X4bTaggerRegion].append({
                                sIpFileNameNice: Year_,
                                sHistName: histo_name_toUse_full,
                            })                    

        histograms_dict[histgramName][sScaleFactors] = kScaleFactors_dict
'''
