%  [P1,P2] = getTransects(soulat,soulon,angles,rangeMax)
%
%  DESCRIPTION
%  Generates the start and end position vectors (P1 and P2) for the specified 
%  radial transects. The end position of each transect is calculated using the 
%  source position $(soulat,soulon), the direction of the transect and its 
%  length or radius. Each transect line, defined by a pair of points 
%  (P1(m),P2(m)),represents one sound propagation path to be modelled. 
%
%  INPUT VARIABLES
%  - soulat: latitude of start point [deg] 
%  - soulon: longitude of start point [deg] 
%  - angles: vector containing the geographic directions of the transects 
%    (0 North, +90 East, -90 West, 180 South) [deg] 
%  - rangeMax: radius of transects (single length) [m]
%
%  OUTPUT VARIABLES
%  - P1: array of start (source) positions of the transects, with one
%    datum (lat,lon) per row ([L,2]) [deg] 
%  - P2: array of end (receiver) positions of the transects, with one
%    datum (lat,lon) per row ([L,2]) [deg] 
%
%  FUNCTION DEPENDENCIES
%  - below360
%  - vincentyDirect
%
%  LIBRARY DEPENDENCIES
%  - Distance_Bearing

%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  3 Apr 2015

function [P1,P2] = getTransects(soulat,soulon,angles,rangeMax)

% Error management
if length(soulat)>1 || length(soulon)>1
    error('Introduce just one source position')
end
if ~isvector(angles) || ~isnumeric(angles)
    error('''angles'' must be a vector of numeric values')
end
if length(rangeMax)>1
    error('More than one distance defined')
end

% Calculate start and end position of each transect
angles = angles(:); % convert to column vector
L = length(angles); % number of transects
soulat = repmat(soulat,L,1); % source latitude vector [deg]
soulon = repmat(soulon,L,1); % source longitude vector [deg]
P1 = [soulat below360(soulon,'deg')]; % matrix of geographic start positions for all transects

[reclat,reclon,~] = vincentyDirect(soulat,soulon,angles,rangeMax); % receiver latitude and longitude vectors [deg]
P2 = [reclat below360(reclon,'deg')]; % matrix of geographic end positions for all transects
