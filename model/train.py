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

from mlflow.models.signature import infer_signature
import mlflow
import mlflow.sklearn 


def eval_metrics(y,y_hat):
    '''metrics for evaluation'''
    rmse = np.sqrt(mean_squared_error(y,y_hat))
    mae = mean_absolute_error(y,y_hat)
    r2 = r2_score(y, y_hat) 
    return rmse, mae, r2

def load_data():
    '''load the pickled dataset'''
    return pickle.load(open("data.p", "rb"))

def get_model_signature(x, y_hat):
    '''inputs are expected to be a dataframe and the prediction of the model'''
    return infer_signature(x, y_hat)


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

        rmse, mae, r2 = eval_metrics(test_y, y_hat)
        
        print(f"ElasticNet regressor model (alpha={alpha}, l1_ratio={l1_ratio})")
        print(f"RMSE: {rmse}")
        print(f"MAE: {mae}")
        print(f"R2: {r2}")
        # model parameters logging 
        mlflow.log_params("alpha", alpha)
        mlflow.log_params("l1_ratio", l1_ratio)
        # evaluation metric logging 
        mlflow.log_metric("rmse",rmse)
        mlflow.log_metric("mae",mae)
        mlflow.log_metric("r2",r2)
        # get the model signature 
        model_sig = get_model_signature(test_x, y_hat)
        # load the model
        mlflow.sklearn.log_model(sk_model=lr,
                                artifact_path="model",
                                registered_model_name="ElasticNetRegressor",
                                signature=model_sig,
                                input_example=test_x.head(1))