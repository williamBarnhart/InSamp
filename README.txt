InSAR Downsampling and Noise Estimation (InSamp)MATLAB Source Code

questions? email: william-barnhart-1@uiowa.edu with Subject “InSamp Help”InSamp is an open source suite of scripts and functions designed to downsample spatially-dense InSAR observations into a computationally tractable number of observations based on a given starting deformation model. InSamp additionally estimates the covariance structure of the downsampled observations. InSamp has been used widely in InSAR studies of earthquake and volcanic deformation. Software citations:Lohman, R. B., and W. D. Barnhart (2010), Evaluation of earthquake triggering during the 2005-2008 earthquake sequence on Qeshm Island, Iran, J. Geophys. Res. Solid Earth, 115, 12413, doi:10.1029/2010JB007710.Lohman, R. B., and M. Simons (2005), Some thoughts on the use of InSAR data to constrain models of surface deformation: Noise structure and data downsampling, Geochem. Geophys. Geosystems, 6(1), n/a–n/a, doi:10.1029/2004GC000841.Software RequirementsMATLABMATLAB Optimization Toolbox*MATLAB Mapping Toolbox**These requirements are currently built into the current source code of InSamp; however, these are not requirements of the code and can be substituted with non-toolbox algorithms.Data RequirementsUnwrapped interferogram (Current support for ISCE, GMTSAR, and ROI_PAC input files)Line-of-sight (look) fileStarting deformation mechanismOptional Data InputsCorrelation/Coherence file used for phase maskingInSamp ModulesFault Maker: GUI-based program for generating a starting fault modelData Loaders: Suite of functions for loading the interferogram, look file, and correlation mapResampler: Suite of functions for downsampling the interferogramNoise Estimator: Suite of functions for estimating the covariance structure of the resampled interferogramInSamp Recipe:Pre-downsampling steps:1. Set path	a. After downloading the source package, the InSamp directory and its subdirectories should be added to your MATLAB path		i. /path/to/InSamp		ii. /path/to/InSamp/FaultMaker		iii. /path/to/InSamp/Resampler		iv. /path/to/InSamp/DataLoaders2. Process data	a. At a minimum, you will need an unwrapped, geocoded interferogram and the geocoded look/line-of-sight file to resample the data
	b. Additionally, you may include a geocoded map of coherence that will be used to mask the unwrapped interferogram
	c. Currently, InSamp accepts ISCE, ROI-PAC, and GMTSAR input files
		i. GMTSAR input files need to be converted to .xyz files using grd2xyz
		ii. Occasional updates to ISCE change the metadata file format which may cause the InSAR data loaders to fail. The current version is up to date for the 201704 release of ISCE


Downsampling steps:
3. Generate a starting fault model
	a. InSamp requires a starting fault model that is used as both a spatial proxy for the resampling as well as a means to remove an estimate of the deformation signal for covariance estimation. The starting fault does not need to be a precise representation of the actual slip distribution; however, you should try to approximate the location, orientation and dimensions of the fault plane as closely as you reasonably can.
	b. To generate a start model, run “faultMaker” from the command line. This will launch a GUI interface from which you can load the unwrapped interferogram
	c. If using GMTSAR data, use the load
	d. Using the cursor, click on the unwrapped interferogram to denote the endpoints of the fault you would like to generate. You may click multiple times to generate a multi-segment fault.
	e. Adjust the dip, width (down-dip width), and zt (depth to the top of the fault plane) values in the GUI interface.
	f. Save the fault model when you are done as a .mat file

4. Fill out resamp_in.m file
	a. Copy the file “resamp_in.m” from the InSamp source directory to the directory where you plan to save your resampled data set
	b. Edit the file to include the paths to your interferogram, look file, and (optionally) correlation file. 
	c. Supply the name of the save fault model from step 3 above
	d. Edit the UTM zone to correspond to your work area
	e. Edit the name of the file to be save (in .mat format)
	f. Most of the other options can remain unchanged

5. Run the resampled
	a. Execute “resamptool_tri” from the MATLAB command line and wait…
	b. The resampler will go through multiple iterations that may take up to an hour to complete, depending on the size of your interferogram



What’s generated?
After InSamp has run to completion, you will be left with a single saved structure that contains a structure variable “savestruct” with the following structure:

savestruct:
	name
	data
	np
	covstruct
	zone
	covstruct2

savestruct.name = the resampled filename

savestruct.data:
	X: X position of observation points (in meters)
	Y: Y position of observation points (in meters)
	data: LOS displacements (in meters)
	S: 3-component look vector
	count: Number of pixels averaged into a single point
	trix: polygon for plotting
	triy: polygon for plotting
	scale: defunct variable
	trid: triangle id for spatial smoothing

savestruct.np = total number of resampled data points

savestruct.covstruct:
	cov: full data covariance matrix
	Var: variance of the entire data set
	All other variables are intermittent steps related to the covariance estimation

savestruct.zone: UTM zone

savestruct.covstruct2: same as construct


To plot the resampled data, execute:

	data = [savestruct.data.data];
	trix = [savestruct.data.trix];
	triy = [savestruct.data.triy];

	figure
	patch(trix,triy,data)
	axis image; shading flat

Alternatively, to just plot the data locations:

	data = [savestruct.data.data];
	X = [savestruct.data.X];
	Y = [savestruct.data.Y];

	figure
	scatter(X,Y,24,data,’filled’)
	axis image; shading flat



Example:
This InSamp distribution includes an example you can run from an ISCE interferogram. The directory inside of example includes all of the files that you need to retain from the ISCE processing workflow in order to resample the interferograms. Copy the resamp_in.m file from the example directory to your working directory and change the appropriate directory paths. Then execute “resamptool_tri”


Enjoy!
