%% canvas2autograder: Converts Canvas files to autograder structure
%
% Creates correctly formatted student folders from the Canvas download
%
% PATH = canvas2autograder(CANVAS) Takes the path in CANVAS and unzips
% accordingly, reformatting the folder names correctly, and ensuring that 
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
%%% Unit Tests
%
%   CANVAS = 'C:\Users\...\Canvas.zip'; % Valid path
%   PATH = canvas2autograder(CANVAS);
%
%   PATH points to a new, unzipped path that is completely 
%   unzipped all student's folders, and the folder names 
%   are correct.
%
%   CANVAS = ''; % Invalid Path
%   PATH = canvas2autograder(CANVAS);
%
%   Threw INVALIDFILE exception
%
%   CANVAS = 'C:\Users\...\Canvas.zip'; % Valid path, but INVALID archive!
%   PATH = canvas2autograder(CANVAS);
%
%   Threw INVALIDFILE exception
%
function newPath = canvas2autograder(canvasPath)

end