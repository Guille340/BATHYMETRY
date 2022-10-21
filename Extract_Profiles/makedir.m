
function fdirnew = makedir(fdir,overwrite)

%**************************************************************************
%  fdirnew = mkfol(fdir,overwrite)
%
%  DESCRIPTION: as #mkdir, #makedir creates a new directory with all 
%  necessary folders, but with the advantage that if the specified 
%  directory already exists, a new folder is created. The new folder
%  includes a suffix which indicating the copy number. The function
%  iterates through subsequent copy numbers until it finds a name for the
%  folder that is not already taken. For example:
%
%  Existing Directories          fdir                 fdirnew
%  ----------------------------------------------------------------------
%  'C:\'                         'C:\'                'C:\'
%  'C:\'                         'C:\Hi'              'C:\Hi'
%  'C:\Hi'                       'C:\Hi'              'C:\Hi (1)'
%  'C:\Hi' and 'C:\Hi (1)'       'C:\Hi'              'C:\Hi (2)'
%  'C:\Hi (1)'                   'C:\Hi'              'C:\Hi'
%  'C:\'                         'C:\Hi\Bye'          'C:\Hi\Bye'
%   
%  INPUT VARIABLES
%  - fdir: absolute directory. It can be an existing or non-existing
%    directory. The last backslash can be kept or omitted (e.g. 'C:' and
%    'C:\' have the same result.
%  - overwrite: numeric flag that indicates whether an existing directory
%    is used directly (¦overwrite¦ = 1, ¦fdirnew¦ = ¦fdir¦) or a new 
%    directory is created (¦overwrite¦ = 1, ¦fdirnew¦ ~= ¦fdir¦). If 
%    overwrite = 1, a new folder is created within the parent directory; 
%    the name of the new folder includes a suffix number in brackets which 
%    indicates the copy number. This is exactly the same Windows does when
%    it finds two files with the same name and the user decides to keep
%    them.
%        
%  OUTPUT VARIABLES
%  - fdirnew: final directory. ¦fdirnew¦ is the same as ¦fdir¦ in 3 cases:
%    ¬ overwrite = 0
%    ¬ overwrite = 1 and ¦fdir¦ does not exist
%    ¬ ¦fdir¦ is a disc unit, e.g. 'C:\'.
%     
%  INTERNALLY CALLED FUNCTIONS
%  - None
%
%  FUNCTION CALLS
%  1) fdirnew = makedir(fdir,0)
%  2) fdirnew = makedir(fdir,1)
%
%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  11 Jan 2017
%
%**************************************************************************

ind = strfind(fdir,'\'); % find backslash indices
if any(ind == length(fdir)) % if there is an ending backslash...
    fdir = fdir(1:end-1); % remove ending backslash, if exists
    ind = ind(1:end-1); % remove index associated ending backslash
end 

if ~isempty(ind)
    parentdir = fdir(1:ind(end)); % parent directory
    folder = fdir(ind(end)+1:end); % folder within parent directory
else
    parentdir = fdir; % parent directory
    folder = []; % no folder (e.g. fdir = 'C:')
end

fdirnew = fdir;
if ~isempty(folder)
    if ~overwrite % create a new folder if the one specified already exists
        cnt = 1;
        while isdir(fdirnew) % if the folder exists, the suffix number in the folder's name is increased until it does not exist
            cnt = cnt + 1;
            newfolder = strcat(folder,sprintf(' (%d)',cnt));
            fdirnew = fullfile(parentdir,newfolder);
        end

        if cnt > 1 % if the specified directory already exists...
            mkdir(parentdir,newfolder); % create new folder with copy subscript (i.e. "(copy number)")
            warning(['The specified directory already exists. A new folder'...
                     ' has been created']);
        end
    else % use the specified folder, even if it already exists
        if ~isdir(fdirnew) % if the specified directory does not exist...
            mkdir(parentdir,folder); % create new folder
        end
    end
end

