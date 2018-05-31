%% emailMessenger: Send an email
%
% emailMessenger(E, S, M, T, K, A) will use token T and key K to send an email
% with message M and subject line S to email E. Additionally, each file
% path in A will be attached to the email.
%
%%% Remarks
%
% This will send any email to an arbitrary email address
%
% M can only be plain text
function emailMessenger(email, subject, message, token, id, secret, key, attachments)
GMAIL_API = 'https://www.googleapis.com/gmail/v1/users/me/messages/send';
UPLOAD_API = 'https://www.googleapis.com/upload/drive/v3/files?uploadType=media';
DRIVE_API = 'https://www.googleapis.com/drive/v3/files/';
    if nargin < 8
        attachments = {};
    elseif isstring(attachments) || ischar(attachments)
        attachments = cellstr(attachments);
    end
    subject = strrep(subject, '&', '&amp;');
    subject = strrep(subject, '<', '&lt;');
    subject = strrep(subject, '>', '&gt;');
    token = refresh2access(token, id, secret);
    % for each attachment, attach it
    names = cell(1, numel(attachments));
    for a = 1:numel(attachments)
        fid = fopen(attachments{a}, 'r');
        bytes = uint8(fread(fid))';
        fclose(fid);
        
        % upload the file
        request = matlab.net.http.RequestMessage;
        auth = matlab.net.http.HeaderField;
        auth.Name = 'Authorization';
        auth.Value  = ['Bearer ' token];
        contentType = matlab.net.http.HeaderField;
        contentType.Name = 'Content-Type';
        contentLength = matlab.net.http.HeaderField;
        contentLength.Name = 'Content-Length';
        contentLength.Value = num2str(length(bytes));
        
        request.Method = 'POST';
        request.Header = [auth contentType contentLength];
        body = matlab.net.http.MessageBody;
        body.Payload = bytes;
        request.Body = body;
        file = request.send(UPLOAD_API);
        id = file.Body.Data.id;
        
        % Renaming the File
        request = matlab.net.http.RequestMessage;
        request.Method= 'PATCH';
        contentType = matlab.net.http.HeaderField;
        contentType.Name = 'Content-Type';
        contentType.Value = 'application/json';
        request.Header = [auth contentType];
        
        body = matlab.net.http.MessageBody;
        [~, name, ext] = fileparts(attachments{a});
        data.name = [name ext];
        body.Data = data;
        request.Body = body;
        request.send([DRIVE_API id]);
        
        % Setting the right permissions
        request = matlab.net.http.RequestMessage;
        request.Method = 'POST';
        contentType = matlab.net.http.HeaderField;
        contentType.Name = 'Content-Type';
        contentType.Value = 'application/json';
        request.Header = [auth contentType];
        
        body = matlab.net.http.MessageBody;
        data.role = 'reader';
        data.type = 'anyone';
        data.allowFileDiscovery = false;
        body.Data = data;
        request.Body = body;
        request.send([DRIVE_API id '/permissions']);
        
        % Get the link
        request = matlab.net.http.RequestMessage;
        request.Header = auth;
        file = request.send([DRIVE_API id '?fields=webContentLink']);
        attachments{a} = file.Body.Data.webContentLink;
        names{a} = [name ext];
    end
    message = {'From: CS 1371 Autograder <cs1371notifier@gmail.com>', ...
            ['To: Texting Server <' email '>'], ...
            ['Subject: ', subject], ...
            ['Date: ' datestr(datetime('now'), 'ddd, dd mmm yyyy HH:MM:SS') ' -0600'], ...
            'Message-ID: <1371@cs1371.gatech.edu>', ...
            '', ...
            message, strjoin([names; attachments], char(10))}; %#ok<CHARTEN>
    message = strjoin(message, char(10)); %#ok<CHARTEN>
    request = matlab.net.http.RequestMessage;
    request.Method = 'POST';
    request.Header = matlab.net.http.HeaderField;
    request.Header.Name = 'Authorization';
    request.Header.Value = ['Bearer ' token];

    body = matlab.net.http.MessageBody;
    payload.raw = strrep(...
        strrep(matlab.net.base64encode(message), '+', '-'), ...
        '/', '_');
    body.Data = payload;
    request.Body = body;

    request.send([GMAIL_API '?key=' key]);
    end