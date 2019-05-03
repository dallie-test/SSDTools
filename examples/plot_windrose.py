import matplotlib.pyplot as plt
from ssdtools.figures import plot_windrose
from ssdtools.meteo import Meteo

if __name__ == "__main__":
    # Set the branding to use
    plt.style.use('../ssdtools/branding/schiphol_default.rc')

    # Get the meteorological information from January 2019
    meteo = Meteo.from_knmi('2019-01-01 00:00', '2019-01-31 23:59')

    # Get the windrose
    windrose = meteo.get_windrose()

    # Plot the windrose
    ax = plot_windrose(windrose)

    # Compare the results with https://www.knmi.nl/nederland-nu/klimatologie/grafieken/maand/windrozen
