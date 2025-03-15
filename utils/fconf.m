function y = fconf(cmd, field, value)
    % FCONF reads/writes from a config file similar to preferences.
    %
    %   FCONF COMMAND FIELD [VALUE]
    %   FCONF read FIELD
    %   FCONF write FIELD VALUE
    %
    % calling "fconf" requires specifying a valid MATLAB struct fieldname
    % and the value to write into the general-use config file. MATLAB out-of-the-box
    % supports JSON syntax and typecasting, (although TOML would be preferrable.) Note
    % this is **case-sensitive**. There is additional error-checking to make sure
    % a nested struct is not blown away by missing nested fields.
    %
    % Using the command syntax will store everything as a char array, whereas the
    % function syntax will preserve the variable type. (conversion is left up to the
    % JSON parser: Consider using base64 encoding for floating point data or a separate
    % string conversion library like Ryu or Dragonbox.)
    %
    % Examples:
    % % command syntax (reading will return '8192'.):
    % fconf write graphing.DefaultNumPoints 8192
    %
    % % function syntax (reading will return (double) 8192.):
    % fconf('read', 'graphing.DefaultNumPoints', 8192)

    y = [];
    CFG_PATH = fullfile(fileparts(mfilename('fullpath')), 'config.json');

    % save on excessive read/write ops if the file hasn't been modified.
    persistent pStat;
    persistent pCfgState;
    if ~isfile(CFG_PATH)
        fid = fopen(CFG_PATH, 'w');
        if (fid < 0)
            error('fconf:InvalidSyntax', ...
                'Unable to instantiate CFG file in source directory.');
        end
        fwrite(fid, jsonencode(struct.empty));
        fclose(fid);
    end
    if isempty(pStat), pStat = dir(CFG_PATH); end
    if (nargin == 1) && strncmpi(cmd, 'r', 1)
        % reload the state if the file's been modified externally.
        if isfile(CFG_PATH)
            if ~isequal(pStat, dir(CFG_PATH))
                pCfgState = jsondecode(fileread(CFG_PATH));
                pStat = dir(CFG_PATH);
            end
            y = pCfgState;
        end
        return
    end
    if (nargin ~= 3) && strncmpi(cmd, 'r', 1)
        error('fconf:InvalidSyntax', ...
            '<COMMAND> FIELD [VALUE] syntax required.');
    end
    splitfields = strsplit(field, '.'); % check for nesting.
    badInds = ~cellfun(@isvarname, splitfields);
    if any(badInds)
        error('fconf:InvalidValue', ...
            'Bad fieldnames found in "%s".', field);
    end
    L = numel(splitfields);
    sep = cell(1, 2*L);
    sep(2:2:end) = splitfields;
    sep(1:2:end-1) = {'.'};
    S = substruct(sep{:});
    if strncmpi(cmd, 'r', 1)
        if ~isfile(CFG_PATH)
            return
        else
            % reload the state if the file's been modified.
            if ~isequal(pStat, dir(CFG_PATH))
                pCfgState = jsondecode(fileread(CFG_PATH));
                pStat = dir(CFG_PATH);
            end
            d = pCfgState;
            try
                y = subsref(d, S);
            catch
                y = [];
            end
        end
    else
        if ~isfile(CFG_PATH)
            d = struct;
        else
            % reload the state if modified.
            if ~isequal(pStat, dir(CFG_PATH))
                pCfgState = jsondecode(fileread(CFG_PATH));
                pStat = dir(CFG_PATH);
            end
            d = pCfgState;
        end

        % corner-case check that we aren't blowing away a nested struct.
        % Either iterate down the stack and check if a field, or check the top
        % level for a struct.
        dminus1 = d;
        if ~isempty(S(1:end-1))
            S2 = S;
            while(~isempty(S2))
                if ~isfield(dminus1, S2(1).subs)
                    break
                end
                dminus1 = subsref(dminus1, S2(1));
                S2 = S2(2:end);
            end
        end
        if isfield(dminus1, S(end).subs) && isstruct(subsref(dminus1, S(end)))
            error('fconf:BadFieldValue', ...
                'Specified field "%s" is a nested struct.', S(end).subs);
        end
        d2 = subsasgn(d, S, value);
        fid = fopen(CFG_PATH, 'w');
        if (fid < 0)
            error('fconf:FileIOError', ...
                'Unable to open the CFG file.');
        end
        fprintf(fid, '%s\n', jsonencode(d2, 'PrettyPrint', true));
        fclose(fid);

        % re-track the new config state and file-write.
        pCfgState = d2;
        pStat = dir(CFG_PATH);
    end

end % fconf


    