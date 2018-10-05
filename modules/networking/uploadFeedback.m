%% uploadFeedback: Upload Feedback to the correct repository
%
% uploadFeedback will take in an array of Students, as well as the current assignment,
% and will upload their feedback.
%
% uploadGrades(S, C, H, T, B) will use the student array S, the CourseID C,
% the HomeworkID H, and the Token T to upload student feedback to Canvas.
% This uses the LMS RESTful API. Additionally, it updates the progress bar
% B.
%
%%% Remarks
%
% uploadFeedback requires a TA token - preferably an admin token. Tokens can be generated manually
% via the settings page of your Canvas Settings.
%
% Care must be taken with this token. Treat it like your password - anyone who has access to this token
% can do anything, masquerading as you.
%
% It is assumed that our Canvas page is located at https://gatech.instructure.com
%
% If a grade is manually changed on canvas, the autograder will skip that student, so tweaked grades are retained.
%
%%% Exceptions
%
% Like other networking functions, this will throw an
% AUTOGRADER:networking:connectionError exception if something goes awry.
%
%%% Unit Tests
%
%   S = Student(); % valid student array
%   C = '12345'; % valid courseID
%   H = '54321'; % valid AssignmentID
%   T = '2096~...'; % valid token
%   B = uiprogressdlg;
%   uploadFeedback(S, C, H, T, B)
%
%   Students' grades are uploaded

function uploadFeedback(students, courseId, assignmentId, token, progress)
    if any(~isvalid(students))
        return;
    end
    progress.Message = 'Uploading Student Feedback to Canvas';
    progress.Indeterminate = 'off';
    progress.Value = 0;
    % set up web options
    apiOpts = weboptions;
    apiOpts.RequestMethod = 'GET';
    apiOpts.HeaderFields = {'Authorization', ['Bearer ' token]};

    % for each student, get student ID from GT Username. Then, using id, upload grades.
    getApiOpts = apiOpts;
    getApiOpts.RequestMethod = 'GET';
    putApiOpts = apiOpts;
    putApiOpts.RequestMethod = 'PUT';
    for s = numel(students):-1:1
        stud.name = students(s).name;
        stud.grade = students(s).grade;
        stud.path = students(s).path;
        workers{s} = parfeval(@uploadFile, 0, ...
            courseId, assignmentId, stud, token);
    end
    workers = [workers{:}];
    
    workers([workers.ID] == -1) = [];
    while ~all([workers.Read])
        fetchNext(workers);
        if progress.CancelRequested
            cancel(workers);
            throw(MException('AUTOGRADER:userCancellation', 'User Cancelled Operation'));
        end
        progress.Value = min([progress.Value + 1/numel(workers), 1]);
    end
end

function uploadFile(courseId, assignmentId, student, token)
    apiOpts = weboptions;
    apiOpts.RequestMethod = 'GET';
    apiOpts.HeaderFields = {'Authorization', ['Bearer ' token]};
    API = 'https://gatech.instructure.com/api/v1/';
    % for each student, get student ID from GT Username. Then, using id, upload grades.
    getApiOpts = apiOpts;
    getApiOpts.RequestMethod = 'GET';
    putApiOpts = apiOpts;
    putApiOpts.RequestMethod = 'PUT';
    id = coveredRead([API 'courses/' courseId '/users'], getApiOpts, 'search_term', student.name);
    if ~isempty(id)
        id = num2str(id.id);
        apiOpts = weboptions;
        apiOpts.RequestMethod = 'POST';
        apiOpts.HeaderFields = {'Authorization', ['Bearer ' token]};
        COMMENT_API = sprintf('https://gatech.instructure.com/api/v1/courses/%s/assignments/%s/submissions/%s/comments/files', ...
            courseId, assignmentId, id);

        % Steps:
        %   1. Get the URL to upload to. To do this, we post to COMMENT_API
        %   with:
        %       * name
        %       * size
        %       * content_type=text/html
        %   From this, you'll get back a URL to upload the actual file to.
        %   2. Upload the file. Get back a URL and File ID
        %   3. Create new submission comment and add the File ID from 2.
        
        %% Step 1
        % first get size
        fileSize = dir([student.path filesep 'feedback.html']);
        fileSize = fileSize.bytes;
        % name is just feedback.html
        resp = webwrite(COMMENT_API, 'name', 'feedback.html', ...
            'size', num2str(fileSize), ...
            'content_type', 'text/html', apiOpts);
        uploadUrl = resp.upload_url;
        params = resp.upload_params;
        
        %% Step 2
        names = fieldnames(params);
        uploadParams = cell(1, 2 * numel(names));
        uploadParams(1:2:end) = names;
        for i = 1:numel(names)
            uploadParams{2 * i} = params.(names{i});
        end
        uploadParams = cellfun(@string, uploadParams, 'uni', false);


        request = matlab.net.http.RequestMessage;

        auth = matlab.net.http.HeaderField;
        auth.Name = 'Authorization';
        auth.Value = ['Bearer ' token];

        contentType = matlab.net.http.HeaderField;
        contentType.Name = 'Content-Type';
        contentType.Value = 'multipart/form-data';

        request.Method = 'POST';
        request.Header = [auth contentType];

        fileProvider = matlab.net.http.io.FileProvider([student.path filesep 'feedback.html']);
        fileProvider = matlab.net.http.io.MultipartFormProvider(uploadParams{:}, "file", fileProvider);
        
        request.Body = fileProvider;
        resp = request.send(uploadUrl);
        
        fileId = num2str(resp.Body.Data.id);
        
        %% Step 3
        coveredRead([API 'courses/' courseId '/assignments/' assignmentId '/submissions/' id], putApiOpts, 'comment[file_ids][]', fileId, 'comment[text_comment]', 'Your Feedback File');
    end
end

function out = coveredRead(url, opts, varargin)
    try
        out = webread(url, varargin{:}, opts);
    catch reason
        e = MException('AUTOGRADER:networking:connectionError', 'Connection was terminated');
        e = e.addCause(reason);
        throw(e);
    end
end