import io
import os
import re
import textwrap

import numpy as np


class Grid(object):
    """
    A Grid object contains the data and methods related to noise grids.

    There are two variants:
    1) A single contour grid
    2) A multi-contour grid

    Multi-contour grids are use to indicate the certainty ranges of the noise levels for a given traffic scenario.
    """

    def __init__(self, data=None, info=None):
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

        self.validate()

    @classmethod
    def from_envira_file(cls, path):
        """
        Create a Grid object from an envira file.

        :param str path:
        """

        # Read the envira file
        info, data = read_envira(path)

        # Return the object
        return cls(data=data, info=info)

    @classmethod
    def from_envira_files(cls, path, pattern='*.dat'):
        """
        Create a Grid object from multiple envira files.

        :param str pattern:
        :param str path:
        """

        # Get the envira files
        file_paths = [os.path.join(path, f) for f in os.listdir(path) if re.search(pattern, f)]

        # Create info and data lists
        cls_info = []
        cls_data = []

        # Read the envira files
        for file_path in file_paths:
            info, data = read_envira(file_path)
            cls_info.append(info)
            cls_data.append(data)

        # Add the data to a Grid object
        return cls(data=cls_data, info=cls_info)

    def validate(self):
        """
        Validate if the object's data and info are consistent with each other.
        Only checks if multigrids are consistent among each other.

        """
        if isinstance(self.data, list) and isinstance(self.info, list):

            # Check if the lists are equal
            if len(self.data) != len(self.info):
                raise IndexError('Provided data list and info list should have the same length.')

            # Set the elements to check
            data_shape = self.data[0].shape
            info_dict = self.info[0]

            # Check all the shapes and info dicts
            for i, d in enumerate(self.data):
                if data_shape != d.shape:
                    raise ValueError('All data in the provided data list should have the same shape.')
                if info_dict != self.info[i]:
                    raise ValueError('All info in the provided info list should be the same')

        elif isinstance(self.data, list) or isinstance(self.info, list):
            raise TypeError('Supplied data and info for a multigrid should both be lists.')

    def to_envira(self, path):
        """

        :param str path:
        """

        return write_envira(path, self.info, self.data)

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
        todo: Translate hoeveelheid geluid
        todo: Add GPtools_matlab/lib/GPcalc_hg_grid.m here
        """
        pass

    def nieuw_meteotoeslaggrid(self):
        """
        todo: Translate nieuw meteotoeslag
        todo: Add GPtools_matlab/lib/GPcalc_nieuw_meteotoeslaggrid.m here
        """
        pass

    def gridstats(self):
        """
        todo: Add doc29lib.gridstats here
        """
        pass

    def interpolate_func(self):
        """
        todo: Add doc29lib.interpolate_func here
        """
        pass

    def grid_interpolatie(self):
        """
        todo: Add doc29lib.grid_interpolatie here
        """
        pass

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


def read_envira(grid, return_header=True, scale=1):
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

    # Apply the scaling factor
    dat = dat + 10 * np.log10(scale)

    if return_header:
        return header, dat
    return dat


def write_envira(filename, hdr, dat, scale=1):
    """
    Write NLR grid-file with header and noise data
    """

    # Apply the scaling factor
    dat = dat + 10 * np.log10(scale)

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