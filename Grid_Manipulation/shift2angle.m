%  Xsh = shift2angle(X,xmin)
%
%  DESCRIPTION
%  Applies a circular shift to make all longitude values in X higher than the 
%  reference longitude XMIN. 
%
%  XMIN is the left limit of a set of geodetic points obtained with BOUNDARIES:
%  the purpose of SHIFT2ANGLE is give format to the longitude values in X so 
%  that they can be sorted in ascending order, from west to east limits.
%
%  INPUT VARIABLES
%  - X: vector or matrix of longitudes [deg]
%  - xmin: west limit of the geographic data in X [deg] (see BOUNDARIES)
%  - R (varargin{1}): number of decimal positions that should be used
%    to decide if the different resolution steps are the same.
%
%  OUTPUT VARIABLES
%  - Xsh: vector or matrix of longitudes where all values are > XMIN
%
%  FUNCTION DEPENDENCIES
%  - below360
%
%  LIBRARY DEPENDENCIES
%  - Grid_Manipulation
%
%  CONSIDERATIONS & LIMITATIONS
%  - SHIFT2ANGLE works exclusively with geodetic data (i.e. positions in
%    degrees).
%
%  See also below360

%  VERSION 1.1 (19 Feb 2021)
%  - Added input precision factor R to address error in find(X < xmin)
%    caused by a slight difference between X(1) and xmin that shouldn't exist.
%
%  VERSION 1.0: 31 May 2015
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com

function Xsh = shift2angle(X,xmin,varargin)

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

if (xmin >= -180) && (xmin < 0)
    X = below360(X,'deg');
elseif (xmin >= 0) && (xmin < 360)
    X = below360(X,'deg+');
else
    error('The start angle xmin has to be within these limits: -180 <= xmin < 360')
end

Xr = round(X*10^R)*10^-R; % rounded version of X
xrmin = round(xmin*10^R)*10^-R; % rounded version of xmin
ind = find(Xr < xrmin);
X(ind) = X(ind) + 360;
Xsh = X;
