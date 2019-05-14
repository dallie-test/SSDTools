import os
import matplotlib.pyplot as plt

from ssdtools.figures import plot_aircraft_types
from ssdtools.traffic import Traffic


def example_1():
    # Get the path to the Daisy file
    file_path = os.path.join(os.path.dirname(__file__), '../tests/data/traffic 1971-2016 - mean.txt')

    # Create a traffic object from the data file
    aggregate = Traffic.read_daisy_mean_file(file_path)

    # Create a aircraft type plot with the data in it
    fig, ax = plot_aircraft_types(aggregate, color='#141251', align='center', width=0.5)

    # Save the figure
    plt.savefig('figures/plot_fleet_to_aircraft_type_example_1.pdf', dpi=300, bbox_inches='tight')

    # Show the figure
    plt.show()


def example_2():
    # Get the path to the Daisy file
    file_path = os.path.join(os.path.dirname(__file__), '../tests/data/traffic 1971-2016 - mean.txt')

    # Create a traffic object from the data file
    aggregate = Traffic.read_daisy_mean_file(file_path)

    # Create a aircraft type plot with the data in it
    fig, ax = plot_aircraft_types(aggregate, align='edge', width=-0.3, label='prognose')
    plot_aircraft_types(aggregate, ax=ax, align='edge', width=0.3, label='realisatie')
    ax.legend()

    # Save the figure
    plt.savefig('figures/plot_fleet_to_aircraft_type_example_2.pdf', dpi=300, bbox_inches='tight')

    # Show the figure
    plt.show()


if __name__ == "__main__":
    # Set the branding to use
    plt.style.use('../ssdtools/branding/schiphol_default.rc')

    example_1()
    example_2()
