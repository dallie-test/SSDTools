import os

from gptools.traffic import Traffic


def test_traffic_from_daisy_file_type_1_winter_season():
    # Get the path to the Daisy file
    file_path = abs_path('data/traffic Winterseizoen.txt')

    # Create a traffic object from the data file
    traffic = Traffic.from_daisy_file_type_1(file_path)

    pass


def test_traffic_from_daisy_file_type_2_summer_season():
    # Get the path to the Daisy file
    file_path = abs_path('data/traffic Zomerseizoen.txt')

    # Create a traffic object from the data file
    traffic = Traffic.from_daisy_file_type_2(file_path)

    pass


def test_traffic_from_daisy_file_type_3_meteo_years_runways():
    # Get the path to the Daisy file
    file_path = abs_path('data/traffic 1971-2016 - years.txt')

    # Create a traffic object from the data file
    traffic = Traffic.from_daisy_file_type_3(file_path)

    pass


def test_traffic_from_daisy_file_type_4_runway_combinations():
    # Get the path to the Daisy file
    file_path = abs_path('data/traffic 1971-2016 - pref.txt')

    # Create a traffic object from the data file
    traffic = Traffic.from_daisy_file_type_4(file_path)

    pass


def test_traffic_from_daisy_file_type_5_mean():
    # Get the path to the Daisy file
    file_path = abs_path('data/traffic 1971-2016 - mean.txt')

    # Create a traffic object from the data file
    traffic = Traffic.from_daisy_file_type_5(file_path)

    pass


def test_traffic_from_casper_file():
    # Get the path to the Casper file
    file_path = abs_path('data/Vluchten Export 2017-11-01 00_00_00 - 2018-11-01 00_00_00_2019-01-29 10_59_35.csv')

    # Create a traffic object from the data file
    traffic = Traffic.from_casper_file(file_path)

    pass


def test_traffic_from_nlr_file():
    # Get the path to the NLR file
    file_path = abs_path('data/20181107_Traffic_2018.xlsx')

    # Create a traffic object from the data file
    traffic = Traffic.from_nlr_file(file_path)

    pass


def abs_path(rel_path):
    return os.path.join(os.path.dirname(__file__), rel_path)
