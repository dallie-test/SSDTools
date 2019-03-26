import glob
import io
import os
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
        file_paths = glob.glob(os.path.join(path, pattern))

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

    def to_envira(self, path):
        """

        :param str path:
        """

        return write_envira(path, self.info, self.data)


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
