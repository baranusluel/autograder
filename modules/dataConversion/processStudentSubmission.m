%% processStuentSubmission: Processes a student's sumissions
%   
% processStudentSubmission will unpack a student's submissions into their same 
% folder.
%
% processStudentSubmission(P) will remove all non .m and all non
% .zip files in path P. If a .zip exists, it will unzip the file
% once and remove all non .m files.
%
%%% Remarks
%
% If the student submitted each .m file separately, this function will not
% change the folder at all.
%
% processStudentSubmission won't recursively unzip archives. In other words,
% suppose the student submits a ZIP archive that has, inside of it, another 
% ZIP archive. That second archive will not be unzipped!
%
% In the event of a name collision (i.e., suppose the ZIP archive has a file
% with the same name as an existing file), the existing file will always win.
% Note that in the case of having multiple archives present, there is no 
% guarantee as to which file will survive if both archives have the same file.
%
% In the event of a name collision within given zip archives, the files 
% contained in the zip that appears first from the dir command will 
% supercede all subsequent files.
%
%%% Exceptions
%
% An AUTOGRADER:PROCESSSTUDENTSUBMISSION:INVALIDPATH exception will be 
% thrown if there is no path.
%
% An AUTOGRADER:PROCESSSTUDENTSUBMISSION:INVALIDDIR exception will be 
% thrown if the path given is not a directory.
%
%%% Unit Tests
%
% 1)
% Folder Containing:
%   Several .m files
%
% Inputs:
%   Path to the Folder
%
% Runtime:
%   None
%
% Outputs:
%   None
%
% Folder Containing:
%   Several .m files
%
% 2)
% Folder Containing:
%   Several .m files
%   Several .png files
%   Several .txt files
%
% Inputs:
%   Path to the Folder
%
% Runtime:
%   None
%
% Outputs:
%   None
%
% Folder Containing:
%   Several .m files
%
% 3)
% Folder Containing:
%   2 zip archives containing the same files (a.zip and b.zip)
%
% Inputs:
%   Path to the Folder
%
% Runtime:
%   None
%
% Outputs:
%   None
%
% Folder Containing:
%   Several .m files (from the a.zip)
%
% 4)
% Folder Containing:
%   Several .m files
%   A zip archive (with no name collisions) containing several .m files,
%    several .png files, and several .txt files
%
% Inputs:
%   Path to the Folder
%
% Runtime:
%   None
%
% Outputs:
%   None
%
% Folder Containing:
%   Several more .m files (from the the zip and original)
% 
% 5)
% Folder Containing:
%   Nothing
%
% Inputs:
%   Path to the Folder
%
% Runtime:
%   None
%
% Outputs:
%   None
%
% Folder Containing:
%   Nothing
%
% 6-7) Test Exceptions