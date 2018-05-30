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
function emailMessenger(email, subject, message, token, key)
GMAIL_API = 'https://www.googleapis.com/gmail/v1/users/me/messages/send';
    subject = strrep(subject, '&', '&amp;');
    subject = strrep(subject, '<', '&lt;');
    subject = strrep(subject, '>', '&gt;');
    token = refresh2access(token);
    message = {'From: CS 1371 Autograder <cs1371notifier@gmail.com>', ...
            ['To: Texting Server <' email '>'], ...
            ['Subject: ', subject], ...
            ['Date: ' datestr(datetime('now'), 'ddd, dd mmm yyyy HH:MM:SS') ' -0600'], ...
            'Message-ID: <1371@cs1371.gatech.edu>', ...
            '', ...
            message};
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