%  [Xr,Yr,Zr] = resamplegrid(X,Y,Z,interpFactor,varargin) 
%
%  DESCRIPTION
%  Changes the resolution of a bathymetry grid Z based on the specified 
%  interpolation factor interpFactor.
%
%  RESAMPLEGRID generates an interpolated version of (X,Y,Z) when 
%  interpFactor > 1 and a decimated version when interpFactor < 1. In the last
%  case, RESAMPLEGRID applies a mask to reduce the high frequency energy to 
%  avoid spatial aliasing (see help in GETMASK, GETMASKSIZE, MFUNRECTWIN and
%  MFUNHANNING for more information about the 2D mask).
%
%  The numeric precision of the position values in (X,Y) affects the 
%  ability to decide whether or not (X,Y) uses a constant resolution step, 
%  and thus whether (X,Y) is a 'grid' or not (see ISGRID for the 
%  definition of 'grid'). The precision factor R is included as input 
%  argument to deal with that uncertainty due to the finite precision of 
%  the position data.
%
%  INPUT VARIABLES
%  - X: original 'grid' of longitudes [deg]
%  - Y: original 'grid' of latitudes [deg]
%  - Z: original 'data grid' of depths [m]
%  - interpFactor: interpolation factor (interpFactor = gres0/gres, with gres0 
%    and gres the resolution steps of the input and output grids). 
%      1. interpFactor > 1: (Xr,Yr,Zr) is an interpolated version of (X,Y,Z)
%      2. interpFactor < 1: (Xr,Yr,Zr) is a decimated version of (X,Y,Z)
%      3. interpFactor = 0: (Xr,Yr,Zr) = (X,Y,Z)
%  - R (varargin{1}): number of decimal positions that should be used
%    to decide if the different resolution steps are the same, and thus to
%    decide whether (X,Y) is a 'grid' or not. See ISCSTRES and GRIDRES 
%    for more info.
%  - fctype (varargin{2}): amplitude response of the filter at the maximum 
%    frequency of new grid fc (1/2gres). Three options available
%    ¬ fctype = 0 -> 1st null (-inf dB) of the filter response at fc
%    ¬ fctype = 1 -> -6dB of the filter response at fc
%    ¬ fctype = 2 -> -3dB of the filter response at fc
%  - winname (varargin{3}): type of window mask. Two options:
%    ¬ 'rectwin': rectangular window mask
%    ¬ 'hanning': hanning window mask
%
%  OUTPUT VARIABLES
%  - Xr: resampled 'grid' of longitudes [deg]
%  - Yr: resampled 'grid' of latitudes [deg]
%  - Zr: resampled 'data grid' of depths [m]
%
%  FUNCTION DEPENDENCIES
%  - gridres
%  - getmask
%  - monotonicx
%  - below360
%
%  LIBRARY DEPENDENCIES
%  - Grid_Manipulation
%  - Grid_Filtering
%
%  FUNCTION CALLS
%  1. [Xr,Yr,Zr] = resamplegrid(X,Y,Z,interpFactor)
%     R = 12, fctype = 1, winname = 'rectwin'
%  2. [Xr,Yr,Zr] = resamplegrid(X,Y,Z,interpFactor,R)
%     fctype = 1, winname = 'rectwin'
%  3. [Xr,Yr,Zr] = resamplegrid(X,Y,Z,interpFactor,R,fctype)
%     winname = 'rectwin'
%  4. [Xr,Yr,Zr] = resamplegrid(X,Y,Z,interpFactor,R,fctype,winname)
%
%  CONSIDERATIONS & LIMITATIONS
%  - (X,Y) has to be a 'grid' and Z its corresponding 'data grid'. 'grid'
%    is a pair of MESHGRID type matrices (X,Y) with constant resolution 
%    step and strictly monotonic. The 'data grid' Z contains the values 
%    of a particular magnitude (depth, temperature,...) at each position 
%    of the 'grid' (X,Y).
%
%  - The value for input parameter R in GRIDRES and ISGRID has to be 
%    selected according to the expected precision of grid (X,Y) (see 
%    GRIDRES).
%
%  - RESAMPLEGRID works exclusively with geodetic data (i.e. longitudes
%    and latitudes, in degrees).

%  REVISION 1.1 (5 Jun 2015)
%  - Code simplified.
%  - Added precision factor R as variable input argument. 
%
%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  7 Apr 2015

function [Xr,Yr,Zr] = resamplegrid(X,Y,Z,interpFactor,varargin)

switch nargin
    case {0 1 2 3}
        error('Not enough input arguments')
    case 4
        R = 12; % precision factor of 12 decimal positions
        fctype = 1; % 6 dB filter attenuation at fs/2
        winname = 'rectwin'; % rectangular window
    case 5 
        R = varargin{1}; % precision factor
        fctype = 1; % 6 dB filter attenuation at fs/2
        winname = 'rectwin'; % rectangular window
    case 6
        R = varargin{1}; % precision factor
        fctype = varargin{2}; % filter attenuation at fs/2
        winname = 'rectwin'; % rectangular window
    case 7
        R = varargin{1}; % precision factor
        fctype = varargin{2}; % filter attenuation at fs/2
        winname = varargin{3}; % window type
    otherwise
        error('Too many input arguments')
end

% Error management
if ~isgrid(X,Y,R) || ~isequal(size(X),size(Y),size(Z))
    error('X,Y,Z have to be matrices of gridded data')
end
 
% Interpolation/Decimation Stage (General)
gres0x = gridres(X,'X',R); % horizontal resolution of original grid [deg]
gres0y = gridres(Y,'Y',R); % vertical resolution of original grid [deg]
gres0 = (gres0x + gres0y)/2; % resolution step of original grid [deg]
gres = gres0/interpFactor; % resolution step of output grid
fs0 = 1/gres0; % sampling frequency of original grid
fs = 1/gres; % sampling frequency of future resampled grid
Xr = X; % iniitalise Xr
Yr = Y; % initialise Yr
Zr = Z; % initialise Zr

% Interpolation/Decimation Stage (Procesing)
if interpFactor ~= 1 % if the interpolation factor is not 1 then ...
    if fs < fs0 % if fs < fs0 then apply the 2D mask
        mask = getmask(fs0,fs,fctype,winname); % build 2D filtering mask
        Zc = conv2(Z,mask); % convolved grid
        L = length(mask); % number of rows or columns in the square 2D mask
    else % if fs > fs0  then do not apply the 2D mask
        Zc = Z;
        L = 1; % mask of 1 element (mask = [1])
    end

    [M,N] = size(X); % size of matrices (X,Y,Z)
    Mc = M+L-1; % number of rows in convolved grid
    Nc = N+L-1; % number of columns in convolved grid
    Mr = floor((M-1)*interpFactor + 1); % number of rows in new (resampled) grid
    Nr = floor((N-1)*interpFactor + 1); % number of columns in new (resampled) grid
    m1 = (Mc-1)/2 - (Mr-1)/(2*interpFactor) + 1; % starting row position in convolved grid
    m2 = (Mr-1)/interpFactor + m1; % final row position in convolved grid
    n1 = (Nc-1)/2 - (Nr-1)/(2*interpFactor) + 1; % starting column position in convolved grid
    n2 = (Nr-1)/interpFactor + n1; % final column position in convolved grid

    % Generate resampled 'data grid' Zr
    xqz = n1:1/interpFactor:n2; % interpolating horizontal positions for the 'data grid'
    yqz = m1:1/interpFactor:m2;  % interpolating vertical positions for the 'data grid'
    [Xqz,Yqz] = meshgrid(xqz,yqz); % grid of interpolating positions for the 'data grid'
    Zr = interp2(Zc,Xqz,Yqz); % resampled 'data grid'

    % Generate resampled 'grid' (Xr,Yr)
    xq = xqz - (L-1)/2; % interpolating horizontal positions for the 'grid'
    yq = yqz - (L-1)/2; % interpolating vertical positions for the 'grid'
    [Xq,Yq] = meshgrid(xq,yq); % grid of interpolating positions for the 'grid'
    Xm = monotonicx(X); % monotonic version of X
    Xr = interp2(Xm,Xq,Yq); % interpolate using monotonic version of X
    Xr = below360(Xr,'deg');  % back to signed degrees (-180 to 180) - resampled horizontal 'grid'
    Yr = interp2(Y,Xq,Yq); % resampled vertical 'grid'
end

