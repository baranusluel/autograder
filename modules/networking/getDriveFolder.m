%% getDriveFolder: Get Metadata about a Google Drive Folder
%
% F = getDriveFolder(I, T, K) will use folder ID I, token T, and key K to
% get the folder information structure F.
%
% ___ = getDriveFolder(___, A) will do the same as above, but also use
% attemptNum A as the incrementer.
%
%%% Remarks
%
% This function can be useful for getting metadata, for actual contents see
% getDriveFolderContents.
function folder = getDriveFolder(folderId, token, key, attemptNum)
    MAX_ATTEMPT_NUM = 10;
    WAIT_TIME = 2;
    
    if nargin < 4
        attemptNum = 1;
    end
    API = 'https://www.googleapis.com/drive/v3/files/';
    opts = weboptions();
    opts.HeaderFields = {'Authorization', ['Bearer ' token]};
    try
        folder = webread([API folderId], 'key', key, opts);
    catch reason
        if attemptNum < MAX_ATTEMPT_NUM
            pause(WAIT_TIME);
            folder = getDriveFolder(folderId, token, key, attemptNum + 1);
        else
            e = MException('AUTOGRADER:networking:connectionError', ...
                'Connection was terminated (Are you connected to the internet?');
            e = e.addCause(reason);
            throw(e);
        end
    end
end