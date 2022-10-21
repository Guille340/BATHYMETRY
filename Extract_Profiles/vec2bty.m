%  vec2bty(fdir,fnames,varargin)
%
%  DESCRIPTION
%  Creates a *.bty file for each bathymetry profile included as input argument.
%  A *.bty file is used in AcTUP to store a bathymetry profile and contains 
%  depth and range values for each point along a certain transect. The input 
%  bathymetry profiles are defined by: 1) depth cell array ¦zp¦, and 2) 
%  position cell array, which can contain either absolute geographic position,
%  ¦xp¦ and ¦yp¦, or range, ¦dp¦.
%
%  INPUT VARIABLES
%  - fdir: storage directory for the *.bty files
%  - fnames: cell array containing the names for all input profiles
%  - dp (varargin{1}): cell array of ranges [m]
%  - zp (varargin{2}): cell array of depths [m]
%  ... or ...
%  - xp (varargin{1}): cell array of longitudes [deg]
%  - yp (varargin{2}): cell array of latitudes [deg]
%  - zp (varargin{3}): cell array of depths [m]
%
%  * each cell contains the information of one bathymetry profile. All
%    cell arrays ¦dp¦, ¦xp¦, ¦yp¦, ¦zp¦ must have the same number of 
%    elements.
%
%  OUTPUT VARIABLES
%  - None
%
%  FUNCTION DEPENDENCIES
%  - vincenty
%  
%  LIBRARY DEPENDENCIES
%
%  FUNCTION CALLS
%  1. vec2bty(fdir,fnames,dp,zp)
%  2. vec2bty(fdir,fnames,xp,yp,zp)
%
%  CONSIDERATIONS & LIMITATIONS
%  - ¦fnames¦ must include file extensions
%
%  See also getProfilesBty, vincenty
   
%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  10 Jan 2017

function vec2bty(fdir,fnames,varargin)

switch nargin
    case {0 1 2 3}
        error('Not enough input arguments')
    case 4
        dp = varargin{1};
        zp = varargin{2};
        
        % Error management
        if ~ischar(fdir) || ~isvector(fdir)
            error('Input argument fdir is not a valid string of characters')
        end
        if ~iscell(fnames) || ~iscell(dp) || ~iscell(zp) ...
                || ~isequal(numel(fnames),numel(dp),numel(zp))
            error(['Input arguments fnames, dp (varargin{1}) and zp' ... 
            '(varargin{2}) have to be cell arrays with the same number' ...
            'of elements ']);
        end
        K = numel(zp);
        
    case 5
        xp = varargin{1};
        yp = varargin{2};
        zp = varargin{3};
        
        % Error management
        if ~ischar(fdir) || ~isvector(fdir)
            error('Input argument fdir is not a string of characters')
        end
        if ~iscell(fnames) || ~iscell(xp) || ~iscell(yp) || ~iscell(zp) ...
                || ~isequal(numel(fnames),numel(xp),numel(yp),numel(zp))
            error(['Input arguments fnames, xp (varargin{1}) and yp' ... 
            '(varargin{2}) and zp(varargin{3}) have to be cell arrays ' ...
            'with the same number of elements ']);
        end
        
        % Calculate cell array of distances to the source dp
        K = numel(xp); % number of transects
        dp = cell(1,K);
        for k = 1:K
            xp0 = xp{k};
            yp0 = yp{k};
            soulat = yp0(1);
            soulon = xp0(1);
            reclat = yp0;
            reclon = xp0;
            [dp{k},~,~] = vincenty(soulat,soulon,reclat,reclon,'off'); 
        end
    otherwise
        error('Too many input arguments')
end

% Make folder
fdir = makedir(fdir);

% Create *.bty files
maxP_actup = 99; % maximum number of points admitted in AcTUP bathymetry files *.bty - 99 points
excmaxp = false(1,K);
D = zeros(1,K);
for k = 1:K
    P = length(zp{k});
    if P > maxP_actup
        excmaxp(k) = true;
        fname = sprintf('[X] %s',fnames{k}); 
    else
        fname = fnames{k}; 
    end
    fpath = fullfile(fdir,fname);
    fid = fopen(fpath,'w');
    if fid ~= -1
        dp0 = dp{k}*1e-3; % distance to the source [km]  
        zp0 = -zp{k}; % positive depth
        D(k) = dp0(end)*1e3;
        fprintf(fid,'%d\r\n',P);     
        for p = 1:P
          fprintf(fid,'%0.3f %0.3f\r\n',dp0(p),zp0(p));
        end
      fclose(fid);                
    end
end

% Error management (does P exceed the maximum number of points allowed in a *.bty file?)
if any(excmaxp)
    excindices = find(excmaxp);
    indStr = sprintf(repmat('%d ',1,length(excindices)),excindices);
    warning(['\nThe number of points in some of the transects exceed the maximum ' ... 
        'number of points (99) that can be stored in an AcTUP *.bty file. ' ...
        'Use a resolution step d > %0.3f [m].\n' ...
        'The following indices correspond to those *.bty files with ' ...
        'more than 99 bathymetry points: %s'], max(D)/maxP_actup,indStr);
end
