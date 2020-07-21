import sys
import uproot
import numpy as np
import math
import matplotlib.pyplot as plt
import pandas as pd
import xgboost as xgb

from analib import Hist, PhysObj, Event, inc

from sklearn.metrics import roc_curve, auc
from sklearn.model_selection import train_test_split

f = uproot.open('GGH_HPT.root')
events = f.get('Events')
trainVars = ['FatJet_pt', 'FatJet_eta', 'FatJet_mass', 'FatJet_btagCSVV2', 'FatJet_btagDeepB', 'FatJet_msoftdrop', 'FatJet_btagDDBvL']
cutVars = ['FatJet_btagDDBvL', 'FatJet_btagDeepB', 'FatJet_mass', 'FatJet_msoftdrop', 'FatJet_pt']
allVars = list(set(trainVars + cutVars))
print(allVars)


'''
  * FatJet_btagDDBvL > 0.8      (This is the CMS double-b-tagger, an MVA which looks for two b-hadron decays in the same AK8 jet)
  * FatJet_btagDeepB > 0.4184   (This is the CMS single b-tagger, an MVA which looks for at least one b-hadron decay in a jet)
  * FatJet_mass      > 90 GeV   (This is the default reconstructed AK8 jet mass)
  * FatJet_msoftdrop > 90 GeV   (This is the mass excluding low-pT or "soft" components of the jet.)
  * FatJet_pt        > 240 GeV  (This is the total pT of the fat jet.)
'''
jetNums = list(range(1,8)) # for naming the columns

## direct pandas.DataFrames
#FatJet_btagDeepB = pd.DataFrame(events.array('FatJet_btagDeepB'))#, columns = ['FatJet_btagDeepB_1', 'FatJet_btagDeepB_2','FatJet_btagDeepB_3','FatJet_btagDeepB_4','FatJet_btagDeepB_5','FatJet_btagDeepB_6','FatJet_btagDeepB_7'])
#print(FatJet_btagDeepB.dropna(how='all'))
#print(FatJet_btagDeepB[FatJet_btagDeepB > 0.8].dropna(how='all'))


## using PhysObj
data = PhysObj("data")
for var in allVars:
    colName = [var + "_" + str(i) for i in jetNums]
    data[var] = pd.DataFrame(events.array(var), columns = colName)
    #data[var] = pd.DataFrame(events.array(var))

## the different tests we did 
# print(data['FatJet_btagDeepB'][data['FatJet_btagDDBvL'] > 0.8])
#print(data['FatJet_btagDeepB'][data.FatJet_btagDDBvL > 0.8].iloc[0])
#print(data['FatJet_btagDeepB'].dropna(how='all')[data.FatJet_btagDDBvL > 0.8])
#print(data.FatJet_btagDDBvL > 0.8)
#print(data['FatJet_btagDeepB'][data.FatJet_btagDDBvL > 0.8])
#rint(data['FatJet_btagDeepB'][data.FatJet_btagDDBvL > 0.8])
#print(data['FatJet_btagDeepB'][data.FatJet_btagDDBvL > 0.8].dropna(how='all'))
#print(data['FatJet_btagDeepB'][data.FatJet_btagDDBvL > 0.8].dropna(how='all').iloc[0])


ev = Event(data)
# data.cut(data.FatJet_btagDDBvL > 0.8 )
# data.cut(data.FatJet_btagDeepB > 0.4184)
# data.cut(data.FatJet_mass > 90)
# data.cut(data.FatJet_msoftdrop > 90)
# data.cut(data.FatJet_pt > 240)
#ev.sync()

#print(data)










#-------------------------------------------------------
## things below here are not related 
#--------------------------------------------------------
# randInt = 1

# trainDataPt, testDataPt = train_test_split(data.FatJet_pt, random_state=randInt)
## so apparently using this, it also shuffles the row column around, but keep the original numbers. this might be useful
## if you set the random state to equal each other, it will have the same split i think
## maybe can generate a random int in the beginning and use that for every split. lmao this is going to be fun
# trainData = dict()
# testData = dict()


# for var in allVars: 
#     trainData[var], testData[var]= train_test_split(data[var], random_state=randInt)
    #trainDataTmp, testDataTmp = train_test_split(data[var], random_state=randInt)
    



# for i in range(len(allVars)):
#     trainDataNd = trainData[allVars[i]].to_numpy()
#     testDataNd = testData[allVars[i]].to_numpy()
    
#     trainDataNd = trainDataNd[np.newaxis, ...]
#     testDataNd = testDataNd[np.newaxis, ...]
#     print(allVars[i])
#     print(trainDataNd.shape)
#     print(testDataNd.shape)

# trainDataNd = trainData[allVars[0]].to_numpy()
# testDataNd = testData[allVars[0]].to_numpy()

# trainDataNd = trainDataNd[np.newaxis, ...]
# testDataNd = testDataNd[np.newaxis, ...]


# for i in range(1,len(allVars)):
#     trainDataTmp = trainData[allVars[i]].to_numpy()
#     testDataTmp = testData[allVars[i]].to_numpy()
#     trainDataTmp = trainDataTmp[np.newaxis, ...]
#     testDataTmp = testDataTmp[np.newaxis, ...]
#     trainDataNd = np.append(trainDataNd, trainDataTmp, axis = 0)
#     testDataNd = np.append(testDataNd, testDataTmp, axis = 0)

# print(trainDataNd.shape)
# print(testDataNd.shape)
# print(trainDataNd.shape[1])

# target = np.random.choice([0, 1], size=trainDataNd.shape[1], p=[.1, .9])

# cls = xgb.XGBClassifier(
#     n_estimators = 800,
#     max_depth = 2, 
#     min_child_weight = 1,
#     learning_rate = 0.01
#     )

# cls.fit(trainDataNd, target)
## BUT THE DOCUMENTATION DIDN'T SAY ANYTHING ABOUT IT NEEDING TO BE 2D!!!!!!


    


#print(trainDataNd)
## we have dicts containing train data and test data for all of this. what to do now









