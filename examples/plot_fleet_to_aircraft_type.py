import os
import matplotlib.pyplot as plt

from gptools.figures import plot_aircraft_types
from gptools.traffic import Traffic
from matplotlib import rc

if __name__ == "__main__":
    # Get the path to the Daisy file
    file_path = os.path.join(os.path.dirname(__file__), '../tests/data/traffic 1971-2016 - mean.txt')

    # Create a traffic object from the data file
    aggregate = Traffic.read_daisy_mean_file(file_path)

    # Define the font branding to use
    font = {
        'family': 'Arial',
        'size': 13
    }

    # Add the branding to the current style
    rc('font', **font)

    # Create a aircraft type plot with the data in it
    fig, ax = plot_aircraft_types(aggregate, bar_color='#141251')

    # Save the figure
    plt.savefig('figures/plot_fleet_to_aircraft_type.pdf', dpi=300, bbox_inches='tight')

    # Show the figure
    plt.show()
