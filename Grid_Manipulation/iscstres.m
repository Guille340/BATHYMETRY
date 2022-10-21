%  truecstres = iscstres(A,varargin)
%  
%  DESCRIPTION
%  True if the resolution step is constant in MESHGRID array (or former 
%  vector) A, whose type is specified by input argument dir (varargin{1}). 
%
%  ISCSTRES can also be used to check if the resolution step in the full
%  grid (A,B) (or former vectors) is constant. When the horizontal and 
%  vertical MESHGRID matrices (A,B) are defined as inputs, "TRUECSTRES == 
%  true" only if the resolution step is constant and the same in x and y 
%  directions.
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
%  - R (varargin{2}): number of decimal positions that should be used
%    to decide if the different resolution steps are the same.
%
%  OUTPUT VARIABLES
%  - truecstres: true if the resolution step in A is constant (dir = 'X' 
%    or dir = 'Y'). True if the resolution step is constant and identical
%    in (A,B) (dir = 'XY').
%
%  FUNCTION DEPENDENCIES
%  - ismgrid
%  - gridres
%
%  LIBRARY DEPENDENCIES
%  - Grid_Manipulation
%
%  FUNCTION CALLS
%  1. iscstres (A,dir)
%     ¬ dir = 'X' or 'Y'
%  2. iscstres (A,B)
%  3. truecstres = iscstres (...)
%
%  CONSIDERATIONS & LIMITATIONS%
%  - ISCSTRES works exclusively with geodetic data (i.e. positions in degrees).
%
%  - The value for input parameter R in GRIDRES has to be selected according 
%    to the expected precision of grid (X,Y) (see GRIDRES help for more info).
%
%  See also ismgrid, gridres

%  VERSION 2.0 (03 Jun 2015)
%  - Performance extended to vectors and single direction (not only MESHGRID
%    matrices in both directions x and y).
%
%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  19 Apr 2015

function truecstres = iscstres(A,varargin)

switch nargin
    case {0 1}
        error('Not enough input arguments')
    case 2
        if ischar(varargin{1})
            dir = varargin{1};
        else 
            dir = 'XY'; 
        end
        R = 12;
    case 3
        if ischar(varargin{1})
            dir = varargin{1};
        else 
            dir = 'XY'; 
        end
        R = varargin{2};
    otherwise
        error('Too many input arguments')
end

truecstres = false;

switch dir
    case 'X'
        if isvector(A)
            a = A; % former vector of horizontal #meshgrid type matrix
        elseif ismgrid(A,'X')
            a = A(1,:); % former vector of horizontal #meshgrid type matrix
        else
            error('1st input argument has to be a #meshgrid ''X'' type matrix or its former vector')
        end
                
        % Assess if resolution step is constant in x direction
        gresx = gridres(a,'X',R); % horizontal resolution step
        nres = numel(gresx); % number of values in gresx (1 or 2) 
        if nres == 1, truecstres = true; end % if constant resolution step in x direction then truecstres = true
        
    case 'Y'
        if isvector(A)
            a = A; % former vector of vertical #meshgrid type matrix
        elseif ismgrid(A,'Y')
            a = A(:,1); % former vector of vertical #meshgrid type matrix          
        else
            error('1st input argument has to be a #meshgrid ''Y'' type matrix or its former vector')
        end
                
        % Assess if resolution step is constant in y direction
        gresy = gridres(a,'Y',R); % vertical resolution step
        nres = numel(gresy); % number of values in gresy (1 or 2)
        if nres == 1, truecstres = true; end % if constant resolution step in y direction then truecstres = true
            
    case 'XY'
        B = varargin{1};
        if isvector(A) && isvector(B) % if A and B are vectors then ...
            a = A; % former vector of horizontal #meshgrid type matrix
            b = B; % former vector of vertical #meshgrid type matrix
        elseif ismgrid(A,B) && isequal(size(A),size(B)) % if A and B are #meshgrid type matrices the same size then ...
            a = A(1,:); % former vector of horizontal #meshgrid type matrix
            b = B(:,1); % former vector of vertical #meshgrid type matrix
        else
            error('1st and 2nd input arguments have to be #meshgrid type matrices the same size or their former vectors')   
        end
                       
        % Assess if resolution step is constant in the x and y directions
        gresx = gridres(a,'X',R); % horizontal resolution step
        gresy = gridres(b,'Y',R); % vertical resolution step
        gres0x = round(gresx*10^R)*10^-R; % gresx rounded to R decimal positions
        gres0y = round(gresy*10^R)*10^-R; % gresy rounded to R decimal positions
        
        nres = numel(unique([gres0x gres0y])); % nres = 1 when gresx == gresy (within an error of 10^-R)
        if nres == 1, truecstres = true; end % if same resolution step in x and y directions then truecstres = true

    otherwise
        error('Invalid input string for dir')
end
