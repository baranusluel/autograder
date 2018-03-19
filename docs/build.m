%% build: Completely Build the Autograder
%
% build will checkout the appropriate branch of the Autograder, lint it,
% and if there are no errors, will completely generate the mlappinstall
% file and the documentation.
%
% build() Lints all the modules. If linting passes, build() will generate 
% an installer (mlappinstall), and place it in the bin folder.
% Then, it will generate new documentation
%
% build(O) uses the options specified in struct O to customize the build
% sequence. For more information on what can be in O, see Remarks
%
% P = build(___) will return any problems encountered in P instead of
% erroring.
%
%%% Remarks
%
% build is a one-click option for completely building the latest
% autograder. It can be customized by specifying different options in the
% input structure O. All options not specified are given the default value.
%
% The available options are:
%
% * branch
%
% The branch to checkout for building. Defaults to the current branch. If
% the value given is empty, then the current branch is used.
%
% * generateDocs
%
% A logical - if true, generateDocs() is run. Defaults to true
%
% * installerPath
%
% The path to use for the generated installer. Defaults to the bin folder
% of the Autograder. If specified and empty, no installer is generated.
%
% * checkSuppressed
%
% A logical - if true, linting detects warnings normally suppressed via the
% %ok construct. Defaults to false
%
% * lint
%
% A logical - if true, linting is done before building. If linting returns
% errors, the build is stopped - no installer or documentation is created.
%
function problems = build(opts)
    if ~exist('opts', 'var')
        % Default correctly
        % get current branch:
        opts.branch = '';
        opts.generateDocs = true;
        opts.installerPath = ['..' filesep 'bin' filesep];
        opts.checkSuppressed = false;
        opts.lint = false;
    end
    [path, ~, ~] = fileparts(mfilename('fullpath'));
    thisFolder = cd(path);
    
    % if opts.branch isn't empty, checkout branch. If unable to, say so
    if ~isempty(opts.branch)
        [status, msg] = system(['git checkout ' opts.branch]);
        if status ~= 0
            e = MException('AUTOGRADER:BUILD:GITERROR', ...
                    'Unable to switch to branch %s\nGit gave this error:\n%s', ...
                    opts.branch, msg);
            if nargout == 0
                throw(e);
            else
                problems = e;
            end
        end
    end
    
    if opts.lint
        % We are linting. If any errors, stop and throw
        % lint each module. 
        problems = [];
        % get all files to be linted (files under modules/**/*.m)
        files = dir(['..' filesep 'modules' filesep '**' filesep '*.m']);
        folders = {files.folder};
        files = {files.name};
        files = cellfun(@(fld, fil)([fld filesep fil]), folders, files, ...
            'uni', false);
        options = {'-id', '-fullpath', '-config=factory'};
        if opts.checkSuppressed
            options = [options {'-notok'}];
        end
        info = checkcode(files, options{:}, '-struct');
        if ~all(cellfun(@isempty, info, 'uni', true))
            % if requesting output, don't error
            if nargout == 0
                e = MException('AUTOGRADER:BUILD:LINTFAILURE', ...
                    'Files failed lint test');
                throw(e);
            else
                problems = info;
                return;
            end
        end
    end
    
    % if given installer path, create installer
    if ~isempty(opts.installerPath)
        % Read lines
        fid = fopen('Autograder.prj', 'rt');
        lines = strsplit(char(fread(fid)'), newline);
        fclose(fid);
        % Set settings in PRJ file accordingly

        % Icons
        % find <param.icons> and </param.icons>, fill with <file>
        iconS = find(contains(lines, '<param.icons>'), 1);
        iconE = find(contains(lines, '</param.icons>'), 1);
        sizes = regexprep({'${PROJECT_ROOT}\docs\resources\images\icon_48.png', ...
            '${PROJECT_ROOT}\docs\resources\images\icon_24.png', ...
            '${PROJECT_ROOT}\docs\resources\images\icon_16.png'}, ...
            '\\', '\\\\');
        for i = (iconS + 1):(iconE - 1)
            % find file tags; replace innards
            lines{i} = regexprep(lines{i}, '(?<=<file>).+(?=<\/file>)', ...
                ['\' sizes{i - iconS}]);
        end

        % Included Files
        % should still work correctly, since based on ROOT

        % Main File
        % should still work correctly, since based on ROOT

        % Output dir
        % param.output is based on root, but build-deliverables isn't. Replace
        % accordingly.
        outputS = find(contains(lines, '<build-deliverables>'), 1);
        outputE = find(contains(lines, '</build-deliverables>'), 1);

        % It should look like this:
        %<build-deliverables>
          %<file location="C:\Users\alexhrao\Documents\autograder" 
          %name="bin" optional="false">
          %C:\Users\alexhrao\Documents\autograder\bin</file>
        %</build-deliverables>
        for i = (outputS + 1):(outputE - 1)
            % relace <file location="stuff" with path TO folder, NOT INCLUDING
            % BIN. no trailing \
            location = dir(['..' filesep '..' filesep 'autograder']);
            location = regexprep(location(1).folder, '\\', '\\\\');
            lines{i} = regexprep(lines{i}, '(?<=\s*<file location=\").+?(?=\")', location);

            % replace inside name
            lines{i} = regexprep(lines{i}, '(?<=name=\").+?(?=\")', 'bin');
            % replace inside tag
            lines{i} = regexprep(lines{i}, '(?<=>).*?(?=<\/file>)', ...
                [location strrep(filesep, '\', '\\') 'bin']);
        end
        proj = strjoin(lines, newline);

        % Write to root
        fid = fopen(['..' filesep 'Autograder.prj'], 'wt');
        fwrite(fid, proj);
        fclose(fid);

        % Create app
        matlab.apputil.package(['..' filesep 'Autograder.prj']);

        % Delete root .prj
        delete(['..' filesep 'Autograder.prj']);
    end
    
    if opts.generateDocs
        generateDocs;
    end
    cd(thisFolder);
end

