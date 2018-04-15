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
    % for each user, get GT Username, create folder, then inside that
    % folder, download submission
    names = cell(2, numel(subs));
    for s = 1:numel(subs)
        student = getStudentInfo(subs{s}.user_id, token);
        % create folder with name as login_id
        mkdir(student.login_id);
        names{1, s} = student.name;
        names{2, s} = student.login_id;
        orig = cd(student.login_id);
        % for each attachment, download it here
        if isfield(subs{s}, 'attachments')
            for a = 1:numel(subs{s}.attachments)
                websave(subs{s}.attachments(a).filename, ...
                    subs{s}.attachments(a).url);
            end
        end
        cd(orig);
    end
    % write info.csv
    records = cell(1, size(names, 2));
    for n = 1:size(names, 2)
        records{n} = strjoin(names(:, n)', ': ');
    end
    fid = fopen('info.csv', 'wt');
    fwrite(fid, strjoin(records, newline));
    fclose(fid);
    cd(origPath);
end

function subs = getSubmissions(courseId, assignmentId, token)
    % get all subs for this assignment. 
    API = 'https://gatech.instructure.com/api/v1';
    opts = weboptions;
    opts.HeaderFields = {'Authorization', ['Bearer ' token]};
    subs = webread([API '/courses/' num2str(courseId) '/assignments/' num2str(assignmentId) '/submissions/'], 'per_page', '10000', opts);
end

function info = getStudentInfo(userId, token)
    API = 'https://gatech.instructure.com/api/v1';
    opts = weboptions;
    opts.HeaderFields = {'Authorization', ['Bearer ' token]};
    info = webread([API '/users/' num2str(userId) '/profile/'], opts);
end
    