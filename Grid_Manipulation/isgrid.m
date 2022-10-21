%  [truegrid,varargout] = isgrid(X,Y,varargin)
%
%  DESCRIPTION
%  True if X and Y are MESHGRID type matrices, with constant resolution step
%  in x and y directions and 'strictly monotonic' former vectors (monotonic 
%  with no repeated values).     
%
%  For more information about what a 'grid' is see help of functions ISMGRID, 
%  ISMONOTONIC and ISCSTRES.
%  
%  INPUT VARIABLES
%  - X: matrix of horizontal geographic positions [deg]
%  - Y: matrix of vertical geographic positions [deg]
%  - R (varargin{1}): number of decimal positions that should be used to decide
%    if the spacing between points is constant (constant resolution step). See
%    help in functions ISCSTRES and GRIDRES for more info.
%
%  OUTPUT VARIABLES
%  - truegrid: true if X and Y are MESHGRID type grids, of constant resolution
%    and strictly monotonic.
%  - dataprop (varargout{1}): 3 elements logical vector in the form [truemesh 
%    truemonot truecstres]
%     ¬ truemesh: true if (X,Y) is a MESHGRID type grid
%     ¬ truemonot: true if (X,Y) is a strictly monotonic MESHGRID grid
%     ¬ truecstres: true if (X,Y) is a constant resolution MESHGRID grid
%
%  FUNCTION DEPENDENCIES
%  - ismgrid
%  - unmeshgrid
%  - ismonotonic
%  - iscstres
%
%  LIBREARY DEPENDENCIES
%  - Grid_Manipulation
%
%  FUNCTION CALLS
%  1. isgrid(...)
%  2. [...] = isgrid(X,Y)
%  3. [...] = isgrid(X,Y,R)
%  4. truegrid = isgrid(...)
%  6. [truegrid,dataprop] = isgrid(...)
%
%  CONSIDERATIONS & LIMITATIONS
%  - ISGRID works exclusively with geographic data (i.e. positions in degrees).
%  - ISGRID only works with matrices. Even if X and Y are authentic 
%    vectorised grids (isgridvec(x,y) == true), ISGRID will return 'false'.
%
%  See also ismgrid, unmeshgrid, ismonotonic, iscstres

%  VERSION 2.4 (3 Jun 2015)
%  - Included variable input argument R (precision factor) to assess
%    correctly whether or not grid (X,Y) has a constant resolution step.
%
%  VERSION 2.3 (26 May 2015)
%  - Extended the condition 'truecstres = true' from "strictly monotonic 
%    in x and y" to "strictly monotonic increase in East direction (left-
%    right) and strictly monotonic decrease in South direction (up-down)".
%
%  VERSION 2.2 (21 May 2015)
%  - Included function MONOTGEODATA to  make the geodetic data in vector
%    x monotonic.
%
%  VERSION 2.1 (19 Apr 2015)
%  - Function modified to deal just with grid matrices
%  - Extended the concept of 'grid'. A grid is now pair of matrices
%    (X,Y) with the same format as the matrices returned by #meshgrid, 
%    whose former row and column are strictly monotonic and with a 
%    constant resolution step in x and y directions.
%  - A new function called #isgridvec has been created to deal with
%    vectors containing gridded data. #isgridvec is the vector version 
%    of #isgrid.
%
%  VERSION 2.0 (17 Apr 2015)
%  - Function updated to deal with both matrices and vectors of grid data
%  - #isgrid now returns the size of the grid as an optional output
%
%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  7 Apr 2015

function [truegrid,varargout] = isgrid(X,Y,varargin)

switch nargin
    case {0 1}
        error('Not enough input arguments')
    case 2
        R = 12; % precision factor
    case 3
        R = varargin{1}; % precision factor
    otherwise
        error('Too many input arguments')
end

if ismgrid(X,Y)         
    [x,y] = unmeshgrid(X,Y); % get former vectors of X and Y
    truemesh = true; % true if (X,Y) are #meshgrid type grids (truemesh = true)
    truemonot = ismonotonic(x,y); % true is x and y are strictly monotonic
    truecstres = iscstres(x,y,R); % true if the #meshgrid type grid (X,Y) have constant resolution
else
    truemesh = false; % true if (X,Y) are #meshgrid type grids (truemesh = false)
    truemonot = false; % true is x and y are strictly monotonic (truemonot = false)
    truecstres = false; % true if the #meshgrid type grid (X,Y) have constant resolution (truecstres = false)
end
truegrid = truemesh && truemonot && truecstres; % true if (X,Y) is a strictly monotonic grid with constant resolution step
dataprop =[truemesh truemonot truecstres]; % logical matrix containing the properties of the grid (#meshgrid type, monotonic, constant resolution)

switch nargout
    case 0
    case 1
    case 2
        varargout{1} = dataprop;
    case 3
        error('Too many output arguments')
end
