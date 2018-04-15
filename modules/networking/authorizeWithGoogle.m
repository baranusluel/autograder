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







API = 'https://accounts.google.com/o/oauth2/v2/auth';




str = 'https://accounts.google.com/o/oauth2/v2/auth?scope=https://www.googleapis.com/auth/drive.readonly&response_type=code&redirect_uri=http://127.0.0.1:9004&client_id=995321590274-1msjncpalf2cj5vmqmudjj2pl7npjicd.apps.googleusercontent.com';



t = tcpip('0.0.0.0', 9004, 'NetworkRole', 'server');


fopen(t);

str = {'HTTP/1.1 200 OK', ...
'', ...
'<html><body><h1>It works!</h1></body></html>'};
str = strjoin(str, newline);

fwrite(t, str);
fclose(t);