%% generateStudents: Generate Student array
%
% generateStudents turns a set of Student Folders into a vector of Students
%
% S = generateStudents(P, B) will convert all the student folders found in P
% into Students, and will return a vector in alphabetical order (case insensitive)
% of the Students, where alphabetical order is based on their ID.
% Additionally, it will attempt to update progress bar B.
%
%%% Remarks
%
% generateStudents will always expect a correctly-structured path.
%
%%% Exceptions
%
% An AUTOGRADER:generateStudents:invalidPath exception will be thrown if the path is
% invalid or if no student folders are found.
%
% An AUTOGRADER:generateStudents:foldersNotFound exception will be thrown if
% no student folders are found.
%
%%% Unit Tests
%
%   For all cases, assume B is a valid uiprogressdlg.
%
%   P = 'C:\Users\...\students.zip'; % Valid path to student folders
%   S = generateStudents(P, B);
%
%   S -> A vector of students in alphabetical order, by their GT Username
%
%   P = ''; % Invalid Path
%   S = generateStudents(P, B);
%
%   Threw invalidPath exception
%
%   P = ''; % Valid path, but no student folders are found
%   S = generateStudents(P, B);
%
%   Threw foldersNotFound exception
%

% Notes for implementation:
% Initializing an array of Student is weird. You have to start with the END first.
% In other words, say you have 1000 students. You should START with the one thousandth student:
%
%   students(1000) = Student(inputs);
%
% And then work your way down to 1 from there.

function students = generateStudents(path, progress)
    progress.Message = 'Generating Students';
    progress.Indeterminate = 'on';
    if ~isfolder(path) % if path doesn't lead to existing folder, exception
        msgID = 'AUTOGRADER:generateStudents:invalidPath';
        msgtext = 'path is invalid';
        ME = MException(msgID, msgtext);
        throw(ME);
    else % if path leads to folder
        studs = dir(path);
        studs(strncmp({studs.name}, '.', 1)) = []; % filter out '.' and '..'
        studs(~[studs.isdir]) = []; % filter out any misc files
        if isempty(studs) % if there are no student folders, exception
            msgID = 'AUTOGRADER:generateStudents:foldersNotFound';
            msgtext = 'no student folders were found';
            ME = MException(msgID, msgtext);
            throw(ME);
        else
            % make vector of Students
            CSV_NAME = 'info.csv'; % magic variable for csv filename
            FULLNAME_COL = 1; % magic number for col with full names
            GT_USERNAME_COL = 2; % magic number for col with usernames
            SECTION_COL = 3;
            fid = fopen([path filesep CSV_NAME], 'rt');
            raw = textscan(fid, '%q%q%q', 'Delimiter', ',');
            fclose(fid);
            studentNames = raw{FULLNAME_COL};
            users = raw{GT_USERNAME_COL};
            sections = raw{SECTION_COL};
            if numel(sections) < numel(users)
                spacer = cell(1, numel(users) - numel(sections));
                spacer(:) = {''};
                sections = [sections; spacer];
            end
            sections(strcmp(sections, '')) = {'U'};
            for i = length(studs):-1:1
                % Student constructor takes in path to individual student
                % folder and student's full name
                studentPath = fullfile(studs(i).folder, studs(i).name);
                studentName = studentNames{strcmp(users, studs(i).name)};
                workers(i) = parfeval(@createStudent, 1, studentPath, studentName);
            end
            students = workers.fetchOutputs();
            [students.section] = deal(sections{:});
            % alphabetize vector of Students based on GT username
            [~, idx] = sort({students.name});
            students = students(idx);
        end
    end
end

function student = createStudent(path, name)
    path(path == '/' | path == '\') = filesep;
    if path(end) == filesep
        path(end) = [];
    end
    zipFiles = dir([path filesep '*.zip']);
    for i = 1:length(zipFiles)
        unzipArchive([path filesep zipFiles(i).name], path, true);
    end
    student = Student(path, name);
end
