%% generateDocs: Generate published documentation from source code
%
% Generates documentation (published) from the path to all modules
%
% generateDocs() will create documentation in the folder this 
% function resides in, and will find all modules and source code files,
% publish them, and add them to documentation.

%#ok<*NASGU>
function generateDocs(email)
    thisDir = pwd;
    % Create temp dir for cloning repo
    tDir = [tempdir 'autograderDocs' filesep];
    % remove if already exists
    status = rmdir(tDir, 's');
    mkdir(tDir);
    cleaner = onCleanup(@() cleanup(thisDir));
    cd(tDir);
    [~, ~] = system('git clone https://github.gatech.edu/CS1371/autograder.git --branch gh-pages --single-branch');
    tDir = [tDir 'autograder' filesep];
    cd(thisDir);
    options.format = 'html';
    % options.stylesheet = [pwd filesep 'resources' filesep 'stylesheet.xls'];
    options.createThumbnail = false;
    options.imageFormat = 'png';
    options.evalCode = false;
    options.catchError = false;
    options.showCode = true;

    % each directory is a module. Create a new directory in for it
    mods = dir(['..' filesep 'modules']);
    mods(~[mods.isdir]) = [];
    mods(strncmp({mods.name}, '.', 1)) = [];
    % For each directory, for each file, publish into mirror directory.
    for i = 1:numel(mods)
        module = mods(i);
        warning('off');
        status = rmdir([tDir module.name], 's');
        warning('on');
        mkdir([tDir module.name]);
        sources = dir(['..' filesep 'modules' filesep module.name filesep '*.m']);
        options.outputDir = [tDir module.name filesep];
        for s = sources'
            publish([s.folder filesep s.name], options);
        end
        % Generate HTML index for this module
        description = parseReadme(['..' filesep 'modules' filesep module.name  filesep 'README.md'], ...
            false, 'https://github.gatech.edu/CS1371/autograder/wiki/');
        
        fid = fopen(['resources' filesep 'module.html'], 'r');
        lines = textscan(fid, '%s', 'Delimiter', {'\n'});
        fclose(fid);
        lines = lines{1};
        fid = fopen([tDir module.name filesep 'index.html'], 'w');
        for l = 1:numel(lines)
            % look for:
            %   MODULE_NAME
            %   MODULE_FUNCTIONS
            %   MODULE_DESCRIPTION
            line = lines{l};
            if contains(line, '<!-- MODULE_NAME -->')
                line = strrep(line, '<!-- MODULE_NAME -->', camel2normal(module.name));
            elseif contains(line, '<!-- MODULE_DESCRIPTION -->')
                line = strrep(line, '<!-- MODULE_DESCRIPTION -->', strjoin(description, '\n'));
            elseif contains(line, '<!-- MODULE_FUNCTIONS')
                % Write all functions in divs
                for s = sources'
                    fprintf(fid, '<div data-link="%s">%s</div>', [s.name(1:end-2) '.html'], s.name(1:end-2));
                end
                line = '';
            end
            fprintf(fid, '%s\n', line);
        end
        fclose(fid);
    end
    fid = fopen(['resources' filesep 'index.html']);
    lines = textscan(fid, '%s', 'Delimiter', {'\n'});
    fclose(fid);
    lines = lines{1};
    fid = fopen([tDir 'index.html'], 'w');
    for l = 1:numel(lines)
        line = lines{l};
        % Look for MODULES
        if contains(line, '<!-- MODULES -->')
            line = '';
            for m = mods'
                fprintf(fid, '<div data-link="%s">%s</div>', [m.name '/index.html'], camel2normal(m.name));
            end
        end
        fprintf(fid, '%s\n', line);
    end
    fclose(fid);
    thisDir = cd(tDir);
    % commit our changes, create commit, push
    if exist('email', 'var')
        [~, ~] = system(['git config user.email ' email]);
        % get gpg key, if gpg exists
        [status, key] = system(['gpg --list-secret-keys --keyid-format LONG ' email]);
        if status == 0
            key = strsplit(key, '\n');
            key = key{1};
            inds = strfind(key, 'rsa4096/');
            key = key((inds(1)+8):end);
            inds = strfind(key, ' ');
            key = key(1:(inds(1) - 1));
            [~, ~] = system(['git config user.signingKey ' key]);
            [~, ~] = system('git config commit.gpgsign true');
        else
            [~, ~] = system('git config commit.gpgsign false');
        end
    end
    
    [~, ~] = system('git add *');
    [~, ~] = system('git commit -m "Update Documentation"');
    [~, ~] = system('git push');
    cd(thisDir);
    status = rmdir([tDir '..' filesep], 's');
end

function str = camel2normal(str)
    % find every capital letter
    mask = str >= 'A' & str <= 'Z';
    % splice in space
    inds = find(mask);
    for i = inds(end:-1:1)
        str = [str(1:(i - 1)) ' ' str(i:end)];
    end
    str(1) = upper(str(1));
end

function cleanup(thisDir)
    warning('off');
    status = rmdir('autograderDocs', 's');
    warning('on');
    if exist(thisDir, 'var')
        cd(thisDir);
    end
end