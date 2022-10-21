%  [truegrid,varargout] = isgridvec(x,y)
%
%  DESCRIPTION
%  True if x and y are vectorised grids, i.e. MESHGRID type matrices (X,Y) 
%  strictly monotonic with a constant resolution step that have been converted 
%  into a vector. The data in a vectorised grid must be sorted in the following
%  way (otherwise truegrid = false)
%
%                 'X grid'              'Y grid'
%               x1 x2 ... xN          y1 y1 ... y1
%               x1 x2 ... xN          y2 y2 ... y2
%               (...)                 (...)
%               x1 x2 ... xN          yM yM ... yM
%
%                       'X Grid Vectorised' 
%                     (row or column vector)
%           x1 x2 ... xN x1 x2 ... xN (...) x1 x2 ... xN
%
%                      'Y Grid Vectorised'
%                     (row or column vector)
%           y1 y1 ... y1 y2 y2 ... y2 (...) yM yM ... yM           
%
%  Typical (x,y,z) bathymetry data is provided in the form of three 
%  vectors, whose values correspond to a particular 2D grid. The mission 
%  of ISGRIDVEC is to find out whether or not the (x,y) vectors contain 
%  gridded data. In case they do, ISGRIDVEC returns the dimensions of
%  the grid in order to recover it.
%
%    [truegrid,gridsize] = isgridvec(x,y);
%     M = gridsize(1); % number of rows in (X,Y) grid
%     N = gridsize(2); % number of columns (X,Y) grid
%
%  If truegrid == true, the following three lines of code can be used to 
%  recover the (X,Y,Z) grid from the vectorised data (x,y,z).
%
%     X = reshape(x,N,M)';
%     Y = reshape(y,N,M)';
%     Z = reshape(z,N,M)';
%
%  For more information about what is a 'grid' see help of functions
%  ISMGRID, ISMONOTONIC and ISCSTRES.
%  
%  INPUT VARIABLES
%  - x: vector of longitudes [deg]
%  - y: vector of latitudes [deg]
%  - R (varargin{1}): number of decimal positions that should be used
%    to decide if the different resolution steps are the same. See help
%    in functions ISCSTRES and GRIDRES for more info.
%
%  OUTPUT VARIABLES
%  - truegrid: true if x and y can be rearranged as MESHGRID type grids,
%    of constant resolution and strictly monotonic.
%  - gridsize (varargout{1}): dimensions of the grid in the form [M N],
%    with M and N the number of rows and columns. If (x,y) doesn't contain 
%    grid data gridsize is empty ('[]')
%  - dataprop (varargout{2}): 3 elements logical vector in the form
%    [truemesh truemonot truecstres]
%     ¬ truemesh: true if (x,y) can be rearranged as a MESHGRID grid (X,Y)
%     ¬ truemonot: true if (x,y) can be rearranged as a strictly monotonic
%       MESHGRID grid.
%     ¬ truecstres: true if (x,y) can be rearranged as a constant 
%       resolution MESHGRID grid.
%
%  INTERNALLY CALLED FUNCTIONS
%  - ismgrid
%  - unmeshgrid
%  - ismonotonic
%  - iscstres
%
%  CONSIDERATIONS & LIMITATIONS
%  - ISGRIDVEC works exclusively with geodetic data (i.e. positions in degrees).
%  - ISGRIDVEC only works with vectors. Even if x and y are authentic grids 
%    (isgrid(x,y) == true), ISGRIDVEC will return 'false' 
%
%  FUNCTION CALLS
%  1. isgridvec(x,y)
%     ¬ R = 12
%  2. isgridvec(x,y,R)
%  3. [...] = isgridvec(...)
%  4. truegrid = isgridvec(...)
%  5. [truegrid,gridsize] = isgridvec(...)
%  6. [truegrid,gridsize,dataprop] = isgridvec(...)
%
%  See also ismgrid, unmeshgrid, ismonotonic, iscstres.


%  VERSION 1.3 (3 Jun 2015)
%  - Included variable input argument R (precision factor) to assess correctly 
%    whether or not grid (X,Y) has a constant resolution step.
%
%  VERSION 1.2 (26 May 2015)
%  - Extended the condition 'truecstres = true' from "strictly monotonic 
%    in x and y" to "strictly monotonic increase in x (left-right) and 
%    strictly monotonic decrease in y (up-down)".
%
%  VERSION 1.1 (21 May 2015)
%  - Included function MONOTGEODATA to  make the geodetic data in vector
%    x monotonic.
%
%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  19 Apr 2015

function [truegrid,varargout] = isgridvec(x,y,varargin)

switch nargin
    case {0 1}
        error('Not enough input arguments')
    case 2
        R = 12;
    case 3
        R = varargin{1};
    otherwise
        error('Too many input arguments')
end

truegrid = false;
gridsize = []; 
dataprop = [];

if  isequal(size(x),size(y)) && isvector(x) && isvector(y) % if x and y are vectors the same size then...
    x = x(:); % convert x to column vector
    y = y(:); % convert y to column vector

    % METHOD 1  (with 'seqperiod')
    N = seqperiod(x); % number of columns in the grid
    L = length(x); % length of vector x
    if N < L % if there is more than one period in vector x then...
        M = L/N; % number of rows in the grid
        X = reshape(x,N,M)'; % grid of horizontal data
        Y = reshape(y,N,M)'; % grid of vertical data
        truemesh = ismgrid(X,Y); % true if (X,Y) are MESHGRID type grids
        if truemesh         
            [x,y] = unmeshgrid(X,Y); % get former vectors of X and Y
            truemonot = ismonotonic(x,y); % true if x and y are strictly monotonic
            truecstres = iscstres(x,y,R); % true if x and y have constant resolution step
        else
            truemonot = false;
            truecstres = false;
        end
        truegrid = truemesh && truemonot && truecstres; % true if (x,y) is a grid of constant resolution step and strictly monotonic
        gridsize =[M N]; % size of the expected grid
        dataprop = [truemesh truemonot truecstres]; % logical matrix containing the properties of the grid ('meshtype' grid, monotonic, constant resolution)
    end
end

switch nargout
    case 0
    case 1
    case 2
        varargout{1} = gridsize;
    case 3
        varargout{1} = gridsize;
        varargout{2} = dataprop;
    case 4
        error('Too many output arguments')
end
