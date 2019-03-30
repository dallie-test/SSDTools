import copy
import io
import os
import re
import textwrap
from warnings import warn

import numpy as np
import pandas as pd
from scipy.interpolate import RectBivariateSpline


def extract_year_from_file_name(file_name):
    """
    The default method to obtain the year from a provided file name.

    :param str file_name: The name of the file.
    :rtype int|None
    """

    # Extract the matches
    matches = re.findall(r'y\d{4}', file_name)

    # Check if there are any matches
    if len(matches) < 1:
        return None

    # Take the first match and extract the year
    return int(matches[0][1:])


def meteotoeslag_years(method, unit):
    """
    Determine the years to include in the meteotoeslag based on the provided method.

    :param str method: The method for selecting the meteorological representative years, which is either 'empirisch'
     or 'hybride'.
    :param str unit: The noise level unit, which is either 'Lden' or 'Lnight'.
    :return: the years to include in the meteotoeslag.
    :rtype np.ndarray
    """

    # Set the exceptional years for each method and unit combination
    exceptional_years = {
        ('empirisch', 'Lden'): [1972, 1976, 1981, 1990, 1994, 1996, 2000, 2003],
        ('empirisch', 'Lnight'): [1973, 1979, 1985, 1989, 1994, 1995, 1996, 2002],
        ('hybride', 'Lden'): [1981, 1984, 1993, 1994, 1996, 2000, 2002, 2010],
        ('hybride', 'Lnight'): [1973, 1976, 1980, 1987, 1994, 1995, 1996, 2010]
    }

    # Exclude the years from the default range of 1971-2011 based on the method and unit
    return np.setdiff1d(np.arange(1971, 2011), exceptional_years[(method, unit)])


class Grid(object):
    """
    A Grid object contains the data and methods related to noise grids.

    There are two variants:
    1) A single contour grid
    2) A multi-contour grid

    Multi-contour grids are use to indicate the certainty ranges of the noise levels for a given traffic scenario.
    """

    def __init__(self, data=None, info=None, years=None, unit=None):
        """

        :param list(np.ndarray)|np.ndarray data: grid data, is two-dimensional for single contour grids and
        three-dimensional for multi-contour grids.
        :param list(dict)|dict info: grid information

        todo: Create a format specification for the grid information.

        """

        if data is not None:
            self.data = data
        if info is not None:
            self.info = info
            self.shape = Shape(info if isinstance(info, dict) else info[0])
        if years is not None:
            self.years = years
        if unit is not None:
            self.unit = unit

        self.validate(exclude=['datum', 'tijd', 'nvlb'])

    @classmethod
    def read_envira(cls, path):
        """
        Create a Grid object from an envira file.

        :param str path: The path to the envira file.
        :rtype Grid
        """

        # Read the envira file
        info, data = read_envira(path)

        # Extract the unit from the envira file
        unit = info['eenheid']

        # Return the object
        return cls(data=data, info=info, unit=unit)

    @classmethod
    def read_enviras(cls, path, pattern='*.dat', year_extractor=extract_year_from_file_name):
        """
        Create a Grid object from multiple envira files.

        :param str path: The path to the envira files.
        :param str pattern: The pattern used to match the envira files.
        :param function year_extractor: The method used to extract the year from the file name.
        :rtype Grid
        """

        # Get the envira files
        file_paths = [os.path.join(path, f) for f in os.listdir(path) if re.search(pattern, f)]

        # Create info and data lists
        cls_info = []
        cls_data = []
        cls_years = []

        # Read the envira files
        for file_path in file_paths:
            # Extract the data and header from the file
            info, data = read_envira(file_path)

            # Extract the year from the file path
            year = year_extractor(file_path)

            # Put the extracted data in the lists
            cls_info.append(info)
            cls_data.append(data)
            cls_years.append(year)

        # Extract the unit from the first envira file
        unit = cls_info[0]['eenheid']

        # Add the data to a Grid object
        return cls(data=cls_data, info=cls_info, unit=unit, years=cls_years)

    def validate(self, exclude=None):
        """
        Validate if the object's data and info are consistent with each other.
        Only checks if multigrids are consistent among each other.

        """

        # Create an empty list if exclude is not provided
        exclude = [] if exclude is None else exclude

        if isinstance(self.data, list) and isinstance(self.info, list):

            # Check if the lists are equal
            if len(self.data) != len(self.info):
                raise IndexError('Provided data list and info list should have the same length.')

            # Set the elements to check
            data = np.array(self.data[0])

            # Put all the info in a data frame for easy checking
            info = pd.DataFrame(self.info)

            if not info.duplicated(subset=info.columns[~info.columns.isin(exclude)], keep=False).all():
                raise ValueError('All info in the provided info list should be the same')

        elif isinstance(self.data, list) or isinstance(self.info, list):
            raise TypeError('Supplied data and info for a multigrid should both be lists.')

        else:
            if not (self.shape.y_number, self.shape.x_number) == self.data.shape:
                raise IndexError('Provided data does not have the same shape as mentioned in the header file.')

    def copy(self):
        return copy.deepcopy(self)

    def to_envira(self, path):
        """

        :param str path:
        """

        # Update the info with the current shape
        self.info.update(self.shape.to_dict())

        # Write the data to the selected path
        return write_envira(path, self.info, self.data)

    def scale(self, factor):
        """
        Apply a scaling factor to the data.

        :param float|int factor: the factor to be applied.
        """

        if isinstance(self.data, list):
            self.data = [d + 10 * np.log10(factor) for d in self.data]
        else:
            self.data += 10 * np.log10(factor)

    def gelijkwaardigheid(self):
        """
        todo: Translate gelijkwaardigheid
        todo: Add the functionality of GPtools_matlab/lib/GPcalc_gelijkwaardigheid.m here
        """
        pass

    def inpasbaarvolume(self):
        """
        todo: Translate inpasbaarvolume
        todo: Add GPtools_matlab/lib/GPcalc_inpasbaarvolume.m here
        """
        pass

    def contourpunten(self):
        """
        todo: Translate contourpunten
        todo: Add GPtools_matlab/lib/ContourPunten.m here
        """
        pass

    def hg(self):
        """
        Calculate the Hoeveelheid Geluid (HG).

        todo: Add support for multigrid.
        """

        if isinstance(self.data, list):
            raise TypeError('Hoeveelheid Geluid (HG) cannot be calculated for a multi-contour grid.')

        # Conversion to "Hindersom" without scaling
        hs = 10 ** (self.data / 10.)

        # Return total noise level (HG)
        return 10. * np.log10(hs.sum() / np.array(hs.shape).prod())

    def meteotoeslag_from_method(self, method):
        """
        Calculate the meteotoeslag based on the provided method.

        :param str method: The method for selecting the meteorological representative years, which is either 'empirisch'
         or 'hybride'.
        :return the max-grid and the included meteorological years.
        :rtype tuple(np.ndarray, np.ndarray)
        """

        return self.meteotoeslag_from_years(meteotoeslag_years(method, self.unit))

    def meteotoeslag_from_years(self, years):
        """
        Determine the meteotoeslag excluding the extraordinary meteorological years.
        Meteotoeslag is a surcharge for meteorological conditions and is a max-grid based on the provided grids

        :param list|np.ndarray years: the years to include in the meteotoeslag, should include
        :return the max-grid and the included meteorological years.
        :rtype tuple(np.ndarray, np.ndarray)
        """

        # Get the selected years from the provided years of the grid
        selected_years = np.isin(self.years, years)

        # There should be 32 years to include
        if selected_years.sum() != 32:
            raise LookupError(
                'Expected 32 years for the meteorological surcharge but found {} years'.format(selected_years.sum()))

        # Get the noise levels for all years
        data = np.array(self.data)

        # Select the maximum noise levels based on the selected years
        meteorological_surcharge = np.amax(data[selected_years, :, :], axis=0)

        # Return the grid with meteorological surcharge and the included years
        return meteorological_surcharge, years

    def statistics(self):
        """
        Determine the average, standard deviation and the confidence interval for a multigrid.

        :return collection of statistics for the current data.
        :rtype dict(nd.array)
        """

        if not isinstance(self.data, list):
            raise TypeError('Statistics can only be extracted from multigrids')

        # Conver the data to a multidimensional array
        data = np.array(self.data)

        # Extract the statistics for each point in the grid
        mean = 10 * np.log10(np.mean(10 ** (data / 10.), axis=0))
        standard_deviation = np.std(self.data, axis=0)

        # Calculate the 99.5% confidence interval
        z = 2.5758
        upper_bound_confidence_interval = mean + z * standard_deviation
        lower_bound_confidence_interval = mean - z * standard_deviation

        return {
            'mean': mean,
            'std': standard_deviation,
            'dhi': upper_bound_confidence_interval,
            'dlo': lower_bound_confidence_interval,
            'dat': data
        }

    def interpolation_function(self):
        """
        Determine the bi-cubic spline interpolation function.

        :return the interpolation function.
        :rtype function
        """

        if isinstance(self.data, list):
            raise TypeError('Interpolation functions can only be created from single grids.')

        # Extract the coordinates of the current grid
        x = self.shape.get_x_coordinates()
        y = self.shape.get_y_coordinates()

        # Extract the data of the current grid
        z = self.data

        # Return the bi-cubic spline interpolation function
        return RectBivariateSpline(y, x, z)

    def refine(self, factor):
        """
        Refine the grid with a bi-cubic spline interpolation.

        """

        # Refine the current shape
        shape = self.shape.copy().refine(factor)

        # Return a reference to this object
        return self.resize(shape)

    def resize(self, shape):
        """
        Reshape the grid based on with a bi-cubic spline interpolation.

        Interpoleer met bi-cubic spline naar een nieuw grid

        todo: Add doc29lib.regrid here
        """

        # Refine the grid and update the data
        self.data = self.interpolation_function()(shape.get_y_coordinates(), shape.get_x_coordinates())

        # Update the info of this object
        self.info.update(shape.to_dict())

        # Assign the shape to the object
        self.shape = shape

        return self

    def interpolation_from_wbs(self, wbs):
        """
        Determine the noise levels on each address in the WBS based on a bi-cubic spline interpolation function.

        :return noise levels for each address
        :rtype np.ndarray
        """

        if isinstance(self.data, list):
            raise TypeError('Grid interpolation can only be performed on single grids.')

        # Get the interpolation function
        interpolation = self.interpolation_function()

        # Return the interpolated noise levels for each wbs location
        return interpolation(wbs.data['y'], wbs.data['x'], grid=False)

    def gehinderden_from_wbs(self, wbs, de='doc29', max_db=None):
        """
        Calculate the number of disturbed people (gehinderden) for the WBS locations. This particular method is only
        valid for Lden grids.

        Two dose-effect relationships are supported:
        1) doc29: the newest relationship, to be used for calculations with ECAC Doc. 29
        2) ges2002: an older dose-effect relationship.

        This method also supports a cut-off at a specified dB value. For doc29 it is not common to use a cut-off, for
        ges2002 it is customary to apply a cut-off at 65dB(A).

        :param WBS wbs: the woningbestand.
        :param str de: the dose-effect relationship to apply, defaults to 'doc29'.
        :param float max_db: the cut-off noise level.
        :return:
        """

        if self.unit != "Lden":
            raise TypeError(
                'Cannot calculate gehinderden based on an {} grid, an Lden grid should be used.'.format(self.unit))

        # Calculate the noise levels for the WBS
        db = self.interpolation_from_wbs(wbs)

        # Apply a cut-off at max_db if provided
        if max_db is not None:
            db[db > max_db] = max_db

        # Apply the dose-effect relationship
        if de == 'ges2002':
            return wbs.data['personen'] * 1 / (1 / np.exp(-8.1101 + 0.1333 * db) + 1)
        elif de == 'doc29':
            if max_db is not None:
                warn('You have set max_db to {} dB(A) while using the doc29 dose-effect relationship. However, for ' +
                     'doc29 it is not common to use a cut-off.'.format(max_db), UserWarning)
            return wbs.data['personen'].values * (1 - 1 / (1 + np.exp(-7.7130 + 0.1260 * db)))

        raise ValueError(
            'The provided dose-effect relationship {} is not know. Please use ges2002 or doc29.'.format(de))

    def slaapverstoorden_from_wbs(self, wbs, de='doc29', max_db=None):
        """
        Calculate the number of slaapverstoorden for the WBS locations. This particular method is only valid for Lnight
        grids.

        Two dose-effect relationships are supported:
        1) doc29: the newest relationship, to be used for calculations with ECAC Doc. 29
        2) ges2002: an older dose-effect relationship.

        This method also supports a cut-off at a specified dB value. For doc29 it is not common to use a cut-off, for
        ges2002 it is customary to apply a cut-off at 57dB(A).

        :param WBS wbs: the woningbestand.
        :param str de: the dose-effect relationship to apply, defaults to 'doc29'.
        :param float max_db: the cut-off noise level.
        :return:
        """

        if self.unit != "Lnight":
            raise TypeError(
                'Cannot calculate gehinderden based on an {} grid, an Lnight grid should be used.'.format(self.unit))

        # Calculate the noise levels for the WBS
        db = self.interpolation_from_wbs(wbs)

        # Apply a cut-off at max_db if provided
        if max_db is not None:
            db[db > max_db] = max_db

        # Apply the dose-effect relationship
        if de == 'ges2002':
            return wbs.data['personen'] * 1 / (1 / np.exp(-6.642 + 0.1046 * db) + 1)
        elif de == 'doc29':
            if max_db is not None:
                warn('You have set max_db to {} dB(A) while using the doc29 dose-effect relationship. However, for ' +
                     'doc29 it is not common to use a cut-off.'.format(max_db), UserWarning)
            return wbs.data['personen'].values * (1 - 1 / (1 + np.exp(-6.2952 + 0.0960 * db)))

        raise ValueError(
            'The provided dose-effect relationship {} is not know. Please use ges2002 or doc29.'.format(de))

    def tellen_etmaal(self):
        """
        todo: Translate tellen etmaal
        todo: Add doc29lib.tellen_etmaal here
        """
        pass

    def tellen_nacht(self):
        """
        todo: Translate tellen nacht
        todo: Add doc29lib.tellen_nacht here
        """
        pass

    def schaal_per_etmaalperiode(self):
        """
        todo: Translate schaal per etmaalperiode
        todo: Add doc29lib.schaal_per_etmaalperiode here
        """
        pass

    def relatief_norm_etmaal(self):
        """
        todo: Translate relatief norm etmaal
        todo: Add doc29lib.relatief_norm_etmaal here
        """
        pass


class Shape(object):
    def __init__(self, data):
        self.x_start = data['x_start']
        self.x_stop = data['x_stop']
        self.x_step = data['x_step']
        self.x_number = data['x_number']
        self.y_start = data['y_start']
        self.y_stop = data['y_stop']
        self.y_step = data['y_step']
        self.y_number = data['y_number']

    def refine_x(self, factor):
        # Calculate the new step distance
        self.x_step /= factor

        # Calculate the new number of steps
        self.x_number = 1 + factor * (self.x_number - 1)

        return self

    def refine_y(self, factor):
        # Calculate the new step distance
        self.y_step /= factor

        # Calculate the new number of steps
        self.y_number = 1 + factor * (self.y_number - 1)

        return self

    def refine(self, factor):
        self.refine_x(factor)
        self.refine_y(factor)
        return self

    def set_x_number(self, number):
        if number < 2:
            raise ValueError('Cannot set the number of x coordinates to {}. The minimum number is 2.'.format(number))
        self.x_number = number
        self.x_step = (self.x_stop - self.x_start) / (self.x_number - 1)
        return self

    def set_y_number(self, number):
        if number < 2:
            raise ValueError('Cannot set the number of y coordinates to {}. The minimum number is 2.'.format(number))
        self.y_number = number
        self.y_step = (self.y_stop - self.y_start) / (self.y_number - 1)
        return self

    def set_x_step(self, step):
        self.x_step = step
        self.x_number = 1 + (self.x_stop - self.x_start) / self.x_step
        return self

    def set_y_step(self, step):
        self.y_step = step
        self.y_number = 1 + (self.y_stop - self.y_start) / self.y_step
        return self

    def get_x_coordinates(self):
        return np.linspace(self.x_start, self.x_stop, num=self.x_number)

    def get_y_coordinates(self):
        return np.linspace(self.y_start, self.y_stop, num=self.y_number)

    def to_dict(self):
        return self.__dict__

    def copy(self):
        return copy.deepcopy(self)


def hdr_val(string, type):
    """
    Read value from header line
    """
    name, val = string.split()
    return type(val)


def read_envira(file_path):
    """
    Read NLR grid-file and return header and noise data

    todo: create a dict or specification for the header
    """

    with open(file_path, "r") as file:
        # Create an empty dict for the header
        header = dict()

        header['tekst1'] = file.readline().strip()
        header['tekst2'] = file.readline().strip()
        header['tekst3'] = file.readline().strip()

        header['datum'], header['tijd'] = file.readline().split()

        header['eenheid'] = hdr_val(file.readline(), str)
        header['grondinvloed'] = hdr_val(file.readline(), str)

        # skip, following line, because it is not used anymore
        # hdr['tellingen'] = hdr_val(data.readline(), int)
        file.readline()

        header['demping_landing'] = hdr_val(file.readline(), float)
        header['demping_start'] = hdr_val(file.readline(), float)
        header['mindba'] = hdr_val(file.readline(), float)
        header['tijdstap'] = hdr_val(file.readline(), float)
        header['x_start'] = hdr_val(file.readline(), int)
        header['x_stop'] = hdr_val(file.readline(), int)
        header['x_step'] = hdr_val(file.readline(), int)
        header['x_number'] = hdr_val(file.readline(), int)
        header['y_start'] = hdr_val(file.readline(), int)
        header['y_stop'] = hdr_val(file.readline(), int)
        header['y_step'] = hdr_val(file.readline(), int)
        header['y_number'] = hdr_val(file.readline(), int)
        header['nvlb'] = hdr_val(file.readline(), int)
        header['neff'] = hdr_val(file.readline(), float)
        header['nlos'] = hdr_val(file.readline(), int)
        header['nweg'] = hdr_val(file.readline(), int)

        # Overwrite unreliable values
        header['x_stop'] = header['x_start'] + (header['x_number'] - 1) * header['x_step']
        header['y_stop'] = header['y_start'] + (header['y_number'] - 1) * header['y_step']

        # Extract the noise data from the remaining lines
        data = np.fromfile(file, sep=" ")

        # Check if the provided header and data are compatible
        if data.shape[0] != header['y_number'] * header['x_number']:
            raise ValueError('The header of the envira file is not consistent with its data.')

        # Reshape the data
        data = np.flipud(np.resize(data, (header['y_number'], header['x_number'])))

    return header, data


def write_envira(file_path, hdr, dat):
    """
    Write NLR grid-file with header and noise data
    """

    with open(file_path, 'w') as f:
        # Write the header
        f.write('{:s}\n'.format(hdr['tekst1']))
        f.write('{:s}\n'.format(hdr['tekst2']))
        f.write('{:s}\n'.format(hdr['tekst3']))
        f.write('{:s} {:s}\n'.format(hdr['datum'], hdr['tijd']))
        f.write('EENHEID {:s}\n'.format(hdr['eenheid']))
        f.write('GRONDINVLOED {:s}\n'.format(hdr['grondinvloed']))
        f.write('TELLINGEN\n')
        f.write('DEMPING-LANDING {:6.2f}\n'.format(hdr['demping_landing']))
        f.write('DEMPING-START {:6.2f}\n'.format(hdr['demping_start']))
        f.write('MINDBA {:6.2f}\n'.format(hdr['mindba']))
        f.write('TIJDSTAP {:6.2f}\n'.format(hdr['tijdstap']))
        f.write('X-ONDER {:9.0f}\n'.format(hdr['x_start']))
        f.write('X-BOVEN {:9.0f}\n'.format(hdr['x_stop']))
        f.write('X-STAP {:9.0f}\n'.format(hdr['x_step']))
        f.write('NX{:6.0f}\n'.format(hdr['x_number']))
        f.write('Y-ONDER {:9.0f}\n'.format(hdr['y_start']))
        f.write('Y-BOVEN {:9.0f}\n'.format(hdr['y_stop']))
        f.write('Y-STAP {:9.0f}\n'.format(hdr['y_step']))
        f.write('NY{:6.0f}\n'.format(hdr['y_number']))
        f.write('NVLB {:9.0f}\n'.format(hdr['nvlb']))
        f.write('NEFF {:9.0f}\n'.format(hdr['neff']))
        f.write('NLOS {:9.0f}\n'.format(hdr['nlos']))
        f.write('NWEG {:9.0f}'.format(hdr['nweg']))

        # Create an in-memory stream for text I/O to capture the numpy data as a string
        z = io.StringIO()
        np.savetxt(z, np.flipud(dat), fmt='%12.6E')
        x = z.getvalue()
        z.close()

        # Extract the individual lines except the last line which is empty
        s = x.split('\n')[:-1]

        # Create a line wrapper
        wrapper = textwrap.TextWrapper(initial_indent=' ', subsequent_indent=' ', width=131)

        # Write each line to the data file
        [f.write('\n' + '\n'.join(wrapper.wrap(p))) for p in s]
