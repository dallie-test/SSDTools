import os

from gptools.traffic import Traffic


def test_read_daisy_phase_file():
    # Get the path to the Daisy file
    file_path = abs_path('data/traffic Winterseizoen.txt')

    # Create a traffic object from the data file
    aggregate = Traffic.read_daisy_phase_file(file_path)

    # Get the DEN distribution for takeoff and landing rounded by 100
    distribution = aggregate.get_den_distribution(separate_by='d_lt').round(decimals=-2)

    pass


def test_read_daisy_phase_file_summer_season():
    # Get the path to the Daisy file
    file_path = abs_path('data/traffic Zomerseizoen.txt')

    # Create a traffic object from the data file
    aggregate = Traffic.read_daisy_phase_file(file_path)

    # Get the DEN distribution for takeoff and landing rounded by 100
    distribution = aggregate.get_den_distribution(separate_by='d_lt')

    pass


def test_read_daisy_meteoyear_file():
    # Get the path to the Daisy file
    file_path = abs_path('data/traffic 1971-2016 - years.txt')

    # Create a traffic object from the data file
    aggregate = Traffic.read_daisy_meteoyear_file(file_path)

    # Get the runway usage statistics
    runway_usage = aggregate.get_runway_usage('D|E|N')

    assert runway_usage.shape == (20, 7)

    assert runway_usage.columns.tolist() == [
        'lt',
        'max',
        'mean',
        'median',
        'min',
        'runway',
        'std',
    ]

    # todo: Add a test with data from Matlab

    # Get the DEN distribution for each meteo year
    distribution = aggregate.get_den_distribution(separate_by='d_myear')

    pass


def test_read_daisy_runway_combination_file():
    # Get the path to the Daisy file
    file_path = abs_path('data/traffic 1971-2016 - pref.txt')

    # Create a traffic object from the data file
    aggregate = Traffic.read_daisy_runway_combination_file(file_path)

    # Get the DEN distribution rounded by 100
    distribution = aggregate.get_den_distribution().round(decimals=-2)

    pass


def test_read_daisy_mean_file():
    # Get the path to the Daisy file
    file_path = abs_path('data/traffic 1971-2016 - mean.txt')

    # Create a traffic object from the data file
    aggregate = Traffic.read_daisy_mean_file(file_path)

    # Get the DEN distribution for takeoff and landing rounded by 100
    distribution = aggregate.get_den_distribution(separate_by='d_lt').round(decimals=-2)

    pass


def test_traffic_from_casper_file():
    # Get the path to the Casper file
    file_path = abs_path('data/Vluchten Export 2017-11-01 00_00_00 - 2018-11-01 00_00_00_2019-01-29 10_59_35.csv')

    # Create a traffic object from the data file
    traffic = Traffic.from_casper_file(file_path)

    # Add day (D), evening (E), night (N)
    traffic.add_den()

    # Get the DEN distribution rounded by 25
    distribution = (25 * (traffic.get_den_distribution() / 25).round()).astype(int)

    pass


def test_traffic_from_nlr_file():
    # Get the path to the NLR file
    file_path = abs_path('data/20181107_Traffic_2018.xlsx')

    # Create a traffic object from the data file
    traffic = Traffic.from_nlr_file(file_path)

    # Add day (D), evening (E), night (N)
    traffic.add_den()

    # Get the DEN distribution rounded by 5
    distribution = (5 * (traffic.get_den_distribution() / 5).round()).astype(int)

    pass


def test_traffic_add_season():
    # Get the path to the Casper file
    file_path = abs_path('data/Vluchten Export 2017-11-01 00_00_00 - 2018-11-01 00_00_00_2019-01-29 10_59_35.csv')

    # Create a traffic object from the data file
    traffic = Traffic.from_casper_file(file_path)

    # Add the seasons to the data
    traffic.add_season()

    # Check if the season is present in the traffic data
    assert 'season' in traffic.data

    # Check if it has winter and summer in it
    assert ['summer', 'winter'] == traffic.data['season'].sort_values().unique().tolist()


def test_traffic_get_denem_distribution():
    # Get the path to the Casper file
    file_path = abs_path('data/Vluchten Export 2017-11-01 00_00_00 - 2018-11-01 00_00_00_2019-01-29 10_59_35.csv')

    # Create a traffic object from the data file
    traffic = Traffic.from_casper_file(file_path)

    # Add the seasons to the data
    traffic.add_season()

    # Add the departure/arrival to the data
    traffic.add_takeoff_landing()

    # Add the day (D), evening (E), night (N), and early morning (EM) to the data
    traffic.add_denem()

    # Get the day (D), evening (E), night (N), and early morning (EM) distribution
    distribution = traffic.get_denem_distribution()

    # Check if it has the requested shape
    assert distribution.shape == (4, 2)


def abs_path(rel_path):
    return os.path.join(os.path.dirname(__file__), rel_path)
