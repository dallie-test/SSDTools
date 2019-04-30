# GPtools

A Python toolbox that contains common objects and functions used for reporting and analysis at the Schiphol department for Stakeholder and Strategy Development.

## Installation

If you want to use this package in your own project, you can import this package by running the following command or include it in the `requirements.txt` or `environment.yml` of your project.

```bash
# Exectute the the following command in your terminal to install the latest version of GPtools. 
pip install git+ssh://github.com/Schiphol-Hub/GPtools@master#egg=GPtools
```

## Recommendations for further development

1. Separate `MultiGrid` from `Grid`
1. Create `Scenario` object which contains both _Lden_ and _Lnight_ grids
1. Add `imshow()` as alternative to `contourf()`
1. Make `Traffic` compatible with `Schedule` from TAFTools
1. Create standardized/preferred data types for each object
1. Organise a git training for all future contributors
1. Separate the verification cases from the unit tests
1. Remove the data from the repository
1. Use map service instead of manually provided background image.

### Add `imshow()` as alternative to `contourf()`
The package now uses vectors to ensure high quality of images, however, for some use cases it might be sufficient to use a pixel-perfect method such as `imshow()`. Supporting both types in heatmaps will result in the possibility to choose between runtime performance and precision. This means faster rendering times during development and high quality images for publication. 

### Remove the data from the repository
The package currently includes a number of large files, including WBS files (_woningbestanden_). It is a good idea to store these large data files on a different location (i.e. not in this repository). Furthermore, it might be a good idea to publish this data and make it available to the public, such that other users of this package can also access this data on request.  

## Contribute

Do you want to contribute to this project? Please contact one of the active maintainers, listed below:

- [Wouter Dalmeijer](mailto://Wouter.Dalmeijer@schiphol.nl) (Schiphol)
- [Robert Koster](mailto://robert@aerlabs.com) ([AerLabs](https://aerlabs.com))