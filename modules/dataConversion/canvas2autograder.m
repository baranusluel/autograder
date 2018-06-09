%% canvas2autograder: Converts Canvas files to autograder structure
%
% Creates correctly formatted student folders from the Canvas download
%
% PATH = canvas2autograder(CANVAS,GRADEBOOK,OUTPATH) Takes the path in 
% CANVAS and unzips accordingly, reformatting the folder names correctly
% using the names held in the csv at GRADEBOOK, placing them in OUTPATH, 
% and ensuring that the contents of the Student folders are always just the
% student's files.
%
%%% Remarks
%
% This function will create a series of folders within the working
% directory of the autograder to ensure that there is no confusion between
% different student's submitted files as well as create runnable files from
% Canvas downloaded student code.
%
%%% Exceptions
%
% AUTOGRADER:canvas2autograder:invalidFile if the canvasZipFile either does
% not contain students or is not in Canvas format.
%
% AUTOGRADER:canvas2autograder:invalidGradebook if the gradebook either
% does not exist or is not of correct format.
%
%%% Unit Tests
%
%   CANVAS = 'C:\Users\...\Canvas.zip'; % Valid path
%   GRADEBOOK = 'C:\Users\...\gradebook.csv'; % Valid gradebook
%   OUTPATH = 'C:\Users\...\students';
%   canvas2autograder(CANVAS,GRADEBOOK,OUTPATH);
%
%   OUTPATH contains new, unzipped path that is completely
%   unzipped all student's folders, and the folder names
%   are correct.
%
%   CANVAS = ''; % Invalid Path
%   GRADEBOOK = 'C:\Users\...\gradebook.csv'; % Valid gradebook
%   canvas2autograder(CANVAS);
%
%   Threw invalidFile exception
%
%   CANVAS = 'C:\Users\...\Canvas.zip'; % Valid path, but INVALID archive!
%   canvas2autograder(CANVAS);
%
%   Threw invalidFile exception
%
function canvas2autograder(canvasPath, canvasGradebook, outPath, progress)

    % Canvas Information
    firstStudentRow = 3;
    studentNameCol = 1;
    canvasIDcol = 2;
    tsquareIDcol = 4;
    
    if ~contains(canvasPath,'.zip')
        throw(MException('AUTOGRADER:canvas2autograder:invalidFile',...
                         'The Path given is not a .zip file'));
    end
    unzippedCanvas = unzipArchive(canvasPath,outPath,false);
    if ~contains(canvasGradebook,'.csv')
        throw(MException('AUTOGRADER:canvas2autograder:invalidGradebook',...
                         'The Gradebook given is not a .csv file'));
    end
    warning('off');
    gradebook = readtable(canvasGradebook);
    warning('on');
    tmp = table2cell(gradebook);
    origNames = gradebook.Properties.VariableDescriptions;
    names = gradebook.Properties.VariableNames;
    for n = numel(origNames):-1:1
        if ~isempty(origNames{n})
            [~, name] = strtok(origNames{n}, '''');
            name = name(2:end-1);
            names{1, n} = name;
        end
    end
    gradebook = [names; tmp];

    % Validate Inputs
    if ~isValidCanvas(unzippedCanvas)
        throw(MException('AUTOGRADER:canvas2autograder:invalidFile',...
                         'The Path given does not contain any valid student submissions'));
    end
    if ~isValidGradebook(gradebook)
        throw(MException('AUTOGRADER:canvas2autograder:invalidGradebook',...
                         'The Gradebook given is not a valid canvas csv'));
    end

    % Generate folders Map
    folderMap = containers.Map(gradebook(firstStudentRow:end,canvasIDcol),...
                               gradebook(firstStudentRow:end,tsquareIDcol));

    % Generate empty folders.
    progress.Value = 0;
    progress.Indeterminate = 'off';
    progress.Message = 'Creating Student Folders';
    
    for key = keys(folderMap)
        mkdir(fullfile(outPath,folderMap(key{1})));
        progress.Value = min([progress.Value + 1/numel(folderMap.keys), 1]);
    end

    % Format of the canvas file:
    % lastNamefirstName(_2ndLastName)(_late)_canvasId_hash_fileName-version.ext
    allFiles = dir(fullfile(unzippedCanvas,'*_*_*_*.*'));

    % Loop through all files
    progress.Indeterminate = 'on';
    progress.Value = 0;
    progress.Message = 'Sorting Files';
    for f = numel(allFiles):-1:1
        name = allFiles(f).name;
        tokens = strsplit(name, '_');
        if any(strcmp(tokens, 'ABCs'))
            ABCs = strcmp(tokens, 'ABCs');
            mask = [false ABCs(1:end-1)];
            tokens{ABCs} = [tokens{ABCs} '_' tokens{mask}];
            tokens(mask) = [];
        end
        
        for j = 1:length(tokens)
            if ~isnan(str2double(tokens{j}))
                canvasID = str2double(tokens{j});
                break;
            end
        end
        
        if contains(tokens{end},'-')
            fparts = strsplit(tokens{end},{'-','.'});
            tokens{end} = [fparts{1} '.' fparts{3}];
        end
        
        src = fullfile(unzippedCanvas, allFiles(f).name);
        dest = fullfile(outPath, folderMap(canvasID), tokens{end});
        workers(f) = parfeval(@movefile, 0, src, dest);
    end
    
    progress.Indeterminate = 'off';
    progress.Value = 0;
    while ~all([workers.Read])
        workers.fetchNext();
        progress.Value = min([progress.Value + 1/numel(workers), 1]);
    end
    delete(workers);
    % Write info.csv
    fh = fopen(fullfile(outPath,'info.csv'),'wt');  
    toWrite = ['"' strjoin(join(gradebook(firstStudentRow:end, [studentNameCol tsquareIDcol]), '", "'), '"\n"') '"'];
    fwrite(fh,toWrite);
    fclose(fh);
end

function log = isValidGradebook(gradebook)
    log = strcmp(gradebook{1,1},'Student')...
       && strcmp(gradebook{1,2},'ID')...
       && strcmp(gradebook{1,3},'SIS User ID')...
       && strcmp(gradebook{1,4},'SIS Login ID')...
       && strcmp(gradebook{1,5},'Section');
end

function log = isValidCanvas(canvasPath)
    files = dir(fullfile(canvasPath,'*_*_*_*.*'));
    fileNames = {files.name};
    log = ~isempty(fileNames);
end

