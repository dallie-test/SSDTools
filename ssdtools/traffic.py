import datetime

import xlrd
import numpy as np
import pandas as pd


class Traffic(object):
    def __init__(self, data=None, date_column=None, class_column=None, id_column=None, den_column='DEN',
                 denem_column='DENEM', procedure_column='procedure', altitude_column='altitude',
                 weight_column='weight'):
        """

        :param pd.DataFrame data: traffic data
        """

        self.data = data
        self.date_column = date_column
        self.class_column = class_column
        self.id_column = id_column
        self.den_column = den_column
        self.denem_column = denem_column
        self.procedure_column = procedure_column
        self.altitude_column = altitude_column
        self.weight_column = weight_column

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
    def read_daisy_weekday_file(cls, path):
        """
        A method to read daisy weekday files.

        :param str path: path to the file.
        :return: daisy weekday aggregate of traffic.
        :rtype: TrafficAggregate
        """

        return TrafficAggregate(data=pd.read_csv(path, sep='\t', index_col=None), aggregate_type='daisy.weekday')

    @classmethod
    def read_taf_file(cls, path, **kwargs):
        """
        A method to read sir TAF files.

        :param str path: path to the file.
        :return: sir TAF aggregate of traffic.
        :rtype: TrafficAggregate
        """

        # Read the csv file
        data = pd.read_csv(path, **kwargs)

        # Replace A (arrival) and D (departure) by L (landing) and T (takeoff)
        data['d_lt'] = data['d_lt'].str.replace(r'^A$', 'L').str.replace(r'^D$', 'T')

        # Return the traffic aggregate
        return TrafficAggregate(data=data, aggregate_type='taf.sir')

    @classmethod
    def read_casper_file(cls, path):

        # Parse the file
        data = pd.read_csv(path, sep=',', index_col=None)

        # Convert the dates
        data['C_actual'] = pd.to_datetime(data['C_actual'], format='%Y-%m-%d %H:%M:%S')

        return cls(data, date_column='C_actual', class_column='C_Klasse', id_column='C_id')

    @classmethod
    def read_nlr_file(cls, path):

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

    def add_landing_takeoff(self, class_column=None):
        # Select the class column to use
        class_column = class_column if class_column is not None else self.class_column

        # Add a departure/arrival column
        self.data['LT'] = None

        # Make sure the the class column is a string
        self.data.at[(self.data[self.class_column] >= 0) & (self.data[self.class_column] < 1000), 'LT'] = 'T'
        self.data.at[(self.data[self.class_column] >= 1000) & (self.data[self.class_column] < 2000), 'LT'] = 'L'

    def add_procedure(self):

        # Add a procedure, altitude and weight column
        self.data[self.procedure_column] = None
        self.data[self.altitude_column] = None
        self.data[self.altitude_column] = None

        # Set procedure to other (takeoff)
        other = (self.data[self.class_column] >= 0) & (self.data[self.class_column] < 100)
        self.data.at[other, self.procedure_column] = 'other'

        # Set procedure to NADP1 (takeoff)
        nadp1 = (self.data[self.class_column] >= 500) & (self.data[self.class_column] < 600)
        self.data.at[nadp1, self.procedure_column] = 'NADP1'

        # Set procedure to NADP2 (takeoff)
        nadp2 = (self.data[self.class_column] >= 600) & (self.data[self.class_column] < 900)
        self.data.at[nadp2, self.procedure_column] = 'NADP2'

        # Set procedure to normal (landing)
        normal = (self.data[self.class_column] >= 1000) & (self.data[self.class_column] < 1100)
        self.data.at[normal, self.procedure_column] = 'normal'

        # Set procedure to reduced flaps (landing)
        reduced_flaps = (self.data[self.class_column] >= 1200) & (self.data[self.class_column] < 1300)
        self.data.at[reduced_flaps, self.procedure_column] = 'reduced_flaps'

        # Set weight to heavy (takeoff)
        heavy = (self.data[self.class_column] >= 0) & (self.data[self.class_column] < 1000) & \
                (self.data[self.class_column].mod(10) == 0)
        self.data.at[heavy, self.weight_column] = 'heavy'

        # Set weight to medium (takeoff)
        medium = (self.data[self.class_column] >= 0) & (self.data[self.class_column] < 1000) & \
                 (self.data[self.class_column].mod(10) >= 1) & (self.data[self.class_column].mod(10) <= 2)
        self.data.at[medium, self.weight_column] = 'medium'

        # Set weight to light (takeoff)
        light = (self.data[self.class_column] >= 0) & (self.data[self.class_column] < 1000) & \
                (self.data[self.class_column].mod(10) == 3)
        self.data.at[light, self.weight_column] = 'light'

        # Set altitude to 2000ft (landing)
        ft2000 = (self.data[self.class_column] >= 1000) & (self.data[self.class_column] < 2000) & \
                 (self.data[self.class_column].mod(10) == 0)
        self.data.at[ft2000, self.altitude_column] = '2000ft'

        # Set altitude to 3000ft (landing)
        ft3000 = (self.data[self.class_column] >= 1000) & (self.data[self.class_column] < 2000) & \
                 (self.data[self.class_column].mod(10) == 1)
        self.data.at[ft3000, self.altitude_column] = '3000ft'

        # Set altitude to CDA (landing)
        cda = (self.data[self.class_column] >= 1000) & (self.data[self.class_column] < 2000) & \
              (self.data[self.class_column].mod(10) == 9)
        self.data.at[cda, self.altitude_column] = 'CDA'

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

    def get_denem_distribution(self, separate_by=None, id_column=None):

        # Select the date column to use
        id_column = id_column if id_column is not None else self.id_column

        if separate_by is None:
            return self.data.groupby([self.denem_column])[id_column].count()

        # Get the distribution
        distribution = self.data.groupby([separate_by, self.denem_column])[id_column].count().reset_index(drop=False)

        # Reshape the distribution
        distribution = distribution.set_index([self.denem_column]).pivot(columns=separate_by).xs(id_column, axis=1,
                                                                                                 level=0)

        return distribution

    def get_season_distribution(self, id_column=None):

        # Select the date column to use
        id_column = id_column if id_column is not None else self.id_column

        # Get the distribution
        distribution = self.data.groupby(['season', 'LT', self.denem_column])[id_column].count().reset_index(drop=False)

        # Reshape the distribution
        distribution = distribution.set_index(['season', 'LT']).pivot(columns=self.denem_column).xs(id_column, axis=1,
                                                                                                    level=0)

        # Return the sorted distribution
        return distribution[['D', 'E', 'N', 'EM']]

    def get_procedure_distribution(self):

        # Get the arrivals
        arrivals = self.data[self.data['LT'] == 'L'].groupby(self.altitude_column)[self.id_column].count()

        # Get the departures
        departures = self.data[self.data['LT'] == 'T'].groupby(self.procedure_column)[self.id_column].count()

        return arrivals, departures


class TrafficAggregate(object):
    def __init__(self, data, aggregate_type=None):
        self.data = data
        self.type = aggregate_type

    def get_runway_usage(self, period):
        """
        Aggregate the runway usage for the given period of the day.

        :param str period: a regular expression for the period, e.g. 'D' or 'D|E|N'
        :rtype: pd.DataFrame
        """

        # Define the supported types
        supported_types = ['daisy.meteoyear', 'daisy.mean']

        # Check if a different type is provided
        if self.type not in supported_types:
            # List the supported types as a string
            supported_types_string = ', '.join(supported_types)

            # Include 'or' after the last comma
            supported_types_string = ', or '.join(supported_types_string.rsplit(', ', 1))

            raise TypeError('This method is only supported for traffic aggregates of type {}, but {} is given'.format(
                supported_types_string, self.type))

        # Match the period
        data = self.data[self.data['d_den'].str.match(period)]

        # Sum the number of flights for each LT-runway combination
        data = data.groupby(['d_lt', 'd_runway'])['total'].sum().reset_index()

        # Return the pivoted dataframe
        return data.pivot('d_lt', 'd_runway', 'total')

    def get_runway_usage_statistics(self, period):
        """
        Aggregate the runway usage for the given period of the day and calculate the various statistics, including mean,
        median, minimum, maximum and standard deviation.

        :param str period: a regular expression for the period, e.g. 'D' or 'D|E|N'
        :rtype: pd.DataFrame
        """

        # Define the supported types
        supported_types = ['daisy.meteoyear']

        # Check if a different type is provided
        if self.type not in supported_types:
            # List the supported types as a string
            supported_types_string = ', '.join(supported_types)

            # Include 'or' after the last comma
            supported_types_string = ', or '.join(supported_types_string.rsplit(', ', 1))

            raise TypeError('This method is only supported for traffic aggregates of type {}, but {} is given'.format(
                supported_types_string, self.type))

        # Match the period
        data = self.data[self.data['d_den'].str.match(period)]

        # Calculate the total runway usage per operation per year
        data = data.groupby(['d_lt', 'd_runway', 'd_myear'])['total'].sum().reset_index()

        # Describe the various yearly scenarios per runway per type of operation
        return data.groupby(['d_lt', 'd_runway'])['total'].describe()

    def get_den_distribution(self, separate_by=None):

        if separate_by is None:
            return self.data.groupby(['d_den'])['total'].sum()

        # Get the distribution
        distribution = self.data.groupby([separate_by, 'd_den'])['total'].sum().reset_index(drop=False)

        # Reshape the distribution
        distribution = distribution.set_index(['d_den']).pivot(columns=separate_by).xs('total', axis=1, level=0)

        return distribution

    def get_n_runway_preference_usage(self, rc_preferences):

        # Get the runway combination usage in the specified period
        rc_usage = self.data[(self.data['d_den'] == 'N') & (self.data['d_schedule'] != 6)]

        # get the runway combination preference for the specified period
        rc_preference = rc_preferences[rc_preferences['period'] == 'N']

        return self.get_runway_preference_usage(rc_usage, rc_preference)

    def get_deem_runway_preference_usage(self, rc_preferences):

        # Get the runway combination usage in the specified period
        rc_usage = self.data[(self.data['d_den'] != 'N') | (self.data['d_schedule'] == 6)]

        # get the runway combination preference for the specified period
        rc_preference = rc_preferences[rc_preferences['period'] != 'N']

        return self.get_runway_preference_usage(rc_usage, rc_preference)

    @staticmethod
    def get_runway_preference_usage(rc_usage, rc_preference):

        # Add the preferences to the runway combinations
        rc_usage = pd.merge(rc_usage, rc_preference, left_on='d_combination', right_on='combination', how='left')

        # Fill the unknowns with -
        rc_usage = rc_usage.fillna('-')

        # Calculate the usage per preference
        rc_preference_usage = rc_usage.groupby(['preference'])['total'].sum()

        # Replace '-' with 'other'
        rc_preference_usage.index = rc_preference_usage.index.str.replace('-', 'other')

        # Add total
        rc_preference_usage = rc_preference_usage.append(pd.Series(rc_preference_usage.sum(), index=['total']))

        # Add subtotal (preferences only)
        is_preferred = rc_preference_usage.index.str.isnumeric()
        rc_preference_usage = rc_preference_usage.append(
            pd.Series(rc_preference_usage[is_preferred].sum(), index=['subtotal']))

        # Change the order of the index
        is_preferred = rc_preference_usage.index.str.isnumeric()
        new_index_order = rc_preference_usage.index[is_preferred].tolist() + ['subtotal', 'other', 'total']
        rc_preference_usage = rc_preference_usage.reindex(index=new_index_order)

        # Calculate the relative preference usage
        rc_preference_usage_relative = (rc_preference_usage / rc_preference_usage['total'] * 100)

        # Get the preference
        return pd.concat([rc_preference_usage.rename('usage'), rc_preference_usage_relative.rename('relative usage')],
                         axis=1)

    def get_bracket(self, percentile=None):
        """
        Aggregate the data for each twenty minute bracket.

        :param float percentile: value between 0 <= percentile <= 1, the percentile to compute. See also
        pd.DataFrame.quantile
        :rtype: Bracket
        """

        # Define the supported types
        supported_types = ['daisy.phase', 'daisy.weekday', 'taf.sir']

        # Check if a different type is provided
        if self.type not in supported_types:
            # List the supported types as a string
            supported_types_string = ', '.join(supported_types)

            # Include 'or' after the last comma
            supported_types_string = ', or '.join(supported_types_string.rsplit(', ', 1))

            raise TypeError('This method is only supported for traffic aggregates of type {}, but {} is given'.format(
                supported_types_string, self.type))

        # Convert the d_schedule column to a timedelta
        dt = pd.to_datetime(self.data['d_schedule'], format="%H:%M") - pd.to_datetime("00:00", format="%H:%M")

        # Create a numeric value for each 20 minute time range
        brackets = np.mod(np.floor(dt / pd.to_timedelta(20, unit='m')).astype(int), 72)

        # Combine the brackets with the original data
        data = pd.concat([self.data, brackets.rename('bracket')], axis=1)

        # Add a total if none is present in the data
        if 'total' not in data:
            data['total'] = 1

        if 'd_date' not in data:
            # Sum the number of takeoffs/landings each bracket
            bracket_data = data.groupby(['d_lt', 'bracket'])['total'].sum()

        else:
            # Sum the number of takeoffs/landings each bracket
            bracket_by_date = data.groupby(['d_lt', 'bracket', 'd_date'])['total'].sum()

            # Use the mean by default, or use the percentile if specified
            if percentile is None:
                bracket_data = bracket_by_date.groupby(['d_lt', 'bracket']).mean()
            else:
                bracket_data = bracket_by_date.groupby(['d_lt', 'bracket']).quantile(percentile)

        # Return a bracket with reshaped data
        return Bracket(bracket_data.reset_index().pivot('d_lt', 'bracket', 'total'))


class Bracket(object):

    def __init__(self, data):
        self.data = data

    @classmethod
    def read_taf_bracket_excel_file(cls, path, **kwargs):
        """
        A method to read TAF bracket files.

        :param str path: path to the file.
        :return: Bracket.
        :rtype: Bracket
        """

        # Get the data from the file
        data = pd.read_excel(path, **kwargs)

        # Use a zero based index for the bracket numbers
        data['bracket'] = data['bracket'] - data['bracket'].min()

        # Reshape the bracket
        data = data.set_index('bracket').T

        return cls(data)

    @classmethod
    def from_periods_and_capacity(cls, period, capacity):
        """
        A method to read Daisy period files.

        :param str path: path to the file.
        :return: Bracket.
        :rtype: Bracket
        """

        # Get the dominant period
        period['period'] = period['period'].str.split(',', 1).str[0]

        # Merge the capacity with the periods and rename the
        period = period.merge(capacity, on='period', how='left').rename(columns={'Lcap': 'L', 'Tcap': 'T'})

        # Reshape the bracket
        period = period[['L', 'T', 'period']].T

        return cls(period)


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
