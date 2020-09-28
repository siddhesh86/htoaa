import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
import xgboost as xgb
import pickle
import random
import os

from info import fileNames, allVars, trainVars
from data_manager import processData

from sklearn.metrics import roc_curve, auc, accuracy_score
from sklearn.model_selection import train_test_split


from optparse import OptionParser
parser = OptionParser()
parser.add_option("--ntrees", type="int", dest="ntrees", help="hyp", default = 1000)
parser.add_option("--treeDeph", type="int", dest="treeDeph", help="hyp", default = 2)
parser.add_option("--lr", type="float", dest="lr", help="hyp", default = 0.05)
parser.add_option("--mcw", type="float", dest="mcw", help="hyp", default = 1)
parser.add_option("--doXML", action="store_true", dest="doXML", help="Do save not write the xml file", default=False) 
(options, args) = parser.parse_args()

hyppar="ntrees_"+str(options.ntrees)+"_deph_"+str(options.treeDeph)+"_mcw_"+str(options.mcw)+"_lr_"+str(options.lr)
print(hyppar)
## process and append them into 1 long dataframe containing all the 
## signal and all bg (that I have)
## should I be concerned that 200to300 returns only 7 events after the 
## selection cuts


## in case i want to special name each plots
## condition is tagged onto the end of each file name and plot title 
## figname and title is for the mass VS BDTscore plots 
## folder name is in case i want to use make <folderName>/distributions and <folderName>/plots
## I tried to have python make folder if it doesn't see one, but that creates many errors
condition = ''
figname = 'less03'
figtitle = '< 0.3'
folderName = ''

data = pd.DataFrame()

for fileName in fileNames: 
    tmpData = processData(fileName)
    print(tmpData)
    data = data.append(tmpData, ignore_index=True, sort = False)

## drop all columns and rows that all nan
data = data.dropna(axis = 1, how = 'all') 
data = data.dropna(how = 'all')

data = data.fillna(0)


## get column names (without the weight, target)
# colNames = list(data.columns)
# colNames = colNames[:-2]


## normalizing the weights?? why do we have to do this? how do we do this?
data.loc[data['target']==0, ['weights']] *= 100000/data.loc[data['target']==0]['weights'].sum()
data.loc[data['target']==1, ['weights']] *= 100000/data.loc[data['target']==1]['weights'].sum()

## 
dataSig = data.loc[data.target == 1]
dataBg = data.loc[data.target == 0]

print('Signal event count: ' + str(len(dataSig.index)))
print('Background event count: ' + str(len(dataBg.index)))

## drop events with NaN weights - for safety
data.dropna(subset=['weights'],inplace = True) 
data.fillna(0)

## split data into training and testing
#randInt = random.randint(0,100)
randInt = 7
print("random int: " + str(randInt))
trainData, testData = train_test_split(data, random_state=randInt)

## training 
cls = xgb.XGBClassifier(
    n_estimators = options.ntrees,
    max_depth = options.treeDeph,
    min_child_weight = options.mcw,
    learning_rate = options.lr,

    )
# cls.fit(trainData[colNames], trainData['target'], sample_weight=(trainData['weights']))
cls.fit(trainData[trainVars], trainData['target'], sample_weight=(trainData['weights']))

print ("XGBoost trained")

## data from rocs?
# proba = cls.predict_proba(trainData[colNames])
train_proba = cls.predict_proba(trainData[trainVars])
fpr, tpr, thresholds = roc_curve(trainData['target'], train_proba[:,1])
train_auc = auc(fpr, tpr)
print("XGBoost train set auc - {}".format(train_auc))
# proba = cls.predict_proba(testData[colNames])
test_proba = cls.predict_proba(testData[trainVars])
fprt, tprt, thresholds = roc_curve(testData['target'], test_proba[:,1])
test_auct = auc(fprt, tprt)
print("XGBoost test set auc - {}".format(test_auct))
fig, ax = plt.subplots()
# prediction = cls.predict(testData[colNames])
prediction = cls.predict(testData[trainVars])
accuracy = accuracy_score(testData['target'], prediction)
print("XGBoost test accuracy - {}".format(accuracy))



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
ax.set_title(hyppar + condition)
if not os.path.exists('{}plots/'.format(folderName)):
    os.makedirs('{}plots/'.format(folderName))
fig.savefig("{}plots/{}_roc_{}.png".format(folderName, hyppar, condition))
plt.clf()


## add the BDT scores to the df so manip is easier. hopefully
trainData.loc[:,'BDTScore'] = train_proba[:,1]
testData.loc[:, 'BDTScore'] = test_proba[:,1]


## making bdt score figs babey
fig, ax = plt.subplots(figsize=(8,8))
ax.hist(trainData.BDTScore.loc[trainData.target == 1], bins=20, ls = '--', histtype='step',stacked=True, label='train signal', density= True)
ax.hist(trainData.BDTScore.loc[trainData.target == 0], bins=20, ls = '--', histtype='step',stacked=True, label='train background', density=True)
ax.hist(testData.BDTScore.loc[testData.target == 1], bins=20, histtype='step', stacked=True, label='test signal', fill=False, density=True)
ax.hist(testData.BDTScore.loc[testData.target == 0], bins=20, histtype='step', stacked=True, label='test background', fill=False, density=True)
ax.legend(loc='lower right')
ax.set_title('BDT score' + condition)
ax.set_xlabel('BDT Score')
fig.savefig("{}plots/BDT_score_{}.png".format(folderName, condition))
plt.clf()

## softdrop mass vs bdt score
fig, ax = plt.subplots(figsize=(8,8))
ax.scatter(trainData.BDTScore.loc[trainData.target == 1], trainData.FatJet_msoftdrop.loc[trainData.target == 1], label='train signal')
ax.scatter(trainData.BDTScore.loc[trainData.target == 0], trainData.FatJet_msoftdrop.loc[trainData.target == 0], label='train background')
ax.scatter(testData.BDTScore.loc[testData.target == 1], testData.FatJet_msoftdrop.loc[testData.target == 1], label='test signal')
ax.scatter(testData.BDTScore.loc[testData.target == 0], testData.FatJet_msoftdrop.loc[testData.target == 0], label='test background')

ax.legend(loc='upper right')
ax.set_xlabel('BDT Score')
ax.set_ylabel('Softdrop mass (GeV)')
ax.set_title('Softdrop mass VS BDT Score' + condition)
fig.savefig('{}plots/softdropMassVsBDTScore {}.png'.format(folderName, condition))
plt.clf()


# d = True
# nbins = 40
# ## 1d hist msoftdrop for bdtscore 
# fig, ax = plt.subplots(figsize=(8,8))
# sigtoplot = pd.concat([
#     trainData.loc[(trainData.BDTScore<0.3) & (trainData.target==1),'FatJet_msoftdrop'],
#     testData.loc[(testData.BDTScore<0.3) & (testData.target==1), 'FatJet_msoftdrop']], 
#     axis = 0)
# ax.hist(sigtoplot, bins=nbins, histtype='step', label='signal', density=d)
# bgtoplot = pd.concat([
#     trainData.loc[(trainData.BDTScore<0.3) & (trainData.target==0),'FatJet_msoftdrop'],
#     testData.loc[(testData.BDTScore<0.3) & (testData.target==0), 'FatJet_msoftdrop']], 
#     axis = 0)
# ax.hist(bgtoplot, bins=nbins, histtype='step', label='background', density=d)
# ax.legend(loc='upper right')
# ax.set_xlabel('softdrop mass (GeV)')
# ax.set_title('msoft drop for BDT score {} {}'.format(figtitle, condition))
# counttext = '\n'.join((
#     "signal count: " + str(len(sigtoplot.index)), 
#     "background count: " + str(len(bgtoplot.index))))
# ax.text(0.7, 0.85, counttext, transform=ax.transAxes)
# fig.savefig('plots/msoftdrop_{}{}.png'.format(figname, condition))
# plt.clf()


# ## 1d hist mass for bdtscore 
# fig, ax = plt.subplots(figsize=(8,8))
# sigtoplot = pd.concat([
#     trainData.loc[(trainData.BDTScore<0.3) & (trainData.target==1),'FatJet_mass'],
#     testData.loc[(testData.BDTScore<0.3) & (testData.target==1), 'FatJet_mass']], 
#     axis = 0)
# ax.hist(sigtoplot, bins=nbins, histtype='step', label='signal', density=d)
# bgtoplot = pd.concat([
#     trainData.loc[(trainData.BDTScore<0.3) & (trainData.target==0),'FatJet_mass'],
#     testData.loc[(testData.BDTScore<0.3) & (testData.target==0), 'FatJet_mass']], 
#     axis = 0)
# ax.hist(bgtoplot, bins=nbins, histtype='step', label='background', density=d)
# ax.legend(loc='upper right')
# ax.set_xlabel('mass (GeV)')
# ax.set_title('mass for BDT score {} {}'.format(figtitle, condition))
# counttext = '\n'.join((
#     "signal count: " + str(len(sigtoplot.index)), 
#     "background count: " + str(len(bgtoplot.index))))
# ax.text(0.7, 0.85, counttext, transform=ax.transAxes)
# fig.savefig('plots/mass_{}{}.png'.format(figname, condition))
# plt.clf()





########

# SI: UNCOMMENT BELOW WHEN FINISH WITH THE BDTSCORE PLOTS

#######
# ## make and fill plots for how many events we have for each training parameters
# dataSig = data.loc[data.target == 1]
# dataBg = data.loc[data.target == 0]


# for colName in colNames: 
for colName in trainVars:
    hist_params = {'density': True, 'histtype': 'bar', 'fill': True , 'lw':3, 'alpha' : 0.4}
    nbins = 40
    min_valueS, max_valueS = np.percentile(dataSig[colName], [0, 99.8])        
    min_valueB, max_valueB = np.percentile(dataBg[colName], [0, 99.8])
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
    if not os.path.exists('{}distributions/'.format(folderName)):
        os.makedirs('{}distributions/'.format(folderName))
    plt.savefig("{}distributions/plot_{}.png".format(folderName, colName))
    plt.clf()


## save model to pickle
pklpath="XGB_classifier_"+str(len(trainVars))+"Var"
if options.doXML==True :
    pickle.dump(cls, open(pklpath+".pkl", 'wb'))
    file = open(pklpath+"pkl.log","w")
    file.write(str(trainVars)+"\n")
    file.close()

## save the data to a pickle for ABCD methods
# pickle.dump(trainData, open('{}trainData.pkl'.format(folderName), 'wb'))
# pickle.dump(testData, open('{}testData.pkl'.format(folderName), 'wb'))

    


