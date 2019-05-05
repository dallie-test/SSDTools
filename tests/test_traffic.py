import os
import numpy as np
import pandas as pd
from ssdtools.traffic import Traffic


def test_read_daisy_phase_file():
    # Get the path to the Daisy file
    file_path = abs_path('data/traffic Winterseizoen.txt')

    # Create a traffic object from the data file
    aggregate = Traffic.read_daisy_phase_file(file_path)

    assert aggregate.type == 'daisy.phase'

    # Get the DEN distribution for takeoff and landing rounded by 100
    distribution = aggregate.get_den_distribution(separate_by='d_lt').round(decimals=-2)

    # Since no runway data is present in this aggregate, the following method should fail
    try:
        aggregate.get_runway_usage('D')
        assert False
    except TypeError:
        assert True

    # Since no runway data is present in this aggregate, the following method should fail
    try:
        aggregate.get_runway_usage_statistics('D')
        assert False
    except TypeError:
        assert True

    # Get the runway combinations
    runway_combinations = pd.read_csv('data/Baancombinaties.txt', delim_whitespace=1)

    # Since no runway data is present in this aggregate, the following method should fail
    try:
        aggregate.get_n_runway_preference_usage(runway_combinations)
        assert False
    except KeyError:
        assert True

    # Since no runway data is present in this aggregate, the following method should fail
    try:
        aggregate.get_deem_runway_preference_usage(runway_combinations)
        assert False
    except KeyError:
        assert True

    # Since no runway data is present in this aggregate, the following method should fail
    bracket = aggregate.get_bracket()


def test_read_daisy_phase_file_summer_season():
    # Get the path to the Daisy file
    file_path = abs_path('data/traffic Zomerseizoen.txt')

    # Create a traffic object from the data file
    aggregate = Traffic.read_daisy_phase_file(file_path)

    assert aggregate.type == 'daisy.phase'

    # Get the DEN distribution for takeoff and landing rounded by 100
    distribution = aggregate.get_den_distribution(separate_by='d_lt')


def test_read_daisy_meteoyear_file():
    # Get the path to the Daisy file
    file_path = abs_path('data/traffic 1971-2016 - years.txt')

    # Create a traffic object from the data file
    aggregate = Traffic.read_daisy_meteoyear_file(file_path)

    assert aggregate.type == 'daisy.meteoyear'

    # Get the runway usage statistics
    runway_usage = aggregate.get_runway_usage_statistics('D|E|N')

    # Check if the expected shape is returned
    assert runway_usage.shape == (20, 8)

    # Check if the expected columns are returned
    assert runway_usage.columns.tolist() == [
        'count',
        'mean',
        'std',
        'min',
        '25%',
        '50%',
        '75%',
        'max',
    ]

    # Get the DEN distribution for each meteo year
    distribution = aggregate.get_den_distribution(separate_by='d_myear')

    # Check if the totals are equal
    assert distribution.sum().sum() == aggregate.data['total'].sum()

    # In this case the day (D) and evening (E) counts are all equal
    assert distribution.loc['D', :].min() == distribution.loc['D', :].max()
    assert distribution.loc['E', :].min() == distribution.loc['E', :].max()

    # The night distribution varies from 31677 to 31688
    assert distribution.loc['N', :].min() == 31677
    assert distribution.loc['N', :].max() == 31688

    # Test if runway usage can be obtained
    assert aggregate.get_runway_usage('D').shape == (2, 12)

    # Get the runway combinations
    runway_combinations = pd.read_csv('data/Baancombinaties.txt', delim_whitespace=1)

    # Since no runway data is present in this aggregate, the following method should fail
    try:
        aggregate.get_n_runway_preference_usage(runway_combinations)
        assert False
    except KeyError:
        assert True

    # Since no runway data is present in this aggregate, the following method should fail
    try:
        aggregate.get_deem_runway_preference_usage(runway_combinations)
        assert False
    except KeyError:
        assert True

    # Since no runway data is present in this aggregate, the following method should fail
    try:
        aggregate.get_bracket()
        assert False
    except TypeError:
        assert True


def test_read_daisy_runway_combination_file():
    # Get the path to the Daisy file
    file_path = abs_path('data/traffic 1971-2016 - pref.txt')

    # Create a traffic object from the data file
    aggregate = Traffic.read_daisy_runway_combination_file(file_path)

    assert aggregate.type == 'daisy.runway_combination'

    # Get the DEN distribution rounded by 100
    distribution = aggregate.get_den_distribution().round(decimals=-2)

    # Since no runway data is present in this aggregate, the following method should fail
    try:
        aggregate.get_runway_usage('D')
        assert False
    except TypeError:
        assert True

    # Since no runway data is present in this aggregate, the following method should fail
    try:
        aggregate.get_runway_usage_statistics('D')
        assert False
    except TypeError:
        assert True

    # Get the runway combinations
    runway_combinations = pd.read_csv('data/Baancombinaties.txt', delim_whitespace=1)

    # Since runway data is present, it should be possible to calculate the runway preferences
    rp_night = aggregate.get_n_runway_preference_usage(runway_combinations)
    rp_deem = aggregate.get_deem_runway_preference_usage(runway_combinations)

    # Since no runway data is present in this aggregate, the following method should fail
    try:
        aggregate.get_bracket()
        assert False
    except TypeError:
        assert True


def test_read_daisy_mean_file():
    # Get the path to the Daisy file
    file_path = abs_path('data/traffic 1971-2016 - mean.txt')

    # Create a traffic object from the data file
    aggregate = Traffic.read_daisy_mean_file(file_path)

    assert aggregate.type == 'daisy.mean'

    # Get the DEN distribution for takeoff and landing rounded by 100
    distribution = aggregate.get_den_distribution(separate_by='d_lt').round(decimals=-2)

    # For this type of aggregate, runway usage should be possible to calculate
    assert aggregate.get_runway_usage('D').shape == (2, 12)

    # Since no runway data is present in this aggregate, the following method should fail
    try:
        aggregate.get_runway_usage_statistics('D')
        assert False
    except TypeError:
        assert True

    # Get the runway combinations
    runway_combinations = pd.read_csv('data/Baancombinaties.txt', delim_whitespace=1)

    # Since no runway data is present in this aggregate, the following method should fail
    try:
        aggregate.get_n_runway_preference_usage(runway_combinations)
        assert False
    except KeyError:
        assert True

    # Since no runway data is present in this aggregate, the following method should fail
    try:
        aggregate.get_deem_runway_preference_usage(runway_combinations)
        assert False
    except KeyError:
        assert True

    # Since no runway data is present in this aggregate, the following method should fail
    try:
        aggregate.get_bracket()
        assert False
    except TypeError:
        assert True


def test_read_daisy_weekday_file():
    # Get the path to the Daisy file
    file_path = abs_path('data/traffic-Daisy.txt')

    # Create a traffic object from the data file
    aggregate = Traffic.read_daisy_weekday_file(file_path)

    assert aggregate.type == 'daisy.weekday'

    # Get the DEN distribution for takeoff and landing rounded by 100
    distribution = aggregate.get_den_distribution(separate_by='d_lt').round(decimals=-2)

    # Since no runway data is present in this aggregate, the following method should fail
    try:
        aggregate.get_runway_usage('D')
        assert False
    except TypeError:
        assert True

    # Since no runway data is present in this aggregate, the following method should fail
    try:
        aggregate.get_runway_usage_statistics('D')
        assert False
    except TypeError:
        assert True

    # Get the runway combinations
    runway_combinations = pd.read_csv('data/Baancombinaties.txt', delim_whitespace=1)

    # Since no runway data is present in this aggregate, the following method should fail
    try:
        aggregate.get_n_runway_preference_usage(runway_combinations)
        assert False
    except KeyError:
        assert True

    # Since no runway data is present in this aggregate, the following method should fail
    try:
        aggregate.get_deem_runway_preference_usage(runway_combinations)
        assert False
    except KeyError:
        assert True

    # Since no runway data is present in this aggregate, the following method should fail
    bracket = aggregate.get_bracket()


def test_read_taf_file():
    # Get the path to the TAF file
    file_path = abs_path('data/traffic.csv')

    # Set the read_csv arguments for this file
    file_kwargs = {
        'usecols': [0, 1, 2],
        'parse_dates': [1],
        'names': ['d_lt', 'd_schedule', 'd_date'],
        'skiprows': 1,
        'delimiter': ','
    }

    # Create a traffic object from the data file
    aggregate = Traffic.read_taf_file(file_path, **file_kwargs)

    assert aggregate.type == 'taf.sir'

    # Get the DEN distribution for takeoff and landing rounded by 100
    try:
        distribution = aggregate.get_den_distribution(separate_by='d_lt').round(decimals=-2)
        assert False
    except KeyError:
        assert True

    # Since no runway data is present in this aggregate, the following method should fail
    try:
        aggregate.get_runway_usage('D')
        assert False
    except TypeError:
        assert True

    # Since no runway data is present in this aggregate, the following method should fail
    try:
        aggregate.get_runway_usage_statistics('D')
        assert False
    except TypeError:
        assert True

    # Get the runway combinations
    runway_combinations = pd.read_csv('data/Baancombinaties.txt', delim_whitespace=1)

    # Since no runway data is present in this aggregate, the following method should fail
    try:
        aggregate.get_n_runway_preference_usage(runway_combinations)
        assert False
    except KeyError:
        assert True

    # Since no runway data is present in this aggregate, the following method should fail
    try:
        aggregate.get_deem_runway_preference_usage(runway_combinations)
        assert False
    except KeyError:
        assert True

    # Since no runway data is present in this aggregate, the following method should fail
    bracket = aggregate.get_bracket()


def test_traffic_from_casper_file():
    # Get the path to the Casper file
    file_path = abs_path('data/Vluchten Export 2017-11-01 00_00_00 - 2018-11-01 00_00_00_2019-01-29 10_59_35.csv')

    # Create a traffic object from the data file
    traffic = Traffic.read_casper_file(file_path)

    # Add day (D), evening (E), night (N)
    traffic.add_den()

    # Add landing (L) or takeoff (T)
    traffic.add_landing_takeoff()

    # Add procedure
    traffic.add_procedure()

    # Get the DEN distribution rounded by 25
    distribution = (25 * (traffic.get_den_distribution() / 25).round()).astype(int)

    # Get the procedure distribution
    arrivals, departures = traffic.get_procedure_distribution()

    # Normalized percentage arrivals per altitude procedure
    arrivals_normalized = (100 * arrivals / arrivals.sum()).round(1)

    # Normalized percentage departures per procedure
    departures_normalized = (100 * departures / departures.sum()).round(1)


def test_traffic_from_nlr_file():
    # Get the path to the NLR file
    file_path = abs_path('data/20181107_Traffic_2018.xlsx')

    # Create a traffic object from the data file
    traffic = Traffic.read_nlr_file(file_path)

    # Add day (D), evening (E), night (N)
    traffic.add_den()

    # Add landing (L) or takeoff (T)
    traffic.add_landing_takeoff()

    # Add procedure
    traffic.add_procedure()

    # Get the DEN distribution rounded by 5
    distribution = (5 * (traffic.get_den_distribution() / 5).round()).astype(int)

    # Get the procedure distribution
    arrivals, departures = traffic.get_procedure_distribution()

    # Normalized percentage arrivals per altitude procedure
    arrivals_normalized = (100 * arrivals / arrivals.sum()).round(1)

    # Normalized percentage departures per procedure
    departures_normalized = (100 * departures / departures.sum()).round(1)


def test_traffic_add_season():
    # Get the path to the Casper file
    file_path = abs_path('data/Vluchten Export 2017-11-01 00_00_00 - 2018-11-01 00_00_00_2019-01-29 10_59_35.csv')

    # Create a traffic object from the data file
    traffic = Traffic.read_casper_file(file_path)

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
    traffic = Traffic.read_casper_file(file_path)

    # Add the seasons to the data
    traffic.add_season()

    # Add the departure/arrival to the data
    traffic.add_landing_takeoff()

    # Add the day (D), evening (E), night (N), and early morning (EM) to the data
    traffic.add_denem()

    # Get the day (D), evening (E), night (N), and early morning (EM) distribution for landing (L) and takeoff (T)
    distribution = traffic.get_denem_distribution(separate_by='LT')

    # Check if it has the requested shape
    assert distribution.shape == (4, 2)


def test_read_daisy_runway_combination_file_get_preference():
    # Get the path to the Daisy file
    file_path = abs_path('data/traffic 1971-2016 - pref.txt')

    # Create a traffic object from the data file
    aggregate = Traffic.read_daisy_runway_combination_file(file_path)

    # Get the runway combinations
    runway_combinations = pd.read_csv('data/Baancombinaties.txt', delim_whitespace=1)

    # Get the night (N) runway preference
    night_preference = aggregate.get_n_runway_preference_usage(runway_combinations)

    # Get the day (D), evening (E) and early morning (EM) runway preference
    deem_preference = aggregate.get_deem_runway_preference_usage(runway_combinations)

    # Test if the (relative) usage of the night preference is consistent
    assert night_preference.index.tolist() == ['1', '2', '3', '4', 'subtotal', 'other', 'total']
    np.testing.assert_almost_equal(night_preference.loc[['1', '2', '3', '4'], 'usage'].sum(),
                                   night_preference.loc['subtotal', 'usage'], 2)
    np.testing.assert_almost_equal(night_preference.loc[['subtotal', 'other'], 'usage'].sum(),
                                   night_preference.loc['total', 'usage'], 2)
    np.testing.assert_almost_equal(night_preference.loc[['1', '2', '3', '4'], 'relative usage'].sum(),
                                   night_preference.loc['subtotal', 'relative usage'], 2)
    np.testing.assert_almost_equal(night_preference.loc[['subtotal', 'other'], 'relative usage'].sum(),
                                   night_preference.loc['total', 'relative usage'], 2)
    np.testing.assert_almost_equal(night_preference.loc['total', 'relative usage'], 100, 2)

    # Test if the (relative) usage of the day, evening and early morning preference is consistent
    assert deem_preference.index.tolist() == ['1', '2', '3', '4', '5', '6', 'subtotal', 'other', 'total']
    np.testing.assert_almost_equal(deem_preference.loc[['1', '2', '3', '4', '5', '6'], 'usage'].sum(),
                                   deem_preference.loc['subtotal', 'usage'], 2)
    np.testing.assert_almost_equal(deem_preference.loc[['subtotal', 'other'], 'usage'].sum(),
                                   deem_preference.loc['total', 'usage'], 2)
    np.testing.assert_almost_equal(deem_preference.loc[['1', '2', '3', '4', '5', '6'], 'relative usage'].sum(),
                                   deem_preference.loc['subtotal', 'relative usage'], 2)
    np.testing.assert_almost_equal(deem_preference.loc[['subtotal', 'other'], 'relative usage'].sum(),
                                   deem_preference.loc['total', 'relative usage'], 2)
    np.testing.assert_almost_equal(deem_preference.loc['total', 'relative usage'], 100, 2)


def abs_path(rel_path):
    return os.path.join(os.path.dirname(__file__), rel_path)
