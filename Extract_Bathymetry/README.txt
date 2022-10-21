Extract Bathymetry Library
===========================

MATLAB code for extracting the bathymetry grid of a region.

GETBATHYMETRY is the most up to date and versatile routine. It allows the
user to extract the bathymetry of a selected area from GEBCO NetCDF files.

"Legacy (.m)" folder contains old versions of code for reading bathymetry. 
READGEBCOGRID and GETGEBCOCELL combined have essentially the same functionality
as GETBATHYMETRY, but they are not updated to support the most recent GEBCO
data. BATHYMETRYGRID and READBATHYMETRY was the first code I developed to read
bathymetry data, and it was designed to accept data exported from NOAA website
or GEBCO Visualisation Tool. The data from NOAA is not gridded and grid 
manipulation and verification is needed, meaning that these last two functions
require the "Grid Manipulation" library.

For any code with dependencies on functions from another library, execute the
command ADDPATH(FPATH), where FPATH is the absolute path of the library.

[Guillermo Jiménez Arranz, 17 Jun 2021]





