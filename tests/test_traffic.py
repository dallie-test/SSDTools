import os

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


def test_traffic_from_daisy_file_type_1_winter_season():
    # Get the path to the Daisy file
    file_path = abs_path('tests/data/traffic Winterseizoen.txt')


def test_traffic_from_daisy_file_type_2_summer_season():
    # Get the path to the Daisy file
    file_path = abs_path('tests/data/traffic Zomerseizoen.txt')


def test_traffic_from_daisy_file_type_3_meteo_years_runways():
    # Get the path to the Daisy file
    file_path = abs_path('tests/data/traffic 1971-2016 - years.txt')


def test_traffic_from_daisy_file_type_4_runway_combinations():
    # Get the path to the Daisy file
    file_path = abs_path('tests/data/traffic 1971-2016 - pref.txt')


def test_traffic_from_daisy_file_type_5_mean():
    # Get the path to the Daisy file
    file_path = abs_path('tests/data/traffic 1971-2016 - mean.txt')


def test_traffic_from_casper_file():
    # Get the path to the Casper file
    file_path = abs_path('tests/data/Vluchten Export 2017-11-01 00_00_00 - 2018-11-01 00_00_00_2019-01-29 10_59_35.csv')


def test_traffic_from_nlr_file():
    # Get the path to the NLR file
    file_path = abs_path('tests/data/20181107_Traffic_2018.xlsx')


def abs_path(rel_path):
    return os.path.join(os.path.dirname(__file__), rel_path)
