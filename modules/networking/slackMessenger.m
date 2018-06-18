%% slackMessenger: Send a message in slack
%
% slackMessenger(T,C,M,A) will use the token T to post a message M in
% the slack channel ID C. The message will include file attachments A.
%
% A = slackMessenger(T) will return a structure array containing a list of
% channels, users, and groups avaliable to recieve messages in the slack
% workspace
%
%
%%% Remarks
%
% M can be formatted using slack message formatting
% ? to print bolded text, surround in asterisks. (*bold text*)
% ? to print italicized text, surround in underscores. (_italicized text_)
% ? to print code blocks within text, surround in single backtick marks
% (`codeblock`)
% See
% https://get.slack.help/hc/en-us/articles/202288908-Format-your-messages
% for more message formatting options
%
% As of now, slackMessenger will have the ability to send basic messages
% with file attachments. Future updates will attempt to implement more
% formatting and interactive messaging options.
%
%

function [channels] = slackMessenger(token,channel,message,attachments)
postMessage_API = 'https://slack.com/api/chat.postMessage';
fileUpload_API = 'https://slack.com/api/files.upload';

%create authorization header to be used in all requests
auth = matlab.net.http.HeaderField;
auth.Name = 'Authorization';
auth.Value = ['Bearer ' token];

if nargin == 1
    listChannel_API = 'https://slack.com/api/channels.list';
    listGroups_API = 'https://slack.com/api/groups.list';
    listUsers_API = 'https://slack.com/api/users.list';
    
    request = matlab.net.http.RequestMessage;

    contentType = matlab.net.http.HeaderField;
    contentType.Name = 'Content-Type';
    contentType.Value = 'application/x-www-form-urlencoded';
    
    request.Method = 'GET';
    request.Header = [contentType auth];
    
    rc = request.send(listChannel_API);
    rg = request.send(listGroups_API);
    ru = request.send(listUsers_API);
    rawUsers = ru.Body.Data.members;
    
    channels = struct('name',{rc.Body.Data.channels.name},...
                        'id',{rc.Body.Data.channels.id},...
                        'type','channel');
    groups = struct('name',{rg.Body.Data.groups.name},...
                        'id',{rg.Body.Data.groups.id},...
                        'type','channel');
    users = struct('name',{rawUsers.real_name},....
                        'id',{rawUsers.id},...
                        'type','user');
                    
    toDelete = [rawUsers.is_bot] | [rawUsers.is_app_user] | strcmp({rawUsers.name},'slackbot');
    users(toDelete) = [];
    
    channels = [channels groups users];
    return
end 

if ~isempty(message)
    mrequest = matlab.net.http.RequestMessage;
    
    contentType = matlab.net.http.HeaderField;
    contentType.Name = 'Content-Type';
    contentType.Value = 'application/json';
    
    mrequest.Method = 'Post';
    mrequest.Header = [auth contentType];
    
    for c = 1:numel(channel)
        body.text = message;
        body.channel = channel{c};
        body = matlab.net.http.MessageBody(body);
        
        mrequest.Body = body;
        
        r = mrequest.send(postMessage_API);
        
        clear body
    end
end

if nargin == 4
    arequest = matlab.net.http.RequestMessage;
    
    contentType = matlab.net.http.HeaderField;
    contentType.Name = 'Content-Type';
    contentType.Value = 'multipart/form-data';
    
    arequest.Method = 'post';
    arequest.Header = [auth contentType];
    for a = 1:numel(attachments)
        fileProv = matlab.net.http.io.FileProvider(attachments{a});
        fp = matlab.net.http.io.MultipartFormProvider("channels",channel,"file",fileProv);
        
        arequest.Body = fp;
        
        f = arequest.send(fileUpload_API);
    end
end










