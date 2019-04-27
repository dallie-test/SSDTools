import os
import matplotlib.pyplot as plt
from gptools.figures import plot_season_traffic
from gptools.traffic import Traffic

if __name__ == "__main__":
    # Get the path to the Casper file
    file_path = os.path.join(os.path.dirname(__file__),
                             '../tests/data/Vluchten Export 2017-11-01 00_00_00 - 2018-11-01 00_00_00_2019-01-29 10_59_35.csv')

    # Create a traffic object from the data file
    traffic = Traffic.from_casper_file(file_path)

    # Add the seasons to the data
    traffic.add_season()

    # Add the departure/arrival to the data
    traffic.add_landing_takeoff()

    # Add the part of the day to the data
    traffic.add_denem()

    # Get the traffic distribution to plot
    distribution = traffic.get_season_distribution()

    # Rename the labels
    distribution = distribution.rename(
        index={'summer': 'zomer', 'L': 'landingen', 'T': 'starts'},
        columns={'D': 'dag', 'E': 'avond', 'N': 'nacht', 'EM': 'vroege ochtend'}
    )

    # Set the colors for each column
    colors = {
        'dag': '#141251',
        'avond': '#1B60DB',
        'nacht': '#9491AA',
        'vroege ochtend': '#027E9B'
    }

    # Create a season traffic plot with the data in it
    fig, ax = plot_season_traffic(distribution, column_colors=colors)

    # Add the legend
    ax[0].legend(bbox_to_anchor=(0., 1.02, 1., .102), loc=1, ncol=distribution.shape[1], borderaxespad=0.)

    # Save the figure
    plt.savefig('figures/plot_traffic_per_season.pdf')

    # Show the figure
    plt.show()
