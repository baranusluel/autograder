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

    % get this folder's information
    folder = getFolder(folderId, token);
    % create directory for this root folder and cd to it
    
    % for all the files inside, download them here
    
    % for each folder inside this, call ourselves recursively
    
    % cd back to original folder
    
    
end

function downloadFile(file, token)
    API = 'https://www.googleapis.com/drive/v3/files/';
    opts = weboptions();
    opts.HeaderFields = {'Authorization', ['Bearer ' token]};
    url = [API file.id '?alt=media'];
    websave(file.name, url, opts);
end

function folder = getFolder(folderId, token)
    API = 'https://www.googleapis.com/drive/v3/files/';
    opts = weboptions();
    opts.HeaderFields = {'Authorization', ['Bearer ' token]};
    folder = webread(API, 'q', ['''' folderId ''' in parents'], opts);
    
end