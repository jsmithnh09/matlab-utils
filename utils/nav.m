function nav(args)
% NAV navigates to a function or folder's active directory.
%
%   NAV FILENAME    will navigate to the filename active directory.
%   NAV -DOCS       will navigate to the users documents home directory.
%   NAV -DOWNLOADS  will navigate to the downloads folder.
%   NAV -S          saves the current active directory in persistent memory.
%   NAV -H          navigates to the "hotswitch" directory, or the last NAV -S call.
%
% See Also: CD

persistent pSave;
if args(1) == '-'
    args = args(2:end);
    hdir = getenv('HOMEDIR');
    switch lower(args)
        case {'download', 'downloads'}
            cd(fullfile(hdir, 'Downloads'));
            return;
        case 'docs'
            cd(fullfile(hdir, 'Documents'));
        case 's'
            pSave = pwd;
            return;
        case 'h'
            if isempty(pSave)
                return;
            else
                cd(fileparts(pSave));
                return;
            end
        otherwise
            error('Unknown directive "-%s"', args);
    end
end
fpath = fileparts(which(args));
if isempty(fpath)
    error('Unrecognized folder/function "%s".', args);
else
    cd(fpath);
end

end



