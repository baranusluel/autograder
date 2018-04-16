%% authorizeWithGoogle: Authorize with Google Drive
%
% authorizeWithGoogle will perform a one-time authorization to allow the
% autograder to access that user's folders.
%
% R = authorizeWithGoogle() will authorize with the current user, on this
% machine. Once this authorization is complete, the refresh token can be
% used anywhere.
%
%%% Remarks
%
% This is primarily used to authenticate with Google so that we can
% programmatically download the solution archive.
%
%%% Exceptions
%
% Like all other networking functions, this throws an
% AUTOGRADER:networking:connectionError exception if something goes wrong.
%
%%% Unit Tests
%
%   R = authorizeWithGoogle();
%
%   % Assuming user says yes, R = '...';
%
%   R = authorizeWithGoogle();
%
%   % Assuming user says no:
%   threw connectionError exception
function token = authorizeWithGoogle()
    SCOPE = 'https://www.googleapis.com/auth/drive.readonly';
    RESP_TYPE = 'code';
    REDIRECT = 'http://127.0.0.1:9004';
    CLIENT_ID = '995321590274-1msjncpalf2cj5vmqmudjj2pl7npjicd.apps.googleusercontent.com';
    CLIENT_SECRET = 'finkYqyQBbOC6HFbqEyeeHAn';
    GRANT_TYPE = 'authorization_code';
    
    URL = ['https://accounts.google.com/o/oauth2/v2/auth?scope=', SCOPE, ...
        '&response_type=', RESP_TYPE, ...
        '&redirect_uri=', REDIRECT, ...
        '&client_id=', CLIENT_ID];
    web(URL, '-browser');
    % start up server socket
    server = tcpip('0.0.0.0', 9004, 'NetworkRole', 'server');
    % wait for connection
    fopen(server);
    RESPONSE = strjoin({'HTTP/1.1 200 OK', '', '<html><body><h1>Success! You can close this window and head back to the autograder...</h1></body></html>'}, newline);
    % get code
    while server.BytesAvailable == 0
        pause(.5);
    end
    code = char(fread(server, server.BytesAvailable, 'uchar')');
    % write response
    fwrite(server, RESPONSE);
    fclose(server);
    % parse the code
    code = strtok(code, newline);
    code = regexp(code, '(?<=^GET [/][?]code[=])[^\s]*', 'match');
    code = code{1};
    % send auth code and get back refresh token
    opts = weboptions();
    opts.RequestMethod = 'POST';
    EXCHANGER = 'https://www.googleapis.com/oauth2/v4/token';
    data = webread(EXCHANGER, 'code', code, 'client_id', CLIENT_ID, ...
        'client_secret', CLIENT_SECRET, 'redirect_uri', REDIRECT, ...
        'grant_type', GRANT_TYPE, opts);
    token = data.refresh_token;
end