
function [x,y,z] = getBathymetry(bounds,varargin)

%**************************************************************************
%  [x,y,Z] = getBathymetry(bounds,varargin)
%
%  DESCRIPTION: returns the bathymetry grid [x y z] for the selected area,
%  delimited by ¦bounds¦. The data is extracted from any of the netcdf 
%  (*.nc) GEBCO grids, freely available at GEBCO's website (the supported 
%  files are listed below). The grids can contain elevation or sid (source 
%  identifier) information.
%
%  GEBCO Files
%  - 'gridone.nc': 60 arcsec elevation grid, 1D, 2008
%  - 'gebco_08.nc': 30 arcsec elevation grid, 1D, 2008
%  - 'gebco_SID.nc': 30 arcsec source identifier grid, 1D, 2008
%  - 'GRIDONE_1D.nc': 60 arcsec elevation grid, 1D, 2014
%  - 'GRIDONE_2D.nc': 60 arcsec elevation grid, 2D, 2014
%  - 'GEBCO_2014_1D.nc': 30 arcsec elevation grid, 1D, 2014
%  - 'GEBCO_2014_2D.nc': 30 arcsec elevation grid, 2D, 2014
%  - 'GEBCO_2014_SID_1D.nc': 30 arcsec source identifier grid, 1D, 2014
%  - 'GEBCO_2014_SID_2D.nc': 30 arcsec source identifier grid, 2D, 2014
%  - 'GEBCO_2020_TID.nc': 15 arcsec
%
%  INPUT VARIABLES
%  - bounds: four-element vector delimiting the selected area. ¦bounds¦ is
%    in the form [x1 x2 y1 y2], with (x1,x2) the left and right limits, and
%    (y1,y2) the bottom and top limits, respectively.
%  - filepath (varargin{1}): full path of the bathymetry grid file, 
%    including extension.
%
%  OUTPUT VARIABLES
%  - x: vector of longitudes for the selected area [deg]
%  - y: vector of latitudes for the selected area [deg]
%  - z: array of elevation [m] or SID data for the selected area
%
%  INTERNALLY CALLED FUNCTIONS
%  - None
%
%  FUNCTION CALLS
%  1) [x,y,z] = getBathymetry(bounds)
%  2) [x,y,z] = getBathymetry(bounds,filepath)
%
%  CONSIDERATIONS & LIMITATIONS
%  - 1D grids and high resolution (30 s) grids require more available
%    memory. In computers with 4 GB of RAM, or less, and very large
%    selected areas (tens of degrees) use preferable 2D and low resolution 
%    grids.
%  - The netcdf functions implemented in Matlab is based in the original
%    netcdf library, coded in C. Some particularities of C language remain
%    in the Matlab version of the library: for example, the start index
%    in netcdf.getVar(ncid,zid,start,count) starts from 0, not 1 as typical 
%    in Matlab.
%
%  REFERENCES
%  - "General Bathymetric Chart of the Oceans" ('GEBCO')
%    http://www.gebco.net/data_and_products/gridded_bathymetry_data/
%    https://www.bodc.ac.uk/data/online_delivery/gebco/%  
%    
%  REVISION 1.1 (19 Feb 2021)
%  - Changed x and y output vectors to be consistent for all grid databases.
%    Now they are column vectors, with x increasing and y decreasing.
%  
%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  15 Jan 2017
%
%**************************************************************************

% Area limits
x1 = bounds(1); % left boundary
x2 = bounds(2); % right boundary
y1 = bounds(3); % bottom boundary 
y2 = bounds(4); % top boundary

% Error management
if y1 > y2
   error('Wrong boundary definition (bottom latitude cannot be higher than top latitude)')
end

% Variable input argument
switch nargin
    case 0
        error('Not enough input arguments')
    case 1
        % Get file absolute path
        [filename,filedir] = uigetfile({'*.nc', 'NetCDF Files (*.nc)'},...
            'Pick GEBCO grid file (Bathymetry or SID)','MultiSelect','off');  
        filepath = fullfile(filedir,filename);
    case 2
        filepath = varargin{1};
    otherwise
        error('Too many input arguments')
end      

% Extract Bathymetry Data
finfo = ncinfo(filepath); % information from selected netcdf file
ncid = netcdf.open(filepath); % open selected netcdf file
isonedim = (numel(finfo.Variables)==6); % true for one-dimension bathymetry data (vector), false for two-dimensions (array)

if isonedim  % 1D grid
    
    dimid = netcdf.inqVarID(ncid,'dimension'); % request identifier for variable 'dimension' (grid dimensions)
    gridsize = double(netcdf.getVar(ncid,dimid)); % extract data from variable 'dimension'
    N = gridsize(1); % number of longitude points in the bathymetry grid
    M = gridsize(2); % number of latitude points in the bathymetry grid
    is1mgrid = (N*M == 233312401); % true for one minute grid, false for 30 s grid

    % Extract longitude and latitude vectors (full)
    xrangeid = netcdf.inqVarID(ncid,'x_range'); % request identifier for variable 'x_range'
    xrange = netcdf.getVar(ncid,xrangeid); % longitude grid limits [deg]
    yrangeid = netcdf.inqVarID(ncid,'y_range'); % request identifier for variable 'y_range'
    yrange = netcdf.getVar(ncid,yrangeid); % latitude grid limits [deg]
    stepid = netcdf.inqVarID(ncid,'spacing'); % request identifier for variable 'spacing'
    step = netcdf.getVar(ncid,stepid); % grid step [deg]
    if is1mgrid % if 1 min grid
        x = xrange(1):step(1):xrange(2); % vector of longitudes (x = -180:1/60:180 for 1 min grid) [deg]
        y = yrange(2):-step(2):yrange(1); % vector of latitudes (y = 90:-1/60:-90 for 1 min grid) [deg] 
    else % if 30 s grid
        x = xrange(1)+step(1)/2:step(1):xrange(2)-step(1)/2; % vector of longitudes (x = -180+1/240:1/120:180-1/240 for 30 s grid) [deg] 
        y = yrange(2)-step(2)/2:-step(2):yrange(1)+step(2)/2; % vector of latitudes (y = 90-1/240:-1/120:-90+1/240 for 30 s grid) [deg]
    end
   
    % Extract selected bathymetry area (provisional, all longitudes)
    [~,iy1] = min(abs(y-y1)); % index for selected bottom limit y1
    [~,iy2] = min(abs(y-y2)); % index for selected top limit y2
    i1 = iy1*N - 1; % end index in vectorised grid (referred to 0)
    i2 = (iy2-1)*N; % start index in vectorised grid (referred to 0)
    count = i1 - i2 +  1; % number of selected points
    start = i2; % start index
    zid = netcdf.inqVarID(ncid,'z'); % request identifier for variable 'z' (elevation, + = above sea level)
    dat = netcdf.getVar(ncid,zid,start,count); % extract data from variable 'z' (all longitudes, selected latitudes)
    M0 = iy1 - iy2 + 1; % number of selected latitudes
    z = reshape(dat,N,M0)'; % elevation or source identifier (SID) data [M0 N]
    clear dat

    % Extract selected bathymetry area (definitive, exact area)
    if x1 > x2 % if selected area includes antimeridian...
        if is1mgrid  % if the grid is 60 s, remove duplicated column (antimeridian)
            ipmer = (x==180);
            x = x(~ipmer); 
            z = z(:,~ipmer);
        end
        iy = iy2:iy1; % indices of selected latitudes
        ix = x>=x1 | x<=x2; % logical indices of selected longitudes
        xshift = N - find(~ix,1,'last'); % horizontal shift positions
        y = y(iy)'; % latitude vector for the selected area (descending) [deg]  
        x = circshift(x(ix),[0 xshift])'; % longitude vector for the selected area (ascending) [deg] - applied circular shift to rearrange the East and West hemisphere data sectors 
        z = circshift(z(:,ix),[0 xshift]); % grid of data (bathymetry or sid) for the selected area - applied circular shift to rearrange the East and West hemisphere data sectors (truamer == 1) 
    else
        iy = iy2:iy1; % indices of selected latitudes
        ix = x>=x1 & x<=x2; % logical indices of selected longitudes
        y = y(iy)';  % latitude vector for the selected area (descending) [deg]  
        x = x(ix)'; % longitude vector for the selected area (ascending) [deg]
        z = z(:,ix); % grid of data (bathymetry or sid) for the selected area
    end
      
else % 2D grid
    
    % Extract longitude and latitude vectors (full)
    xid = netcdf.inqVarID(ncid,'lon'); % request identifier for variable 'lon' (longitude)
    yid = netcdf.inqVarID(ncid,'lat'); % request identifier for variable 'lat' (latitude)
    x = netcdf.getVar(ncid,xid)'; % extract data from variable 'lon' (row vector)
    y = netcdf.getVar(ncid,yid)'; % extract data from variable 'lat' (row vector)
    N = length(x); % number of columns in the bathymetry grid
       
    % Extract selected bathymetry area
    [~,ix1] = min(abs(x-x1)); % index for selected left limit x1
    [~,ix2] = min(abs(x-x2)); % index for selected right limit x2
    [~,iy1] = min(abs(y-y1)); % index for selected bottom limit y1
    [~,iy2] = min(abs(y-y2)); % index for selected top limit y2
    ystart = iy1 - 1; % start index for latitude dimension
    ycount = iy2 - iy1 +  1; % number of selected latitudes
    
    if ismember('sid',{finfo.Variables.Name})
        zid = netcdf.inqVarID(ncid,'sid'); % request identifier for variable 'sid' (source identifier)
    elseif ismember('tid',{finfo.Variables.Name})
        zid = netcdf.inqVarID(ncid,'tid'); % request identifier for variable 'tid' (type identifier)
    else
        zid = netcdf.inqVarID(ncid,'elevation'); % request identifier for variable 'elevation' (elevation data)
    end
    
    if x1 > x2 % if selected area includes antimeridian...
        xstart_block1 = ix1 - 1; % start index for longitude dimension (1st block, referred to 0)
        xcount_block1 = abs(N - ix1 + 1); % number of selected longitudes (1st block)
        xstart_block2 = 0; % start index for longitude dimension (2nd block, referred to 0)
        xcount_block2 = ix2; % number of selected longitudes (2nd block)
        x = [netcdf.getVar(ncid,xid,xstart_block1,xcount_block1);...
            netcdf.getVar(ncid,xid,xstart_block2,xcount_block2)]; % extract longitude vector from selected area
        y = netcdf.getVar(ncid,yid,ystart,ycount); % extract latitude vector from selected area
        z = flipud([netcdf.getVar(ncid,zid,[xstart_block1 ystart],[xcount_block1 ycount]);...
            netcdf.getVar(ncid,zid,[xstart_block2 ystart],[xcount_block2 ycount])]'); % extract bathymetry data from selected area
    else
        xstart = ix1 - 1; % start index for longitude dimension (referred to 0)
        xcount = abs(ix2 - ix1 + 1); % number of selected longitudes
        x = netcdf.getVar(ncid,xid,xstart,xcount); % longitude vector from selected area (ascending)  
        y = flipud(netcdf.getVar(ncid,yid,ystart,ycount)); % latitude vector from selected area (descending)
        z = flipud(netcdf.getVar(ncid,zid,[xstart ystart],[xcount ycount])'); % bathymetry data from selected area    
    end    
    
end

netcdf.close(ncid) % close netcdf file




