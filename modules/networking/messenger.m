%% messenger: Send messages on all predefined channels
%
% messenger(A, S) will send the messages as defined within autograder A,
% using student array S.
%
%%% Remarks
%
% messenger is used to communicate along user-defined channels.
%
%%% Exceptions
%
% If any single method fails, then that exception is not caught.
%
function messenger(app, students)
    MESSAGE_FORMAT = ['Hi!,' newline, ...
        '    The autograder has finished execution. Attached, you''ll find some useful files.' newline, ...
        'The average grade was %0.2f, with a minimum of %0.2f and a maximum of %0.2f.' newline, ...
        newline, ...
        'Best Regards,' newline, ...
        'The CS 1371 Autograder'];
    message = sprintf(MESSAGE_FORMAT, mean([students.Grade]), min([students.Grade]), max([students.Grade]));
    
    % Save grades and IDs to csv file
    names = {students.name};
    ids = {students.id};
    grades = arrayfun(@num2str, [students.Grade], 'uni', false);
    csv = join([names; ids; grades]', '","');
    csv = ['"' strjoin(csv, ['"' newline]) '"'];
    tmp = tempname;
    mkdir(tmp);
    
    fid = fopen([tmp filesep 'grades.csv'], 'wt');
    fwrite(fid, csv);
    fclose(fid);
    
    % Send email
    if ~isempty(app.email)
        emailMessenger(app.email, 'Autograder Finished', ...
            message, ...
            app.notifierToken, app.googleClientId, app.googleClientSecret, ...
            app.driveKey, [tmp filesep 'grades.csv']);
    end
    
    % Send text
    if ~isempty(app.phoneNumber)
        textMessenger(app.phoneNumber, ...
            'Autograder Finished! Please check your email or the autograder itself for more information!', ...
            app.twilioSid, app.twilioToken, app.twilioOrigin);
    end
    
    % Send slack message
    if ~isempty(app.slackRecipients)
        slackMessenger(app.slackToken, {app.slackRecipients.id}, message, [tmp filesep 'grades.csv']);
    end
    delete([tmp filesep 'grades.csv']);
    
    desktopMessenger('Grading has finished');
    [~] = rmdir(tmp, 's');
end