%% downloadFromCanvas: Download the ZIP archive from Canvas
%
% downloadFromCanvas will download the given assignment to be parsed by the
% autograder
%
% downloadFromCanvas(C, A, T, P) will use the course ID in C, the assignment
% ID in A, the token in T, and the path in P to download and save the homework submission
% in an autograder-ready format in the path specified.
%
%%% Remarks
%
% This is used when instead of pre-downloading a ZIP archive, the user
% wants the autograder to directly download the student's submissions.
%
%%% Exceptions
%
% This will throw a generic AUTOGRADER:networking:connectionError exception
% if something goes wrong with the connection
%
%%% Unit Tests
%
%   % Assume the parameters are correct: C, A, T, P
%   downloadFromCanvas(C, A, T, P);
%
%   In path P, the student folders are all saved, along with a `grades.csv`
%
%   % Assume credentials are incorrect
%   downloadFromCanvas(C, A, T, P);
%
%   threw connectionError exception
function downloadFromCanvas(courseId, assignmentId, token, path)
    subs = getSubmissions(courseId, assignmentId, token);
    origPath = cd(path);
    cleaner = onCleanup(@()(cd(origPath)));
    % for each user, get GT Username, create folder, then inside that
    % folder, download submission
    names = cell(1, numel(subs));
    ids = cell(1, numel(subs));
    parfor s = 1:numel(subs)
        student = getStudentInfo(subs{s}.user_id, token);
        % create folder with name as login_id
        mkdir(student.login_id);
        names{s} = student.name;
        ids{s} = student.login_id;
        % for each attachment, download it here
        if isfield(subs{s}, 'attachments')
            for a = 1:numel(subs{s}.attachments)
                try
                    websave([pwd filesep student.login_id filesep subs{s}.attachments(a).filename], ...
                        subs{s}.attachments(a).url);
                catch reason
                    e = MException('AUTOGRADER:networking:connectionError', 'Connection was interrupted - see causes for details');
                    e = addCause(e, reason);
                    throw(e);
                end
            end
        end
    end
    % write info.csv
    names = [names; ids]';
    names = join(names, ', "');
    names = ['"' strjoin(names, '"\n"'), '"'];
    fid = fopen('info.csv', 'wt');
    fwrite(fid, names);
    fclose(fid);
    cd(origPath);
end

function subs = getSubmissions(courseId, assignmentId, token)
    % get all subs for this assignment. 
    API = 'https://gatech.instructure.com/api/v1';
    opts = weboptions;
    opts.HeaderFields = {'Authorization', ['Bearer ' token]};
    try
        subs = webread([API '/courses/' courseId '/assignments/' assignmentId '/submissions/'], 'per_page', '10000', opts);
    catch reason
        e = MException('AUTOGRADER:networking:connectionError', 'Connection was interrupted - see causes for details');
        e = addCause(e, reason);
        throw(e);
    end
end

function info = getStudentInfo(userId, token)
    API = 'https://gatech.instructure.com/api/v1';
    opts = weboptions;
    opts.HeaderFields = {'Authorization', ['Bearer ' token]};
    try
        info = webread([API '/users/' num2str(userId) '/profile/'], opts);
    catch reason
        e = MException('AUTOGRADER:networking:connectionError', 'Connection was interrupted - see causes for details');
        e = addCause(e, reason);
        throw(e);
    end
end
    