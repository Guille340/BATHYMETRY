%  [xr,yr,zr] = reshapesvecgmat(x,y,z,varargin)
%
%  DESCRIPTION
%  Reshapes scattered data into a vector and gridded data into a matrix. The 
%  purpose of RESHAPESVECGMAT is to provide the data with the correct format
%  before further processing is done (e.g. interpolation).
%
%  This function will return either 3 vectors of scattered data or 3 
%  matrices of gridded data.(x,y,z) vectors of gridded data are converted
%  into matrices and (x,y,z) matrices of scattered data are converted into 
%  vectors. RESHAPESVECGMAT takes no action (xr = x,yr = x,zr = z) when (x,y,z) 
%  are vectors of scattered data or matrices of gridded data. The returned 
%  arguments (xr,yr,zr) will always be vectors or matrices the same size.
%
%  The numeric precision of the position values in (x,y) affects the ability 
%  to decide whether or not a set of gridded data uses a constant resolution 
%  step, and thus whether (x,y) is a 'grid' or not. The precision factor R is 
%  included as input argument to deal with that uncertainty due to the finite 
%  precision of the data.
%  
%  INPUT VARIABLES
%  - x: vector or array of longitudes (scatter/grid) [deg]
%  - y: vector or array of latitudes (scatter/grid) [deg]
%  - z: matrix or vector of magnitude values -depth, temperature, etc 
%   (scatter/gridd)
%  - R (varargin{1}): number of decimal positions that should be used
%    to decide if the spacing between points is constant (constant 
%    resolution step). See help in functions #iscstres and #gridres for 
%    more info.
%
%  OUTPUT VARIABLES
%  - xr: longitude ('grid' or vector of scatter data)  
%  - yr: latitude ('grid' or vector of scatter data)  
%  - zr: magnitude -depth, temp., etc ('grid' or vector of scatter data)
%
%  FUNCTION DEPENDENCIES
%  - isgridvec
%  - isgrid
%
%  LIBRARY DEPENDENCIES
%  - Grid_Manipulation
%
%  FUNCTION CALLS
%  1. [xr,yr,zr] = reshapesvecgmat(x,y,z)
%     ¬ R = 12;
%  2. [xr,yr,zr] = reshapesvecgmat(x,y,z,R)
%
%  CONSIDERATIONS & LIMITATIONS
%  - RESHAPESVECGMAT works exclusively with geodetic data (i.e. positions
%    in degrees).
%
%  - The term 'grid' refers to a pair of #meshgrid type matrices (X,Y) with 
%    constant resolution step and strictly monotonic (see #isgrid for details). 
%    A 'data grid' Z contains the values of a particular magnitude 
%    (temperature,depth...) at each position of the 'grid' (X,Y).
%
%  See also isgrid, isgridvec

%  VERSION 1.1 (5 Jun 2015)
%  - Code simplified.
%  - Added precision factor R as variable input argument. 
%
%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  20 Apr 2015

function [xr,yr,zr] = reshapesvecgmat(x,y,z,varargin)

switch nargin
    case {0 1 2}
        error('Not enough input arguments')
    case 3
        R = 12; % precision factor
    case 4
        R = varargin{1}; % precision factor
    otherwise
        error('Too many input arguments')
end

% Error Management
if ~isequal(size(x),size(y),size(z))
    error('x0,y0 and z0 must be matrices or vectors the same size'); 
end

% Initialise outputs
xr = x; 
yr = y; 
zr = z;

% Reshape Input Data (x,y,z)
if isvector(x) % if x,y and z are vectors then ...
    [truegridvec,gridsize]=isgridvec(x,y,R);
    if truegridvec % if (x,y) is a vectorised grid then ...
        M = gridsize(1); % number of rows in the grid
        N = gridsize(2); % number of columns in the grid
        xr = reshape(x,N,M)'; % horizontal geodetic positions ('grid')
        yr = reshape(y,N,M)'; % vertical geodetic positions ('grid')
        zr = reshape(z,N,M)'; % depth values ('data grid')
    end
else % if x,y and z are matrices then...
    truegrid = isgrid(x,y,R);
    if ~truegrid % (x,y) is a matrix of scattered data then ...
        [M,N] = size(x); % size of x,y and z matrices
        xr = reshape(x',M*N,1); % horizontal geodetic positions (column vector of scatter data)
        yr = reshape(y',M*N,1); % vertical geodetic positions (column vector of scatter data)
        zr = reshape(z',M*N,1); % depth values (column vector of scatter data)
    end     
end
