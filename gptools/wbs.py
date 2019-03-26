import pandas as pd


class WBS(object):
    def __init__(self, data=None):
        """

        :param pd.DataFrame data: woningbestand (wbs) data
        """

        if data is not None:
            self.data = data

    @classmethod
    def read_file(cls, path):
        # Read the file as DataFrame
        data_frame = pd.read_hdf(path)

        # Return the traffic object
        return cls(data_frame)
