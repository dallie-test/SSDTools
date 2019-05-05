import matplotlib.pyplot as plt

from ssdtools.branding import set_schiphol_default

if __name__ == "__main__":
    # Set the branding to use
    set_schiphol_default()

    # Plot the various colors as bars
    for x in range(11):
        plt.bar(x, 10, label='Color {}'.format(x))

    # Add a legend to show the labels
    plt.legend()

    # Show the figure
    plt.show()
