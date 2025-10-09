'''
Python environment with ROOT and cmsstyle: https://cms-analysis.docs.cern.ch/guidelines/plotting/#installation, https://cms-sw.github.io/venv.html
    cd /afs/cern.ch/work/s/ssawant/private/htoaa/cmsplots/CMSSW_14_1_0_pre4/src
    cmsenv

    python3 PlotHistos2D.py
'''

import os, sys
import ROOT
ROOT.PyConfig.IgnoreCommandLineOptions = False
from ROOT import TCanvas, TFile, TProfile, TNtuple, TH1D, TH2D, TH1, TF1, TEfficiency, TLegend
from ROOT import gROOT, gBenchmark, gRandom, gSystem, gStyle
import cmsstyle
import copy

ROOT.gROOT.SetBatch(ROOT.kTRUE)


sys.path.append( os.path.abspath('../') )
print(f"{os.path.abspath('../') = }")

from htoaa_Settings import *


def readHistFromFile(sFile, sHistNameFull, nRebinX=1, nRebinY=1, maintainScale=0):
    h = None
    f = TFile(sFile)
    if not f.IsOpen():
        print(f"{sFile} could not open")
        exit(0)
    
    h = copy.deepcopy( f.Get(sHistNameFull) )
    if h == None:
        print(f"Could not read {sHistNameFull} histogram from {sFile} file. \t\t\t *** ERROR ***")
        exit(0)
    f.Close()

    return h

def plot2D(sInFile, sHisto, nameXaxis, nameYaxis, lumi, CMEnergy, sSaveAs):
    h = readHistFromFile(sInFile, sHisto)

    # set the global ROOT style to CMS style
    cmsstyle.setCMSStyle()
    #cmsstyle1 = cmsstyle.getCMSStyle()
    #cmsstyle1.SetPadRightMargin(0.10)

    # set the luminosity, the COM energy, the Run period to show in the canvases
    lumi_rounding = 0 if lumi > 100 else 1
    lumi_toUse = round(lumi, lumi_rounding)
    lumi_toUse = int(lumi_toUse)if lumi > 100 else lumi_toUse
    cmsstyle.SetLumi(lumi_toUse)
    cmsstyle.SetEnergy(CMEnergy)
    # default extra text is "Preliminary", set it to an empty string to remove it
    cmsstyle.SetExtraText('Preliminary')

    square = False #True
    c = cmsstyle.cmsCanvas( #https://github.com/cms-cat/cmsstyle/blob/master/src/cmsstyle/cmsstyle.py#L962
        canvName="c",
        x_min=h.GetXaxis().GetXmin(),
        x_max=h.GetXaxis().GetXmax(),
        y_min=h.GetYaxis().GetXmin(),
        y_max=h.GetYaxis().GetXmax(),
        nameXaxis=nameXaxis,
        nameYaxis=nameYaxis,
        square=square, #cmsstyle.kSquare,
        iPos=0,
        extraSpace=0.01,
        with_z_axis=True,
        #scaleLumi=1,
        yTitOffset=0.9,     
    )   
    #h.GetZaxis().SetTitle("Efficiency")
    #h.GetZaxis().SetTitleOffset(1.4 if square else 0.8)
    #h.GetXaxis().SetTitleOffset(1.9)
    c.SetLogx(1)
    #c.SetRightMargin(0.25)

    cmsstyle.SetCMSPalette()

    gStyle.SetPaintTextFormat("4.2f");
    h.SetMarkerSize(1.5)

    h.Draw("same colz TEXT")

    # Set a new palette
    #cmsstyle.SetAlternative2DColor(h)

    # Allow to adjust palette position
    cmsstyle.UpdatePalettePosition(h, c)
    #cmsstyle.UpdatePalettePosition(h, c, 0.85,0.99,0.1,0.9)
    #cmsstyle.UpdatePalettePosition(hist=h, canv=None, X1=0.8, X2=0.9, Y1=0.13, Y2=0.95, isNDC=True)   

    cmsstyle.UpdatePad() 

    cmsstyle.SaveCanvas(c, sSaveAs)

if __name__ == '__main__':
    sIpFileName = 'ipFileName'
    sHistName   = 'histogramName'
    sXaxisLabel = 'xAxisLabel'
    sYaxisLabel = 'yAxisLabel'
    sLumi       = 'lumi'
    sCMEnergy   = 'CMEnergy'
    
    sTriggerCombo = 'Trg_Combo_AK4AK8Jet_HT_VBF'
    cmEnergy = '13'

    sOpDir = "/eos/cms/store/user/ssawant/htoaa/analysis/BtagSFs"
    #sOpDir = "./"
    

    plotsDetails_dict = {} # {'sSaveAs_plot1': {}, ..}

    for Year in [Era_2016preVFP, Era_2016postVFP, Era_2017,Era_2018]:
        lumi = Luminosities_TotalPerYear[Year][sTriggerCombo][0]
        
        plotsDetails_dict['JetBtagEffi_b_%s.pdf' % (Year)] = {
            sIpFileName: "data/correction/mc/BtagSF/%s/jetBtagEfficiency.root" % (Year),
            sHistName:   "hJetBtagEffi_b_TT_Presel",
            sXaxisLabel: r"p_{T} [GeV]",
            sYaxisLabel: r"|\eta|",
            sLumi:       lumi,
        }

        plotsDetails_dict['JetBtagEffi_c_%s.pdf' % (Year)] = {
            sIpFileName: "data/correction/mc/BtagSF/%s/jetBtagEfficiency.root" % (Year),
            sHistName:   "hJetBtagEffi_c_TT_Presel",
            sXaxisLabel: r"p_{T} [GeV]",
            sYaxisLabel: r"|\eta|",
            sLumi:       lumi,
        }

        plotsDetails_dict['JetBtagEffi_l_%s.pdf' % (Year)] = {
            sIpFileName: "data/correction/mc/BtagSF/%s/jetBtagEfficiency.root" % (Year),
            sHistName:   "hJetBtagEffi_l_TT_Presel",
            sXaxisLabel: r"p_{T} [GeV]",
            sYaxisLabel: r"|\eta|",
            sLumi:       lumi,
        }


    os.makedirs(sOpDir, exist_ok=True) 
    for sPlotName, plotDetails_dict in plotsDetails_dict.items():
        sSaveAs = '%s/%s' % (sOpDir, sPlotName)



        plot2D(
            sInFile = plotDetails_dict[sIpFileName], 
            sHisto = plotDetails_dict[sHistName], 
            nameXaxis = plotDetails_dict[sXaxisLabel], 
            nameYaxis = plotDetails_dict[sYaxisLabel], 
            lumi = plotDetails_dict[sLumi], 
            CMEnergy = cmEnergy, 
            sSaveAs = sSaveAs)

    



        
        
  