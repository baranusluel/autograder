%% slackMessenger: Send a message in slack
% 
% slackMessenger(C,M,T,A) will use the token T to post a message M in
% the slack channel name C. The message will include file attachments A.  
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

function slackMessenger(channel,message,token,attachments)


end










