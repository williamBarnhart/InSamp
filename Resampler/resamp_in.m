datafilename    = '../p122/int_170817_170910/merged/filt_topophase.unw.geo';      %Full or relative path to the unwrapped interferogram

% ROI_PAC and ISCE LOSFILENAME
%%losfilename     = '../p122/int_170817_170910/merged/los.rdr.geo';                 % Full or relative path to the look file, can be multiple files for GMTSAR
                                                                                  % Note that GMT looks files should be order East, North, Up

% GAMMA LOSFILENAME and param file
losfilename     = {'phi.r4','theta.r4'}                                           % Full or relative path to phi.r4 and theta.r4 files. MUST BE IN THIS ORDER
parfil          = 'eqa.dem_par'                                                   % InSAR params files with length and width, location information. Can be left as is if not processing GAMMA


faultfilename   = {'fault.mat'};                                              % Full or relative path of the fault file generated with faultMaker
corrfilename    = '';           % Full or relative path to the correlation file. Leave empty to not mask
demfilename     = '';
savestructname  = '170817-170910_p122.mat';                                      % Desire outputfile name
% savexyname      = '';  %Output ascii xyfile name (or null)                  
processor       = 'GAMMA';                                                   % Can be 'ISCE', 'ROIPAC', or 'GMT'. GMT inputs should be converted to .xyz files prior to running using grd2xyz
nx              = 0;                                                        % Image width, only needs to be defined for GMT files
ny              = 0;                                                        % Image length, only needs to be defined for GMT files

corThresh       = 0.2;                                                      % Correlation/coherence threshold for masking, between 0-1
zone            = 0;                                                    % UTM zone; zone = 0 forces data loading to check zone
azo             = 0;                                                        % 1 if using azimuth offsets instead of interferogram
const_los       = 0;                                                        % if no los file (may be broken)
limitny         = 0;                                                        % option in load_any_data -usually 0
minhgt          = 200;                                                      % hgt cutoff to use in hgt scaling (only if demfile is set)
maskdist        = 5e3;                                                      % distance around fault trace to mask data, m

%The following values can generally be left as-is and are related to the
%starting model
Lp              = 10;                                                       % Number of patches along-strike in the fault model
Wp              = 10;                                                       % Number of patches down-dip in the fault model
maxnp           = 2000;                                                     % maximum # points in resampling (could end up as a few more)
smoo            = 0.25;                                                     % Smoothing constant for inversions


getcov          = 2;                                                        % 1 is just diag, 2 estimates full covariance matrix
