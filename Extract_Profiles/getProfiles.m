%  [xp,yp,zp,varargout] = getProfiles(X,Y,Z,P1,P2,rangeStep,varargin)
%
%  DESCRIPTION
%  Extracts from a (X,Y,Z) bathymetry grid the bathymetry profiles for all 
%  transects defined by start point vector P1 (source) and end point vector 
%  P2 (receiver).
%
%  The resolution step of the bathymetry profiles is defined by input
%  argument rangeStep. When the selected resolution step for the transects is
%  higher than the resolution step of the bathymetry grid (rangeStep > gresx), 
%  a 2D mask has to be used to reduce the high frequency energy in the 
%  grid and thus avoid spatial aliasing. See #getmasksize, #getmask,
%  #mfunrectwin and #mfunhanning for more info about the 2D mask.
%
%  INPUT VARIABLES
%  - X: 'grid' of longitudes [deg]
%  - Y: 'grid' of latitudes [deg]
%  - Z: 'grid' of depths [m]
%  - P1: array of start (source) positions of the transects, with one
%    datum (lat,lon) per row ([L,2]) [deg] 
%  - P2: array of end (receiver) positions of the transects, with one
%    datum (lat,lon) per row ([L,2]) [deg] 
%  - rangeStep: resolution step for the transects [m]
%  - transmode (varargin{1}): string specifying the distribution of points
%    within the transect. Two options available:
%    ¬ 'normal': points in the transect are evenly spaced a distance rangeStep. 
%       The last point in the transect may not reach the receiver point 
%       P2(end,:).
%    ¬ 'adjust': points in the transect are evenly spaced a distance d0,
%      different than rangeStep. The last point in the transect matches the
%      receiver point P2(end,:).
%  - R (varargin{2}): number of decimal positions that should be used
%    to decide if the different resolution steps are the same, and thus to
%    decide wheter (X,Y) is a 'grid' or not. See #iscstres and #gridres 
%    for more info.
%  - fctype (varargin{3}): amplitude response of the filter at the maximum
%    frequency of the transect grid fc2 (1/2d). Three options available:
%    ¬ fctype = 0 -> 1st null (-inf dB) of the filter response at fc2
%    ¬ fctype = 1 -> -6dB of the filter response at fc2
%    ¬ fctype = 2 -> -3dB of the filter response at fc2
%  - winname (varargin{4}): type of window mask. Two options:
%    ¬ 'rectwin': rectangular window mask
%    ¬ 'hanning': hanning window mask
%
%  OUTPUT VARIABLES
%  - xp: cell array of longitudes (one cell for each transect) [deg]
%  - yp: cell array of latitudes (one cell for each transect) [deg]
%  - zp: cell array of depths (one cell for each transect) [m]
%  - dp (varargout{1}): cell array of distances (one cell for each 
%    transect) [m]
%
%  FUNCTION CALLS
%  1) [xp,yp,zp] = getProfiles(X,Y,Z,P1,P2,rangeStep)
%     ¬ transmode = 'normal'
%     ¬ R = 12
%     ¬ fctype = 1
%     ¬ winname = 'rectwin'
%  2) [xp,yp,zp] = getProfiles(X,Y,Z,P1,P2,rangeStep,transmode)
%     ¬ R = 12
%     ¬ fctype = 1
%     ¬ winname = 'rectwin'
%  3) [xp,yp,zp] = getProfiles(X,Y,Z,P1,P2,rangeStep,transmode,R)
%     ¬ fctype = 1
%     ¬ winname = 'rectwin'
%  4) [xp,yp,zp] = getProfiles(X,Y,Z,P1,P2,rangeStep,transmode,R,fctype)
%     ¬ winname = 'rectwin'
%  5) [xp,yp,zp] = getProfiles(X,Y,Z,P1,P2,rangeStep,transmode,R,fctype,winname)
%
%  FUNCTION DEPENDENCIES
%  - monotonicx
%  - boundaries
%  - shift2angle
%  - vincenty
%  - vincentyDirect
%  - gridres
%  - getmask
% 
%  LIBRARY DEPENDENCIES
%  - Grid_Manipulation
%  - Grid_Filtering
%  - Distance_Bearing
%  
%  CONSIDERATIONS & LIMITATIONS
%  - (X,Y) has to be a 'grid' and Z its corresponding 'data grid'. 'grid' 
%    is a pair of #meshgrid type matrices (X,Y) with constant resolution
%    step and strictly monotonic. The 'data grid' Z contains the values 
%    of a particular magnitude (depth, temperature,...) at each position
%    of the 'grid' (X,Y).
%
%  - The value for input parameter R in #isgrid has to be selected
%    according to the expected precision of grid (X,Y) (see #gridres).
%
%  - The anti-aliasing mask used for the extraction of bathymetry profiles
%    has a particularity: its low cut frequency decreases, and thus size 
%    increases (especially in its x dimension), at latitudes far from the
%    equator. The cause of this change in size and shape of the mask at
%    different latitudes is the use a constant distance step (rangeStep [m]) for 
%    the transects and a constant angular step (gres [deg]) for the grid; 
%    at higher absolute latitudes the same distance rangeStep covers a higher 
%    longitude range. Hence areas far from the equator are more liable to 
%    require low frequency filtering than those close to it.
%
%  - #getProfiles works exclusively with geodetic data (i.e. longitudes 
%    and latitudes, in degrees).
%
%  See also monotonicx, boundaries, shift2angle, vincenty, vincentyDirect,
%  gridres, getmask

%  REVISION 1.2 (19 Feb 2021)
%  - Convert array of depths Z to float if integer.
%
%  REVISION 1.1 (7 Jun 2015)
%  - Included variable input argument dp, a cell array containing the 
%    distances to the source for all transects (one transect per cell).
%
%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  5 Jun 2015

function [xp,yp,zp,varargout] = getProfiles(X,Y,Z,P1,P2,rangeStep,varargin)

switch nargin
    case {0 1 2 3 4 5} 
        error('Not enough input arguments');
    case 6
        transmode = 'normal';
        R = 12;
        fctype = 1;
        winname = 'rectwin';
    case 7
        transmode = varargin{1};
        R = 12;
        fctype = 1;
        winname = 'rectwin';
    case 8 
        transmode = varargin{1};
        R = varargin{2};
        fctype = 1;
        winname = 'rectwin';
    case 9
        transmode = varargin{1};
        R = varargin{2};
        fctype = varargin{3};
        winname = 'rectwin';
    case 10
        transmode = varargin{1};
        R = varargin{2};
        fctype = varargin{3};
        winname = varargin{4};
    otherwise
        error('Too many input arguments')
end
                      
% Error management (general)
if ~isgrid(X,Y,R) || ~isequal(size(X),size(Y),size(Z))
    error('X,Y,Z have to be matrices of gridded data')
end
if ~isequal(size(P1),size(P2)) || size(P1,2)~=2
    error('P1 and P2 must be two column arrays of the same size')
end

% Convert Depth to Float if Integer
if isa(Z,'integer'), Z = single(Z); end   

% Definitions
soulat = P1(:,1); % source latitudes vector [K,1] [deg]
soulon = P1(:,2); % source longitudes vector [K,1] [deg]
reclat = P2(:,1); % receiver latitudes vector [K,1] [deg]
reclon = P2(:,2); % receiver longitudes vector [K,1] [deg]
K = length(soulat); % number of bathymetry transects

% Normalise angles in 'grid' (X,Y)
X = monotonicx(X);

% Boundaries in 'grid' (X,Y)
[minlon,maxlon,minlat,maxlat] = boundaries(X,Y);

% Normalise angles in scatter positions P1,P2
soulon = shift2angle(soulon,minlon);
reclon = shift2angle(reclon,minlon);

% Boundaries in 'scatter' dataset P1,P2
[minlon0,maxlon0,minlat0,maxlat0] = boundaries([soulon;reclon],[soulat;reclat]); % boundary limits of the set of bathymetry transects

% Error management (do transects exceed the bathymetry limits?)
if minlon0 < minlon || maxlon0 > maxlon || minlat0 < minlat || maxlat0 > maxlat
    error(['\nSome of the bathymetry profiles exceed the limits of the '...
        'bathymetry grid.\nThe bathymetry grid must cover at least the '...
        'area delimited by:\nxmin=%0.10f \nxmax=%0.12f \nymin=%0.12f \n'...
        'ymax=%0.12f'],minlon0,maxlon0,minlat0,maxlat0);
end

% Define D, bea1, P and rangeStep
[maxRanges,bea1,~] = vincenty(soulat,soulon,reclat,reclon); % P1-P2 distance and bearing [K,1]
switch transmode
    case 'normal'
        nPoints = floor(maxRanges/rangeStep) + 1; % number of points in each bathymetry transect [K,1]
        rangeStep = repmat(rangeStep,K,1); % sampling distance for each pair P1-P2 [K,1]
    case 'adjust'
        nPoints = round(maxRanges/rangeStep) + 1; % number of points in each bathymetry transect [K,1]
        rangeStep = maxRanges./(nPoints-1); % sampling distance for each pair P1-P2 [K,1]
    otherwise
        error('Invalid string for transmode input argument');
end

% Error management (does P exceed the maximum number of points allowed in a *.bty file?)
maxPoints_actup = 99; % maximum number of points admitted in AcTUP bathymetry files *.bty - 99 points
maxPoints = max(nPoints); % maximum number of points from the largest transect line
if maxPoints > maxPoints_actup
    warning(['\nThe number of points in some of the transects exceed the '...
        'maximum number of points that can be stored in an AcTUP *.bty '...
        'file. Use a resolution step rangeStep > %0.3f [m]'],...
        max(maxRanges)/maxPoints_actup);
end

% Generate bathymetry transects (lines of query points)
xp = cell(1,K); % initialise cell of horizontal positions (one cell per transect) {1,K}
yp = cell(1,K); % initialise cell of vertical positions (one cell per transect) {1,K}
for k = 1:K
    dv = (0:rangeStep(k):maxRanges(k))'; % vector of distances [P(k),1]
    [yp0,xp0,~] = vincentyDirect(soulat(k),soulon(k),bea1(k),dv,'off'); % geodetic positions in transect k
    xp{k} = xp0; % geodetic horizontal positions in transect k
    yp{k} = yp0; % geodetic vertical positions in transect k
end

% Calculate source distance for each point in the transects dp (if requested)
if nargout == 4
    dp = cell(1,K);
    for k = 1:K
        dp{k} = (0:rangeStep(k):maxRanges(k))';
    end
end

% Calculate cut-off frequencies fsx and fsy for the filtering mask
maxd = max(rangeStep); % maximum resolution step in the set of transect lines
[~,lon1,~] = vincentyDirect(minlat,0,90,maxd);
[~,lon2,~] = vincentyDirect(maxlat,0,90,maxd);
gresx = (lon1 + lon2)/2; % spatially averaged horizontal resolution step for transects [deg]

[lat1,~] = vincentyDirect(minlat,0,0,maxd);
[lat2,~] = vincentyDirect(maxlat,0,0,maxd);
gresy = ((lat1-minlat) + (lat2-maxlat))/2; % spatially averaged vertical resolution step for transects [deg]

gres0x = gridres(X,'X',R); % horizontal resolution step of original grid [deg]
gres0y = gridres(Y,'Y',R); % vertical resolution step of original grid [deg]
gres0 = (gres0x + gres0y)/2; % resolution step of original grid [deg]

fs0 = 1/gres0; % sampling frequency of original grid [deg-1]
fsx = 1/gresx; % spatially averaged horizontal sampling frequency for the bathymetry transects [deg-1]
fsy = 1/gresy; % spatially averaged vertical sampling frequency for the bathymetry transects [deg-1]

% Generate filtered grid (Xc,Yc,Zc)    
Xc = X; % initialise horizontal 'grid' for convolved 'data grid' Zc
Yc = Y; % initialise vertical 'grid' for convolved 'data grid' Zc
Zc = Z; % initialise 'data grid'

if (fsx < fs0) || (fsy < fs0) % apply mask
    mask = getmask(fs0,[fsx fsy],fctype,winname); % build 2D filtering mask
    [Ly,Lx] = size(mask); % number of rows or columns in the 2D mask
    [M,N] = size(X); % number of rows or columns in grid (X,Y)
    Mc = M+Ly-1; % number of rows in convolved grid
    Nc = N+Lx-1; % number of columns in convolved grid
    xc1 = X(1,1); % start position of Xc former vector
    yc1 = Y(1,1); % start position of Yc former vector
    xc2 = xc1 + gres0*(Nc-1); % end position of Xc former vector
    yc2 = yc1 - gres0*(Mc-1); % end position of Yc former vector
    xc = xc1: gres0:xc2; % Xc former vector
    yc = yc1:-gres0:yc2; % Yc former vector
    [Xc,Yc] = meshgrid(xc,yc); % provisional position grid (Xc,Yc) for convolved data grid Zc
    
    Xc = Xc - gres0*(Lx-1)/2; % 'grid' of longitudes for the convolved 'data grid' Zc
    Yc = Yc + gres0*(Ly-1)/2; % 'grid' of latitudes for the convolved 'data grid' Zc
    Zc = conv2(Z,mask); % convolved 'data grid'
end

% Extract bathymetry profiles for each transect
zp = cell(1,K);
for k = 1:K
    zp{k} = interp2(Xc,Yc,Zc,xp{k},yp{k});
end

% Assign variable output arguments
switch nargout
    case {0 1 2}
        error('Not enough output arguments')
    case 3
    case 4
        varargout{1} = dp;
    otherwise
        error('Too many output arguments')
end
