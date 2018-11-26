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
    progress.Message = 'Uploading Student Feedback to Canvas';
    progress.Indeterminate = 'off';
    progress.Value = 0;
    
    for s = numel(students):-1:1
        stud.path = students(s).path;
        stud.id = students(s).canvasId;
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
    API = 'https://gatech.instructure.com/api/v1/';
    putApiOpts = weboptions;
    putApiOpts.HeaderFields = {'Authorization', ['Bearer ' token]};
    putApiOpts.RequestMethod = 'PUT';
    auth = matlab.net.http.HeaderField;
    auth.Name = 'Authorization';
    auth.Value = ['Bearer ' token];
    id = student.id;
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
    request = matlab.net.http.RequestMessage;
    opts = matlab.net.http.HTTPOptions;
    opts.ConvertResponse = false;
    
    body = matlab.net.http.MessageBody;
    body.Data = struct('name', 'feedback.html', ...
        'size', num2str(fileSize), ...
        'content_type', 'text/html');
    request.Body = body;
    request.Header = auth;
    request.Method = 'POST';
    
    resp = request.send(COMMENT_API, opts);
    decodedResp = jsondecode(resp.Body.Data);
    
    searchString = char(resp.Body.Data);
    searchString(~isstrprop(searchString, 'alphanum')) = '_';
    
    originalString = char(resp.Body.Data);
    
    uploadUrl = decodedResp.upload_url;
    params = decodedResp.upload_params;

    %% Step 2
    names = fieldnames(params);
    uploadParams = cell(1, 2 * numel(names));
    for i = 1:numel(names)
        uploadParams{2 * i} = params.(names{i});
        % change the parameter names
        % for each parameter, find in the search string. Then, use the
        % index to get the correspond ACTUAL name out of originalString.
        
        ind = strfind(searchString, names{i});
        
        uploadParams{(2 * i) - 1} = originalString(ind(1):(ind(1) + length(names{i}) - 1));
    end
    uploadParams = cellfun(@string, uploadParams, 'uni', false);


    request = matlab.net.http.RequestMessage;

    contentType = matlab.net.http.HeaderField;
    contentType.Name = 'Content-Type';
    contentType.Value = 'multipart/form-data';

    request.Method = 'POST';
    request.Header = contentType;

    fileProvider = matlab.net.http.io.FileProvider([student.path filesep 'feedback.html']);
    fileProvider = matlab.net.http.io.MultipartFormProvider(uploadParams{:}, "file", fileProvider);

    request.Body = fileProvider;
    try
        request.send(uploadUrl);
    catch
    end
    warning('off');
    tmp = struct(request.Body);
    warning('on');
    contentLength = matlab.net.http.HeaderField;
    contentLength.Name = 'Content-Length';
    contentLength.Value = num2str(tmp.BytesSent);
    request.Header = [request.Header contentLength];
    resp = request.send(uploadUrl);
    
    request = matlab.net.http.RequestMessage;
    request.Method = 'GET';
    contentLength.Value = '0';
    mask = [resp.Header.Name];
    mask = strcmpi(mask, 'Location');
    request.Header = [auth contentLength];
    resp = request.send(resp.Header(mask).Value);

    fileId = num2str(resp.Body.Data.id);

    %% Step 3
    coveredRead([API 'courses/' courseId '/assignments/' assignmentId '/submissions/' id], putApiOpts, 'comment[file_ids][]', fileId, 'comment[text_comment]', 'Your Feedback File');
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