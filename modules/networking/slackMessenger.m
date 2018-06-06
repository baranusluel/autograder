%% slackMessenger: Send a message in slack
% 
% sendSlack will post a message in slack providing the recipient with
% information regarding the status of the autograder.
% 
% slackSender(C,M,T,A) will use the token T to post a message M in
% the slack channel C. The message will include file attachments A. 
% 
%
%%% Remarks
%
% As of now, slackMessenger will have the ability to send basic messages
% with file attachments. Future updates will attempt to implement more
% formatting and interactive messaging options. 