%  varargout = boundaries(A,varargin)
%
%  DESCRIPTION
%  Finds the geographic boundaries in matrix (or vector) of geographic 
%  positions A, in the direction specified by input argument DIR (varargin{1}).
%  BOUNDARIES admits any matrix or vector of gridded or scattered data.
%
%  BOUNDARIES can also calculate the horizontal and vertical limits of 
%  full grid (A,B) in just one call. 
%  
%  BOUNDARIES determines the spatial distribution of the cluster of geographic 
%  data points in A or (A,B) and extracts its limits in the horizontal 
%  ([x1 x2]) and/or vertical ([y1 y2]) directions.
%
%  INPUT VARIABLES
%  - A: matrix (or vector) of longitudes or latitudes [deg]
%  - B (varargin{1}): matrix (or vector) of latitudes [deg]
%  - dir (varargin{1}): string specifying in which direction the geographic 
%    limits of matrix (or vector) A must be calculated. There are two options:
%    ¬ 'X': calculte geographic limits in x direction (A contains
%      horizontal geodetic data)
%    ¬ 'Y': calculate geographic limits in y direction (A contains
%      vertical geodetic data)
%  - R (varargin{2}): number of decimal positions that should be used to decide 
%    if the different resolution steps are the same.
%
%  OUTPUT VARIABLES (variable output arguments)
%  - x1: left geographic limit of matrix (or vector) of x positions [deg]
%  - x2: right geographic limit of matrix (or vector) of x positions [deg]
%  - y1: bottom geographic limit of matrix (or vector) of y positions [deg]
%  - y2: top geographic limit of matrix (or vector) of y positions [deg]
%
%  FUNCTION DEPENDENCIES
%  - ismgrid
%  - below360
%
%  LIBRARY DEPENDENCIES
%  - Grid_Manipulation
%
%  FUNCTION CALLS
%  1. [x1,x2] = boundaries(A,dir)
%     ¬ dir = 'X'
%     ¬ R = 12
%  2. [y1,y2] = boundaries(Y,'Y')
%     ¬ dir = 'Y'
%     ¬ R = 12
%  3. [x1,x2,y1,y2] = boundaries(X,Y)
%     ¬ R = 12
%  4. [...] = boundaries(...,R)
%
%  CONSIDERATIONS & LIMITATIONS
%  - BOUNDARIES works exclusively with geodetic data (i.e. positions in
%    degrees).
%
%  - The precision factor R is included to accurately calculate the horizontal
%    limits [x1 x2] of large constant resolution grids, where GRES >= non 
%    covered area.
%
%  - LOCCLUSTER is an old version of BOUNDARIES
%
%  See also imgrid, below360

%  VERSION 2.0 (04 Jun 2015)
%  - Performance extended to matrices, single direction and gridded data
%    (not only paired vectors of scatter data (x,y)).
%
%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  21 May 2015

function varargout = boundaries(A,varargin)

switch nargin
    case {0 1}
        error('Not enough input arguments')
    case 2
        if ischar(varargin{1})
            dir = varargin{1};
            nout = 2; % number of generated output arguments
        else 
            dir = 'XY';
            nout = 4; % number of generated output arguments
        end
        R = 12; % precision factor
    case 3
        if ischar(varargin{1})
            dir = varargin{1};
            nout = 2; % number of generated output arguments
        else 
            dir = 'XY'; 
            nout = 4; % number of generated output arguments
        end
        R = varargin{2}; % precision factor
    otherwise
        error('Too many input arguments')
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
        
        % Calculate horizontal boundaries
        a = a(:); % convert x to column vector
        a = sort(a); % sort a in ascending order
        gap = below360(diff([a(end); a]),'deg+'); % spacing between consecutive points
        gap = round(gap*10^R)*10^-R; % reduce precision of gap (case of full grid, from 180W to 180E)
        [~,ind] = max(gap); % maximum gap between points in x direction
        if ind == 1 % if maximum gap is between the last and first horizontal sample
            a1 = a(1);
            a2 = a(end);
        else % if maximum gap is between the first and last horizontal sample
            a1 = a(ind+1);
            a2 = a(ind);
        end
        
    case 'Y'
        if isvector(A)
            a = A; % vector of vertical positions (scatter or #meshgrid former vector)
        elseif ismgrid(A,'Y')
            a = A(:,1); % vector of vertical positions (#meshgrid former vector)
        else
            a = reshape(A,1,size(A,1)*size(A,2)); % vector of vertical positions (from scatter matrix)
        end
        
        % Calculate vertical boundaries
        a1 = min(a);
        a2 = max(a);
               
    case 'XY'
        B = varargin{1};
        if isvector(A) && isvector(B)
            a = A; % former vector of horizontal #meshgrid type matrix
            b = B; % former vector of vertical #meshgrid type matrix
        elseif ismgrid(A,B) && isequal(size(A),size(B))
            a = A(1,:); % former vector of horizontal #meshgrid type matrix
            b = B(:,1); % former vector of vertical #meshgrid type matrix
        elseif isequal(size(A),size(B))
            a = reshape(A,1,size(A,1)*size(A,2)); % vector of horizontal positions (from scatter matrix)
            b = reshape(B,1,size(B,1)*size(B,2)); % vector of vertical positions (from scatter matrix)
        else
            error('1st and 2nd input arguments have to be matrices the same size or vectors')   
        end
        
        % Calculate horizontal boundaries
        a = a(:); % convert x to column vector
        a = sort(a); % sort a in ascending order
        gap = below360(diff([a(end); a]),'deg+'); % spacing between consecutive points
        gap = round(gap*10^R)*10^-R; % reduce precision of gap (case of full grid, from 180W to 180E)
        [~,ind] = max(gap); % maximum gap between points in x direction
        if ind == 1 % if maximum gap is between the last and first horizontal sample
            a1 = a(1);
            a2 = a(end);
        else % if maximum gap is between the first and last horizontal sample
            a1 = a(ind+1);
            a2 = a(ind);
        end
        
        % Calculate vertical boundaries
        b1 = min(b);
        b2 = max(b);
                
    otherwise
        error('Invalid input string for dir')
end

if nargout > nout % if the requested output arguments > generated output arguments then...
    error('Too many output arguments')
elseif nargout < nout % if the requested output arguments < generated output arguments then...
    error('Not enough output arguments')
else
    switch nargout
        case 2
            varargout{1} = a1; % left or bottom geographic boundary
            varargout{2} = a2; % right or top geographic boundary
        case 4
            varargout{1} = a1; % left geographic boundary
            varargout{2} = a2; % right geographic boundary
            varargout{3} = b1; % bottom geographic boundary
            varargout{4} = b2; % top geographic boundary
    end
end

