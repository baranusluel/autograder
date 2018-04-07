%% canvas2autograder: Converts Canvas files to autograder structure
%
% Creates correctly formatted student folders from the Canvas download
%
% PATH = canvas2autograder(CANVAS,GRADEBOOK) Takes the path in CANVAS and unzips
% accordingly, reformatting the folder names correctly using the names held
% in the csv at GRADEBOOK, and ensuring that 
% the contents of the Student folders are always just the student's files.
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
% AUTOGRADER:CANVAS2AUTOGRADER:INVALIDFILE if the canvasZipFile either does
% not contain students or is not in Canvas format.
% 
% AUTOGRADER:CANVAS2AUTOGRADER:INVALIDGRADEBOOK if the gradebook either
% does not exist or is not of correct format.
%
%%% Unit Tests
%
%   CANVAS = 'C:\Users\...\Canvas.zip'; % Valid path
%   GRADEBOOK = 'C:\Users\...\gradebook.csv'; % Valid gradebook
%   PATH = canvas2autograder(CANVAS,GRADEBOOK);
%
%   PATH points to a new, unzipped path that is completely 
%   unzipped all student's folders, and the folder names 
%   are correct.
%
%   CANVAS = ''; % Invalid Path
%   GRADEBOOK = 'C:\Users\...\gradebook.csv'; % Valid gradebook
%   PATH = canvas2autograder(CANVAS);
%
%   Threw INVALIDFILE exception
%
%   CANVAS = 'C:\Users\...\Canvas.zip'; % Valid path, but INVALID archive!
%   PATH = canvas2autograder(CANVAS);
%
%   Threw INVALIDFILE exception
%
function newPath = canvas2autograder(canvasPath,canvasGradebook)
    
    cur = pwd;
    if ~contains(canvasGradebook,'.zip')
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
    folderMap = containers.Map(gradebook(3:end,2),gradebook(3:end,4));
    
    % Generate empty folders.
    for key = keys(folderMap)
        mkdir(fullfile(cur,'submissions',folderMap(key{1})))
        mkdir(fullfile(cur,'submissions',folderMap(key{1}),'feedback'))
    end
    
    % Format of the canvas file:
    % lastNamefirstName(_2ndLastName)(_late)_canvasId_hash_fileName-version.ext
    allFiles = dir(unzippedCanvas);
    
    % Loop through all files
    for i = 1:length(allFiles)
        fileName = allFiles(i).name;
        
        % Remove if a student submitted after 8:00pm
        fileName = strrep(fileName,'_late','');
        
        % Get parts of file name and account for 
        tokens = strsplit(fileName,'_');
        if isempty(str2double(tokens{2}))
            tokens{1} = [tokens{1} '_' tokens{2}];
            tokens(2) = [];
        end
        if length(tokens) == 5
            tokens{4} = [tokens{4} '_' tokens{5}];
            tokens(5) = [];
        end
        
        % Remove Version tag
        if contains(token{4},'-')
            fparts = strsplit(token{4},{'-','.'});
            token{4} = [fparts{1} '.' fparts{3}];
        end
        
        % Get key
        key = str2double(tokens{2});
        
        % Copy the file to new location
        copyfile(fullfile(unzippedCanvas,allfiles(i).name),...
                 fullfile(cur,'submissions',folderMap(key)));
    end
    
    for key = keys(folderMap)
        % Process student submissions
        processStudentSubmissions(fullfile(cur,'submissions',folderMap(key{1})));
    end
    
    % Output Variable
    newPath = fullfile(cur,'submissions');
    
    % Write info.csv
    fh = fopen(fullfile(newPath,'info.csv'),'w');
    for i = 3:size(gradebook,1)-1
        fprintf(fh,'%s,"%s"\n',gradebook{i,4},gradebook{i,1});
    end
    fprintf(fh,'%s,"%s"',gradebook{end,4},gradebook{end,1});
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