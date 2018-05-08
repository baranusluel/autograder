%% processStuentSubmission: Processes a student's sumissions
%
% processStudentSubmission will unpack a student's submissions into their same
% folder.
%
% processStudentSubmission(P) will unpack any ZIP files, and generally prepare
% the student folder for the autograder.
%
%%% Remarks
%
% If the student submitted each file separately, this function will not
% change the folder at all.
%
% processStudentSubmission won't recursively unzip archives. In other words,
% suppose the student submits a ZIP archive that has, inside of it, another
% ZIP archive. That second archive will not be unzipped!
%
% Additionally, folder structure within the ZIP archive will remain intact,
% with the exception of the case where inside the ZIP archive is a single folder.
% In that case, the contents of that single folder will be considered to be the
% contents of the ZIP archive.
%
% In the event of a name collision (i.e., suppose the ZIP archive has a file
% with the same name as an existing file), the existing file will always win.
% Note that in the case of having multiple archives present, there is no
% guarantee as to which file will survive if both archives have the same file.
%
%%% Exceptions
%
% An AUTOGRADER:processStudentSubmission:invalidPath exception will be
% thrown if the given path is not a valid folder.
%
%%% Unit Tests
%
%   % Assume P points to a student folder, and the student folder
%   % contains several files.
%   P = 'C:\Users\...\';
%   processStudentSubmission(P);
%
%   The folder referenced in P is unchanged
%
%   % Assume P points to student folder, and the student folder
%   % contains only a ZIP archive. This ZIP archive contains only
%   % files
%   P = 'C:\Users\...\';
%   processStudentSubmission(P);
%
%   % Whereas before, the student folder only had a ZIP archive, it now
%   % only has the files contained within that ZIP archive.
%
%   % Assume P points to a student folder, and the student folder
%   % contains a single ZIP archive. However, this ZIP archive itself
%   % contains a single folder, which then just has files.
%   P = 'C:\Users\...\';
%   processStudentSubmission(P);
%
%   % The student folder now has all the files contained within the single
%   % folder of the ZIP archive.
%
%   % Assume P points to a student folder, and the student folder
%   % contains multiple files, including a ZIP archive.
%   P = 'C:\Users\...\';
%   processStudentSubmission(P);
%
%   % Now the student's folder only contains files; the ZIP archive has been
%   % removed. Furthermore, the structure within the ZIP archive has been
%   % preserved.
%
%   % Assume P points to a student folder, and the student folder
%   % contains multiple files, including a ZIP archive. Furthermore,
%   % assume a single file in the submission is called 'myFun.m',
%   % and that a file named 'myFun.m' exists in the ZIP archive.
%   P = 'C:\Users\...\';
%   processStudentSubmission(P);
%
%   % Now the folder contains only files. Note that 'myFun.m' is
%   % the one from the original submission; NOT the one inside the
%   % ZIP archive!
%
%   % Assume P points to a student folder, which contains multiple ZIPs.
%   P = 'C:\Users\...\';
%   processStudentSubmission(P);
%
%   % Now there are only the files and folders that were inside the ZIP archive(s).
%   % Note that, if two of them had a file or folder with the same name, then
%   % which one "survives" is indeterminant.
%
%   % Assume P points to a student folder, which contains one ZIP archive. This
%   % ZIP archive contains another ZIP archive!
%   P = 'C:\Users\...\';
%   processStudentSubmission(P);
%
%   % The folder now contains the archive that was inside the original submssion's
%   % archive. It does NOT recursively unzip!
%
%   P = ''; % Invalid Path
%   processStudentSubmission(P);
%
%   Threw invalidPath exception
function processStudentSubmission(startPath)
    startPath(startPath == '/' | startPath == '\') = filesep;
    if startPath(end) == filesep
        startPath(end) = [];
    end
    zipFiles = dir([startPath filesep '*.zip']);
    for i = 1:length(zipFiles)
        [~] = unzipArchive([startPath filesep zipFiles(i).name], pwd, true);
    end
end