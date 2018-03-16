%% generateDocs: Generate published documentation from source code
%
% Generates documentation (published) from the path to all modules
%
% generateDocs() will create documentation in the folder this 
% function resides in, and will find all modules and source code files,
% publish them, and add them to documentation.

function generateDocs()
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
        rmdir(module.name, 's');
        mkdir(module.name);
        sources = dir(['..' filesep 'modules' filesep module.name filesep '*.m']);
        options.outputDir = [pwd filesep module.name filesep];
        for s = sources(1:end)
            publish([s.folder filesep s.name], options);
        end
        % Generate HTML index for this module
        fid = fopen(['resources' filesep 'module.html'], 'r');
        lines = textscan(fid, '%s', 'Delimiter', {'\n'});
        fclose(fid);
        fid = fopen([module.name filesep 'index.html'], 'w');
        for i = 1:numel(lines)
            % look for:
            %   MODULE_NAME
            %   MODULE_FUNCTIONS
            %   MODULE_DESCRIPTION
            line = lines{i};
            if contains(line, '<!-- MODULE_NAME -->')
                line = strrep(line, '<!-- MODULE_NAME -->', module.name);
            elseif contains(line, '<!-- MODULE_DESCRIPTION -->')
                line = strrep(line, '<!-- MODULE_DESCRIPTION -->', 'Hello world');
            elseif contains(line, '<!-- MODULE_FUNCTIONS')
                % Write all functions in divs
                for s = sources(1:end)
                    fprintf(fid, '<div>%s</div>', s.name(1:end-2));
                end
                line = '';
            end
            fprintf(fid, '%s\n', line);
        end
    end
    % Generate HTML index for documentation
end

function str = camel2normal(str)
    % find every capital letter
    mask = str >= 'A' & str <= 'Z';
    % splice in space
    inds = find(mask);
    for i = ends(end:-1:1)
        str = [str(1:(i - 1)) ' ' str(i:end)];
    end
    str(1) = upper(str(1));
end