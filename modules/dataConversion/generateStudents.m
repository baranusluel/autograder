%% generateStudents: Generate Student array
%
% generateStudents turns a set of Student Folders into a vector of Students
%
% [S] = generateStudents(P) will convert all the student folders found in P
% into Students, and will return a vector in alphabetical order (case insensitive)
% of the Students, where alphabetical order is based on their ID.
%
%%% Remarks
%
% generateStudents will always expect a correctly-structured archive, and also
% always assumes that all students have been previously unpacked.
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
%   P = 'C:\Users\...\students.zip'; % Valid path to student folders
%   S = generateStudents(P);
%
%   S -> A vector of students in alphabetical order, by their GT Username
%
%   P = ''; % Invalid Path
%   S = generateStudents(P);
%
%   Threw invalidPath exception
%
%   P = ''; % Valid path, but no student folders are found
%   S = generateStudents(P);
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

function students = generateStudents(path)

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
        FULLNAME_COL = 2; % magic number for col with full names
        GT_USERNAME_COL = 1; % magic number for col with usernames
        [~, ~, raw] = xlsread([path filesep CSV_NAME]);
        studentNames = raw(:, FULLNAME_COL);
        users = raw(:, GT_USERNAME_COL);
        for i = length(studs):-1:1
            % Student constructor takes in path to individual student
            % folder and student's full name
            studentPath = fullfile(studs(i).folder, studs(i).name);
            studentName = studentNames(strcmp(users, studs(i).name));
            processStudentSubmission(studentPath);
            students(i) = Student(studentPath, studentName);
        end
        % alphabetize vector of Students based on GT username
        [~, idx] = sort({students.name});
        students = students(idx);
    end
end

end