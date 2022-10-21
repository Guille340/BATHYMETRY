%  gres = gridres(A,dir,varargin)
%
%  DESCRIPTION
%  Calculates the resolution step in the x or y directions in a strictly 
%  monotonic MESHGRID type matrix (X or Y) or its former vector. If the
%  resolution step is not constant in the direction specified by input argument
%  DIR, GRIDRES returns the minimum and maximum resolution steps. 
%
%  GRIDRES also calculates the minimum and maximum resolution steps of non-
%  strictly monotonic matrices or vectors of scatter data.
%
%  The typical grid steps are 1 minute or 1/2 minute. These steps, when
%  expressed in degrees, exceed the limited precision of the computer
%  (infinitely periodic figures). The grid positions are rounded either in
%  the original data or when this data is imported into Matlab. It means 
%  that the grid step varies slightly between points and that could be
%  interpreted by #iscstres as non-constant resolution step (TRUECSTRES ==
%  false). The input variable R is included to deal with the limited 
%  numeric precision. The precision factor R indicates the number of 
%  decimal positions that should be used to decide if the different 
%  resolution steps are the same. R has to be selected according to the
%  expected precision of the data in (X,Y). The table below shows the 
%  precision and R values for bathymetry data imported from different
%  sources with READBATHYMETRY and READGEBCOGRID:
%
%   Function            Source          Format         Precision      R
%   ---------------------------------------------------------------------
%   #readBathymetry     'GEBCO'          DEG             10^-n       n-1        
%                                  (n decimal points)
%
%   #readBathymetry     'GEBCO'         DM/DMS         > 3*10^-14     12
%                                                        (double)
%
%   #readBathymetry     'NOAA1'          DEG           > 3*10^-14     12
%                                                        (double)
%
%   #readBathymetry     'NOAA2'         Not applicable (scattered data)!
%
%   #readGebcogrid      'GEBCO'          DEG           > 3*10^-14     12
%                                                        (double)
%  
%  INPUT VARIABLES
%  - A: matrix or vector of longitudes or latitudes [deg]
%  - dir: string specifying in which direction the resolution has to be
%    assessed. There are two options for dir:
%    ¬ 'X': assess resolution in x direction (A contains horizontal
%      geodetic data)
%    ¬ 'Y': assess resolution in y direction (A contrains vertical
%      geodetic data)
%  - R (varargin{1}): number of decimal positions that should be used
%    to decide if the different resolution steps are the same.
%
%  OUTPUT VARIABLES
%  - gres: resolution step in the direction specified by dir [deg]
%
%  FUNCTION DEPENDENCIES
%  - ismgrid
%  - boundaries
%  - shift2angle
%
%  FUNCTION CALLS
%  1. gres = gridres(A,dir)
%     ¬ dir = 'X' or 'Y'
%     ¬ R = 12;
%  2. gres = gridres(A,dir,R)
%     ¬ dir = 'X' or 'Y'
%
%  CONSIDERATIONS & LIMITATIONS%%
%  - GRIDRES works exclusively with geodetic data (i.e. positions in degrees).
%
%  - R is used to decide when different resolution steps can be considered
%    the same, but it doesn't affect to the precision of the returned
%    resolution step gres.
%
%  See also ismgrid, boundaries, shift2angle.

%  VERSION 2.0 (03 Jun 2015)
%  - Performance extended to vectors.
%  - Calculation of resolution step in a single direction x or y.
%  - Corrected the method used to calculate the resolution of matrices or
%    vectors of scatter data.
%
%  VERSION 1.2 (22 May 2015)
%  - Extended the calculation of resolution steps to non-monotonic grids
%   (grids of scattered data)
%
%  VERSION 1.1 (21 May 2015)
%  - Included function #monotgeodata to  make the geodetic data in vector
%    x monotonic.
%  - Corrected a few lines dedicated to return a single high precision
%    resolution step for x and y directions.
%
%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  19 Apr 2015

function gres = gridres(A,dir,varargin)

switch nargin
    case {0 1}
        error('Not enough input arguments')
    case 2
        R = 12; % maximum number of decimal points for gresx and gresy
    case 3
        R = varargin{1};
    otherwise
        error('Too many output arguments')
end

switch dir
    case 'X'       
        if isvector(A)
            a = A; % vector of horizontal positions (scatter or #meshgrid former vector)
        elseif ismgrid(A,'X')
            a = A(1,:); % vector of horizontal positions (#meshgrid former vector)
        else
            a = reshape(A,1,size(A,1)*size(A,2)); % vector of horizontal positions (from scatter matrix)
        end
        
        [a1,~] = boundaries(a,'X'); % left boundary of geographic data in 'a'
        a = shift2angle(a,a1,R); % make angles to increase from 'a1'
        a = sort(a); % monotonic increasing geographic data
   
    case 'Y'
        if isvector(A)
            a = A; % vector of vertical positions (scatter or #meshgrid former vector)
        elseif ismgrid(A,'Y')
            a = A(:,1); % vector of vertical positions (#meshgrid former vector)
        else
            a = reshape(A,1,size(A,1)*size(A,2)); % vector of vertical positions (from scatter matrix)
        end
        
        a = sort(a); % monotonic increasing geographic data
         
    otherwise
        error('Invalid input string for dir')
end 
    
L = length(a); % length of former vector
Da = abs(diff(a)); % resolution steps
Da = round(Da*10^R)*10^-R; % Da rounded to R decimal positions
gres0 = unique([min(Da) max(Da)]); % min and max resolution steps

if numel(gres0) == 1
    gres = (a(end)-a(1))/(L-1); % constant resolution step with increased precision 
else
    gres = gres0; % minimum and maximum resolution step (precision defined by R)
end
     