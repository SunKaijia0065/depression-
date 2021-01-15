#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Jan 11 11:27:18 2021

@author: sunkaijia
"""

import scipy.io as scio 
import numpy as np
from sklearn.metrics import roc_curve, auc
from sklearn.preprocessing import scale
from sklearn.linear_model import LogisticRegressionCV,LogisticRegression
from sklearn.model_selection import ShuffleSplit,cross_val_score
from sklearn.svm import SVC
from sklearn.naive_bayes import GaussianNB

#read the .mat file 
path = '/Users/sunkaijia/data/depreMU/feature/feature.mat'
feature = scio.loadmat(path)


#read the feature, label information from matlab .mat file 
label       = feature['label']
channelLabel= feature['channelLabel']
alphaasym   = feature['feature']['alphaasym'  ][0][0]
alphapower  = feature['feature']['alphapower' ][0][0]
betapower   = feature['feature']['betapower'  ][0][0]
thetaapower = feature['feature']['thetaapower'][0][0]
deltapower  = feature['feature']['deltapower' ][0][0]
label = np.squeeze(label, axis=(1,))



def featureSelection(featureMatrix,label):
    # feature selection by ROC of every feature
    # and get the sub-feature matrix (5,10,15,19)
    #
    featureMatrix=scale(featureMatrix) #standardization the data
    
    def roc_Rank(featureMatrix,label):# sort the feature by ROC
        rocValue=[0]*featureMatrix.shape[1]
        # roc of every feature
        for ichannel in range(0,featureMatrix.shape[1]):
            fpr, tpr, _ = roc_curve(label, featureMatrix[:,ichannel])
            roc_auc = auc(fpr, tpr)
            rocValue[ichannel] = roc_auc
            
        rocValue = abs(np.array(rocValue)-0.5) 
        rocRank = np.argsort(rocValue) #rank of feature
        return rocRank,rocValue
    
    featureRank,featureValue = roc_Rank(featureMatrix,label) #rank of feature
    # Feature selection
    feature5  = featureMatrix[:,featureRank[-5 :]]
    feature10 = featureMatrix[:,featureRank[-10:]]
    feature15 = featureMatrix[:,featureRank[-15:]] 
    
    return feature5,feature10,feature15,featureMatrix,featureValue
    
    

# feature of patient
thetaP5,thetaP10,thetaP15,thetaP,thetaPValue=featureSelection(thetaapower,label)
alphaP5,alphaP10,alphaP15,alphaP,alphaPValue=featureSelection(alphapower ,label)
betaP5 ,betaP10 ,betaP15 ,betaP ,betaPValue =featureSelection(betapower  ,label)
deltaP5,deltaP10,deltaP15,deltaP,deltaPValue=featureSelection(deltapower ,label)

alphaA5,alphaA10,alphaA15,alphaA,alphaAValue=featureSelection(alphaasym  ,label)

# learn model
featureList=[thetaP5,thetaP10,thetaP15,thetaP,alphaP5,alphaP10,alphaP15,alphaP,
             betaP5 ,betaP10 ,betaP15 ,betaP,deltaP5,deltaP10,deltaP15,deltaP ,
             alphaA5,alphaA10,alphaA15,alphaA]
featureName=['theta5','theta10','theta15','theta19',
             'alpha5','alpha10','alpha15','alpha19',
             'beta5','beta10','beta15','beta19',
             'delta5','delta10','delta15','delta19',
             'alphaA5','alphaA10','alphaA15','alphaA19']
featureAcc=[0]*16

#model
Cs=100
cv = ShuffleSplit(n_splits=100, train_size=0.9, test_size=.1,  random_state=0)
logClacv=LogisticRegressionCV(Cs=Cs, penalty='l1',refit=True,cv=cv,
                                      solver='saga',
                                      max_iter=10000)
gnb = GaussianNB()
svmCla=SVC(kernel='linear', C=1,)


# train and result
for name,matrix in zip(featureName,featureList):

    logClacv.fit(matrix,label)
    logACC=logClacv.score(matrix, label)
    
    svmCla=SVC(kernel='linear', C=1)
    svmACC = cross_val_score(svmCla, matrix, label, cv=cv)    
    
    gnb.fit(matrix, label)
    gnbACC = cross_val_score(gnb, matrix, label, cv=cv)
    
    print(name,' |',"%.2f" % (logACC*100),' |',"%.2f" % (np.mean(gnbACC)*100), ' |',"%.2f" % (np.mean(svmACC)*100) )
    

