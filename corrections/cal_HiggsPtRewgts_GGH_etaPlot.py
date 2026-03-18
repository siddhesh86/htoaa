
import os
import sys
#sys.argv.append( '-b-' )
import ROOT
ROOT.PyConfig.IgnoreCommandLineOptions = False
from ROOT import TCanvas, TPad, TFile, TProfile, TNtuple, TH1D, TH2D, TH1, TF1, TEfficiency, TLegend
from ROOT import gROOT, gBenchmark, gRandom, gSystem
import ctypes
import re
import argparse
import enum
import copy
import math
import numpy as np

ROOT.gROOT.SetBatch(True)

sIpFileName = 'ipFileName'
sHistName   = 'histogramName'


def readHistFromFile(sFile, sHistNameFull, nRebinX=1, nRebinY=1):
    h = None
    f = TFile(sFile)
    
    if not f.IsOpen():
        print(f"{sFile} could not open", flush=True)
        exit(0)
    
    h = copy.deepcopy( f.Get(sHistNameFull) )
    if h == None:
        print(f"Could not read {sHistNameFull} histogram from {sFile} file. \t\t\t *** ERROR ***", flush=True)
        return h
        #exit(0)
    f.Close()
    h.Rebin(nRebinX)
    return copy.deepcopy(h)

def readAndAddHistsFromFile(histograms_list, hTotName, nRebinX=1, nRebinY=1):
    hAdded = None
    for hist_i_dict in histograms_list:
        sFIn_      = hist_i_dict[sIpFileName]
        sHistName_ = hist_i_dict[sHistName]
        hTmp_ = readHistFromFile(sFIn_, sHistName_, nRebinX=nRebinX)  
        if hTmp_ == None: continue

        if hAdded == None: hAdded = hTmp_.Clone(hTotName)
        else:              hAdded.Add(hTmp_)
        #print(f"{sHistName_}: {hTmp_.Integral()}, {hAdded.Integral()}, ", flush=True)

    return copy.deepcopy(hAdded)

def histIntegralAbvX(h, x1):
    integral = h.Integral(h.FindBin(x1), h.GetNbinsX())
    return integral

def histIntegralAndError(h, xLowBin=1, xHighBin=-1):
    if xHighBin<=0: xHighBin = h.GetNbinsX()
    eN = ctypes.c_double()
    N  = h.IntegralAndError(xLowBin, xHighBin, eN)
    return N, eN

def makeRatioHist(hNume, hDenom, sRatioName):
    hRatio = hNume.Clone(sRatioName)
    hRatio.Divide(hNume, hDenom)
    return hRatio

def makeCumulativeHist(h):
    hCumulative = h.Clone('%s_cumulative' % (h.GetName()))
    nBinsX = h.GetNbinsX()
    for iBin in range(1, nBinsX):
        eN = ctypes.c_double()
        N = h.IntegralAndError(iBin, nBinsX, eN)
        hCumulative.SetBinContent(iBin, N)
        hCumulative.SetBinError(iBin, eN)
    return hCumulative

def fitHistogram(h, sFitFuncLocal, FitRangeLocal, sFitFull, FitRangeFull, sCanvasName=''):
    c1 = TCanvas(sCanvasName, sCanvasName, 600,500)
    #c1.SetLogy(setLogY)
    c1.SetGrid()
    c1.cd()

    h.Draw()

    fLocal = TF1('fLocal_%s'%(h.GetName()), sFitFuncLocal, FitRangeLocal[0], FitRangeLocal[1])
    fLocal.SetLineColor(2)
    fLocal.SetLineWidth(2)
    fResultsPtr = h.Fit(fLocal, "RVS")
    fitParams = fLocal.GetParameters()
    print(f"{fResultsPtr = }")
    print(f'{fResultsPtr.Print("V") = }')
    print(f"{fLocal.GetName() = }, {fitParams = }, {type(fitParams) = }  ")
    print(f"{len(fitParams) = }")
    print(f"{fitParams[0] = }")
    print(f"{fitParams[1] = }")
    print(f"{fitParams[2] = }")
    print(f"{fitParams[3] = }")
    #print(f"{np.frombuffer(fitParams, dtype=np.float32, count=4) = }")
    
    

    return copy.deepcopy( c1 )
    



def plotHistograms(histogram_dict, sCanvasName, xLable='', yLable='', setLogY=1, xRange=[]):
    colors_list = [1, 2, 4, 6, 28, 46, 7, 3]

    c1 = TCanvas(sCanvasName, sCanvasName, 600,500)
    c1.SetLogy(setLogY)
    c1.SetGrid()
    c1.cd()

    function_tmp_ = TF1()

    i = 0
    leg = TLegend(0.5,0.85,0.99,0.99)
    for sHistName, h_ in histogram_dict.items():
        h_.SetMarkerStyle(20)
        h_.SetMarkerSize(0.5)
        h_.SetMarkerColor(colors_list[i])
        h_.SetLineColor(colors_list[i])  
        if i==0:   
            if  xLable != '': h_.GetXaxis().SetTitle(xLable)
            if  yLable != '': h_.GetYaxis().SetTitle(yLable)   
            if len(xRange)>0: h_.GetXaxis().SetRangeUser(xRange[0], xRange[1])     

        #if i == 0: h_.Draw()
        #else:      h_.Draw('same')  
        sDrawOption = ''
        sLegendOption = ''
        if i == 0: sDrawOption = ''
        else:      sDrawOption = 'same'
        if isinstance(h_, type(function_tmp_)): sDrawOption += 'R'
        if isinstance(h_, type(function_tmp_)): sLegendOption = 'l'
        else:                                   sLegendOption = 'lep'
        h_.Draw(sDrawOption)
        leg.AddEntry(h_, sHistName, sLegendOption)
        i += 1

    c1.cd()
    leg.Draw()

    return copy.deepcopy( c1 )

def plotHistogramsAndRatios(histogram_dict, sCanvasName, xLable='', yLable='', setLogY=1, xRange=[]):
    print(f"plotHistogramsAndRatios():: {sCanvasName = }, {xLable = }, {yLable = }, {setLogY = }, {xRange = }")
    colors_list = [1, 2, 4, 6, 28, 46, 7, 3]

    c1 = TCanvas(sCanvasName, sCanvasName, 600,500)
    pad1 = TPad('%s_pad0'%(sCanvasName), '%s_pad0'%(sCanvasName), 0,0.3,1,1)
    pad1.SetBottomMargin(0)
    pad1.Draw()
    pad1.cd()
    pad1.SetLogy(setLogY)
    pad1.SetGrid()    

    function_tmp_ = TF1()

    i = 0
    leg = TLegend(0.5,0.85,0.99,0.99)
    for sHistName, h_ in histogram_dict.items():
        h_.SetMarkerStyle(20)
        h_.SetMarkerSize(0.5)
        h_.SetMarkerColor(colors_list[i])
        h_.SetLineColor(colors_list[i])  
        if i==0:   
            if  xLable != '': h_.GetXaxis().SetTitle(xLable)
            if  yLable != '': h_.GetYaxis().SetTitle(yLable)   
            if len(xRange)>0: h_.GetXaxis().SetRangeUser(xRange[0], xRange[1])  
            h_.SetStats(0)  
            h_.GetYaxis().SetTitleSize(0.045) 
            #h_.GetXaxis().SetTitleSize(0.1)
            #h_.GetYaxis().SetTitleSize(0.1)
            

        #if i == 0: h_.Draw()
        #else:      h_.Draw('same')  
        sDrawOption = ''
        sLegendOption = ''
        if i == 0: sDrawOption = ''
        else:      sDrawOption = 'same'
        if isinstance(h_, type(function_tmp_)): sDrawOption += 'R'
        if isinstance(h_, type(function_tmp_)): sLegendOption = 'l'
        else:                                   sLegendOption = 'lep'
        h_.Draw(sDrawOption)
        leg.AddEntry(h_, sHistName, sLegendOption)
        i += 1

    pad1.cd()
    leg.Draw()

    c1.cd()
    pad2 = TPad('%s_pad0'%(sCanvasName), '%s_pad0'%(sCanvasName), 0,0,1,0.3)
    pad2.SetTopMargin(0)
    pad2.SetBottomMargin(0.2);
    pad2.Draw()
    pad2.cd()
    #pad2.SetLogy(setLogY)
    pad2.SetGrid() 

    sDenom = list(histogram_dict.keys())[0]
    hDenom = histogram_dict[sDenom]
    i = 0
    hRatio_ = {}
    for sHistName, h_ in histogram_dict.items():
        if sHistName == sDenom: 
            i += 1
            continue

        hRatio_[i] = copy.deepcopy( h_.Clone('%s_ratio'%(h_.GetName())) )
        hRatio_[i].Divide(h_, hDenom)

        hRatio_[i].SetMarkerStyle(20)
        hRatio_[i].SetMarkerSize(0.5)
        hRatio_[i].SetMarkerColor(colors_list[i])
        hRatio_[i].SetLineColor(colors_list[i]) 
        hRatio_[i].SetStats(0)  
        if i==1:   
            print(f"plotHistogramsAndRatios():: hRatio {i = }")
            if  xLable != '': hRatio_[i].GetXaxis().SetTitle(xLable)
            #if  yLable != '': hRatio_[i].GetYaxis().SetTitle(yLable)  
            hRatio_[i].GetYaxis().SetTitle(r'$\frac{LO}{NLO}$') 
            if len(xRange)>0: hRatio_[i].GetXaxis().SetRangeUser(xRange[0], xRange[1])  
            hRatio_[i].GetYaxis().SetRangeUser(0, 2)
            hRatio_[i].GetYaxis().SetNdivisions(505)
            hRatio_[i].GetXaxis().SetTitleSize(0.12)
            hRatio_[i].GetYaxis().SetTitleSize(0.12)
            hRatio_[i].GetXaxis().SetTitleOffset(0.7)
            hRatio_[i].GetXaxis().SetLabelSize(0.1)
            hRatio_[i].GetYaxis().SetLabelSize(0.1)
            hRatio_[i].GetYaxis().SetTitleOffset(0.3)

        sDrawOption = ''
        sLegendOption = ''
        if i == 1: sDrawOption = ''
        else:      sDrawOption = 'same'
        if isinstance(h_, type(function_tmp_)): sDrawOption += 'R'
        if isinstance(h_, type(function_tmp_)): sLegendOption = 'l'
        else:                                   sLegendOption = 'lep'
        hRatio_[i].Draw(sDrawOption)
        i += 1

    return copy.deepcopy( c1 )


def stitchInclAndExclHistogramsAlongXaxis(hInclusive, hExclusive, X_toStitchHistograms):
    # Normalize hInclusive to unit area
    print(f"Before: {histIntegralAndError(hInclusive) = }")
    hInclusive.Scale( 1./hInclusive.Integral() )
    print(f"After:  {histIntegralAndError(hInclusive) = }")

    # Scale hHighPt (= h_Excl) to match hInclusive area for Pt > X_toStitchHistograms (400 GeV)
    integral1_Incl     = histIntegralAbvX(hInclusive,     X_toStitchHistograms)
    integral1_Excl = histIntegralAbvX(hExclusive, X_toStitchHistograms)
    hExclusive.Scale( integral1_Incl / integral1_Excl )

    # hStitch =  
    #           hInclusive (when Pt <  X_toStitchHistograms)
    #           +
    #           hHighPt    (when Pt >= X_toStitchHistograms)
    hHToAATo4B_Stitch = hInclusive.Clone(hInclusive.GetName().replace('Incl','Stitch'))
    print(f"Before: {histIntegralAndError(hHToAATo4B_Stitch) = }")
    for iBin in range(hHToAATo4B_Stitch.FindBin(X_toStitchHistograms), hHToAATo4B_Stitch.GetNbinsX()+1):
        hHToAATo4B_Stitch.SetBinContent(iBin, hExclusive.GetBinContent(iBin))
        hHToAATo4B_Stitch.SetBinError(iBin,   hExclusive.GetBinError(iBin))
    print(f"After:  {histIntegralAndError(hHToAATo4B_Stitch) = }")

    return hInclusive, hExclusive, hHToAATo4B_Stitch


def makeHqt_HiggsPt_Hist(sFInHqtHiggsSpectrum, sFOutHqtHiggsHist):
    hHiggsCrosssecStitchedInPt     = TH1D('hGenHiggsPt_Nom_HqtStitched',     'Calculated with Hqt - stitched',  2000,            0,               2000)
    hHiggsCrosssecStitchedInLog2Pt = TH1D('hGenHiggsLog2Pt_Nom_HqtStitched', 'Calculated with Hqt- stitched',   200,  math.log2(1),    math.log2(2000))
    hHiggsCrosssecMatchedInPt      = TH1D('hGenHiggsPt_Nom_HqtMatched',      'Calculated with Hqt - matched',  2000,            0,               2000)
    hHiggsCrosssecMatchedInLog2Pt  = TH1D('hGenHiggsLog2Pt_Nom_HqtMatched',  'Calculated with Hqt - matched',   200,  math.log2(1),    math.log2(2000))
    
    ## Read Hqt Higgs Pt spectrum and store it into histogram
    HiggsCrosssection_dict = {}
    with open(sFInHqtHiggsSpectrum) as fInHqtHiggsSpectrum:
        for line in fInHqtHiggsSpectrum:
            data_list = re.split(r'\s+', line.rstrip()) # split line into list of words. 
            if '' in data_list:  data_list.remove('')   # remove empy string if any
            print(f"{data_list = }")

            if data_list[0] == '(': continue  # comment line starts with '(' charecter

            # data_list columns: 'qt', 'res', 'asym', 'fixor', 'matched', 'switched'
            # Read 'qt': Higgs pT,      'switched': Higgs differential cross-section NNLO+LO
            # https://www.physik.uzh.ch/~grazzini/codes/note20.pdf#page=4
            Pt           = float(data_list[0])
            Crosssection_stitched = float(data_list[-1])
            Crosssection_matched  = float(data_list[-2])
            print(f"{Pt}, \t {Crosssection_matched = }, \t {Crosssection_stitched = }")

            # skip -ve cross-section readings
            if (Crosssection_matched < 0) and (Crosssection_stitched < 0): continue

            HiggsCrosssection_dict[Pt] = {
                'matched':  Crosssection_matched,
                'switched': Crosssection_stitched
            }
            
    xsErrorFraction = 0.05

    # Set cross-section for hHiggsCrosssecInPt bins
    hTmp_dict = {
        'matched':  hHiggsCrosssecMatchedInPt,
        'switched': hHiggsCrosssecStitchedInPt
    }
    for XSType, hTmp_ in hTmp_dict.items():
        for iBin in range(1, hTmp_.GetNbinsX()+1):
            # calculate average of cross-sections over pT points fall in the histogram pT bin
            PtPoints_list = []
            for Pt in HiggsCrosssection_dict.keys():
                if Pt >= hTmp_.GetXaxis().GetBinLowEdge(iBin) and \
                   Pt <  hTmp_.GetXaxis().GetBinUpEdge(iBin):
                    PtPoints_list.append(Pt)

            #hTmp_.SetBinContent(iBin, avgXS)
            nPtPoints = len(PtPoints_list)
            if nPtPoints == 0: continue

            # Pick up middle point in Pt that lie within bin of hitogram
            iPtPointSel = int( np.median( range(nPtPoints) ) )
            PtPointSel  = PtPoints_list[iPtPointSel]
            XS = HiggsCrosssection_dict[PtPointSel][XSType]
            if XS < 0: continue
            hTmp_.SetBinContent(iBin, XS)
            hTmp_.SetBinError(  iBin, XS * xsErrorFraction) # error: 5%

    
    # Set cross-section for hHiggsCrosssecInLog2Pt bins
    hTmp_dict = {
        'matched':  hHiggsCrosssecMatchedInLog2Pt,
        'switched': hHiggsCrosssecStitchedInLog2Pt
    }
    for XSType, hTmp_ in hTmp_dict.items():
        for iBin in range(1, hTmp_.GetNbinsX()+1):
            # calculate average of cross-sections over pT points fall in the histogram pT bin
            PtPoints_list = []
            for Pt in HiggsCrosssection_dict.keys():
                if math.log2(Pt) >= hTmp_.GetXaxis().GetBinLowEdge(iBin) and \
                   math.log2(Pt) <  hTmp_.GetXaxis().GetBinUpEdge(iBin):
                    PtPoints_list.append(Pt)

            nPtPoints = len(PtPoints_list)
            if nPtPoints == 0: continue

            # Pick up middle point in Pt that lie within bin of hitogram
            iPtPointSel = int( np.median( range(nPtPoints) ) )
            PtPointSel  = PtPoints_list[iPtPointSel]
            XS = HiggsCrosssection_dict[PtPointSel][XSType]
            if XS < 0: continue
            hTmp_.SetBinContent(iBin, XS)
            hTmp_.SetBinError(  iBin, XS * xsErrorFraction) # error: 5%
    



    ## Write Higgs Pt histograms into output root file
    sDir_ = os.path.dirname( os.path.realpath(sFOutHqtHiggsHist) )
    if not os.path.exists(sDir_): 
        os.makedirs( sDir_ )
    fOutHqtHiggsHist = TFile(sFOutHqtHiggsHist, 'recreate')
    fOutHqtHiggsHist.cd()
    hHiggsCrosssecStitchedInPt.Write()
    hHiggsCrosssecStitchedInLog2Pt.Write()   
    hHiggsCrosssecMatchedInPt.Write()
    hHiggsCrosssecMatchedInLog2Pt.Write()   
    fOutHqtHiggsHist.Close()

    print(f"\nWrote Higgs pT cross-section (Hqt) histograms into {sFOutHqtHiggsHist}.")   


#def calculateGGFHiggsPtRewgt(
#    hHToAATo4B_Incl_list, hHToAATo4B_Excl_list,  hGGFHTo2B_Incl_list, 
#):







if __name__ == "__main__":
    # Higgs pT reweighting discussion on 22/01/2026: 
    # https://mattermost.web.cern.ch/cms-exp/pl/xzgfq4n7stdm3xif1u1saj77wr

    print("Running cal_HiggsPtRewgts_ggH", flush=True)

    parser = argparse.ArgumentParser(description='cal_HiggsPtRewgts')
    parser.add_argument('-era', dest='era',   type=str, default='2018',                    choices=['2016','2017','2018'], required=False)
    parser.add_argument('-prodMode', dest='prodMode',   type=str, default='ggH',           choices=['ggH','VBFH', 'WH', 'WplusH','WminusH', 'ZH', 'ttH'], required=True)
    parser.add_argument('-useHToAATo4TauSignal',  action='store_true', default=False, help='Use HToAATo4Tau signal for cross-checks')
    args=parser.parse_args()
    print("args: {}".format(args), flush=True)
    era                     = args.era
    productionMode          = args.prodMode   
    useHToAATo4TauSignal    = args.useHToAATo4TauSignal # Default: False
    
    sOutDir                           = "/eos/cms/store/user/ssawant/htoaa/analysis/HiggsPtRewgts_v2p1/%s" % (era)

    #sIpFileAllHist = '/eos/cms/store/user/ssawant/htoaa/analysis/20260312_HiggsPtReweighting/2018/analyze_htoaa_stage1.root'
    sIpFileAllHist = '/eos/cms/store/user/ssawant/htoaa/analysis/20260317_HiigsPtRewgt/2018/analyze_htoaa_stage1.root'
    sHistNameShort_list = ['hGenHiggsEta_Nom', 'hGenHiggsEta_HiggsPt250to350_Nom', 'hGenHiggsEta_HiggsPt350to450_Nom', 'hGenHiggsEta_HiggsPtGt450_Nom'] # ['hGenHiggsPt_Nom', 'hGenHiggsLog2Pt_Nom']  'hGenHiggsPt_Nom', 'hGenHiggsPt_wHiggsPtRewgt_Nom'
    nRebinX_dict = {'hGenHiggsPt_Nom': 50, 'hGenHiggsLog2Pt_Nom': 4, 'hGenHiggsEta_Nom': 4, 'hGenHiggsEta_HiggsPt250to350_Nom': 4, 'hGenHiggsEta_HiggsPt350to450_Nom': 4, 'hGenHiggsEta_HiggsPtGt450_Nom': 4}
    xRange_dict = {'hGenHiggsPt_Nom': [200., 1000.], 'hGenHiggsLog2Pt_Nom': [math.log2(250.), math.log2(1200.)], 'hGenHiggsEta_Nom': [-5, 5], 'hGenHiggsEta_HiggsPt250to350_Nom': [-5, 5], 'hGenHiggsEta_HiggsPt350to450_Nom': [-5, 5], 'hGenHiggsEta_HiggsPtGt450_Nom': [-5, 5]}
    xLabel_dict = {'hGenHiggsPt_Nom': r'Higgs pT [GeV]', 'hGenHiggsLog2Pt_Nom': r'log2(Higgs pT)', 'hGenHiggsEta_Nom': r'Higgs #eta', 'hGenHiggsEta_HiggsPt250to350_Nom': r'Higgs #eta', 'hGenHiggsEta_HiggsPt350to450_Nom': r'Higgs #eta', 'hGenHiggsEta_HiggsPtGt450_Nom': r'Higgs #eta'}
    HiggsPtPoint_toStitchHToAATo4BSamples = 300 # GeV
    HiggsPtPoint_toStitchHTo2BSamples     = 300 # GeV
    HiggsPt_fitRange                  = [150, 1100] # GeV
    HiggsPt_fullRange                 = [  1, 2000] # GeV
    sFOutHiggsPtRewgt    = "%s/%sHiggsPtRewgt_%s_v20260312.root" % (sOutDir, productionMode, 'HToAATo4Tau' if useHToAATo4TauSignal else 'HToAATo4B')
    xsHiggs_dict = {
        'ggH': 48.61   * 1000, # 33.8 * 1000, # 48.61 * 1000, # fb
        'VBFH': 3.888  * 1000, # Used in arXiv:2005.07762
        'ttH':  0.5071 * 1000, # Used in arXiv:2005.07762
    }

    '''
    xs_EFT_QCD = { # in fb 
        ## EFT NNLO QCD + EWK from arXiv:2005.07762: https://docs.google.com/spreadsheets/d/1cxN35LaQAgTxWiECsH9Tv_72xcQimIartktx8mYPTuM/edit?usp=sharing
        # XSEC are scaled from 33.8 pb to 48.61 pb
        425:	[20.09,	5.94],
        475:	[10.48,	3.24],
        525:	[5.68,	1.83],
        575:	[3.18,	1.07],
        625:	[1.81,	0.64],
        675:	[1.08,	0.39],
        725:	[0.65,	0.24],
        775:	[0.40,	0.16],
    }'''
    xs_EFT_QCD = {}


    


    sProcessesHiggsLO = productionMode
    if productionMode == 'WplusH' or productionMode == 'WminusH':  sProcessesHiggsLO = 'WH'
    
    sProcessesHiggsNLO = []
    if productionMode == 'VBFH':    sProcessesHiggsNLO = ['VBFH_dipoleRecoilOn'] #['VBFHToBB_powheg'] 
    if productionMode == 'WH':      sProcessesHiggsNLO = ['WplusHToBBQQ', 'WplusHToBBLNu', 'WminusHToBBQQ', 'WminusHToBBLNu'] 
    if productionMode == 'WplusH':  sProcessesHiggsNLO = ['WplusHToBBQQ', 'WplusHToBBLNu'] 
    if productionMode == 'WminusH': sProcessesHiggsNLO = ['WminusHToBBQQ', 'WminusHToBBLNu'] 
    #if productionMode == 'ZH':      sProcessesHiggsNLO = ['ZHToBBX'] # powheg
    if productionMode == 'ZH':      sProcessesHiggsNLO = ['ZHToMuMuG'] # dalitz amcatnloFXFX
    if productionMode == 'ttH':     sProcessesHiggsNLO = ['ttHToBB'] 


    os.makedirs( os.path.dirname( os.path.realpath(sFOutHiggsPtRewgt) ), exist_ok=True )
    if os.path.exists(sFOutHiggsPtRewgt): os.remove(sFOutHiggsPtRewgt) # Delete output file if it exists

    
    fOutHiggsPtRewgt_GGF = TFile(sFOutHiggsPtRewgt, 'RECREATE')        
    cCompareSamples = {}
    hHiggsPtReweights_NLO = {}
    for iHistNameShort, sHistNameShort in enumerate(sHistNameShort_list):
        hHToAATo4B_Excl_list = []
        hHToAATo4B_Incl_list     = []
        hHToAATo4B_Excl_rewgt_list = []
        mAs = [ '12p0', '15p0', '20p0', '25p0', '30p0', '35p0', '40p0', '45p0', '50p0', '55p0', '60p0'  ]
        #mAs = [ '12p0', ]
        sHistName_HToAATo4B_Excl_0 = 'evt/%stoaato4b_mA_%s/%s'
        sHistName_HToAATo4B_Incl_0 = 'evt/%stoaato4b_Incl_mA_%s/%s'
        if useHToAATo4TauSignal:
            mAs = ['All']
            sHistName_HToAATo4B_Incl_0 = 'evt/%stoaato4tau_mA_%s/%s'    
            if productionMode in ['WH', 'WplusH', 'WminusH', 'ZH']:
                sProcessesHiggsLO = 'VH'        
        for mA in mAs:
            hHToAATo4B_Excl_list.append({
                sIpFileName: sIpFileAllHist,
                sHistName:  sHistName_HToAATo4B_Excl_0     % (sProcessesHiggsLO,mA, sHistNameShort)
            }) 
            '''
            hHToAATo4B_Incl_list.append({
                sIpFileName: sIpFileAllHist,
                sHistName:  sHistName_HToAATo4B_Incl_0     % (sProcessesHiggsLO,mA, sHistNameShort)
            }) '''
            
            hHToAATo4B_Excl_rewgt_list.append({
                sIpFileName: sIpFileAllHist,
                sHistName:  sHistName_HToAATo4B_Excl_0     % (sProcessesHiggsLO,mA, sHistNameShort.replace('_Nom', '_wHiggsPtRewgt_Nom'))
            }) 
        print(f'{hHToAATo4B_Excl_list = }\n\n', flush=True)
        print(f'{hHToAATo4B_Excl_rewgt_list = }', flush=True)
            

        hGGFHTo2B_Excl_list = [
            {
                sIpFileName: sIpFileAllHist,
                sHistName: 'evt/GluGluHToBB_Pt-200ToInf/%s' % (sHistNameShort)
            }
        ]
        '''
        hGGFHTo2B_Incl_list  = [
            {
                sIpFileName: sIpFileAllHist,
                sHistName: 'evt/GluGluHToBB_Incl/%s' % (sHistNameShort)
            }
        ]'''

        hHiggsNLO_list = []
        for sProcessHiggsNLO in sProcessesHiggsNLO:
            hHiggsNLO_list.append({
                sIpFileName: sIpFileAllHist,
                sHistName: 'evt/%s/%s'      % (sProcessHiggsNLO, sHistNameShort)
            })

        nRebinX = nRebinX_dict[sHistNameShort]
        HiggsPtPoint_toStitchHToAATo4BSamples_toUse = HiggsPtPoint_toStitchHToAATo4BSamples
        HiggsPtPoint_toStitchHTo2BSamples_toUse     = HiggsPtPoint_toStitchHTo2BSamples 
        HiggsPt_fitRange_toUse                      = HiggsPt_fitRange
        HiggsPt_fullRange_toUse                     = HiggsPt_fullRange
        if 'Log2Pt' in sHistNameShort:
            HiggsPtPoint_toStitchHToAATo4BSamples_toUse = math.log2(HiggsPtPoint_toStitchHToAATo4BSamples)
            HiggsPtPoint_toStitchHTo2BSamples_toUse     = math.log2(HiggsPtPoint_toStitchHTo2BSamples) 
            HiggsPt_fitRange_toUse                      = np.log2(HiggsPt_fitRange_toUse)
            HiggsPt_fullRange_toUse                     = np.log2(HiggsPt_fullRange)

        '''
        print(f"Test here1", flush=True)
        f = TFile('/eos/cms/store/user/ssawant/htoaa/analysis/20260317_HiigsPtRewgt/2018/analyze_htoaa_stage1.root')
        print(f"Test here2", flush=True)
        '''

        ## HToAATo4B histogram ------------
        print(f"\n\nWorking with HToAATo4B")
        if not useHToAATo4TauSignal:
            hHToAATo4B_Excl = readAndAddHistsFromFile(hHToAATo4B_Excl_list, '%s_HToAATo4B_Excl'%(sHistNameShort), nRebinX=nRebinX)
            #hHToAATo4B_Incl = readAndAddHistsFromFile(hHToAATo4B_Incl_list, '%s_HToAATo4B_Incl'%(sHistNameShort), nRebinX=nRebinX)
            # Stitch hInclusive and hExclusive histograms
            '''
            hHToAATo4B_Incl, hHToAATo4B_Excl, hHToAATo4B_Stitch = stitchInclAndExclHistogramsAlongXaxis(
                hInclusive = hHToAATo4B_Incl, 
                hExclusive = hHToAATo4B_Excl, 
                X_toStitchHistograms = HiggsPtPoint_toStitchHToAATo4BSamples_toUse
                )
            print(f"After: {histIntegralAndError(hHToAATo4B_Incl) = }, {histIntegralAndError(hHToAATo4B_Excl) = }, {histIntegralAndError(hHToAATo4B_Stitch) = }, ")
            '''
            hHToAATo4B_Stitch = hHToAATo4B_Excl
            print(f"{hHToAATo4B_Stitch.Integral() = }", flush=True)
            
            hHToAATo4B_Excl_rewgt = readAndAddHistsFromFile(hHToAATo4B_Excl_rewgt_list, '%s_HToAATo4B_Excl_rewgt'%(sHistNameShort), nRebinX=nRebinX)
            hHToAATo4B_rewgt_Stitch = hHToAATo4B_Excl_rewgt
            print(f"{hHToAATo4B_rewgt_Stitch.Integral() = }", flush=True)
        else:
            hHToAATo4B_Stitch = readAndAddHistsFromFile(hHToAATo4B_Incl_list, '%s_HToAATo4Tau_mA_All'%(sHistNameShort), nRebinX=nRebinX)
            hHToAATo4B_Stitch.Scale( 1./hHToAATo4B_Stitch.Integral() )
            hHToAATo4B_Incl = hHToAATo4B_Stitch.Clone('%s_cloneIncl'%hHToAATo4B_Stitch.GetName())
            hHToAATo4B_Excl = hHToAATo4B_Stitch.Clone('%s_cloneExcl'%hHToAATo4B_Stitch.GetName())

        hHiggsNLO = None
        if productionMode == 'ggH':
            ## GGFHTo2B histogram ------------
            print(f"\n\nWorking with GGFHTo2B")
            hGGFHTo2B_Excl = readAndAddHistsFromFile(hGGFHTo2B_Excl_list, '%s_GGFHTo2B_Excl'%(sHistNameShort), nRebinX=nRebinX)
            #hGGFHTo2B_Incl = readAndAddHistsFromFile(hGGFHTo2B_Incl_list, '%s_GGFHTo2B_Incl'%(sHistNameShort), nRebinX=nRebinX)
            # Stitch hInclusive and hExclusive histograms
            '''hGGFHTo2B_Incl, hGGFHTo2B_Excl, hGGFHTo2B_Stitch = stitchInclAndExclHistogramsAlongXaxis(
                hInclusive = hGGFHTo2B_Incl, 
                hExclusive = hGGFHTo2B_Excl, 
                X_toStitchHistograms = HiggsPtPoint_toStitchHTo2BSamples_toUse
                )
            print(f"After: {histIntegralAndError(hGGFHTo2B_Incl) = }, {histIntegralAndError(hGGFHTo2B_Excl) = }, {histIntegralAndError(hGGFHTo2B_Stitch) = }, ")
            '''
            hGGFHTo2B_Stitch = hGGFHTo2B_Excl
            hHiggsNLO = hGGFHTo2B_Stitch 
        else: # Production modes other than ggH
            hHiggsNLO = readAndAddHistsFromFile(hHiggsNLO_list, '%s_HiggsNLO'%(sHistNameShort), nRebinX=nRebinX)
            #hHiggsNLO.Scale( 1./hHiggsNLO.Integral() )

        
        # Normalized histograms to particular cross-section
        xs_toUse     = xsHiggs_dict[productionMode] if productionMode in xsHiggs_dict else 1
        sXs_toUse    = r' \sigma = %.0f fb' % xsHiggs_dict[productionMode] if productionMode in xsHiggs_dict else ''
        for h_ in [hHToAATo4B_Stitch, hHiggsNLO, hHToAATo4B_rewgt_Stitch]: 
            h_.Scale( xs_toUse/h_.Integral() )

        # Cross-section: EFT QCD+EWK
        hHiggsEFT_QCD = TH1D('%s_EFT_QCD'%(sHistNameShort), '%s_EFT_QCD'%(sHistNameShort), hHiggsNLO.GetNbinsX(), hHiggsNLO.GetXaxis().GetXmin(), hHiggsNLO.GetXaxis().GetXmax())
        for pt_, XS_ in xs_EFT_QCD.items():
            ptBin = hHiggsEFT_QCD.FindBin(pt_)
            hHiggsEFT_QCD.SetBinContent(ptBin, XS_[0])
            hHiggsEFT_QCD.SetBinError(ptBin,   XS_[1])
            

        ## Plot compare different samples
        if   productionMode == 'ggH':
            sLegend_ProdMode = r"\text{gg}\rightarrow"
        elif productionMode == 'VBFH':
            sLegend_ProdMode = r"\text{VBF}"
        elif productionMode == 'ttH':
            sLegend_ProdMode = r"\text{tt}"
            
        histograms_dict_ = {
            r"%s \text{ H (NLO MC), } %s" % (sLegend_ProdMode, sXs_toUse):               hHiggsNLO,
            r"%s \text{ H (LO MC), } %s" % (sLegend_ProdMode, sXs_toUse):            hHToAATo4B_Stitch,
            r"%s \text{ H (LO reweighted MC), } %s" % (sLegend_ProdMode, sXs_toUse):            hHToAATo4B_rewgt_Stitch,
            #r"\text{gg}\rightarrow \text{H (EFT NNLO MC), } %s" % (sXs_toUse):       hHiggsEFT_QCD,
            
        }
        xRange_toUse = xRange_dict[sHistNameShort] if sHistNameShort in xRange_dict else []
        yLable_toUse = r'$\frac{d\sigma}{dpT}  [fb/GeV]$' if productionMode in xsHiggs_dict else 'A.U.'
        xLable_toUse = xLabel_dict[sHistNameShort] if sHistNameShort in xLabel_dict else ''    
        print(f"{xLable_toUse = }")    
        cCompareSamples[iHistNameShort] = plotHistogramsAndRatios(histograms_dict_, 'c%s_%s_CompareSamples'%(productionMode, sHistNameShort), xLable=xLable_toUse, yLable=yLable_toUse, xRange=xRange_toUse)            
        cCompareSamples[iHistNameShort].SaveAs('%s/%s_%s.png'%(sOutDir, productionMode, sHistNameShort))

        ## Higgs Pt reweights: w/ NLO
        hHiggsPtReweights_NLO[iHistNameShort] = makeRatioHist(
            hNume      = hHiggsNLO, 
            hDenom     = hHToAATo4B_Stitch, 
            sRatioName = '%s_Wgt_NLO'%(sHistNameShort) 
        )
        '''
        hHiggsPtReweights_EFT_QCD_0 = makeRatioHist(
            hNume      = hHiggsEFT_QCD, 
            hDenom     = hHToAATo4B_Stitch, 
            sRatioName = '%s_Wgt_EFT_QCD_0'%(sHistNameShort)
        )
        '''
        
        

        fOutHiggsPtRewgt_GGF.cd()

        cCompareSamples[iHistNameShort].Write()
        hHiggsPtReweights_NLO[iHistNameShort].Write()
        
        
        


    fOutHiggsPtRewgt_GGF.Close()
    print(f"\nWrote Higgs pT reweights histograms ({sHistNameShort}) into {sFOutHiggsPtRewgt}.")         


