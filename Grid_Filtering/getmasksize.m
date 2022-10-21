%  [M,N] = getmasksize(fs0,fs,fctype,winname)
%
%  DESCRIPTION
%  Calculates the dimensions of the 2D filtering mask (see GETMASK) based on 
%  the frequency response of the spatial filter. The spatial filter is designed
%  using four input arguments: sampling frequencies of the original and 
%  resampled grid (FS0,FS), filter attenuation at the attenuation band (FCTYPE)
%  and shape of the spatial filter (WINNAME).
%
%  The 2D mask or 'spatial filter' is designed to be convolved with the grid 
%  that has to be resampled. The purpose of the 2D mask is to prevent the 
%  aliasing when a grid is resampled at a lower frequency (spatially decimated).
%
%  The 'mean' mask is the most common and is characterised by a constant value, 
%  repeated in all positions. However there are many other masks with different
%  frequency responses that can provide better filtering and lower level of 
%  secondary lobes (higher secondary lobes add higher aliasing energy).'Window 
%  shaped' masks are a simple but effective alternative for the design of a 
%  spatial filter. But remember: high order filters, with high secondary lobe 
%  attenuation and steep roll-off, translate into larger 2D masks (higher M 
%  and N). 
%
%  Two window masks are currently available: rectangular and hanning. Three 
%  different amplitudes can be selected for the filter response at the baseband
%  frequency of the new grid fc2 (=fs/2): -inf (1st null filter response),-6dB 
%  and -3dB. The most aggressive filter (fctype = 0, -inf relative amplitude) 
%  removes an important amount of high frequency energy, some of it useful; 
%  the softer filter (fctype = 2, -3dB relative amplitude) removes just the 
%  necessary amount of high frequency energy, but mightbe unable to filter all 
%  the aliasing energy.
%
%  FC1 and FC2 (= FS/2) are the cut frequencies of the 'pass band' (PB) and
%  'attenuation band' (AB), respectively. The 'transition band' (TB) is 
%  defined between fc1 and fc2 and is where the filter starts attenuating.
%  At fc2 (= fs/2) a well designed filter would reach its maximum attenuation, 
%  making sure that most energy in AB is removed.
%
%     Amplitude
%      |
%      |________
%      |        \
%      |         \    _    _    _
%      |          \  / \  / \  / \
%      |_ _ _ _ _ _\/_ _\/_ _\/_ _\_ _ frequency
%      |    PB   |  TB |     AB    |
%      |         |     |           |
%      0        fc1   fc2         fs0/2
%
%
%  INPUT VARIABLES
%  - fs0: sampling frequency of the original grid [1/deg]. FS0 = 1/GRES0,
%    with gres0 the resolution step of the original grid.
%  - fs: sampling frequency of the resampled grid [deg-1]. FS = 1/GRES, with 
%    GRES the resolution step of the resampled grid. If the resampling 
%    frequency is different in x and y directions, fs has to be a 
%    2-element vector in the form [fsx fsy].
%  - fctype: integer indicating the amplitude response of the filter at 
%    the maximum frequency of new grid fc2. Three options are available:
%    ¬ fctype = 0 -> 1st null (-inf dB) of the filter response at FC2
%    ¬ fctype = 1 -> -6dB of the filter response at FC2
%    ¬ fctype = 2 -> -3dB of the filter response at FC2
%  - winname: string with the name of the window mask. It can be:
%    ¬ 'rectwin': rectangular window mask
%    ¬ 'hanning': hanning window mask
%
%  OUTPUT VARIABLES
%  - [M,N]: estimated size for the 2D mask (M = number of rows, N = number
%    of columns). M and N are decimal values.
%
%  FUNCTION DEPENDENCIES
%  - mfunrectwin
%  - mfunhanning
%
%  LIBRARY DEPENDENCIES
%  - Grid_Filtering
%
%  FUNCTION CALLS
%  1. [M,N] = getmasksize(fs0,fs,fctype,winname) - for square mask
%     ¬ fs0 = fs0: constant resolution step in original grid
%     ¬ fs = fs: constant resolution step in resampled grid
%     ¬ (M == N) = true: square mask
%  2. [M,N] = getmasksize(fs0,fs,fctype,winname) - for rectangular mask
%     ¬ fs0 = fs0: constant resolution step in original grid
%     ¬ fs = [fsx fsy]: different x-y resolution step in resampled grid
%     ¬ (M == N) = false: rectangular mask
%
%  CONSIDERATIONS & LIMITATIONS
%  - In order to generate the mask, M and N have to be approximated to 
%    the next integer. 
%  - fc1 is not included as input argument. The filter design is limited
%    to 3 possible amplitude values of the filter response at fc2: -inf,
%    -6 and -3 dB. This design method is more intuitive than using a fixed
%    filter amplitude at a pass-band frequency fc1 defined by the user. In 
%    that case it would be difficult to guess what attenuation has been
%    reached at fc2, where the attenuation-band (AB) starts.
%
%  See also mfunrectwin, mfunhanning, getmask, resamplegrid.

%  VERSION 1.1 (25 May 2015)
%  - GETMASKSIZE upgraded to also deal with non-square masks, with different 
%    size (cut-off frequency) in x and y directions.
%
%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  22 Apr 2015

function [M,N] = getmasksize(fs0,fs,fctype,winname)

switch winname
    case 'rectwin'
        hfun = @mfunrectwin;
    case 'hanning'
        hfun = @mfunhanning; 
    otherwise
        error('Specify a valid window name')
end

% Error management
nelem = length(fs);
if nelem>2
    error(['A maximum of two resampling frequencies fs can be ' ...
        'selected, one for each ortogonal direction x and y']); 
end
if (fctype > 2) || (fctype < 0)
    error('Specify a valid value for fctype');
end
    
% EQUATION SOLVER USING BISECTION METHOD
maxit = 100; % maximum iteration
tol = 1e-3; % error tolerance for M
L = zeros(1,nelem); % initialise mask size L
for k = 1:nelem
    a = 0*fs0/fs(k); % minimum expected value of L(k) 
    b = 4*fs0/fs(k); % maximum expected value of L(k)
    fa = feval(hfun,a,fs0,fs(k),fctype);
    fb = feval(hfun,b,fs0,fs(k),fctype);
    if fa*fb > 0
    error('a and b have to be integers of different sign')
    end
    
    x = (a+b)/2; % first bisection estimation of L(k)
    err = abs(a-b)/2; % estimation error of L(k)
    cnt = 0; % counter
    while (err > tol) && (cnt < maxit)
        fx = feval(hfun,x,fs0,fs(k),fctype);
        if fx*fa < 0
            b = x;
        else
            a = x;
        end
        x = (a+b)/2; % bisection estimation of L(k)
        err = abs(a-b)/2; % estimation error of L(k)
        cnt = cnt+1; % increase counter
    end
    L(k) = x; % estimated mask size in k dimension
end

if nelem == 1
    N = L(1); 
    M = L(1);
else
    N = L(1);
    M = L(2);
end

