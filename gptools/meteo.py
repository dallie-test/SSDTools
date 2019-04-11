import io

import requests
import pandas as pd


class Meteo(object):
    def __init__(self, data):
        self.data = data

    def get_windrose(self):
        # todo: Aggregate per direction (within 30 degrees)
        # todo: Aggregate per speed (within x knots)

        pass

    @classmethod
    def from_knmi(cls, start, end):
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
                          })

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
        data['kts'] = data['FF'] * 0.194384449

        return cls(data)
