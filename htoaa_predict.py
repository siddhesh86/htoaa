import pickle
import numpy as np
import pandas as pd
from analib import PhysObj, Event
from info import trainVars, allVars, cutVars, cutDict, weightDict
from data_manager import processData
import collections
import matplotlib.pyplot as plt


print('neural network')

## prepare testdata for prediction 
fileName = 'GGH_HPT'
data = processData(fileName) 

## drop all columns and rows that all nan, then fill nan->0
data = data.dropna(axis = 1, how = 'all') 
data = data.dropna(how = 'all')
data = data.fillna(0)



## load model from file
loaded_model = pickle.load(open('XGB_classifier_8Var.pkl', 'rb'))

## make predictions for test data
prediction = loaded_model.predict(data.iloc[:,:-2])
count = collections.Counter(prediction)

## am i also making plots of how many signal and background we found 
## for each region of bin? 
## what is my bin even??????? 
## uh this feels wrong. 
hist = plt.hist(prediction, 2)