%% postToCanvas: Post a message to canvas
%
% postToCanvas will post a message to the course website on Canvas as the
% specified user
%
% postToCanvas(C, T, M) will post a message to the course specified by the
% courseID C, as the poster specified by the token T, using the message M.
%
%%% Remarks
%
% While this is primarily used to post messages about homework grading to
% Canvas, it can actually be used to post _anything_ to Canvas. Be careful.
%
%%% Exceptions
%
% Like all other networking functions, this will throw an
% AUTOGRADER:postToCanvas:invalidCredentials exception if the token given 
% doesn't work.
%
% Additionally, it will also throw an AUTOGRADER:postToCanvas:connection
% exception if the connection is somehow broken.
%
%%% Unit Tests
%
%   C = 1234; % valid CourseID
%   T = '...'; % valid token
%   M = 'Hello, World!'; % message
%   postToCanvas(C, T, M);
%
%   Message 'Hello, World!' posted
function postToCanvas(courseId, token, message)
    API = 'https://gatech.instructure.com/api/v1/';
    apiOpts = weboptions;
    apiOpts.RequestMethod = 'POST';
    apiOpts.HeaderFields = {'Authorization', ['Bearer ' token]};
    
    title = 'Homework Grades Released';
    published = 'true';
    allow_rating = 'false';
    is_announcement = 'true';
    try
        webwrite([API 'courses/' num2str(courseId) '/discussion_topics'], ...
            'title', title, 'message', message, 'published', published, ...
            'allow_rating', allow_rating, 'is_announcement', is_announcement, apiOpts);
    catch reason
        if strcmp(reason.identifier, 'MATLAB:webservices:HTTP401StatusCodeError')
            e = MException('AUTOGRADER:postToCanvas:invalidCredentials', 'Invalid token was provided');
            e = e.addCause(reason);
            throw(e);
        end
        e = MException('AUTOGRADER:postToCanvas:connection', 'Connection was interrupted');
        e = e.addCause(reason);
        throw(e);
    end
        
end