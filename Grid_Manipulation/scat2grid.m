
function [X,Y,Z] = scat2grid(x,y,z,gres)

%**************************************************************************
%  [X,Y,Z] = scat2grid(x,y,z,gres)
%  
%  DESCRIPTION: Fits scattered data ?(x,y,z) into a grid ?(X,Y,Z) with a 
%  constant resolution step ?gres. #scat2grid uses #gridfit to generate a 
%  smoothed grid from scattered data (#gridfit is not an interpolant).
%  
%  INPUT VARIABLES
%  - x: vector of longitudes (scatter data) [deg]
%  - y: vector of latitudes (scatter data) [deg]
%  - z: vector of magnitude values - depth,temperature,etc (scatter data)
%  - gres: grid resolution step (same for x and y directions) [deg]
%
%  OUTPUT VARIABLES
%  - X: matrix of longitudes (grid data) [deg]
%  - Y: matrix of latitudes (grid data) [deg]
%  - Z: matrix of magnitude values - depth, temperature, etc (grid data)
%
%  INTERNALLY CALLED FUNCTIONS
%  - isgridvec
%  - below360
%  - boundaries
%  - monotonicx
%  - gridfit
%
%  FUNCTION CALLS
%  1) [X,Y,Z] = scat2grid(x,y,z,gres)
%
%  CONSIDERATIONS & LIMITATIONS
%  - #scat2grid works exclusively with geodetic data (i.e. positions in
%    degrees).
%
%  REVISION 1.1 (4 Jun 2015)
%  - Code corrected, simplified and old functions replaced.
%
%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  22 May 2015
%
%**************************************************************************

% Error management (general)
if ~isequal(size(x),size(y),size(z)) || ~isvector(x)
    error('x,y and z must be vectors the same size'); 
end

if isgridvec(x,y)
    warning(['The input vectors (x,y) contain gridded data. The data will ' ...
            'be treated as scattered and resampled using the specified ' ...
            'resolution step.'])
end

if ~isnumeric(gres) || gres <= 0 
    error('The resolution step has to be a positive number (non-zero)')
end

% Ensure (x,y) are expressed in negative degrees format (-180 to +180)
x = below360(x,'deg');
    
% Find boundary limits of scattered data
[xmin,xmax,ymin,ymax] = boundaries(x,y); 

% Error management (is gres > maxgres ?)
maxgresx = below360((xmax-xmin),'deg+'); % maximum admitted resolution step in x
maxgresy = (ymax-ymin); % maximum admitted resolution step in y
maxgres = min([maxgresx maxgresy]); % maximum admitted resolution step
if gres > maxgres
    error('Choose a resolution step gres < %f',maxgres);
end

% Calculate start and end positions in horizontal grid ([x1 x2])
nxsteps = maxgresx/gres; % number of steps in x
Dx = (ceil(nxsteps) - nxsteps)*gres; % extra width for the grid in the horizontal direction
xminmax = monotonicx([xmin xmax]); % degrees format conversion to ensure xmax > xmin
xmin = xminmax(1); % left boundary (modified degrees format) [deg]
xmax = xminmax(2); % right boundary (modified degrees format) [deg]
x1 = xmin - Dx/2; % left x position of the grid (modified degrees format) [deg]
x2 = xmax + Dx/2; % right x position of the grid (modified degrees format) [deg]
gresx = gres; % use original horizontal grid resolution [deg]

% Modify [x1 x2] when x boundaries overlap (unlikely to happen, just when gres > max gap in x)
if (x2 - x1) >= 360 % if new horizontal boundaries (x1,x2) cover more than (or exactly) 360 degrees then ...
    Dx = (nxsteps - fix(nxsteps))*gres; % exceedance width for the grid in the horizontal direction
    x1 = xmin + Dx/2; % left x position of the grid (modified degrees format) [deg]
    x2 = xmax - Dx/2; % right x position of the grid (modified degrees format) [deg]
end

% Extract grid positions in x direction
xq = x1:gresx:x2; % grid positions in x direction (modified degrees format) [deg]
xq = below360(xq,'deg'); % grid positions in x direction (original degrees format) [deg]

% Calculate start and end positions in vertical grid ([y1 y2])
nysteps = maxgresy/gres; % number of steps in y
Dy = (ceil(nysteps) - nysteps)*gres; % extra width for the grid in the vertical direction
y1 = ymin - Dy/2; % bottom y position of the grid [deg]
y2 = ymax + Dy/2; % top y position of the grid [deg]
gresy = gres; % use original vertical grid resolution [deg]

% Modify [y1 y2] when y boundaries exceed vertical limits (unlikely to happen, just when gres > max gap in y)
if (y2 - y1) >= 180 % if new horizontal boundaries (x1,x2) cover more than (or exactly) 180 degrees then ...
    Dy = (nysteps - fix(nysteps))*gres; % exceedance width for the grid in the vertical direction [deg]
    y1 = ymin + Dy/2; % bottom y position of the grid [deg]
    y2 = ymax - Dy/2; % top y position of the grid [deg]
end

% Extract grid positions in y direction
yq = y2:-gresy:y1; % grid positions in y direction [deg]

% Generate grid from scattered data
[X,Y] = meshgrid(xq,yq);
Z = gridfit(x,y,z,xq,fliplr(yq), ...
           'smooth',1, ...
           'interp','triangle', ...
           'solver','normal', ...
           'regularizer','gradient', ...
           'extend','warning', ...
           'tilesize',inf);
Z = flipud(Z);

end
