import io
import os
import re
import textwrap

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

    def to_envira(self, path):
        """

        :param str path:
        """

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
        x = np.linspace(self.info['Xonder'], self.info['Xboven'], num=self.info['nx'])
        y = np.linspace(self.info['Yonder'], self.info['Yboven'], num=self.info['ny'])

        # Extract the data of the current grid
        z = self.data

        # Return the bi-cubic spline interpolation function
        return RectBivariateSpline(y, x, z)

    def interpolation(self, wbs):
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
        return interpolation(wbs['y'], wbs['x'], grid=False)

    def verfijn(self):
        """
        todo: Translate verfijn
        todo: Add doc29lib.verfijn here
        """
        pass

    def regrid(self):
        """
        todo: Add doc29lib.regrid here
        """
        pass

    def gehinderden(self):
        """
        todo: Translate gehinderden
        todo: Add doc29lib.gehinderden here
        """
        pass

    def slaapverstoorden(self):
        """
        todo: Translate slaapverstoorden
        todo: Add doc29lib.slaapverstoorden here
        """
        pass

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


def hdr_val(string, type):
    """
    Read value from header line
    """
    name, val = string.split()
    return type(val)


def read_envira(grid):
    """
    Read NLR grid-file and return header and noise data

    todo: create a dict or specification for the header
    """

    with open(grid, "r") as data:
        # Create an empty dict for the header
        header = dict()

        header['tekst1'] = data.readline().strip()
        header['tekst2'] = data.readline().strip()
        header['tekst3'] = data.readline().strip()

        header['datum'], header['tijd'] = data.readline().split()

        header['eenheid'] = hdr_val(data.readline(), str)
        header['grondinvloed'] = hdr_val(data.readline(), str)

        # skip, following line, because it is not used anymore
        # hdr['tellingen'] = hdr_val(data.readline(), int)
        data.readline()

        header['demping_landing'] = hdr_val(data.readline(), float)
        header['demping_start'] = hdr_val(data.readline(), float)
        header['mindba'] = hdr_val(data.readline(), float)
        header['tijdstap'] = hdr_val(data.readline(), float)
        header['Xonder'] = hdr_val(data.readline(), int)
        header['Xboven'] = hdr_val(data.readline(), int)
        header['Xstap'] = hdr_val(data.readline(), int)
        header['nx'] = hdr_val(data.readline(), int)
        header['Yonder'] = hdr_val(data.readline(), int)
        header['Yboven'] = hdr_val(data.readline(), int)
        header['Ystap'] = hdr_val(data.readline(), int)
        header['ny'] = hdr_val(data.readline(), int)
        header['nvlb'] = hdr_val(data.readline(), int)
        header['neff'] = hdr_val(data.readline(), float)
        header['nlos'] = hdr_val(data.readline(), int)
        header['nweg'] = hdr_val(data.readline(), int)

        # Overwrite unreliable values
        header['Xboven'] = header['Xonder'] + (header['nx'] - 1) * header['Xstap']
        header['Yboven'] = header['Yonder'] + (header['ny'] - 1) * header['Ystap']

        # Extract the noise data from the remaining lines
        dat = np.flipud(np.fromfile(data, sep=" ").reshape(header['ny'], header['nx']))

    return header, dat


def write_envira(filename, hdr, dat):
    """
    Write NLR grid-file with header and noise data
    """

    with open(filename, 'w') as f:
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
        f.write('X-ONDER {:9.0f}\n'.format(hdr['Xonder']))
        f.write('X-BOVEN {:9.0f}\n'.format(hdr['Xboven']))
        f.write('X-STAP {:9.0f}\n'.format(hdr['Xstap']))
        f.write('NX{:6.0f}\n'.format(hdr['nx']))
        f.write('Y-ONDER {:9.0f}\n'.format(hdr['Yonder']))
        f.write('Y-BOVEN {:9.0f}\n'.format(hdr['Yboven']))
        f.write('Y-STAP {:9.0f}\n'.format(hdr['Ystap']))
        f.write('NY{:6.0f}\n'.format(hdr['ny']))
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
