%  truemesh = ismgrid(A,varargin)
%
%  DESCRIPTION
%  True if the input matrix (A) is a #meshgrid matrix of the type specified 
%  by input argument dir (varargin{1}), i.e. 'X' or 'Y'. 
%
%  ISMGRID can also be used to assess in just one call if input matrices 
%  (A,B) are the horizontal and vertical matrices that MESHGRID produces.
%  
%  INPUT VARIABLES
%  - A: matrix of horizontal or vertical positions (X)
%  - B (varargin{1}): matrix of vertical positions (Y)
%  - dir (varargin{1}): string which specifies the type ('direction') of 
%    matrix A. There are two options for dir:
%    ¬ 'X': assess if A is a horizontal #meshgrid type matrix.
%    ¬ 'Y': assess if A is a vertical #meshgrid type matrix.
%
%  OUTPUT VARIABLES
%  - truemesh: true if A is a meshgrid matrix of the type specified by dir 
%   (no variable input argument B). True also if (A,B) are the horizontal 
%   and vertical matrices returned  by meshgrid (variable input argument B).
%
%  FUNCTION DEPENDENCIES
%  - None
%
%  LIBRARY DEPENDENCIES
%  - None
%
%  FUNCTION CALLS
%  1. ismgrid(A,dir)
%     ¬ dir = 'X' or 'Y'
%  2. ismgrid(A,B)
%  3. truemesh = ismgrid(...)
%
%  CONSIDERATIONS & LIMITATIONS
%  - ISMGRID only works with matrices. Even if the inputs (X,Y) are the former
%    vectors of the corresponding MESHGRID type grid, TRUEMESH will return 
%    false.

%  VERSION 1.1 (29 May 2015)
%  - Extended performance to single #meshgrid type matrices X or Y (not 
%    only full position grid (X,Y)).
%
%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  19 Apr 2015

function truemesh = ismgrid(A,varargin)

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

truemesh = false; % truemesh is false by default

switch dir
    case 'X' % evaluate if A is a horizontal #meshgrid type matrix
        if ~isvector(A) % if A is a matrix then...
            M = size(A,1); % number of rows in horizontal matrix A
            a = A(1,:); % first row of matrix A
            truemesh = isequal(repmat(a,M,1),A); % assess if A is a horizontal #meshgrid type matrix
        end
        
    case 'Y' % evaluate if A is a vertical #meshgrid type matrix
        if ~isvector(A) % is A is a matrix then...
            N = size(A,2); % number of columns in matrix A
            a = A(:,1); % first column of matrix A
            truemesh = isequal(repmat(a,1,N),A); % assess if A is a vertical #meshgrid type matrix
        end
            
    case 'XY' % evaluate if (A,B) are the horizontal and vertical #meshgrid type matrices
        B = varargin{1}; % vertical matrix
        if ~isvector(A) && ~isvector(B) && isequal(size(A),size(B)) % if X and Y are matrices the same size then...
            M = size(A,1); % number of rows in horizontal matrix A
            N = size(B,2); % number of columns in vertical matrix B
            a = A(1,:); % first row of matrix A
            b = B(:,1); % first column of matrix B
            truemeshx = isequal(repmat(a,M,1),A); % assess if A is a horizontal #meshgrid type matrix
            truemeshy = isequal(repmat(b,1,N),B); % assess if B is a vertical #meshgrid type matrix
            truemesh = truemeshx && truemeshy; % assess if (A,B) are horizontal and vertical #meshgrid type matrices
        end
    otherwise
        error('Invalid input string for dir')
end
        