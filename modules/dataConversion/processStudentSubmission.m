%% processStuentSubmission: Processes a student's sumissions
%   
% processStudentSubmission will unpack a student's submissions into their same 
% folder.
%
% processStudentSubmission(P) will try and unpack
% the data located at the given pathway into a single folder. P is a 
% string or character vector that represents the path to the student's 
% folder.
%
%%% Remarks
%
% If the student submitted each file seperately, this function will do
% nothing.
%
% processStudentSubmission won't _recursively_ unzip archives. In other words,
% suppose the student submits a ZIP archive that has, inside of it, _another_ 
% ZIP archive. That second archive will not be unzipped!
%
% In the event of a name collision (i.e., suppose the ZIP archive has a file
% with the same name as an existing file), the existing file will always win.
% Note that in the case of having multiple archives present, there is no 
% guarantee as to which file will survive if both archives have the same file.
%
%%% Exceptions
%
% An AUTOGRADER:ISEMPTY:INVALIDPATH exception will be thrown if 
% the pathway is invalid
%
%%% Unit Tests
%
%   Given there is only files found on the pathway, the files will be moved
%   to the student's labeled folder.
%
%   Given a pathway with one or more ZIP archive, the function will open the ZIP
%   archive and move its contents to the student's folder.
%
%   Given both ZIP archives and files found on the given pathway, the files
%   found will be moved to the student's labeled folder and then the ZIP
%   archives will be opened and their contents moved to the student's
%   folder.
%
%   P = ''; % Invalid Path
%   processStudentSubmissions(P);
%
%   Threw INVALIDPATH exception