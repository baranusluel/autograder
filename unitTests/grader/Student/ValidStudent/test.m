%% ValidStudent
% Given a valid PATH to a student folder containing submissions
% (with filenames FILE1, FILE2, ...):
%
%   NAME = 'Hello';
%   this = Student(PATH, NAME);
%
%   this.name -> "Hello"
%   this.id -> Student's GT username (from name of folder)
%   this.path -> PATH;
%   this.submissions -> ["FILE1", "FILE2", ...];
%   this.feedbacks -> Feedback[];
%   this.isGraded -> false;
function [passed, message] = test();

