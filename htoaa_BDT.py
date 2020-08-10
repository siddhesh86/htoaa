import sys
import uproot
import numpy as np
import math
import matplotlib.pyplot as plt
import pandas as pd
import xgboost as xgb

from analib import PhysObj, Event

from sklearn.metrics import roc_curve, auc
from sklearn.model_selection import train_test_split

## signal files
fSig = uproot.open('GGH_HPT.root')
eventsSig = fSig.get('Events')

# ## background files + weights
# bgFiles = {
#     'QCD_HT200to300' : 1,
#     'QCD_HT300to500' : 0.259,
#     'QCD_HT500to700' : 0.0515,
#     'QCD_HT700to1000' : 0.01666,
#     'QCD_HT1000to1500' : 0.00905,
#     'QCD_HT1500to2000' : 0.003594,
#     'QCD_HT2000toInf': 0.001401
#         } 
# fBg = []
# eventsBg = []
# for i in range(len(bgFiles)):
#     fBg[i] = uproot.open('QCD_HT1000to1500.root')
#     eventsBg[i] = fBg.get('Events')

fBg = uproot.open('QCD_HT1000to1500.root')
eventsBg = fBg.get('Events')

## uhh make a dict of names and weights and for over the dict, 
## if name in fuck that doesn't work. or maybe. i need to think
## okay if we make data a dict too, it can hold sig and different bg
## and then we can loop through that to make cuts, hold weight, hold name, and hold weather it's signal or bg 
## will need to make the btag,mass,pt cut first, before adding the weight and name and shit column


## for possible multiple signal/background files, maybe a for loop and store the things in a list? 
## that will be a lot of for loops. maybe just hardcode open them if it's just 7 bk files
## store all the background in 1 list of eventsBg, then stack that into the dataframe of data,
## make sure to label that it is sig/bk as you fill it. 


trainVars = ['FatJet_pt', 'FatJet_eta', 'FatJet_mass', 'FatJet_btagCSVV2', 'FatJet_btagDeepB', 'FatJet_msoftdrop', 'FatJet_btagDDBvL']
cutVars = ['FatJet_btagDDBvL', 'FatJet_btagDeepB', 'FatJet_mass', 'FatJet_msoftdrop', 'FatJet_pt']
allVars = list(set(trainVars + cutVars))

'''
  * FatJet_btagDDBvL > 0.8      (This is the CMS double-b-tagger, an MVA which looks for two b-hadron decays in the same AK8 jet)
  * FatJet_btagDeepB > 0.4184   (This is the CMS single b-tagger, an MVA which looks for at least one b-hadron decay in a jet)
  * FatJet_mass      > 90 GeV   (This is the default reconstructed AK8 jet mass)
  * FatJet_msoftdrop > 90 GeV   (This is the mass excluding low-pT or "soft" components of the jet.)
  * FatJet_pt        > 240 GeV  (This is the total pT of the fat jet.)
'''

jetNums = list(range(1,8)) # for naming the columns
data = PhysObj('data')

for var in allVars: 
    data[var] = pd.DataFrame(eventsSig.array(var))
    
## we only want positive etas 
data.FatJet_eta = data.FatJet_eta.abs()

## Event so I can make cuts. this also runs .dropna(how='all)
ev = Event(data)
data.cut(data.FatJet_btagDDBvL > 0.8 )
data.cut(data.FatJet_btagDeepB > 0.4184)
data.cut(data.FatJet_mass > 90)
data.cut(data.FatJet_msoftdrop > 90)
data.cut(data.FatJet_pt > 240)
ev.sync()

wideData = pd.DataFrame() 

## rename column + make a single dataframe that contains all the dataframes sideways. 
## this is so i can shove it into XGBClassifier.fit()
colNames = []
for var in allVars: 
    colValues = [var + "_" + str(i) for i in jetNums]
    colNames = colNames + colValues
    colDict = dict(list(enumerate(colValues)))
    data[var] = data[var].rename(columns = colDict)
    if var == 'FatJet_btagDeepB':
        wideData = wideData.append(data[var])
    else:
        wideData = wideData.join(data[var])


## adding if thing is sig or bg (gonna have to fix this when i have real data)
target = np.random.choice([0, 1], size=wideData.shape[0], p=[.8, .2])
wideData['target'] = target
wideData = wideData.fillna(0)


## split data into training and testing
randInt = 1
trainData, testData = train_test_split(wideData, random_state=randInt)


## training 
cls = xgb.XGBClassifier(
    n_estimators = 800,
    max_depth = 2, 
    min_child_weight = 1,
    learning_rate = 0.01
    )

cls.fit(trainData[colNames], trainData['target'])
## BUT THE DOCUMENTATION DIDN'T SAY ANYTHING ABOUT IT NEEDING TO BE 2D!!!!!!

print ("XGBoost trained")

## make and fill plots for how many events we have for each training parameters
dataSig = wideData.loc[wideData.target == 1] #this used to be ix, but that depreciated :(
dataBg = wideData.loc[wideData.target == 0]

for colName in colNames: 
    hist_params = {'density': False, 'histtype': 'bar', 'fill': True , 'lw':3, 'alpha' : 0.4}
    nbins = 8
    min_valueS, max_valueS = np.percentile(dataSig[colName], [0.0, 99])        
    min_valueB, max_valueB = np.percentile(dataBg[colName], [0.0, 99])
    range_local = (min(min_valueS,min_valueB),  max(max_valueS,max_valueB))
    valuesS, binsS, _ = plt.hist(
        dataSig[colName].values,
        range = range_local,
        bins = nbins, edgecolor='b', color='b',
        label = "Signal", **hist_params
        )   
    to_ymax = max(valuesS)
    to_ymin = min(valuesS)
    valuesB, binsB, _ = plt.hist(
        dataBg[colName].values,
        range = range_local,
        bins = nbins, edgecolor='g', color='g',
        label = "Background", **hist_params
        )
    to_ymax2 = max(valuesB)
    to_ymax  = max([to_ymax2, to_ymax])
    to_ymin2 = min(valuesB)
    to_ymin  = max([to_ymin2, to_ymin])
    plt.ylim(ymin=to_ymin*0.1, ymax=to_ymax*1.2)
    plt.legend(loc='best')
    plt.xlabel(colName)
    plt.savefig("plots/plot_%s.png" % colName)
    plt.clf()

## data for rocs? 
## i don't actually know what this snippet of code does. ask siddesh
proba = cls.predict_proba(trainData[colNames])
fpr, tpr, thresholds = roc_curve(trainData['target'], proba[:,1])
train_auc = auc(fpr, tpr)
print("XGBoost train set auc - {}".format(train_auc))
proba = cls.predict_proba(testData[colNames])
fprt, tprt, thresholds = roc_curve(testData['target'], proba[:,1])
test_auct = auc(fprt, tprt)
print("XGBoost test set auc - {}".format(test_auct))
fig, ax = plt.subplots()


## draw them rocs
fig, ax = plt.subplots(figsize=(8, 8))
train_auc = auc(fpr, tpr)
ax.plot(fpr, tpr, lw=1, color='g',label='XGB train (area = %0.5f)'%(train_auc))
ax.plot(fprt, tprt, lw=1, ls='--',color='g',label='XGB test (area = %0.5f)'%(test_auct) )
ax.set_ylim([0.0,1.0])
ax.set_xlim([0.0,1.0])
ax.set_xlabel('False Positive Rate')
ax.set_ylabel('True Positive Rate')
ax.legend(loc="lower right")
ax.grid()
fig.savefig("plots/roc.png" )


## feature importance plot
fig, ax = plt.subplots()
f_score_dict = cls.get_booster().get_fscore()
#print("f_score_dict: {}".format(f_score_dict))

## okay si think about what this line is doing
## so I think siddesh had this line becuase his f_score_dict came out to be dict of {'f1': 34, 'f2': 21,...}
## because he was using .values on everything going into the classifier. He is doing this so the dict has
## correct names. I don't have to do this becuase mine went in with the column names 
# f_score_dict = {trainVars[k[1:]] : v for k,v in f_score_dict.items()}

feat_imp = pd.Series(f_score_dict).sort_values(ascending=True)
feat_imp.plot(kind='barh', title='Feature Importances')
fig.tight_layout()
fig.savefig("plots/importance.png")

## classifier o/p plot
hist_params = {'density': False, 'bins': 10 , 'histtype':'step'}
plt.clf()
y_pred  = cls.predict_proba(testData.loc[testData.target == 0, colNames])[:, 1] #
y_predS = cls.predict_proba(testData.loc[testData.target == 1, colNames])[:, 1] #
plt.figure('XGB',figsize=(6, 6))
values, bins, _ = plt.hist(y_pred ,  label="Background", **hist_params)
values, bins, _ = plt.hist(y_predS , label="Signal", **hist_params )
plt.legend(loc='best')
plt.savefig("plots/classifier.png")



