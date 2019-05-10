# SSDtools

A Python toolbox that contains common objects and functions used for reporting on the environmental impact of air traffic movements on airports surrounding. It's consist of two main functionalities:
- Datafiles containing air traffic schedules can be loaded and analysis can be performed.
- Noise grids can be loaded and Lden and Lnight levels at individual locations can be computed. Used for official reporting about noise impact at Schiphol airport. 

## Creating conda environment with ssdtools installed (for Schiphol users)
If you are using the conda editor, here is some useful code to get you started by setting up an environment this packages has been tested in. First make a environment.yml file, from which to set up your conda environment, containing the following code:
```yaml
name: ssd
channels:
  - conda-forge
dependencies:
  - python=3.6
  - numpy=1.16.*
  - pandas=0.24.*
  - scipy=1.2.*
  - xlrd=1.2.*
  - requests=2.21.*
  - matplotlib=3.0.*
  - gdal=2.3.*
  - proj4=5.*
  - pyshp=2.1.*
  - pytables=3.5.*
  - geopandas=0.5.*
  - descartes=1.1.*
  - pip=19.1.*
  - pip:
      - Pillow==6.0.*
      - python-docx==0.8.*
      - git+https://github.com/Schiphol-Hub/SSDTools.git@master#egg=SSDTools
```

Make sure you have a personal access token, to circumvent the two-factor identification. For more info on a personal access token, see: https://github.com/settings/tokens Then install using:
```bash
# To install from an environment.yml, use:
conda env create -f environment.yml

```
When prompted for a password use the personal access token.

## Installation (for non-schiphol users)

If you want to use this package in your own project, you can import this package by running the following command or include it in the `requirements.txt` or `environment.yml` of your project.

```bash
# Execute the the following command in your terminal to install the latest version of GPtools. 

# If you work with an ssh key, then use:
pip install git+ssh://git@github.com/Schiphol-Hub/SSDTools@master#egg=SSDTools

# OR clone first using for example https:
git clone https://github.com/Schiphol-Hub/SSDTools.git

# and then install to environement from local repo:
pip install git+file:///PATH_TO_CLONE#egg=SSDTools

# OR install directly using hhtps:
pip install git+https://github.com/Schiphol-Hub/SSDTools.git@master#egg=SSDTools

```

For more information about installing a Python package from a repository, please visit https://pip.pypa.io/en/stable/reference/pip_install/#git.

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
