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

### Add `imshow()` as alternative to `contourf()`
The package now uses vectors to ensure high quality of images, however, for some use cases it might be sufficient to use a pixel-perfect method such as `imshow()`. Supporting both types in heatmaps will result in the possibility to choose between runtime performance and precision. This means faster rendering times during development and high quality images for publication. 

## Contribute

Do you want to contribute to this project? Please contact one of the active maintainers, listed below:

- [Wouter Dalmeijer](mailto://Wouter.Dalmeijer@schiphol.nl) (Schiphol)
- [Robert Koster](mailto://robert@aerlabs.com) ([AerLabs](https://aerlabs.com))