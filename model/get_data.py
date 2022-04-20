
import pandas as pd 
import logging
import pickle 

logging.basicConfig(level=logging.WARN)
logger = logging.getLogger(__name__)


def save_data():
    # Read the wine-quality csv file from the URL
    csv_url = (
        "http://archive.ics.uci.edu/ml/machine-learning-databases/wine-quality/winequality-red.csv"
    )
    try:
        df = pd.read_csv(csv_url, sep=";")
    except Exception as e:
        logger.exception(
            "Unable to download training & test CSV, check your internet connection. Error: %s", e
        )
    pickle.dump(df, open("data.p", "wb"))



if __name__ == "__main__":
    save_data()