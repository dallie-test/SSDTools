import os

from gptools.wbs import WBS


def test_wbs_read_file():
    # Get the path to the WBS file
    file_path = abs_path('data/wbs2005.h5')

    # Create a wbs object from the data file
    wbs = WBS.read_file(file_path)

    pass


def abs_path(rel_path):
    return os.path.join(os.path.dirname(__file__), rel_path)
