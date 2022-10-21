%  Xm = monotonicx(X)
%
%  DESCRIPTION
%  Converts the geographic positions in the horizontal MESHGRID type matrix
%  (or former vector) X into monotonic.
% 
%  MONOTONICX converts X into a monotonic increase version Xm without 
%  altering the order or magnitude of its values. To achieve this, 
%  ISMONOTONIC adds 360 degrees to any value after a non-monotonic 
%  circular jump.
%
%   Example: 
%   Horizontal MESHGRID former vector (X)
%   x = [100 120 140 160 180 200 220 240 260 280 300 320 340 0 20]
%                                                            jump
%   Monotonic version (Xm)
%   x = [100 120 140 160 180 200 220 240 260 280 300 320 340 360 380]
%  
%  INPUT VARIABLES
%  - X: horizontal MESHGRID type matrix or former vector [deg]
%
%  OUTPUT VARIABLES
%  - Xm: horizontal MESHGRID type matrix or former vector (monotonic
%    increase) [deg]
%
%  FUNCTION DEPENDENCIES
%  - ismgrid
%
%  LIBRARY DEPENDENCIES
%  - Grid_Manipulation
%
%  CONSIDERATIONS & LIMITATIONS
%  - MONOTONIC works exclusively with horizontal geodetic data (i.e. longitude
%    values, in degrees).
%  - MONOTONIC and MONOTGEODATA are old versions of MONOTONICX.
%
%  See also ismgrid

%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  31 May 2015

function Xm = monotonicx(X)

if isvector(X) 
    x = X; % former vector of horizontal MESHGRID type matrix
    truemeshx = false;
elseif ismgrid(X,'X')
    x = X(1,:); % former vector of horizontal MESHGRID type matrix
    truemeshx = true;
else
   error('X has to be a MESHGRID ''X'' type matrix or its former vector')
end

% Convert horizontal MESHGRID type matrix (or former vector) into monotonic
Dx = diff(x); % vector of differences
ind = find(Dx < 0,1,'first'); % position of first non-monotonic step
x(ind+1:end) = x(ind+1:end) + 360; % convert horizontal geographic positions into monotonic
if truemeshx
    Xm = repmat(x,size(X,1),1); % monotonic horizontal MESHGRID type matrix
else
    Xm = x; % monotonic horizontal MESHGRID former vector
end      
  