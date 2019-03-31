import copy
import numpy as np
import pandas as pd

from warnings import warn

from gptools.grid import Grid


class WBS(object):
    """
    A WBS object contains the data and methods related to woningbestanden.

    """

    def __init__(self, data=None):
        """

        :param pd.DataFrame data: woningbestand (WBS) data
        """

        if data is not None:
            self.data = data

    @classmethod
    def read_file(cls, path):
        """
        Create a new WBS object based on a HDF5 formatted file.

        :param string | buffer | Path path: the location of the file.
        :return: the WBS file as object.
        :rtype: WBS
        """

        # Read the file as DataFrame
        data_frame = pd.read_hdf(path)

        # Return the traffic object
        return cls(data_frame)

    def copy(self):
        """
        Make a deep copy of this WBS object.

        :return: a copy of this WBS object.
        :rtype: WBS
        """
        return copy.deepcopy(self)

    def add_noise_from_grid(self, grid):
        """
        Calculate the noise levels for each residence by interpolating the grid results.

        :param Grid grid: the grid data to add.
        :return: this WBS object.
        :rtype: WBS
        """

        # Get the interpolation function
        interpolation = grid.interpolation_function()

        # Set the interpolated noise levels for each wbs location
        self.data[grid.unit] = interpolation(self.data['y'], self.data['x'], grid=False)

        return self

    def select_above(self, level, unit):
        """
        Select the rows above the specified level for the specified unit.

        :param float level: the level to compare with.
        :param str unit: any column in the WBS data frame.
        :return: the rows.
        :rtype: pd.Series
        """

        return self.data[unit] >= level

    def count_above(self, level, unit):
        """
        Count the number of rows above the specified level for the specified unit.

        :param float level: the level to compare with.
        :param str unit: any column in the WBS data frame.
        :return: the number of rows.
        :rtype: int
        """

        return self.select_above(level, unit).sum()

    def count_homes_above(self, level, unit):
        """
        Count the number of homes above the specified level for the specified unit.

        :param float level: the level to compare with.
        :param str unit: any column in the WBS data frame.
        :return: the number of homes.
        :rtype: float
        """

        return self.data.loc[self.select_above(level, unit), 'woningen'].sum()

    def count_annoyed_people(self, threshold=48):
        """
        Count the number of annoyed people. Uses the Lden metric with a minimum value (threshold) and applies a relative
        annoyance.

        :param float threshold: The Lden value threshold. Only include values above the threshold.
        :return: the number of annoyed people.
        :rtype: float
        """

        # Get the rows above the Lden threshold
        data = self.data[self.select_above(threshold, 'Lden')]

        # Calculate the relative annoyance for each residence
        relative_annoyance = annoyance(data['Lden'])

        # Multiply the relative annoyance by the number of people
        return (data['personen'] * relative_annoyance).sum()

    def count_sleep_disturbed_people(self, threshold=40):
        """
        Count the number of sleep disturbed people. Uses the Lnight metric with a minimum value (threshold) and applies
        a relative sleep disturbance.

        :param float threshold: The Lnight value threshold. Only include values above the threshold.
        :return: the number of sleep disturbed people.
        :rtype: float
        """

        # Get the rows above the Lnight threshold
        data = self.data[self.select_above(threshold, 'Lnight')]

        # Calculate the relative sleep disturbance for each residence
        relative_sleep_disturbance = sleep_disturbance(data['Lnight'])

        # Multiply the relative sleep disturbance by the number of people
        return (data['personen'] * relative_sleep_disturbance).sum()


def annoyance(noise_levels, de='doc29', max_noise_level=None):
    """
    Calculate the relative annoyance for each noise level value. This particular method is only valid for Lden noise
    levels.

    Two dose-effect relationships are supported:
    1) doc29: the newest relationship, to be used for calculations with ECAC Doc. 29
    2) ges2002: an older dose-effect relationship.

    This method also supports a cut-off at a specified dB value. For doc29 it is not common to use a cut-off, for
    ges2002 it is customary to apply a cut-off at 65dB(A).

    :param np.ndarray | pd.Series noise_levels: the noise levels for which to calculate the relative annoyance.
    :param str de: the dose-effect relationship to apply, defaults to 'doc29'.
    :param float max_noise_level: the cut-off noise level.
    :return: the relative annoyance for the provided noise levels.
    :rtype: np.ndarray | pd.Series
    """

    # Apply a cut-off at max_db if provided
    if max_noise_level is not None:
        noise_levels[noise_levels > max_noise_level] = max_noise_level

    # Apply the dose-effect relationship
    if de == 'ges2002':
        return 1 / (1 / np.exp(-8.1101 + 0.1333 * noise_levels) + 1)
    elif de == 'doc29':
        if max_noise_level is not None:
            warn('You have set max_db to {} dB(A) while using the doc29 dose-effect relationship. However, for ' +
                 'doc29 it is not common to use a cut-off.'.format(max_noise_level), UserWarning)
        return 1 - 1 / (1 + np.exp(-7.7130 + 0.1260 * noise_levels))

    raise ValueError('The provided dose-effect relationship {} is not know. Please use ges2002 or doc29.'.format(de))


def sleep_disturbance(noise_levels, de='doc29', max_noise_level=None):
    """
    Calculate the relative sleep disturbance for each noise level value. This particular method is only valid for Lnight
    noise levels.

    Two dose-effect relationships are supported:
    1) doc29: the newest relationship, to be used for calculations with ECAC Doc. 29
    2) ges2002: an older dose-effect relationship.

    This method also supports a cut-off at a specified dB value. For doc29 it is not common to use a cut-off, for
    ges2002 it is customary to apply a cut-off at 57dB(A).

    :param np.ndarray | pd.Series noise_levels: the noise levels for which to calculate the relative sleep disturbance.
    :param str de: the dose-effect relationship to apply, defaults to 'doc29'.
    :param float max_noise_level: the cut-off noise level.
    :return: the relative sleep disturbance for the provided noise levels.
    :rtype: np.ndarray | pd.Series
    """

    # Apply a cut-off at max_db if provided
    if max_noise_level is not None:
        noise_levels[noise_levels > max_noise_level] = max_noise_level

    # Apply the dose-effect relationship
    if de == 'ges2002':
        return 1 / (1 / np.exp(-6.642 + 0.1046 * noise_levels) + 1)
    elif de == 'doc29':
        if max_noise_level is not None:
            warn('You have set max_db to {} dB(A) while using the doc29 dose-effect relationship. However, for ' +
                 'doc29 it is not common to use a cut-off.'.format(max_noise_level), UserWarning)
        return 1 - 1 / (1 + np.exp(-6.2952 + 0.0960 * noise_levels))

    raise ValueError('The provided dose-effect relationship {} is not know. Please use ges2002 or doc29.'.format(de))
