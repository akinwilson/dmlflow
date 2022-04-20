import os, sys
from random import random 
import warnings 

from argparse import ArgumentParser

import pandas as pd 
import numpy as np 
import pickle 


from sklearn.metrics import mean_squared_error, mean_absolute_error, r2_score 
from sklearn.model_selection import train_test_split 
from sklearn.linear_model import ElasticNet 

import mlflow
import mlflow.sklearn 


def eval_metrics(y,y_hat):
    '''metrics for evaluation'''
    rmse = np.sqrt(mean_squared_error(y,y_hat))
    mae = mean_absolute_error(y,y_hat)
    r2 = r2_score(y, y_hat) 
    return rmse, mae, r2

def load_data():
    return pickle.load(open("data.p", "rb"))


if __name__ == "__main__":
    # setting seed for reproducibility 

    print("imports okay")
    
    parser = ArgumentParser()
    parser.add_argument("--alpha")
    parser.add_argument("--l1_ratio")

    args = parser.parse_args()
    
    data = load_data()

    train, test = train_test_split(data)

    # features 
    train_x = train.drop(["quality"], axis=1)
    test_x = test.drop(["quality"], axis=1)

    # targets 
    train_y = train[["quality"]]
    test_y = test[["quality"]]

    # parameters 
    alpha = float(args.alpha)
    l1_ratio = float(args.l1_ratio)


    with mlflow.start_run():
        lr = ElasticNet(alpha=alpha, l1_ratio=l1_ratio, random_seed=42)
        lr.fit(train_x,train_y)

        y_hat = lr.predict(test_x)
