%% downloadFromDrive: Download the solutions from Google Drive
%
% downloadFromDrive will download the |grader| folder from Google Drive
%
% downloadFromDrive(F, T, P, B) will use the token in T to download the folder ID
% in F. It will recursively download everything within that folder. The
% files will be saved within the same heirarchy in path P. Additionally, it
% will update the progress bar in B.
%
%%% Remarks
%
% This is used to download solution archives from Google Drive, but it
% could be used to download anything from Google Drive, theoretically. It
% is agnostic about what it's actually downloading
%
%%% Exceptions
%
% Like other |networking| functions, this will throw an
% AUTOGRADER:networking:connectionError exception if a connection is
% interrupted.
%
%%% Unit Tests
%
%   T = '...'; % valid access token
%   F = '...'; % valid FolderID
%   B is valid uiprogressdlg.
%   downloadFromDrive(F, T, pwd, B);
%
%   There is now a grader folder in the current directory
%
function downloadFromDrive(folderId, token, path, key, progress)
    progress.Indeterminate = 'off';
    progress.Value = 0;
    progress.Message = 'Downloading Solution Archive from Google Drive';
    workers = downloadFolder(folderId, token, key, path);
    tot = numel(workers);
    while ~all([workers.Read])
        fetchNext(workers);
        progress.Value = min([progress.Value + 1/tot, 1]);
    end
    delete(workers);
end

function workers = downloadFolder(folderId, token, key, path)
    FOLDER_TYPE = 'application/vnd.google-apps.folder';
    if nargin == 3
        origPath = cd(path);
    else
        origPath = pwd;
    end
    cleaner = onCleanup(@()(cd(origPath)));
    % get this folder's information
    folder = getFolder(folderId, token, key);
    % create directory for this root folder and cd to it
    % for all the files inside, download them here
    contents = getFolderContents(folder.id, token, key);
    workers = cell(1, numel(contents));
    for c = numel(contents):-1:1
        content = contents(c);
        if strcmp(content.mimeType, FOLDER_TYPE)
            % folder; call recursively
            mkdir([path filesep content.name]);
            workers{c} = downloadFolder(content.id, token, key, [path filesep content.name]);
        else
            % file; download
            workers{c} = parfeval(@downloadFile, 0, content, token, key, path);
        end
    end
    workers = [workers{:}];
    workers([workers.ID] == -1) = [];
end

function downloadFile(file, token, key, path, attemptNum)
    MAX_ATTEMPT_NUM = 10;
    WAIT_TIME = 2;
    if nargin < 5
        attemptNum = 1;
    end
    API = 'https://www.googleapis.com/drive/v3/files/';
    opts = weboptions();
    opts.HeaderFields = {'Authorization', ['Bearer ' token]};
    url = [API file.id '?alt=media&key=' key];
    try
        websave([path filesep file.name], url, opts);
    catch reason
        if attemptNum <= MAX_ATTEMPT_NUM
            pause(WAIT_TIME);
            downloadFile(file, token, key, path, attemptNum + 1);
        else
            e = MException('AUTOGRADER:networking:connectionError', ...
                'Connection was terminated (Are you connected to the internet?');
            e = e.addCause(reason);
            throw(e);
        end
    end
end

function contents = getFolderContents(folderId, token, key)
    API = 'https://www.googleapis.com/drive/v3/files/';
    opts = weboptions();
    opts.HeaderFields = {'Authorization', ['Bearer ' token]};
    try
        contents = webread(API, 'q', ['''' folderId ''' in parents'], 'key', key, opts);
    catch reason
        e = MException('AUTOGRADER:networking:connectionError', ...
            'Connection was terminated (Are you connected to the internet?');
        e = e.addCause(reason);
        throw(e);
    end
    contents = contents.files;
end

function folder = getFolder(folderId, token, key)
    API = 'https://www.googleapis.com/drive/v3/files/';
    opts = weboptions();
    opts.HeaderFields = {'Authorization', ['Bearer ' token]};
    try
        folder = webread([API folderId], 'key', key, opts);
    catch reason
        e = MException('AUTOGRADER:networking:connectionError', ...
            'Connection was terminated (Are you connected to the internet?');
        e = e.addCause(reason);
        throw(e);
    end
end