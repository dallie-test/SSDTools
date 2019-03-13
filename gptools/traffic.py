import xlrd
import pandas as pd


class Traffic(object):
    def __init__(self, data=None):
        """

        :param pd.DataFrame data: traffic data
        """

        if data is not None:
            self.data = data

    @classmethod
    def from_daisy_file_type_1(cls, path):
        return cls(pd.read_csv(path, sep='\t', index_col=None))

    @classmethod
    def from_daisy_file_type_2(cls, path):
        return cls(pd.read_csv(path, sep='\t', index_col=None))

    @classmethod
    def from_daisy_file_type_3(cls, path):
        return cls(pd.read_csv(path, sep='\t', index_col=None))

    @classmethod
    def from_daisy_file_type_4(cls, path):
        # Read the file as DataFrame
        data_frame = pd.read_csv(path, sep='\t', index_col=None)

        # todo: Split the runway combination (d_combination)

        # Return the traffic object
        return cls(data_frame)

    @classmethod
    def from_daisy_file_type_5(cls, path):
        return cls(pd.read_csv(path, sep='\t', index_col=None))

    @classmethod
    def from_casper_file(cls, path):
        return cls(pd.read_csv(path, sep=',', index_col=None))

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

        # Return the traffic object
        return cls(data_frame)
