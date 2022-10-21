%  truemonot = ismonotonic (A,varargin)
%
%  DESCRIPTION
%  True if the input MESHGRID matrix of geographic positions (A), of type 
%  specified by input argument dir (varargin{1}), is strictly monotonic 
%  (non-repeated values). Input argument A can also be the former vector of 
%  the corresponding MESHGRID type matrix. 
%
%  ISMONOTONIC can also be used to assess the monotonicity of the full
%  grid (X,Y) or its former vectors (x,y) ([X,Y] = MESHGRID(x,y)) all
%  together.
%
%  ISMONOTONIC evaluates the monotonicity of geographic grids (or former
%  vectors) differently in x and y directions. A 'grid' of geographic 
%  positions can only be considered fully monotonic if its values show a 
%  strictly monotonic increase in East direction (left to right) and a 
%  strictly monotonic decrease in South direction (top to bottom).
%
%               'X grid'              'Y grid'
%             x1 x2 ... xN          y1 y1 ... y1  | 
%             x1 x2 ... xN          y2 y2 ... y2  |  monotonic
%             (...)                 (...)         |   decrease
%             x1 x2 ... xN          yM yM ... yM  V 
%             ---------->                         
%              monotonic             
%               increase              
%  
%  ISMONOTONIC only works with geographic positions (in degrees).
%  ISMONOTONIC accounts for the circular nature of geographic grids in 
%  the horizontal direction, ignoring any non-monotonic jump due to the
%  circularity of degrees. 
%
%   Example 1: Monotonic Grid, Former Vectors (x,y)
%   x = [100 120 140 160 180 200 220 240 260 280 300 320 340 0 20]
%     or expressed in -180 to +180 format:
%   x = [100 120 140 160 180 -160 -140 -120 -100 -80 -60 -40 -20 0 20]
%     x is monotonic! The values increase in East direction (notice though
%     the non-monotonic jump between 340 and 0 [0 to +360 format] or
%     between 180 and -160 [-180 to +180 format]).
%   y = [30 10 -10 -30 -50]
%   y is monotonic! The values decrease in NS direction
%
%   Example 2: Non-monotonic Grid, Former Vectors (x,y)
%   x = [100 120 140 160 180 180 200 220 240 220 280 300 320 340 0 20]
%     or expressed in -180 to +180 format:
%   x = [100 120 140 160 180 180 -160 -140 -120 -140 -80 -60 -40 -20 0 20]
%     x is not monotonic! The values do not increase in East direction 
%     throughout the whole length of the vector (notice the repeated value
%     of 180 and the change to West direction at 240 [0 to +360 format] or
%     -120 [-180 to +180 format]).
%   y = [-50 -30 -10 10 30]
%   y is not monotonic! The values increase in South direction
%  
%  INPUT VARIABLES
%  - A: horizontal MESHGRID matrix of longitudes ('X grid') or vertical
%    MESHGRID matrix of latitudes ('Y grid') or their respective former 
%    vectors [deg]. 
%  - B (varargin{1}): vertical MESHGRID matrix of latitudes ('Y grid') 
%    or its former vector [deg]. 
%  - dir (varargin{1}): string which specifies the type (direction) of 
%    MESHGRID matrix (or former vector) A. There are two options for dir:
%    ¬ 'X': assess monotonicity of 'X grid' A or its former vector.
%    ¬ 'Y': assess monotonicity of 'Y grid' A or its former vector.
%  
%  OUTPUT VARIABLES
%  - truemonot: true if A or (A,B) are strictly monotonic.
%
%  FUNcTION DEPENDENCIES
%  - ismgrid
%  - below360
%
%  LIBRARY DEPENDENCIES
%  - Grid_Manipulation
%
%  FUNCTION CALLS
%  1. ismonotonic (A,dir)
%     ¬ dir = 'X' or 'Y'
%  2. ismonotonic (A,B)
%  3. truemonot = ismonotonic (...)
%
%  CONSIDERATIONS & LIMITATIONS
%  - ISMONOTONIC works exclusively with geodetic data (i.e. positions in
%    degrees).
%
%  See also ismgrid, below360

%  VERSION 2.0 (29 May 2015)
%  - Corrected the method to assess the monotonicity. ISMONOTONIC now evaluates
%    correctly the monotonicity of large grids of horizontal geodetic positions
%    (coverage > 180 degrees).
%  
%  - Performance extended to MESHGRID type grids (not only vectors).
%
%  VERSION 1.1 (26 May 2015)
%  - Included input argument monotype to assess increasing and decreasing 
%    monotonicity.
%
%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  19 Apr 2015

function truemonot = ismonotonic (A,varargin)

switch nargin
    case {0 1}
        error('Not enough input arguments')
    case 2
        if ischar(varargin{1})
            dir = varargin{1};
        else 
            dir = 'XY'; 
        end
    otherwise
        error('Too many input arguments')
end

switch dir
    case 'X' % evaluate if 'X grid' (or former vector) A is 'East monotonic increasing'
        if isvector(A) % if A is a vector then ...
            a = A; % former vector of horizontal MESHGRID type matrix
        elseif ismgrid(A,'X') % if A is an 'X grid' then ...
            a = A(1,:); % former vector of horizontal MESHGRID type matrix
        else
            error('1st input argument has to be a MESHGRID ''X'' type matrix or its former vector')
        end
        
        % Assess monotonicity of horizontal vector
        a = below360(a,'deg+'); % convert into positive degrees
        Da = diff(a); % vector of differences
        ind = find(Da < 0,1,'first'); % position of first non-monotonic step
        a(ind+1:end) = a(ind+1:end) + 360; % convert horizontal geographic positions into 'East monotonic increasing'  
        truemonot = all(diff(a)>0); % assess monotonicity of horizontal vector 'a'
        
    case 'Y' % evaluate if 'Y grid' (or former vector) A is 'North monotonic increasing'
        if isvector(A) % if A is a vector then ...
            a = A; % former vector of vertical MESHGRID type matrix
        elseif ismgrid(A,'Y') % if A is an 'Y grid' then ...
            a = A(:,1); % former vector of vertical MESHGRID type matrix          
        else
            error('1st input argument has to be a MESHGRID ''Y'' type matrix or its former vector')
        end
        
        % Assess monotonicity of vertical vector
        truemonot = all(diff(a)<0); % assess monotonicity of vertical vector 'a'
            
    case 'XY'
        B = varargin{1};
        if isvector(A) && isvector(B) % if A and B are vectors then ...
            a = A; % former vector of horizontal MESHGRID type matrix
            b = B; % former vector of vertical MESHGRID type matrix
        elseif ismgrid(A,B) && isequal(size(A),size(B)) % if A and B are MESHGRID type matrices the same size then ...
            a = A(1,:); % former vector of horizontal MESHGRID type matrix
            b = B(:,1); % former vector of vertical MESHGRID type matrix
        else
            error('1st and 2nd input arguments have to be MESHGRID type matrices the same size or their former vectors')   
        end
        
        % Assess monotonicity of horizontal vector
        a = below360(a,'deg+'); % convert into positive degrees
        Da = diff(a); % vector of differences
        ind = find(Da < 0,1,'first'); % position of first non-monotonic step
        a(ind+1:end) = a(ind+1:end) + 360; % convert horizontal geographic positions into monotonic   
        truemonotx = all(diff(a)>0); % assess monotonicity of 'a'
        
        % Assess monotonicity of vertical vector
        truemonoty = all(diff(b)<0); % assess monotonicity of 'b'
        
        % Assess global monotonicity
        truemonot = truemonotx && truemonoty;
        
    otherwise
        error('Invalid input string for dir')
end

