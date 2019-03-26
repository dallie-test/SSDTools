import datetime

import xlrd
import numpy as np
import pandas as pd


class Traffic(object):
    def __init__(self, data=None):
        """

        :param pd.DataFrame data: traffic data
        """

        if data is not None:
            self.data = data

    @classmethod
    def from_daisy_file_type_1(cls, path):
        return cls(pd.read_csv(path, sep='\t', index_col=None))

    @classmethod
    def from_daisy_file_type_2(cls, path):
        return cls(pd.read_csv(path, sep='\t', index_col=None))

    @classmethod
    def from_daisy_file_type_3(cls, path):
        return cls(pd.read_csv(path, sep='\t', index_col=None))

    @classmethod
    def from_daisy_file_type_4(cls, path):
        # Read the file as DataFrame
        data_frame = pd.read_csv(path, sep='\t', index_col=None)

        # todo: Split the runway combination (d_combination)

        # Return the traffic object
        return cls(data_frame)

    @classmethod
    def from_daisy_file_type_5(cls, path):
        return cls(pd.read_csv(path, sep='\t', index_col=None))

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
    Valid between 1900 and 2099.
    source: http://delphiforfun.org/Programs/Math_Topics/DSTCalc.htm

    :param int year: the calendar year of the season
    :return the start date of the summer season
    :rtype datetime.date
    """
    if year > 2099 or year < 1900:
        raise ValueError('This method is only valid for years between 1900 and 2099.')
    return datetime.date(year, 3, 31 - np.round((4 + 5 * year / 4), 0) % 7)


def start_winter_season(year):
    """
    Determine the start of the summer season, which is the last Sunday of the month October.
    Valid between 1900 and 2099.
    source: http://delphiforfun.org/Programs/Math_Topics/DSTCalc.htm

    :param int year: the calendar year of the season
    :return the start date of the summer season
    :rtype datetime.date
    """
    if year > 2099 or year < 1900:
        raise ValueError('This method is only valid for years between 1900 and 2099.')
    return datetime.date(year, 10, 31 - np.round((1 + 5 * year / 4), 0) % 7)


def get_year_of_use(year):
    """
    Determine start- and end date, number of days in the year of use
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
