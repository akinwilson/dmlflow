import os, sys 
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
