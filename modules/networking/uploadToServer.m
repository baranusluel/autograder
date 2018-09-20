%% uploadToServer: Upload the student's submission files to the Server
%
% uploadToServer is responsible for uploading files to the CS 1371 Server
%
% uploadToServer(U, P, N, B) will upload the files for homework using the 
% username U and the password P. Additionally, it will  update the progress
% bar B. It will use the homework name N.
%
%%% Remarks
%
% This method is used to upload homework files to the CS 1371 website, so
% that the students can view regrades.
%
%%% Exceptions
%
% This method, like all other networking methods, will throw an
% AUTOGRADER:networking:connectionError exception if interrupted.
%
%%% Unit Tests
%
%   U = 'autograder'; % valid username
%   P = 'password'; % valid password
%   B = uiprogressdlg;
%   N = 'homework01';
%   uploadToServer(U, P, N, B);
%
%   Student files are correctly uploaded
function uploadToServer(user, pass, hwName, progress)
    progress.Message = 'Uploading Homework Data to Server';
    progress.Value = 0;
    progress.Indeterminate = 'on';
    
    javaaddpath([fileparts(mfilename('fullpath')) filesep 'JSch.jar']);
    cleaner = onCleanup(@()...
        (javarmpath([fileparts(mfilename('fullpath')) filesep 'JSch.jar'])));
    sftp = getSftp(user, pass);
    wait(parfevalOnAll(@()(clear('uploadToServer')), 0));

    % get HW num
    num = hwName(hwName >= '0' & hwName <= '9');
    % Upload solutions
    solnFolder = [pwd filesep 'Solutions'];
    mkdir(hwName);
    newOGName = [pwd filesep hwName filesep 'hw' num 'Rubric.json'];
    newResubName = [pwd filesep hwName filesep 'hw' num 'Rubric_resub.json'];
    copyfile(solnFolder, hwName);
    % rename rubrics and upload
    movefile([pwd filesep hwName filesep 'rubrica.json'], ...
        newOGName);
    movefile([pwd filesep hwName filesep 'rubricb.json'], ...
        newResubName);
    % upload these two files to: httpdocs/regrades/rubrics
    sftp.put(newOGName, '/httpdocs/regrades/rubrics/');
    sftp.put(newResubName, '/httpdocs/regrades/rubrics/');
    % delete rubrics
    delete(newOGName);
    delete(newResubName);
    
    % zip supporting files
    if contains(hwName, 'resubmission')
        name = 'Supporting_Resub.zip';
    else
        name = 'Supporting.zip';
    end
    zip([pwd filesep hwName filesep name], ...
        [pwd filesep hwName filesep 'SupportingFiles' filesep '*']);
    [~] = rmdir([pwd filesep hwName filesep 'SupportingFiles'], 's');
    % folder is ready to upload; upload it!
    % initial folder needs to be made: httpdocs/regrades/solutions/hwName
    executeCommand(user, pass, ['rm -rf /httpdocs/regrades/solutions/Homework' num]);
    sftp.mkdir(['/httpdocs/regrades/solutions/Homework' num]);
    % for each file in folders, upload accordingly. No need to parallelize
    % because this shouldn't take long
    solns = dir([pwd filesep hwName filesep 'Solutions' filesep '*.m']);
    for n = 1:numel(solns)
        sftp.put([solns(n).folder filesep solns(n).name], ...
            ['/httpdocs/regrades/solutions/Homework' num '/' solns(n).name]);
    end
    % upload supporting.zip
    sftp.put([pwd filesep hwName filesep name], ...
        ['/httpdocs/regrades/solutions/Homework' num '/' name]);
    
    [~] = rmdir(hwName, 's');
    
%     % create csv
%     ids = {students.id};
%     grades = arrayfun(@num2str, [students.grade], 'uni', false);
%     csv = strjoin(join([ids; grades]', ','), newline);
%     fid = fopen('grades.csv', 'wt');
%     fwrite(fid, csv);
%     fclose(fid);
%     sftp.put([pwd filesep 'grades.csv'], ['/httpdocs/homework_files/' hwName '/grades.csv']);
%     delete('grades.csv');
%     % create JSON for names
%     ids = {students.id};
%     names = {students.name};
%     
%     for s = numel(ids):-1:1
%         json.(ids{s}) = struct('name', names{s});
%     end
%     json = jsonencode(json);
%     fid = fopen('names.json', 'wt');
%     fwrite(fid, json);
%     fclose(fid);
%     sftp.put([pwd filesep 'names.json'], '/httpdocs/regrades/json/names.json');
%     delete('names.json');
%     %TODO: how to get sections?
    
    sftp.disconnect();
    workers = parfevalOnAll(@uploadStudent, 0);
    workers.wait();
end

function uploadStudent(student, user, pass, startPath)
    persistent sftp;
    if nargin == 0 && isempty(sftp)
        return;
    elseif nargin == 0 && ~isempty(sftp)
        sftp.disconnect;
        sftp = [];
        return;
    elseif isempty(sftp)
        sftp = getSftp(user, pass);
    end
    for a = numel(student.submissions):-1:1
        uploadFile(sftp, [pwd filesep 'Students' filesep student.id filesep student.submissions{a}], ...
            [startPath '/' student.id '/Submission Attachment(s)/' student.submissions{a}]);
    end
    uploadFile(sftp, [pwd filesep 'Students' filesep student.id filesep 'feedback.html'], ...
        [startPath '/' student.id '/Feedback Attachment(s)/feedback.html']);
end    

function uploadFile(sftp, localPath, remotePath)
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

function executeCommand(user, pass, cmd)
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
    
    ssh = session.openChannel("exec");
    ssh.setCommand(cmd);
    ssh.connect();
    ssh.disconnect();
    pause(3);
end