import datetime

import xlrd
import numpy as np
import pandas as pd


class Traffic(object):
    def __init__(self, data=None, date_column=None, class_column=None, id_column=None,
                 den_column='DEN', denem_column='DENEM'):
        """

        :param pd.DataFrame data: traffic data
        """

        self.data = data
        self.date_column = date_column
        self.class_column = class_column
        self.id_column = id_column
        self.den_column = den_column
        self.denem_column = denem_column

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

        # Parse the file
        data = pd.read_csv(path, sep=',', index_col=None)

        # Convert the dates
        data['C_actual'] = pd.to_datetime(data['C_actual'], format='%Y-%m-%d %H:%M:%S')

        return cls(data, date_column='C_actual', class_column='C_Klasse', id_column='C_id')

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

        # Create a datetime column
        data_frame['timestamp'] = pd.to_datetime(data_frame['Datum'] + data_frame['Tijd (LT)'], unit='D',
                                                 origin=pd.Timestamp(1900, 1, 1))

        # Return the traffic object
        return cls(data_frame, date_column='timestamp', class_column='Klasse', id_column='FlightId')

    def add_season(self, date_column=None):
        # Select the date column to use
        date_column = date_column if date_column is not None else self.date_column

        # Get the years
        years = self.data[date_column].dt.year.unique()

        # Put the season by default on winter
        self.data['season'] = 'winter'

        # Check for each year if the season should be summer
        for year in years:
            # Get the start dates for the two seasons and check which dates match the summer season
            after_start_summer = self.data[date_column] >= start_summer_season(year)
            before_start_winter = self.data[date_column] < start_winter_season(year)

            # Update the season for the matches
            self.data.at[np.logical_and(after_start_summer, before_start_winter), 'season'] = 'summer'

    def add_takeoff_landing(self, class_column=None):
        # Select the class column to use
        class_column = class_column if class_column is not None else self.class_column

        # Add a departure/arrival column
        self.data['TL'] = None

        # Make sure the the class column is a string
        self.data.at[self.data[class_column] >= 0, 'TL'] = 'T'
        self.data.at[self.data[class_column] >= 1000, 'TL'] = 'L'

    def add_denem(self, date_column=None):

        # Select the date column to use
        date_column = date_column if date_column is not None else self.date_column

        # Add a phase column
        self.data[self.denem_column] = None

        # Check for early morning (EM)
        em = self.data[date_column].dt.hour == 6
        self.data.at[em, self.denem_column] = 'EM'

        # Check for day (D)
        d = np.logical_and(self.data[date_column].dt.hour >= 7, self.data[date_column].dt.hour < 19)
        self.data.at[d, self.denem_column] = 'D'

        # Check for evening (E)
        e = np.logical_and(self.data[date_column].dt.hour >= 19, self.data[date_column].dt.hour < 23)
        self.data.at[e, self.denem_column] = 'E'

        # Check for night (N)
        n = np.logical_or(self.data[date_column].dt.hour >= 23, self.data[date_column].dt.hour < 6)
        self.data.at[n, self.denem_column] = 'N'

    def add_den(self, date_column=None):

        # Select the date column to use
        date_column = date_column if date_column is not None else self.date_column

        # Add a phase column
        self.data[self.den_column] = None

        # Check for day (D)
        d = np.logical_and(self.data[date_column].dt.hour >= 7, self.data[date_column].dt.hour < 19)
        self.data.at[d, self.den_column] = 'D'

        # Check for evening (E)
        e = np.logical_and(self.data[date_column].dt.hour >= 19, self.data[date_column].dt.hour < 23)
        self.data.at[e, self.den_column] = 'E'

        # Check for night (N)
        n = np.logical_or(self.data[date_column].dt.hour >= 23, self.data[date_column].dt.hour < 7)
        self.data.at[n, self.den_column] = 'N'

    def get_den_distribution(self, separate_by=None, id_column=None):

        # Select the date column to use
        id_column = id_column if id_column is not None else self.id_column

        if separate_by is None:
            return self.data.groupby([self.den_column])[id_column].count()

        # Get the distribution
        distribution = self.data.groupby([separate_by, self.den_column])[id_column].count().reset_index(drop=False)

        # Reshape the distribution
        distribution = distribution.set_index([self.den_column]).pivot(columns=separate_by).xs(id_column, axis=1,
                                                                                               level=0)

        return distribution

    def get_denem_distribution(self, id_column=None):

        # Select the date column to use
        id_column = id_column if id_column is not None else self.id_column

        # Get the distribution
        distribution = self.data.groupby(['TL', self.denem_column])[id_column].count().reset_index(drop=False)

        # Reshape the distribution
        distribution = distribution.set_index([self.denem_column]).pivot(columns='TL').xs(id_column, axis=1, level=0)

        return distribution

    def get_season_distribution(self, id_column=None):

        # Select the date column to use
        id_column = id_column if id_column is not None else self.id_column

        # Get the distribution
        distribution = self.data.groupby(['season', 'TL', self.denem_column])[id_column].count().reset_index(drop=False)

        # Reshape the distribution
        distribution = distribution.set_index(['season', 'TL']).pivot(columns=self.denem_column).xs(id_column, axis=1,
                                                                                                    level=0)

        # Return the sorted distribution
        return distribution[['D', 'E', 'N', 'EM']]


class TrafficAggregate(object):
    def __init__(self, data, aggregate_type=None):
        self.data = data
        self.type = aggregate_type

    def get_runway_usage(self, period):
        """
        Aggregate the runway usage for the given period of the day and calculate the mean, median, minimum, maximum and
        standard deviation.

        :param str period: a regular expression for the period, e.g. 'D' or 'D|E|N'
        :rtype: pd.DataFrame
        """

        if not self.type == 'daisy.meteoyear':
            raise TypeError(
                'This method is only supported for traffic aggregates of type daisy.meteoyear, but {} is given'.format(
                    self.type))

        # Match the period
        data = self.data[self.data['d_den'].str.match(period)]

        # Count the number of meteoyears in the dat
        years = data['d_myear'].unique()

        # Create a list for all statistics
        statistics = []

        # Aggregate for each type of operation, runway combination and meteoyear
        for key, data_aggregate in data.groupby(['d_lt', 'd_runway']):
            # Make sure that each meteoyear is present
            x = pd.DataFrame({'d_myear': years, 'total': np.zeros(years.shape[0], dtype=int)})

            # By adding all meteoyears to the data aggregate
            y = data_aggregate.append(x)

            # Calculate the totals for each meteoyear
            z = y.groupby(['d_myear'])['total'].sum()

            # Extract the statistics
            statistics += [{
                'lt': key[0],
                'runway': key[1],
                'mean': z.mean(),
                'median': z.median(),
                'std': z.std(),
                'max': z.max(),
                'min': z.min(),
            }]

        return pd.DataFrame(statistics)

    def get_den_distribution(self, separate_by=None):

        if separate_by is None:
            return self.data.groupby(['d_den'])['total'].sum()

        # Get the distribution
        distribution = self.data.groupby([separate_by, 'd_den'])['total'].sum().reset_index(drop=False)

        # Reshape the distribution
        distribution = distribution.set_index(['d_den']).pivot(columns=separate_by).xs('total', axis=1, level=0)

        return distribution


def start_summer_season(year):
    """
    Determine the start of the summer season, which is the last Sunday of the month March.

    :param int year: the calendar year of the season
    :return the start date of the summer season
    :rtype pd.Timestamp
    """

    # Get the last day of March
    last_day = pd.Timestamp(year=year, month=3, day=31)

    # Return the last Sunday of March
    return last_day - pd.Timedelta((last_day.weekday() + 1) % 7, unit='day')


def start_winter_season(year):
    """
    Determine the start of the summer season, which is the last Sunday of the month October.

    :param int year: the calendar year of the season
    :return the start date of the summer season
    :rtype datetime.date
    """

    # Get the last day of October
    last_day = pd.Timestamp(year=year, month=10, day=31)

    # Return the last Sunday of March
    return last_day - pd.Timedelta((last_day.weekday() + 1) % 7, unit='day')


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
