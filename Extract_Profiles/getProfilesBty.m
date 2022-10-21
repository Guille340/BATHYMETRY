%  getProfilesBty(soulat,soulon,varargin)
%
%  DESCRIPTION
%  Generates one AcTUP bathymetry file (.bty) per specified azimuthal transect.
%  
%  INPUT ARGUMENTS
%  - soulat: latitude of start point (vertical source position) [deg] 
%  - soulon: longitude of start point (horizontal source position) [deg] 
%
%  INPUT PROPERTIES (Variable Input Arguments)
%  The strings below represent function properties. Any number can be included
%  in the call. These must be specified after the second input argument,
%  (NAVIMPDATAONE), and each of them must be followed by their corresponding 
%  value separated by comma.
%  - 'Angles': vector of transect azimuths (DEFAULT = 0:20:340)[deg]
%  - 'RangeMax': maximum range for transects (DEFAULT = 1e4) [m]
%  - 'RangeStep': range resolution step for transects (DEFAULT = 200) [m]
%  - 'FilePath': absolute path of bathymetry file (DEFAULT = PWD)
%  - 'Prefix': prefix names for .bty files (DEFAULT = 'Bathymetry')
%  - 'Plot': TRUE for bathymetry, transects and profiles to be plotted
%    (DEFAULT = TRUE).
%
%  OUTPUT VARIABLES
%  - None
%
%  FUNCTION CALLS
%  1. getProfilesBty(soulat,soulon,...)
%  2. getProfilesBty(...,<PROPERTY_NAME>,<PROPERTY_VALUE>)
%
%  FUNCTION DEPENDENCIES
%  - getBathymetry
%  - getTransects
%  - getProfiles
%  - vec2bty
%
%  LIBRARY DEPENDENCIES
%  - Extract_Bathymetry
%
%  See also getBathymetry, getTransects, getProfiles, vec2bty

%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  24 Feb 2021

function getProfilesBty(soulat,soulon,varargin)

% Check Number of Input Arguments
narginchk(2,14)
nVarargin = nargin - 2;
if rem(nVarargin,2)
    error('Property and value input arguments must come in pairs')
end

% Initialise Default Parameters
angles = 0:20:340; % no horizontal offset for source/receiver
rangeMax = 1e4; % fixed offset
rangeStep = 200; % 0 s smoothing
filePath = pwd; % 10 minutes gap
prefix = 'Bathymetry'; % interpolation method
plotFlag = true;

% Retrieve Input Variables
for m = 1:2:nVarargin
    inputProperty = lower(varargin{m}); % case insensitive
    inputProperties = lower({'Angles','RangeMax','RangeStep',...
        'FilePath','Prefix','Plot'});
    if ~ismember(inputProperty,inputProperties)
        error('Invalid input property')
    else
        switch inputProperty
            case 'angles'
                angles = varargin{m+1};
            case 'rangemax'
                rangeMax = varargin{m+1};
            case 'rangestep'
                rangeStep = varargin{m+1};
            case 'filepath'
                filePath = varargin{m+1};
            case 'prefix'
                prefix = varargin{m+1};
            case 'plot'
                plotFlag = varargin{m+1};
        end
    end
end
 
% Extract Limits
R = 111200; % meters per degree of latitue [m]
DeltaLat = ceil(rangeMax/R * 50)/50;
DeltaLon = ceil(rangeMax/(cos(soulat*pi/180)*R) * 50)/50;
latMax = soulat + DeltaLat;
latMin = soulat - DeltaLat;
lonMax = soulon + DeltaLon;
lonMin = soulon - DeltaLon;

% Extract Bathymetry
[x,y,Z] = getBathymetry([lonMin lonMax latMin latMax],filePath);
[X,Y] = meshgrid(x,y);

% Calculate Bathymetry Profiles
[P1,P2] = getTransects(soulat,soulon,angles,rangeMax);
[xp,yp,zp,dp] = getProfiles(X,Y,Z,P1,P2,rangeStep);

% Generate Bathymetry Files (.bty)
newFolder = 'Bathymetry (.bty)';
mkdir(newFolder)
fdir = fullfile(pwd,newFolder);
nTransects = length(angles);
for m = 1:nTransects
    fnames{m} = sprintf('%s_%ddeg_%dm.bty',prefix,round(angles(m)),round(rangeMax)); 
end
vec2bty(fdir,fnames,dp,zp)

% Plot Bathymetry, Transects and Profiles
if plotFlag
    
    % 2D Bathymetry & Transects
    figure
    imagesc(x,y,Z)
    set(gca,'YDir','normal')
    colorbar
    caxis([-100 0])
    hold on
    for m = 1:nTransects
        plot(xp{m},yp{m},'Color',[0.8 0.8 0.8],'Linewidth',1.5), 
    end
    plot(soulon,soulat,'ro','MarkerSize',5,'MarkerFaceColor','r',...
        'MarkerEdgeColor','w','Color','none')
    box on
    DLon = 0.02*rangeMax/(R*cos(soulat*pi/180));
    DLat = 0.02*rangeMax/R;
    axis([lonMin - DLon, lonMax + DLon, latMin - DLat, latMax + DLat])
    xlabel('Longitude [deg]')
    ylabel('Latitude [deg]')
    title(prefix)
    fileName = strcat(prefix,'_Transects');
    print(fullfile(fdir,fileName),'-dpng','-r250')

    % Bathymetry Profiles
    figure
    hold on
    thickLine = 1:floor(nTransects/4):nTransects;
    cnt = 1;
    for m = 1:nTransects
        if ismember(m,thickLine)
            h(cnt) = plot(dp{m},-zp{m},'LineWidth',3);
            legStr{cnt} = sprintf('%d deg',angles(m));
            cnt = cnt + 1;
        else
            plot(dp{m},-zp{m},'LineWidth',1);
        end
    end
    set(gca,'YDir','reverse')
    box on
    yMax = 120;
    ylim([0 yMax])
    xlabel('Range [m]')
    ylabel('Depth [m]')
    title(prefix)
    legend(h,legStr,'Location','SouthWest')
    fileName = strcat(prefix,'_Profiles');
    print(fullfile(fdir,fileName),'-dpng','-r250')
end
