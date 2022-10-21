%  varargout = unmeshgrid(A,varargin)
%
%  DESCRIPTION
%  Extracts the former vector of the MESHGRID type matrix A in the direction 
%  specified by input argument dir (varargin{1}).
%  
%  UNMESHGRID can also be used to extract the two former vectors of the 
%  full grid (A,B) in just one call. UNMESHGRID previously checks if A or
%  (A,B) are MESHGRID type matrices.
%  
%  INPUT VARIABLES
%  - A: MSHGRID matrix of horizontal positions
%  - B (varargin{1}): MESHGRID matrix of vertical positions
%  - dir (varargin{1}): string that specifies the type ('direction') of 
%    MESHGRID matrix A (i.e. 'X' or 'Y' type). There are two options:
%    � 'X': extracts the former vector of horizontal MESHGRID matrix
%    � 'Y': extracts the former vector of vertical MESHGRID matrix
%
%  OUTPUT VARIABLES
%  - a (varargout{1}): former vector of horizontal or vertical MESHGRID 
%    matrix A.
%  - b (varargout{2}): former vector of vertical MESHGRID matrix B.
%
%  FUNCTION DEPENDENCIES
%  - ismgrid
%
%  LIBRArY DEPENDENCIES
%  - Grid_Manipulation
%
%  FUNCTION CALLS
%  1. x = unmeshgrid(A,dir)
%     � dir = 
%  2. y = unmeshgrid(Y,'Y')
%  3. [x,y] = unmeshgrid(X,Y)
%
%  See also ismgrid

%  VERSION 2.0 (04 Jun 2015)
%  - Performance extended to vectors and single direction (not only MESHGRID 
%    matrices in both directions x and y).
%
%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  19 Apr 2015

function varargout = unmeshgrid(A,varargin)

switch nargin
    case {0 1}
        error('Not enough input arguments')
    case 2
        if ischar(varargin{1})
            dir = varargin{1};
            nout = 1; % number of generated output arguments
        else 
            dir = 'XY';
            nout = 2; % number of generated output arguments
        end
    otherwise
        error('Too many input arguments')
end

switch dir
    case 'X' % evaluate if A is a horizontal MESHGRID type matrix
        if ~ismgrid(A,'X') % if X is not the horizontal matrix generated by MESHGRID then...
           error('Invalid MESHGRID X type matrix')
        end
        a = A(1,:); % former vector of horizontal MESHGRID type matrix
        
    case 'Y' % evaluate if A is a vertical MESHGRID type matrix
        if ~ismgrid(A,'Y') % if Y is not the vertical matrix generated by MESHGRID then...
           error('Invalid MESHGRID Y type matrix')
        end
        a = A(:,1)'; % former vector of vertical MESHGRID type matrix
            
    case 'XY' % evaluate if (A,B) are the horizontal and vertical MESHGRID type matrices
        B = varargin{1}; % vertical matrix
        if ~ismgrid(A,B) % if (A,B) are not matrices generated by MESHGRID then...
           error('Invalid MESHGRID type matrices (X,Y)')
        end
        a = A(1,:); % former vector of horizontal MESHGRID type matrix
        b = B(:,1)'; % former vector of vertical MESHGRID type matrix
        
    otherwise
        error('Invalid input string for dir')
end

if nargout > nout % if the requested output arguments > generated output arguments then...
    error('Too many output arguments')
elseif nargout < nout % if the requested output arguments < generated output arguments then...
    error('Not enough output arguments')
else
    switch nargout
        case 1
            varargout{1} = a; % former vector of horizontal MESHGRID type matrix
        case 2
            varargout{1} = a; % former vector of horizontal MESHGRID type matrix
            varargout{2} = b; % former vector of vertical MESHGRID type matrix
    end
end
 