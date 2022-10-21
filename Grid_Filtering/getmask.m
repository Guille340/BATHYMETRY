%  mask = getmask(fs0,fs,fctype,winname)
%
%  DESCRIPTION
%  Builds the 2D filtering mask necessary to prevent the aliasing that happens 
%  when a 2D grid is resampled at a lower sampling rate than the original. 
%
%  The 2D mask is a 'spatial' mask designed to be convolved with the spatial 
%  grid that has to be resampled. The filtering mask is a 2D version of well
%  known windows used in signal processing. The advantage of 'window shape' 2D 
%  masks is their simplicity of design and application, and the possibility of 
%  controlling the amplitude and trend of the secondary lobes of the frequency 
%  response. 
%
%  The design of the mask is controlled by the 4 input arguments FS0, FS,
%  FCTYPE and WINNAME. FC2 = FS/2 is the cutoff frequency, at which the LPF 
%  has an attenuation of -inf, -6 or -3 dB, depending on fctype. The dimensions
%  of the mask [M,N] are mainly controlled by the ratio FS0/FS, but the final 
%  value for [M,N] depends also on the attenuation specified for FC2 ('fctype')
%  and the window used ('winname'). Lower 'fctype' values are equivalent to 
%  select lower cutoff frequencies FC2 (more agressive LPF). The 'hanning'
%  window generates low amplitude secondary lobes. A lower fctype value and 
%  windows with softened response tend to generate bigger masks (higher 
%  dimensions [M,N]).
%  
%  INPUT VARIABLES
%  - fs0: sampling frequency of the original grid [1/deg]. FS0 = 1/GRES0,
%    with gres0 the resolution step of the original grid.
%  - fs: sampling frequency of the resampled grid [deg-1]. FS = 1/GRES, with 
%    GRES the resolution step of the resampled grid. If the resampling 
%    frequency is different in x and y directions, fs has to be a 
%    2-element vector in the form [fsx fsy].
%  - fctype: integer indicating the amplitude response of the filter at 
%    the maximum frequency of new grid FC2. Three options are available:
%    ¬ fctype = 0 -> 1st null (-inf dB) of the filter response at FC2
%    ¬ fctype = 1 -> -6dB of the filter response at FC2
%    ¬ fctype = 2 -> -3dB of the filter response at FC2
%  - winname: string with the name of the window mask. It can be:
%    ¬ 'rectwin': rectangular window mask
%    ¬ 'hanning': hanning window mask
%
%  OUTPUT VARIABLES
%  - mask: 2D anti-aliasing mask
%
%  FUNCTION DEPENDENCIES
%  - getmasksize
%
%  LIBRARY DEPENDENCIES
%  - Grid_Filtering
%
%  See also getmasksize

%  VERSION 1.1 (25 May 2015)
%  - GETMASK upgraded to also generate non-square masks, with different
%    size (cut-off frequency) in x and y directions.
%
%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  22 Apr 2015

function mask = getmask(fs0,fs,fctype,winname)

[M,N] = getmasksize(fs0,fs,fctype,winname); % get dimensions of 2D mask
M = round(M); % number of rows in 2D mask
N = round(N); % number of columns in 2D mask
w1Dx = window(winname,N); % former horizontal 1D window
w1Dy = window(winname,M); % former vertical 1D window
w2D = w1Dy(:)*w1Dx(:)'; % spatial anti-aliasing mask
nfact = sum(sum(w2D)); % normalising factor
mask = w2D/nfact; % spatial anti-aliasing mask (normalised)

