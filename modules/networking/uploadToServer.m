%% uploadToServer: Upload the student's submission files to the Server
%
% uploadToServer is responsible for uploading files to the CS 1371 Server
%
% uploadToServer(S, U, P, N, B) will upload the files for students in 
% array S using the username U and the password P. Additionally, it will 
% update the progress bar B. It will use the homework name N.
%
%%% Remarks
%
% This method is used to upload student files to the CS 1371 website, so
% that the students can view them.
%
%%% Exceptions
%
% This method, like all other networking methods, will throw an
% AUTOGRADER:networking:connectionError exception if interrupted.
%
%%% Unit Tests
%
%   S = Student(); % valid student array
%   U = 'autograder'; % valid username
%   P = 'password'; % valid password
%   B = uiprogressdlg;
%   N = 'homework01';
%   uploadToServer(S, U, P, N, B);
%
%   Student files are correctly uploaded
function uploadToServer(students, user, pass, hwName, progress)
    progress.Message = 'Uploading Student Data to Server';
    progress.Value = 0;
    progress.Indeterminate = 'on';
    
    javaaddpath([fileparts(mfilename('fullpath')) filesep 'JSch.jar']);
    cleaner = onCleanup(@()...
        (javarmpath([fileparts(mfilename('fullpath')) filesep 'JSch.jar'])));
    sftp = getSftp(user, pass);
    % for each student we will need to upload their files to their
    % appropriate directory. First, however, we'll need to make those
    % directories!
    % cd to the httpdocs/homework_files
    sftp.cd('/httpdocs/homework_files');
    % check if already exists?
    % if it exists, then what do we do? Archive it?
    
    exists = false;
    if exists
        % We don't really know what to do right now, but the way I see it
        % is:
        %
        % 1. We just delete the previous data.
        % 2. We download the data, then delete it
        % 3. We move the data elsewhere
    end
    sftp.mkdir(hwName);
    sftp.cd(hwName);
    % upload new files
    % for each student, we'll be uploading two files: Their submissions,
    % and their Feedback. The folder name is the ID of the student, which
    % is underneath the HW name. In that folder is "Feedback Attachment(s)"
    % and "Submission Attachment(s)".
    % So, for each student, create their folders. Then, parfeval their
    % uploads.
    workers = cell(1, numel(students));
    for s = numel(students):-1:1
        % create their remote directory and sub directories
        student = students(s);
        sftp.mkdir(student.id);
        sftp.mkdir([student.id '/Feedback Attachment(s)']);
        sftp.mkdir([student.id '/Submission Attachment(s)']);
        % for each of their submissions, make a worker to upload
        for a = numel(student.submissions):-1:1
            workers{s}(a + 1) = parfeval(@uploadFile, 0, ...
                [pwd filesep 'Students' filesep student.id filesep student.submissions{a}], ...
                [char(sftp.pwd) '/' student.id '/Submission Attachment(s)/' student.submissions{a}], ...
                user, ...
                pass);
        end
        workers{s}(1) = parfeval(@uploadFile, 0, ...
            [pwd filesep 'Students' filesep student.id filesep 'feedback.html'], ...
            [char(sftp.pwd) '/' student.id '/Feedback Attachment(s)/feedback.html'], ...
            user, ...
            pass);
        % upload their feedback
    end
    workers = [workers{:}];
    workers([workers.ID] == -1) = [];
    tot = numel(workers);
    progress.Indeterminate = 'off';
    progress.Value = 0;
    while ~all([workers.Read])
        if progress.CancelRequested
            cancel(workers);
            throw(MException('AUTOGRADER:userCancellation', ...
                'User Cancelled operation'));
        end
        fetchNext(workers);
        progress.Value = min([progress.Value + 1/tot, 1]);
    end
    workers = parfevalOnAll(@uploadFile, 0);
    workers.wait();
    sftp.disconnect();
end

function uploadFile(localPath, remotePath, user, pass)
    persistent sftp;
    if nargin == 0 && isempty(sftp)
        return;
    elseif nargin == 0 && ~isempty(sftp)
        sftp.disconnect();
        return;
    elseif ~isempty(sftp)
        sftp = getSftp(user, pass);
    end
    sftp.put(localPath, remotePath);
end

function sftp = getSftp(user, pass)
    import com.jcraft.jsch.*;
    controller = JSch;
    HOST = 'cs1371.gatech.edu';
    PORT = 22;
    session = controller.getSession(user, HOST, PORT);
    session.setConfig("PreferredAuthentications", "password");
    session.setConfig("StrictHostKeyChecking", "no");
    session.setPassword(pass);
    try
        session.connect();
    catch reason
        e = MException('AUTOGRADER:networking:connectionError', ...
            'Unable to connect');
        e = e.addCause(reason);
        throw(e);
    end
    
    sftp = session.openChannel("sftp");
    sftp.connect();
end