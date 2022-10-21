%  nlines = numLines(fpath)
%
%  DESCRIPTION
%  Returns the number of lines in a file.
%
%  NUMLINES is useful to preallocate memory for a variable that is going
%  to store the information of each line found in .*txt file. For example,
%  before reading a GPS, AIS or P190 file, the longitude and latitude
%  variables can be initialised using "zeros(1,L)", where L is the number
%  of lines in the *.txt file. 
%  
%  Pre-allocating will reduce the time used to populate a variable that 
%  changes dynamically in each iteration of a loop, specially when the 
%  number of iterations is particularly high.
%
%  INPUT VARIABLES
%  - fpath: full path (directory/filename.extension) of the input file
%
%  OUTPUT VARIABLES
%  - nlines: number of lines in the file
%
%  FUNCTION DEPENDENCIES
%  - None
%
%  LIBRARY DEPENDENCIES
%  - None
%
%  FUNCTION CALLS
%  1. nlines = numLines(fpath)

%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  14 Nov 2014

function nlines = numLines(fpath)

% METHOD 1
fid = fopen(fpath, 'rb');

% Get file size.
fseek(fid, 0, 'eof');
fileSize = ftell(fid);
frewind(fid);

% Read the file and count lines
data = fread(fid, fileSize, 'uint8'); % read the whole file.
nlines = sum(data == 10); % count number of line-feeds and increase by one.
fclose(fid);

% METHOD 2 (bit slower)
% fid = fopen(fpath);
% allText = textscan(fid,'%s','delimiter','\n');
% nlines = length(allText{1});
% fclose(fid)