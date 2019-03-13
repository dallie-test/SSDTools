import pandas as pd


class Traffic(object):
    def __init__(self, data=None):
        if data is not None:
            self.data = data

    @classmethod
    def from_daisy_file_type_1(cls, file_name):
        return cls(pd.DataFrame.from_csv(file_name))
