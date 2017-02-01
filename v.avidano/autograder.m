function runtimeInfo = autograder(rubric,studentDirName,homeworkName)
rubric = 'rubric.json';
studentDirName = 'HW1';
homeworkName = studentDirName;
runDir = 'C:\Users\mavidano3\Documents\MATLAB\autograderRun';
cd(runDir);

%File Structure
%{
(studentFolderName): dir
    contains student submissiond downloaded from Tsquare
Solutions: dir
    contains solution files (.m)
SupportingFiles: dir
    contains supporting files (.mat)
rubric file (.json)

%}

close(get(0,'Children')); %close all figures
fclose('all');

%% Initialization: define paths to solution and supporting files
solutionPath = fullfile(pwd,'Solutions');
supportPath = fullfile(pwd,'SupportingFiles');
addpath(fullfile(pwd,'SupportingFiles'));


%% Initialization: Start up a parallel pool with one worker
%Parallel pool used while running student solutions
if isempty(gcp('nocreate'))
    %Start parallel pool if not already active
    timeoutInMinutes = 180;
    p = parpool('IdleTimeout', timeoutInMinutes);
else
    %Remove all queued futures in case any are left from previous runs
    p = gcp;
    p.FevalQueue.RunningFutures.cancel;
    p.FevalQueue.QueuedFutures.cancel;
end
%If opening the pool fails, check out this page: 
% http://www.mathworks.com/matlabcentral/answers/92124-why-am-i-unable-to-use-parpool-with-the-local-scheduler-or-validate-my-local-configuration-of-parall
%Or try running this command:
% distcomp.feature( 'LocalUseMpiexec', false)

%% Conversion: Convert json file to structure.
%First convert json to structure
sa = json2struct(rubric);

%Then, convert structure for use with feval
sa = eval2feval(sa,solutionPath,supportPath);


%% Solution: Get solution file outputs (correct outputs)
cd('Solutions')
cleanSolutionDirectory; %remove all files that are not .m files
sa = getSolutionOutputs(sa,solutionPath);
cd('..');

%% Student: Initialize student array
emptyStudent = initializeStudentStructure(sa);


%% Student: Grade students
cd(studentDirName);

% Get all student names
list = dir;
folderNames = {list(3:end).name};
folderNames = folderNames([list(3:end).isdir]);

% Parse folder names
[last,rest] = strtok(folderNames,',');
[first]  = strtok(rest,', (');

% Initialize loop variables
save_fn = 'runtimeSave.mat';
if exist(save_fn,'file')
    % Load previous run data; starts autograder where it left off
    load(save_fn);
else
    % Initialize run data; first run only
    grades = nan(length(folderNames),1);
    runtimeInfo.individualRuntimes = zeros(length(folderNames),1); %RUNTIME_MONITOR
    runtimeInfo.names = cellfun(@(x,y) [x ' ' y],first,last,'UniformOutput',false)'; %RUNTIME_MONITOR\
%     students = repmat(emptyStudent,length(folderNames),1);
%     students(1).points = [];
%     students(1).problemScore = [];
end

for i = find(isnan(grades))'
    %% Start timer
    studentName = [first{i} ' ' last{i}];
    fprintf('Grading %s...',studentName); %RUNTIME_MONITOR
    tic; %RUNTIME_MONITOR


    %% Move to student's folder
    cd(folderNames{i});


    %% Use submitted files to grade student
    cd('Submission attachment(s)');
    % TODO LOW implement ability to unzip student submissions
    functionNames = cleanStudentSubmissions(sa); % remove all unneeded files
    student = getStudentOutputs(emptyStudent,sa,functionNames);
    student = gradeStudent(student,sa);
    students(i,:) = student;
    grades(i) = sum([student.problemScore]);
    cd('..');


    %% Generate feedback file
    cd('Feedback Attachment(s)');
    giveStudentFeedback(student,sa,studentName,grades(i),homeworkName);
%     winopen('feedback.html')
    cd('../..');
    fclose('all'); %Backup incase a student / autograder forgot to close a file


    %% Stop timer, save state
    timeElapsed = toc; %RUNTIME_MONITOR
    fprintf('Elapsed time is %.6f seconds.\n',timeElapsed); %RUNTIME_MONITOR
    runtimeInfo.individualRuntimes(i) = timeElapsed; %RUNTIME_MONITOR
    fprintf('Progress: %d/%d students graded\n',i,length(folderNames));
    if mod(i,100) == 50
        save(save_fn,'grades','runtimeInfo','students');
    end
end

%% Student,Cleanup: Add grades to master, remove priorRun info
updateGradeFile(grades);
movefile(save_fn,['../' save_fn])
cd('..');


%% Cleanup: Take supporting files off of the path, close parallel pool
rmpath(fullfile(pwd,'SupportingFiles'));
delete(p);


%% Cleanup: Build runtimeInfo structure
runtimeInfoVec = runtimeInfo.individualRuntimes;
runtimeInfo.averageRuntime = mean(runtimeInfoVec);
[~,loc] = max(runtimeInfoVec);
runtimeInfo.longestPerson = [last{loc} ', ' first{loc}];
save(save_fn,'grades','runtimeInfo','students');
end


%% Helper Functions
function cleanSolutionDirectory
names = dir;
names = {names(3:end).name};
mask = cellfun(@isempty,strfind(names,'.m'));
if any(mask)
    delete(names{mask});
end
end


function functionNames = cleanStudentSubmissions(sa)
%% remove all unneeded files
names = dir;
functionNames = {names(3:end).name};
if ~isempty(functionNames)
    allowedNames = cellfun(@(x) [x '.m'],{sa.funcName},'UniformOutput',false)';
    mask = any(strcmp(repmat(functionNames,length(allowedNames),1),...
                      repmat(allowedNames,1,length(functionNames))));
    if any(~mask)
        delete(functionNames{~mask});
    end
    functionNames = functionNames(mask);
end

end


function emptyStudent = initializeStudentStructure(sa)
%preallocate student structure array
%
% Fields
%   success: logical
%   errorMessage: char
%   outValues: cell w/ values (varying types)
%   outType: cell w/ string of 'value','file', and/or 'figure'
%   outFiles: string of filenames

fields = {'success','errorMessage','outType','outValues','outFiles','outFigures'};
c = cell(1,length(sa));
for i = 1:length(sa)
    c{i} = cell(1,length(sa(i).tests));
end
in = cell(1,2*length(fields));
for i = 1:length(fields)
    in(2*i-1) = fields(i);
    in(2*i) = {c};
end
emptyStudent = struct(in{:});
end


