%% getDriveFolderContents: Get the entries of a Google Drive Folder
%
% C = getDriveFolderContents(I, T, K) will use folder ID I, token T, and
% key K to get folder content structures C. C is guaranteed to be a
% structure array.
%
% ___ = getDriveFolderContents(___, A) will use attempt number A to retry a
% certain number of times.
%
%%% Remarks
%
% This function does not return any information about the parent folder -
% this functionality is contained within getDriveFolder.
function contents = getDriveFolderContents(folderId, token, key, attemptNum)
    MAX_ATTEMPT_NUM = 10;
    WAIT_TIME = 2;
    API = 'https://www.googleapis.com/drive/v3/files/';
    
    if nargin < 4
        attemptNum = 1;
    end
    opts = weboptions();
    opts.HeaderFields = {'Authorization', ['Bearer ' token]};
    try
        contents = webread(API, 'q', ['''' folderId ''' in parents'], 'key', key, opts);
    catch reason
        if attemptNum < MAX_ATTEMPT_NUM
            pause(WAIT_TIME);
            contents = getDriveFolderContents(folderId, token, key, attemptNum + 1);
        else
            e = MException('AUTOGRADER:networking:connectionError', ...
                'Connection was terminated (Are you connected to the internet?');
            e = e.addCause(reason);
            throw(e);
        end
    end
    if ~isempty(contents)
        contents = contents.files;
    else
        contents = [];
    end
    
end