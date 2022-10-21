% Source Coordinates
lat = [43.47157222, 43.46548125, ...             % Leg 1
    43.45939028, 43.45329931, 43.44720833, ...      % Leg 1
    43.44720833, 43.44523333, 43.44325833, ...      % Leg 2
    43.44325833, 43.43994861, 43.43663889];         % Leg 3
lon = [-2.791586111, -2.800668276,...            % Leg 1
    -2.809748611, -2.818827117, -2.827903795,...    % Leg 1
    -2.827903795, -2.841556944, -2.855201887,...    % Leg 2
    -2.855201887, -2.858877778, -2.862552376];      % Leg 3
legId = [1 1 1 1 1 2 2 2 3 3 3];
souId = [1 2 3 4 5 1 2 3 1 2 3];

% Input
leg = 3; % selected leg ID
sou = 3; % selected source ID
index = legId==leg & souId==sou; % index of selected source coordinates
soulon = lon(index); % longitude of selected leg-source
soulat = lat(index); % % longitude of selected leg-source
angles = 0:5:355; % transect angles (0 N, 90 E) [deg]
rmax = 4000; % transect length [m]
rres = 100; % range resolution step [m]
suffix = sprintf('LEG%d__S%d',leg,sou); % suffix for bathymetry file names (.bty)
fpath = ['J:\DATABASES (CTD, Bathymetry,...)\GEBCO\GEBCO Tool (Updated)\'...
    'Grid 2020\GEBCO_2020.nc']; % absolute path of bathymetry grid

getProfilesBty(soulat,soulon,angles,rmax,rres,fpath,suffix)
