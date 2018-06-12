%% slackMessenger: Send a message in slack
% 
% slackMessenger(C,M,T,A) will use the token T to post a message M in
% the slack channel ID C. The message will include file attachments A.  
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

function slackMessenger(channel,message,token,attachments)
postMessage_API = 'https://slack.com/api/chat.postMessage';

auth = matlab.net.http.HeaderField;
auth.Name = 'Authorization';
auth.Value = ['Bearer ' token];

contentType = matlab.net.http.HeaderField;
contentType.Name = 'Content-Type';
contentType.Value = 'application/json';

body.text = message;

request.Method = 'Post';
request.Header = [auth contentType];

for c = 1:numels(channel)
    body.channel = channel(c);
    body = matlab.net.http.MessageBody(body);
    
    request.Body = body;
    
    r = request.send(postMessage_API);
end 

end










