import datetime

import xlrd
import pandas as pd


class Traffic(object):
    def __init__(self, data=None):
        """

        :param pd.DataFrame data: traffic data
        """

        if data is not None:
            self.data = data

    @classmethod
    def read_daisy_phase_file(cls, path):
        """
        A method to read daisy phase files.
        E.g. summer seasons, winter seasons and maintenance periods.

        :param str path: path to the file.
        :return: daisy phase aggregate of traffic.
        :rtype: TrafficAggregate
        """
        return TrafficAggregate(data=pd.read_csv(path, sep='\t', index_col=None), aggregate_type='daisy.phase')

    @classmethod
    def read_daisy_meteoyear_file(cls, path):
        """
        A method to read daisy meteoyear files.

        :param str path: path to the file.
        :return: daisy meteoyear aggregate of traffic.
        :rtype: TrafficAggregate
        """
        return TrafficAggregate(data=pd.read_csv(path, sep='\t', index_col=None), aggregate_type='daisy.meteoyear')

    @classmethod
    def read_daisy_runway_combination_file(cls, path):
        """
        A method to read daisy runway combination files.

        :param str path: path to the file.
        :return: daisy runway combination aggregate of traffic.
        :rtype: TrafficAggregate
        """

        # Read the file as DataFrame
        data_frame = pd.read_csv(path, sep='\t', index_col=None)

        # todo: Split the runway combination (d_combination)

        # Return the traffic object
        return TrafficAggregate(data=data_frame, aggregate_type='daisy.runway_combination')

    @classmethod
    def read_daisy_mean_file(cls, path):
        """
        A method to read daisy mean files.

        :param str path: path to the file.
        :return: daisy mean aggregate of traffic.
        :rtype: TrafficAggregate
        """

        return TrafficAggregate(data=pd.read_csv(path, sep='\t', index_col=None), aggregate_type='daisy.mean')

    @classmethod
    def from_casper_file(cls, path):
        return cls(pd.read_csv(path, sep=',', index_col=None))

    @classmethod
    def from_nlr_file(cls, path):

        # Open the .xlsx file (this might take a while, but this is the only way to open large .xlsx files...)
        workbook = xlrd.open_workbook(path, on_demand=True)

        # Select the first worksheet
        worksheet = workbook.sheet_by_index(0)

        # Extract the data, column by column, with the first row as the column name
        data = {}
        for col in range(worksheet.ncols):
            data[worksheet.cell_value(0, col)] = worksheet.col_values(col, 1)

        # Put the data in a DataFrame
        data_frame = pd.DataFrame(data)

        # Return the traffic object
        return cls(data_frame)


class TrafficAggregate(object):
    def __init__(self, data, aggregate_type=None):
        self.data = data
        self.type = aggregate_type


def runway_usage(traffic, period):
    """
    Aggregate the runway usage and calculate the mean, median, minimum, maximum and standard deviation

    :param Traffic traffic:
    :param str period: a regular expression for the period, e.g. 'D' or 'D|E|N'
    """

    # todo: Require the following columns d_lt, d_runway, d_period, d_den, d_myear en total


def start_summer_season(year):
    """
    Determine the start of the summer season, which is the last Sunday of the month March.

    :param int year: the calendar year of the season
    :return the start date of the summer season
    :rtype datetime.date
    """

    # Get the last day of March
    last_day = datetime.date(year, 3, 31)

    # Return the last Sunday of March
    return last_day - datetime.timedelta(days=(last_day.weekday() + 1) % 7)


def start_winter_season(year):
    """
    Determine the start of the summer season, which is the last Sunday of the month October.

    :param int year: the calendar year of the season
    :return the start date of the summer season
    :rtype datetime.date
    """

    # Get the last day of October
    last_day = datetime.date(year, 10, 31)

    # Return the last Sunday of March
    return last_day - datetime.timedelta(days=(last_day.weekday() + 1) % 7)


def get_year_of_use(year):
    """
    Determine start- and end date, number of days in the year of use.
    """

    # Create a dictionary for the information
    year_info = {
        'year': year,
        'start_summer': start_summer_season(year),
        'end_summer': start_winter_season(year) + datetime.timedelta(-1),
        'start_winter': start_winter_season(year - 1),
        'end_winter': start_summer_season(year)
    }

    # Number of days, weeks
    year_info['winter_days'] = (year_info['end_winter'] - year_info['start_winter']).days + 1
    year_info['summer_days'] = (year_info['end_summer'] - year_info['end_winter']).days
    year_info['winter_weeks'] = year_info['winter_days'] / 7
    year_info['summer_weeks'] = year_info['summer_days'] / 7

    return year_info
