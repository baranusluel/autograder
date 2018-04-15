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
    URL = 'https://accounts.google.com/o/oauth2/v2/auth?scope=https://www.googleapis.com/auth/drive.readonly&response_type=code&redirect_uri=http://127.0.0.1:9004&client_id=995321590274-1msjncpalf2cj5vmqmudjj2pl7npjicd.apps.googleusercontent.com';
    web(URL, '-browser');
    % start up server socket
    server = tcpip('0.0.0.0', 9004, 'NetworkRole', 'server');
    % wait for connection
    fopen(server);
    RESPONSE = strjoin({'HTTP/1.1 200 OK', '', '<html><body><h1>Success! You can close this window and head back to the autograder...</h1></body></html>'}, newline);
    % get code
    code = fread(server, server.BytesAvailable);
    % write response
    fwrite(server, RESPONSE);
    fclose(server);
    
    % send auth code and get back refresh token
end