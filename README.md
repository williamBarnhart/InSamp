# InSamp: InSAR Downsampler and Covariance Estimator (MATLAB version)

InSamp is a suite of MATLAB scripts and functions that allow you to downsample a full resolution interferogram into a data set that is tractable for inversions. The algorithm variably resamples interferograms to allow for more observations points close to the location of surface deformation. Instead of resampling based on gradients in the deformation field, InSamp uses a user-defined starting model for the source of the deformation. InSamp generates downsampled meshes using the open source Mesh2D unstructured meshing tool developed by D. Engwirda (https://www.mathworks.com/matlabcentral/fileexchange/25555-mesh2d-delaunay-based-unstructured-mesh-generation)

In addition to downsampling data, InSamp generates an estimate of the full covariance structure of the downsampled interferograms. This allows the user to include noise information that is representative of the true, spatially varying noise structure.

Currently Supported Processor:

           ISCE

           GMTSAR

           ROI-PAC

Includes a README file and example data Sentinel-1 data set processed using the JPL/Caltech ISCE procesing package


Reference:
Lohman, R. B., and W. D. Barnhart (2010), Evaluation of earthquake triggering during the 2005-2008 earthquake sequence on Qeshm Island, Iran, J. Geophys. Res. Solid Earth, 115, 12413, doi:10.1029/2010JB007710.

Lohman, R. B., and M. Simons (2005), Some thoughts on the use of InSAR data to constrain models of surface deformation: Noise structure and data downsampling, Geochem. Geophys. Geosystems, 6(1), n/a–n/a, doi:10.1029/2004GC000841.

## Requirements:
MATLAB
MATLAB Optimization Toolbox
MATLAB Mapping Toolbox (to convert between lon/lat and UTM)
