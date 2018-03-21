%% generateStudents: Generate Student array
%
% generateStudents turns a set of Student Folders into a vector of Students
%
% [S] = generateStudents(P) will convert all the student folders found in ZIP P
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
% An AUTOGRADER:GENERATESTUDENTS:INVALIDPATH exception will be thrown if the path is
% invalid or if no student folders are found.
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
%   Threw INVALIDPATH exception
%

% Notes for implementation:
% Initializing an array of Student is weird. You have to start with the END first. 
% In other words, say you have 1000 students. You should START with the one thousandth student:
%
%   students(1000) = Student(inputs);
%
% And then work your way down to 1 from there.