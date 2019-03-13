import numpy as np
import pandas as pd
from gptools.traffic import Traffic


def test_traffic_from_daisy_file_type_1():
    # Create dummy data
    df = pd.DataFrame(np.ones(6))

    # Write dummy data to file
    df.to_csv('data/df.csv')

    # Create a traffic object from the dummy data file
    traffic = Traffic.from_daisy_file_type_1('data/df.csv')

    # Check if the content is correct
    np.testing.assert_equal(df.values, traffic.data.values)
