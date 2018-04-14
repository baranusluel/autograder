%% generateDocs: Generate published documentation from source code
%
% Generates documentation (published) from the path to all modules
%
% generateDocs() will create documentation in the folder this
% function resides in, and will find all modules and source code files,
% publish them, and add them to documentation.

function generateDocs(email)
    thisDir = pwd;
    thisPath = path;

    addpath(genpath([fileparts(pwd) filesep 'unitTests']));
    addpath(genpath([fileparts(pwd) filesep 'modules']));
    addpath(genpath(pwd));
    % if the email doesn't exist, try to get it from the current folder...
    if ~exist('email', 'var')
        [status, email] = system('git config --get user.email');
        if status == 0
            email = strtok(email, newline);
        else
            clear('email');
        end
    end
    [genFolder, ~, ~] = fileparts(mfilename('fullpath'));
    % Create temp dir for cloning repo
    tDir = [tempname filesep];
    % remove if already exists
    mkdir(tDir);
    cleaner = onCleanup(@() cleanup(thisDir, thisPath));
    cd(tDir);
    [~, ~] = system('git clone https://github.gatech.edu/CS1371/autograder.git --branch gh-pages --single-branch');
    tDir = [tDir 'autograder' filesep];
    cd(genFolder);
    options.format = 'html';
    options.stylesheet = fullfile(pwd, 'resources', 'stylesheet.xsl');
    options.createThumbnail = false;
    options.imageFormat = 'png';
    options.evalCode = false;
    options.catchError = false;
    options.showCode = false;

    % each directory is a module. Create a new directory in for it
    mods = dir(['..' filesep 'modules']);
    mods(~[mods.isdir]) = [];
    mods(strncmp({mods.name}, '.', 1)) = [];
    % For each directory, for each file, publish into mirror directory.
    parfor i = 1:numel(mods)
        module = mods(i);
        warning('off');
        [~] = rmdir([tDir module.name], 's');
        warning('on');
        mkdir([tDir module.name]);
        sources = dir(['..' filesep 'modules' filesep module.name filesep '*.m']);
        modOpts = options;
        modOpts.outputDir = [tDir module.name filesep];
        for s = sources'
            publish([s.folder filesep s.name], modOpts);
        end
        % Generate HTML index for this module
        description = parseReadme(['..' filesep 'modules' filesep module.name  filesep 'README.md'], ...
            false, 'https://github.gatech.edu/CS1371/autograder/wiki/');

        fid = fopen(['resources' filesep 'module.html'], 'rt');
        lines = strsplit(char(fread(fid)'), newline);
        fclose(fid);
        fid = fopen([tDir module.name filesep 'index.html'], 'wt');
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
            elseif contains(line, '<!-- MODULE_FUNCTIONS -->')
                % Write all functions in divs
                for s = sources'
                    fprintf(fid, '<div data-link="%s">%s</div>\n', [s.name(1:end-2) '.html'], s.name(1:end-2));
                end
                line = '';
            end
            fprintf(fid, '%s\n', line);
        end
        fclose(fid);
    end
    opts.showFeedback = false;
    opts.output = '';
    opts.completeFeedback = true;
    opts.modules = {};
    opts.css = [fileparts(pwd) filesep 'unitTests' filesep 'index.css'];
    [status, html] = autotester(opts);
    % splice in header:
    body = regexp(html, '<body.*?>', 'end');
    html = [html(1:body) backNav(tDir) html((body+1):end)];
    fid = fopen([tDir 'results.html'], 'wt');
    fwrite(fid, html);
    fclose(fid);
    fid = fopen(['resources' filesep 'index.html'], 'rt');
    lines = strsplit(char(fread(fid)'), newline);
    fclose(fid);
    fid = fopen([tDir 'index.html'], 'wt');
    for l = 1:numel(lines)
        line = lines{l};
        % Look for MODULES
        if contains(line, '<!-- MODULES -->')
            line = '';
            for m = mods'
                fprintf(fid, '<div data-link="%s">%s</div>', [m.name '/index.html'], camel2normal(m.name));
            end
        elseif contains(line, '<!-- UNIT_RESULTS -->')
            if status
                line = '<i class="fas fa-check"></i>';
            else
                line = '<i class="fas fa-times"></i>';
            end
        end
        fprintf(fid, '%s\n', line);
    end
    fclose(fid);
    % create unit test results
    cd(tDir);
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
    [~] = rmdir([tDir '..' filesep], 's');
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

function cleanup(thisDir, thisPath)
    warning('off');
    [~] = rmdir('autograderDocs', 's');
    warning('on');
    if exist('thisDir', 'var')
        cd(thisDir);
    end
    if exist('thisPath', 'var')
        path(thisPath, '');
    end
end

function nav = backNav(tDir)
    fid = fopen([tDir 'rubric.html'], 'rt');
    data = char(fread(fid)');
    fclose(fid);
    nav = strfind(data, '<nav');
    nav = nav(1);
    nav = [nav, strfind(data, '</nav>') - 1];
    nav = nav(1:2);
    nav = [data(nav(1):nav(end)) '</nav>'];
end