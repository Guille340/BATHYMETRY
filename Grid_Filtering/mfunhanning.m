%  y = mfunhanning(winLength,fs0,fs,fctype)
%
%  DESCRIPTION
%  Function used to calculate the number of points per side WINLENGTH in the 
%  2D low pass filtering mask. The filtering mask is a 2D 'hanning window', 
%  where the values are attenuated towards the borders of the mask. FS0 and FS 
%  are the sampling rates of the original and final (resampled) grid. FCTYPE 
%  specifies the degree of attenuation at the maximum frequency of the final 
%  grid FC2 (= FS/2).
%
%  MFUNHANNING is called by function GETMASKSIZE, an iterative equation solver. 
%  
%  INPUT VARIABLES
%  - winLength: integer especifying the lenght of the hanning window.
%  - fs0: sampling frequency of the original grid [deg-1]. FS0 = 1/GRES0, 
%    with gres0 the resolution step of the original grid.
%  - fs: sampling frequency of the resampled grid [deg-1]. FS = 1/GRES, with
%    gres the resolution step of the resampled grid. 
%  - fctype: integer indicating the amplitude response of the filter at 
%    baseband frequency of new grid FC2. Three options are available:
%    # fctype = 0 -> 1st null of the filter response at FC2
%    # fctype = 1 -> -6dB of the filter response at FC2
%    # fctype = 2 -> -3dB of the filter response at FC2
%
%  OUTPUT VARIABLES
%  - y: function f(x) evaluated at x = WINLENGTH. f(x) relates the sampling
%    frequency of the original and resampled grid to the size WINLENGTH of
%    the 2D mask. The correct value WINLENGTH makes y = 0. 
%
%  FUNCTION DEPENDENCIES
%  - None
%
%  LIBRARY DEPENDENCIES
%  - None
% 
%  CONSIDERATIONS & LIMITATIONS
%  - MFUNHANNING is an unidimensional function, i.e. it has to be used
%    twice if the cut-off frequencies of the filtering mask in x and y
%    directions are different (see GETMASKSIZE).
%
%  - The functions f(x) included in MFUNHANNING were modelled based on
%    experimental data. The frequencies at relative amplitudes of the 
%    filter response of -inf (1st null of filter response), -6 dB and 
%    -3 dB were measured manually on a #freqz graph, using different 
%    window lengths WINLENGTH. The error introduced by the modelled equation 
%    is minimum, but might alter the estimated WINLENGTH value by 1 when 
%    WINLENGTH is rounded to the nearest integer.

%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  22 Apr 2015

function y = mfunhanning(winLength,fs0,fs,fctype)

% Error management
if fs > fs0
    error('fs cannot be higher than fs0')
end

% HANNING WINDOW
switch fctype
    case 0 
        % Cut Frequency at 1st Null
        k = 1.956 - 0.5634*exp(-0.1065*winLength);
    case 1
        % Cut Frequency at -6dB
        k = 0.991 - 0.23*exp(-0.074*winLength);
    case 2
        % Cut Frequency at -3dB
        k = 0.711 - 0.1656*exp(-0.08*winLength);
    otherwise
        error('Specify a valid value for fctype (0, 1 or 2)')
end

y = k./winLength - fs/(2*fs0);