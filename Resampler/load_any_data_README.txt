load_any_data.m
Rowena Benfer Lohman, most recent update ~July, 2009

Usage: [datastruct]=load_any_data(filename,zone,limitny,azo,scaleval)

Note: currently requires mapping toolbox.  Contact me if you need a different version.


Input arguments (no arguments results in defaults as indicated)

filename: path and name (or just name if in same directory) of the ROI_PAC imagery product of interest.  Can be *.unw, *.int, *.slc, *.amp, *.cor, *.hgt, *.msk, *.dem, *.byt, *.flg, *.slp or *.off.  If no arguments are sent to load_any_data, then input dialog for file choice appears and rest of settings are defaults (see below).  Resource file (e.g., filename.suffix.rsc) must exist.

zone:  UTM zone, in string format such as '11S' or '10N', as returned with the matlab routine UTMzone.  If not set, then the "natural" zone for that lat/lon range will be used (if coordinates are in lat/lon), and rest of settings will be set to defaults.  Useful for cases where data is at edge of zone and it is desirable to "fix" it to be in the same zone as other data under consideration.

limitny:  If set, will limit the range of lines read in to a smaller value than exists in the data (e.g., will only read in the first 1000 lines).  Useful for debugging time series analysis codes.

azo: Set to 1 if the data in a *.unw file reflects pixel tracking or azimuth/range offsets instead of an interferogram.  Will then not scale the data by it's wavelength.  If left at 0 (default), then converts radians to cm, m or whatever units are contained in the *.rsc file.  

scaleval:  This value should be zero unless it is important to pad the size of the data to some power of 2 (as you would need in Quadtree resampling, for instance).  


*Currently, code is not smart enough to allow you to set the 3rd input argument without setting the first and 2nd, etc.  


Output arguments:  datastruct

datastruct is a matlab data structure that contains the following fields:

data: matrix of the values within the data set in question (varies), in units that depend on file type, etc.  For the multi-band data sets (cpx or rmg format), the field is usually the 2nd one (e.g., the phase, not the amplitude).

mag: matrix of the values within the 1st band of a cpx or rmg dataset (yes, it's not always magnitude).

phs: matrix of the values within the 2nd band of a cpx or rmg dataset (yes, it's not always phase). Both "mag" and "phs" are empty for single-band datasets.

X: matrix of X coordinate values.  If geocoding information was available in *.rsc file, this will be in meters.  It should be smart enough to not convert if the DEM used in ROI_PAC was in meters, but I never use those so I can't be absolutely sure.  I have tested this code primarily on DEM's generated using SRTM data, with coordinates in lat/lon.  If no geocoding information is available (e.g., if you try to view a flat*.int file or a *.slc), then these units are just in pixels.

Y: Same deal as with X.

pixelsize (scalar value):  If geocoding info is available, is set to the spacing between some of the first couple of points.  Obviously, this may change across the image and may not be the same in range and azimuth.

zone: UTM zone, if set. 

lambda: wavelength of radar, in units set within *.rsc file (meters, in current version of ROI_PAC)

nx: number of points in x

ny: number of points in y

filename: input filename of data that was loaded

scale: related to scale size of padding, if used.

extrax: number of zeros added in x, to pad data

extray: number of zeros added in y, to pad data



EXAMPLE:

datastruct=load_any_data('geo_080222-081022.unw');
%uses default values for all but name of file

figure
pcolor([datastruct.X],[datastruct.Y],[datastruct.data])
axis image, shading flat, colorbar

nx=datastruct.nx;
ny=datastruct.ny;
disp(['There should be ' num2str(nx*ny) 'pixels in this file']);

	