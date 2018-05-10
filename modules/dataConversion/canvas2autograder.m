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
function canvas2autograder(canvasPath,canvasGradebook,outPath)

    % Canvas Information
    firstStudentRow = 3;
    studentNameCol = 1;
    canvasIDcol = 2;
    tsquareIDcol = 4;
    
    if ~contains(canvasPath,'.zip')
        throw(MException('AUTOGRADER:canvas2autograder:invalidFile',...
                         'The Path given is not a .zip file'));
    end
    unzippedCanvas = unzipArchive(canvasPath,'temp',true);
    if ~contains(canvasGradebook,'.csv')
        throw(MException('AUTOGRADER:canvas2autograder:invalidGradebook',...
                         'The Gradebook given is not a .csv file'));
    end
    [~,~,gradebook] = xlsread(canvasGradebook);

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
    for key = keys(folderMap)
        mkdir(fullfile(outPath,folderMap(key{1})))
        mkdir(fullfile(outPath,folderMap(key{1}),'feedback'))
    end

    % Format of the canvas file:
    % lastNamefirstName(_2ndLastName)(_late)_canvasId_hash_fileName-version.ext
    allFiles = dir(fullfile(unzippedCanvas,'*_*_*_*.*'));

    % Loop through all files
    for i = 1:length(allFiles)
        fileName = allFiles(i).name;

        % Get parts of file name
        tokens = strsplit(fileName,'_');
        
        % Extract Student ID and file name
        
        % Put ABCs filenames back together.
        if any(strcmp(tokens,'ABCs'))
            ABCsMask = strcmp(tokens,'ABCs');
            toCatMask = [false, ABCsMask(1:end-1)];
            tokens{ABCsMask} = [tokens{ABCsMask} '_' tokens{toCatMask}];
            tokens(toCatMask) = [];
        end

        % Get Student CanvasID
        for j = 1:length(tokens)
            if ~isnan(str2double(tokens{j}))
                canvasID = str2double(tokens{j});
                break
            end
        end
        
        % Remove Version tag
        if contains(tokens{end},'-')
            fparts = strsplit(tokens{end},{'-','.'});
            tokens{end} = [fparts{1} '.' fparts{3}];
        end

        % Copy the file to new location
        copyfile(fullfile(unzippedCanvas,allFiles(i).name),...
                 fullfile(outPath,folderMap(canvasID),tokens{end}));
    end

    % Write info.csv
    fh = fopen(fullfile(outPath,'info.csv'),'wt');  
    toWrite = [strjoin(join(gradebook(firstStudnetRow:end, [tsquareIDcol studentNameCol]), ', "'), '"\n') '"'];
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

