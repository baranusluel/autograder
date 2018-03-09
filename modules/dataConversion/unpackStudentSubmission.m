%% unpackStuentSubmission: Unpacks a student's sumissions
%   
% unpackStudentSubmission will unpack a student's submissions into their same 
% folder.
%
% [void] = unpackStudentSubmission(string_startPath) will try and unpack
% the data located at the given pathway into a single folder. The function
% is able to manage .png, .mat, .m, .jpeg, .txt, .xlsx, .xls, (.json?), and ZIP 
% archives found in pathway.
% string_startPath will be a character vector indicating the pathway to
% access the information.
%
%%% Remarks
%
% If the student submitted each file seperately, this function will do
% nothing.
%
%%% Exceptions
%
% An AUTOGRADER:ISEMPTY:NOVALIDINPUT exception will be thrown if 
% the pathway is empty
%
%%% Unit Tests
%
%   Given there is only files found on the pathway, the files will be moved
%   to the student's labeled folder.
%
%   Given a pathway with one or more ZIP archive, the function will open the ZIP
%   archive and move its contents to the student's labelled folder.
%
%   Given both ZIP archives and files found on the given pathway, the files
%   found will be moved to the student's labeled folder and then the ZIP
%   archives will be opened and their contents moved to the student's
%   labelled folder.
%
%   Exception Raised: no files found in given pathway
%
%   Given a pathway that is empty, the function will output (a value that
%   will represent to the next function that the student did not submit any
%   code, letting it skip the grading procedure.