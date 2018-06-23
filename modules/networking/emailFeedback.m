%% emailFeedback: Emails feedback to students
%
% emailFeedback(T, K, I, C, S, M) will send message and feedback files tied 
% to students in Student array S, using token T, key K, client ID I, and 
% secret C.
%
%%% Remarks
%
% This is used instead of (or in addition to) uploading the files
function emailFeedback(token, key, id, secret, students, message)
    % for each student, email feedback
    parfor s = students(1:end)
        emailMessenger([s.id '@gatech.edu'], 'Feedback', message, ...
            token, id, secret, key, [s.path filesep 'feedback.html']);
    end
end