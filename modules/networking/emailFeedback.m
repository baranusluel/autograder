%% emailFeedback: Emails feedback to students
%
% emailFeedback(T, K, I, C, S, M, P) will send message and feedback files 
% tied  to students in Student array S, using token T, key K, client ID I, 
% and secret C. Additionally, it will update progress bar P.
%
%%% Remarks
%
% This is used instead of (or in addition to) uploading the files
function emailFeedback(token, key, id, secret, students, message, progress)
    % for each student, email feedback
    for s = numel(students):-1:1
        student = students(s);
        workers(s) = parfeval(@emailMessenger, 0, ...
            [student.id '@gatech.edu'], 'Feedback', message, token, id, ...
            secret, key, [student.path filesep 'feedback.html']);
    end
    progress.Indeterminate = 'off';
    progress.Value = 0;
    while ~all([workers.Read])
        workers.fetchNext();
        progress.Value = min([progress.Value + 1/numel(workers), 1]);
    end
end