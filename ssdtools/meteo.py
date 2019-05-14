import io
import requests
import numpy as np
import pandas as pd


class Meteo(object):
    def __init__(self, data):
        self.data = data

    def get_windrose(self):
        """
        Get the number of observed data points for every direction (rounded 30 degrees) and every windspeed (in bins of
        5 knots).

        :return: data frame containing all the counts for each windspeed and direction combination.
        :rtype: pd.DataFrame
        """

        # Select the exceptional cases
        exceptional = (self.data['DD'] == 0) | (self.data['DD'] == 990)

        # Round the direction by 30 degrees
        self.data['DR'] = (((np.round(self.data['DD'] / 30.) - 1) % 12).astype(int) + 1) * 30

        # Set the direction for exceptional cases to zero
        self.data.loc[exceptional, 'DR'] = 0

        # Round the speed to 5 kts
        self.data['SC'] = np.ceil(self.data['kts'] / 5.).astype(int) * 5

        # Add an upper limit of 30 kts
        self.data.loc[self.data['kts'] >= 30, 'SC'] = 30

        # Count occurrence per classification
        return self.data.groupby(['DR', 'SC'])['STN'].count()

    @classmethod
    def from_knmi(cls, start, end, proxy=None):
        """
        Uses the hourly records from KNMI.
        See http://projects.knmi.nl/klimatologie/uurgegevens/selectie.cgi

        The following data is requested from the API:
        DD: Windrichting (in graden) gemiddeld over de laatste 10 minuten van het afgelopen uur (360=noord, 90=oost,
        180=zuid, 270=west, 0=windstil 990=veranderlijk).
        FH: Uurgemiddelde windsnelheid (in 0.1 m/s).

        See http://www.knmi.nl/kennis-en-datacentrum/achtergrond/klimatologische-brochures-en-boeken

        :param start:
        :param end:
        :return: meteorological data.
        :rtype: Meteo
        """
		
        # Get the start and end of the requested period
        start = pd.to_datetime(start)
        end = pd.to_datetime(end)
        
        # Make the call to the KNMI API
        r = requests.post('http://projects.knmi.nl/klimatologie/uurgegevens/getdata_uur.cgi',
                          data={
                              'start': start.strftime('%Y%m%d%H'),
                              'end': end.strftime('%Y%m%d%H'),
                              'vars': 'DD:FF',
                              'stns': '240'
                          }, proxies=proxy)

        # Check the status code of the response
        if not r.status_code == 200:
            raise ValueError("Did not get the proper response from the KNMI API", r)

        # Set the column names
        column_names = "STN,YYYYMMDD,HH,DD,FF".split(',')

        # Create an in-memory stream for text I/O to capture the output data as a data frame
        z = io.StringIO(r.content.decode('utf-8'))
        data = pd.read_csv(z, comment='#', header=None, skipinitialspace=True, names=column_names)
        z.close()

        # Add the windspeed in knots
        data['kts'] = data['FF'] * 360 / 1852.

        return cls(data)
