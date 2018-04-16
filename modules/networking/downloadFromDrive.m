%% downloadFromDrive: Download the solutions from Google Drive
%
% downloadFromDrive will download the |grader| folder from Google Drive
%
% downloadFromDrive(F, T, P) will use the token in T to download the folder ID
% in F. It will recursively download everything within that folder. The
% files will be saved within the same heirarchy in path P.
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
%   downloadFromDrive(F, T, pwd);
%
%   There is now a grader folder in the current directory
%
%   T = '';
%   F = '';
%   downloadFromDrive(F, T, pwd);
%
%   threw connectionError exception
%
function downloadFromDrive(folderId, token, path)
    FOLDER_TYPE = 'application/vnd.google-apps.folder';
    if nargin == 3
        origPath = cd(path);
    else
        origPath = pwd;
    end
    cleaner = onCleanup(@()(cd(origPath)));
    % get this folder's information
    folder = getFolder(folderId, token);
    % create directory for this root folder and cd to it
    mkdir(folder.name);
    cd(folder.name);
    % for all the files inside, download them here
    contents = getFolderContents(folder.id, token);
    for c = 1:numel(contents)
        content = contents(c);
        if strcmp(content.mimeType, FOLDER_TYPE)
            % folder; call recursively
            downloadFromDrive(content.id, token);
        else
            % file; download
            downloadFile(content, token);
        end
    end
    
end

function downloadFile(file, token)
    API = 'https://www.googleapis.com/drive/v3/files/';
    opts = weboptions();
    opts.HeaderFields = {'Authorization', ['Bearer ' token]};
    url = [API file.id '?alt=media'];
    try
        websave(file.name, url, opts);
    catch reason
        e = MException('AUTOGRADER:networking:connectionError', ...
            'Connection was terminated (Are you connected to the internet?');
        e = e.addCause(reason);
        throw(e);
    end
end

function contents = getFolderContents(folderId, token)
    API = 'https://www.googleapis.com/drive/v3/files/';
    opts = weboptions();
    opts.HeaderFields = {'Authorization', ['Bearer ' token]};
    try
        contents = webread(API, 'q', ['''' folderId ''' in parents'], opts);
    catch reason
        e = MException('AUTOGRADER:networking:connectionError', ...
            'Connection was terminated (Are you connected to the internet?');
        e = e.addCause(reason);
        throw(e);
    end
    contents = contents.files;
end

function folder = getFolder(folderId, token)
    API = 'https://www.googleapis.com/drive/v3/files/';
    opts = weboptions();
    opts.HeaderFields = {'Authorization', ['Bearer ' token]};
    try
        folder = webread([API folderId], opts);
    catch reason
        e = MException('AUTOGRADER:networking:connectionError', ...
            'Connection was terminated (Are you connected to the internet?');
        e = e.addCause(reason);
        throw(e);
    end 
end