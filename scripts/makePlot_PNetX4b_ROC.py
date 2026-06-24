import os, ROOT
import ctypes
import json
import math
from array import array
#import cmsstyle as CMS
import cmsstyle

from collections import OrderedDict as OD
import random


COMEnergy = 13
ResultStatus = 'Simulation Preliminary' # '' or 'Preliminary' 

# CMS color schemes: https://cms-analysis.docs.cern.ch/guidelines/plotting/colors/#categorical-data-eg-1d-stackplots
colors_CMS = {
    'DarkBlue':     '#3f90da', # [1] Dark Blue (#3f90da)
    'LightOrange':  '#ffa90e', # [2] Light orange (#ffa90e)
    'DarkRed':      '#bd1f01', # [3] Dark Red (#bd1f01)
    'LightGray':    '#94a4a2', # [4] Light Gray (#94a4a2)
    'Purple':       '#832db6', # [5] Purple (#832db6)
    'Brown':        '#a96b59', # [6] Brown (#a96b59)
    'DarkOrange':   '#e76300', # [7] Dark Orange (#e76300)
    'Tan':          '#b9ac70', # [8] Tan (#b9ac70) 
    'DarkGray':     '#717581', # [9] Dark Gray (#717581)
    'LightBlue':    '#92dadd', # [10] Light Blue (#92dadd)      
}

def cal_efficiency_and_error(N, eN, D, eD):
    effi = N / D
    effi_err = math.sqrt( effi * (1 - effi) / D )
    return effi, effi_err


def cal_Effi_vs_TaggerScore(hTagger):
    nBins = hTagger.GetNbinsX()
    xAxis = hTagger.GetXaxis()

    sEffi = 'hEffi_%s' % (hTagger.GetName())
    hEfficiency = ROOT.TH1D(sEffi, sEffi, nBins, xAxis.GetXmin(), xAxis.GetXmax())

    nEvts_Tot_err = ctypes.c_double(0.0)
    nEvts_Tot = hTagger.IntegralAndError(1, nBins, nEvts_Tot_err)
    
    effi_vs_taggerScore_dict = {}
    for iBin in range(1, nBins+1):
        xLow = xAxis.GetBinLowEdge(iBin)

        nEvts_selected_err = ctypes.c_double(0.0)
        nEvts_selected     = hTagger.IntegralAndError(iBin, nBins, nEvts_selected_err)

        effi_i_, effi_err_i_ = cal_efficiency_and_error(
            nEvts_selected, nEvts_selected_err,
            nEvts_Tot, nEvts_Tot_err
        )

        hEfficiency.SetBinContent(iBin, effi_i_)
        hEfficiency.SetBinError(  iBin, effi_err_i_)

    return hEfficiency
        

def make_ROC(sROCName, hSig, hBkg, TaggerWPs):
    nBins = hSig.GetNbinsX() 
    xAxis = hSig.GetXaxis()
    xBinWidth = xAxis.GetBinWidth(1)

    S_vs_B_Effi_dict = {}
    ROC_Points_For_TaggerWPs = {}
    for iBin in range(1, nBins+1):        
        effi_S = hSig.GetBinContent(iBin)
        effi_B = hBkg.GetBinContent(iBin)

        S_vs_B_Effi_dict[effi_S] = effi_B

        for sWP in TaggerWPs:
            TaggerWP_Threshold = TaggerWPs[sWP]

            #if abs(TaggerWP_Threshold - tagger_threshold) < xBinWidth:
            if (TaggerWPs[sWP] >= xAxis.GetBinLowEdge(iBin)) and (TaggerWPs[sWP] < xAxis.GetBinUpEdge(iBin)):
                ROC_Points_For_TaggerWPs[sWP] = (effi_S, effi_B)
                print(f"{sWP = }, {TaggerWPs[sWP] = }, {xAxis.GetBinLowEdge(iBin) = }, {xAxis.GetBinUpEdge(iBin) = }, {ROC_Points_For_TaggerWPs[sWP] = }")
        
    print(f"{sROCName = } {S_vs_B_Effi_dict = }, {ROC_Points_For_TaggerWPs = }")

    effi_S_list = list(S_vs_B_Effi_dict.keys())
    effi_B_list = list(S_vs_B_Effi_dict.values())
    
    gr = ROOT.TGraph(len(effi_S_list), array('d', effi_S_list), array('d', effi_B_list) )
    gr.SetTitle(sROCName)
    gr.SetName(sROCName)
    
    return gr, ROC_Points_For_TaggerWPs







if __name__ == "__main__":
    print(f"makePlot_PNetX4b_ROC()")

    Luminosity_dict = {
        'Run2': 138,
        '2018': 60,
    }
    '''
    ipFileName_list = [
        '/eos/cms/store/user/ssawant/htoaa/analysis/20260212_DataMC/2016preVFP/gg0l/analyze_htoaa_stage1.root',
        '/eos/cms/store/user/ssawant/htoaa/analysis/20260212_DataMC/2016postVFP/gg0l/analyze_htoaa_stage1.root',
        '/eos/cms/store/user/ssawant/htoaa/analysis/20260212_DataMC/2017/gg0l/analyze_htoaa_stage1.root',
        '/eos/cms/store/user/ssawant/htoaa/analysis/20260212_DataMC/2018/gg0l/analyze_htoaa_stage1.root',            
    ]
    '''
    ipFileName_list = [
        '/Users/siddhesh/Work/CMS/htoaa/analysis/20260212_DataMC/2016preVFP/gg0l/analyze_htoaa_stage1.root',
        '/Users/siddhesh/Work/CMS/htoaa/analysis/20260212_DataMC/2016postVFP/gg0l/analyze_htoaa_stage1.root',
        '/Users/siddhesh/Work/CMS/htoaa/analysis/20260212_DataMC/2017/gg0l/analyze_htoaa_stage1.root',
        '/Users/siddhesh/Work/CMS/htoaa/analysis/20260212_DataMC/2018/gg0l/analyze_htoaa_stage1.root',            
    ]
    

    MCProcesses_dict = {
        'Signal': [
            'ggHtoaato4b_mA_12p0',
            'ggHtoaato4b_mA_p0',
            
        ],
        'QCD': [
            'QCD_bEnr',
            'QCD_BGen'
        ],
        'ttbar':[
            'TT0l',
            'TT1l',
            'TT2l'
        ],
    }

    HistogramName_short = 'hLeadingFatJetPNet_X4b_v2ab_Haa4b_score_gg0lIncl_Nom'
    TaggerWPs = {
        '40': 0.96,
        '60': 0.93,
    }
    Luminosity = Luminosity_dict['Run2']

    #opFileName = '/eos/cms/store/user/ssawant/htoaa/analysis/20260212_DataMC/Run2/ROC_PNet_X4b_v2ab_Haa4b_score.root'
    opFileName = '/Users/siddhesh/Work/CMS/htoaa/analysis/20260212_DataMC/Run2/ROC_PNet_X4b_v2ab_Haa4b_score.root'


    Plot_xMin = 0.2
    Plot_xMax = 1
    Plot_yMin = 1e-6
    Plot_yMax = 1
    Plot_xAxisLable = 'Signal efficiency'
    Plot_yAxisLable = 'Background efficiency'
    
    


    ipFiles_dict = {}
    for ipFileName in ipFileName_list:
        ipFile_i = ROOT.TFile.Open(ipFileName)
        if not ipFile_i.IsOpen():
            print(f"Input file {ipFileName} could not open. **** ERROR **** \n")
            exit(0)  
        ipFiles_dict[ipFileName] = ipFile_i  

    dir_ = os.path.dirname(opFileName)
    os.makedirs(dir_, exist_ok=True)
    opFile = ROOT.TFile(opFileName, 'RECREATE')


    hTaggerScore_dict = {}
    hEfficiency_dict  = {}
    for MCProcessName in MCProcesses_dict:
        hTaggerScore_dict[MCProcessName] = None

        MCProcesses_list = MCProcesses_dict[MCProcessName]
        for MCProcess in MCProcesses_list:
            sHistoNameFull = 'evt/%s/%s' % (MCProcess,HistogramName_short)

            for ipFileName in ipFileName_list:
                ipFile = ipFiles_dict[ipFileName]
                h_ = ipFile.Get(sHistoNameFull)
                print(f"{sHistoNameFull = }, {ipFileName = }, {h_ = }")

                if hTaggerScore_dict[MCProcessName] == None: hTaggerScore_dict[MCProcessName] = h_.Clone('%s_%s' % (HistogramName_short, MCProcessName))
                else:                                        hTaggerScore_dict[MCProcessName].Add(h_)


        hEfficiency_dict[MCProcessName] = cal_Effi_vs_TaggerScore(hTaggerScore_dict[MCProcessName])

        opFile.cd();
        hTaggerScore_dict[MCProcessName].Write()
        hEfficiency_dict[MCProcessName].Write()


    gr_roc_SVsQCD, ROC_Points_For_TaggerWPs_SVsQCD = make_ROC('ROC_Sig_vs_QCD', hEfficiency_dict['Signal'], hEfficiency_dict['QCD'], TaggerWPs)

    gr_roc_SVsttbar, ROC_Points_For_TaggerWPs_SVsttbar = make_ROC('ROC_Sig_vs_ttbar', hEfficiency_dict['Signal'], hEfficiency_dict['ttbar'], TaggerWPs)


    print(f"{ROC_Points_For_TaggerWPs_SVsQCD = }")
    print(f"{ROC_Points_For_TaggerWPs_SVsttbar = }")

    gr_WP40 = ROOT.TGraph()
    gr_WP40.AddPoint(ROC_Points_For_TaggerWPs_SVsQCD['40'][0], ROC_Points_For_TaggerWPs_SVsQCD['40'][1])
    gr_WP40.AddPoint(ROC_Points_For_TaggerWPs_SVsttbar['40'][0], ROC_Points_For_TaggerWPs_SVsttbar['40'][1])
    
    gr_WP60 = ROOT.TGraph()
    gr_WP60.AddPoint(ROC_Points_For_TaggerWPs_SVsQCD['60'][0], ROC_Points_For_TaggerWPs_SVsQCD['60'][1])
    gr_WP60.AddPoint(ROC_Points_For_TaggerWPs_SVsttbar['60'][0], ROC_Points_For_TaggerWPs_SVsttbar['60'][1])
    



    ## ROC plot -----------------------------------------
    # set the global ROOT style to CMS style
    cmsstyle.setCMSStyle()

    # set the luminosity, the COM energy, the Run period to show in the canvases
    cmsstyle.SetLumi(Luminosity, run=None) # run=plot_info_dict['Year']
    cmsstyle.SetEnergy(COMEnergy)
    # default extra text is "Preliminary", set it to an empty string to remove it
    cmsstyle.SetExtraText(ResultStatus)


    # prepare the canvas, specifying a name, min and maxes on X and Y axes and axis titles.
    c = cmsstyle.cmsCanvas("ROC",
                           Plot_xMin, Plot_xMax,
                           Plot_yMin, Plot_yMax, 
                           Plot_xAxisLable,
                           Plot_yAxisLable,
                           iPos=0
                           )

    # prepare a legend and fill it
    plotlegend = cmsstyle.cmsLeg(0.15,0.75,0.92,0.9, textSize=0.04, columns=2)  # The legend!
    cmsstyle.addToLegend(plotlegend, (gr_roc_SVsQCD, 'QCD background', 'l'))
    cmsstyle.addToLegend(plotlegend, (gr_roc_SVsttbar, r't\bar{t} background', 'l'))
    cmsstyle.addToLegend(plotlegend, (gr_WP40, r'WP 40', 'P'))
    cmsstyle.addToLegend(plotlegend, (gr_WP60, r'WP 60', 'P'))
    
    


    ROOT.gPad.SetLogy(1)
    
    
    color_ = ROOT.TColor.GetColor(colors_CMS['DarkRed'])
    cmsstyle.cmsObjectDraw(gr_roc_SVsQCD,"L", LineColor=color_, LineWidth=2)

    color_ = ROOT.TColor.GetColor(colors_CMS['Purple'])
    cmsstyle.cmsObjectDraw(gr_roc_SVsttbar,"L SAME", LineColor=color_, LineWidth=2)


    color_ = ROOT.TColor.GetColor(colors_CMS['Brown'])
    cmsstyle.cmsObjectDraw(gr_WP40,"P SAME", MarkerColor=color_, MarkerStyle=29, MarkerSize=3)

    color_ = ROOT.TColor.GetColor(colors_CMS['Tan'])
    cmsstyle.cmsObjectDraw(gr_WP60,"P SAME", MarkerColor=color_, MarkerStyle=29, MarkerSize=3)

    

    
    
     #Saving the result!
    cmsstyle.UpdatePad(c)

    c.SaveAs(opFileName.replace('.root', '.pdf'))






























    opFile.cd();
    gr_roc_SVsQCD.Write()
    gr_roc_SVsttbar.Write()
    c.Write()

    opFile.Close();
    print(f"Wrote histogram in op file {opFileName}")