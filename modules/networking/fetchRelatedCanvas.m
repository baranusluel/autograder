%% fetchRelatedCanvas: Fetch related canvas assignment information
%
% R = fetchRelatedCanvas(H, I, C, T, P) will use homework number H,
% resubmission flag I, course ID C, Canvas token T, and progress bar P to
% fetch the related course information
%
%%% Remarks
%
% This fetches the courses that are associated with the current assignment;
% namely, the other (i.e., if we are grading the submission, the
% resubmission, otherwise the submission), and the "collector" - the actual
% homework grade that will be reported to canvas.

function related = fetchRelatedCanvas(hwNum, isResub, courseId, token, progress)
    API = 'https://gatech.instructure.com/api/v1/courses/';
    % Find the corresponding submission/resubmission
    
    % list our assignments - shouldn't be more than 50 so shouldn't have to
    % worry about pages!
    opts = weboptions;
    opts.HeaderFields = {'Authorization', ['Bearer ' token]};
    rawAssigns = webread([API courseId '/assignments?per_page=50'], opts);
    
    % sanitize into structure array
    assigns = cellfun(@sanitizeAssignment, rawAssigns);
    % If we are resubmission
    if ~isResub
        % We are submission
        mask = contains({assigns.name}, 'resubmission', 'IgnoreCase', true) & ...
            contains({assigns.name}, [' ' num2str(hwNum) ' ']) & ...
            (contains({assigns.name}, 'homework', 'IgnoreCase', true) | ...
            contains({asssigns.name}, 'hw', 'IgnoreCase', true));
        other = assigns(mask);
    else
        % We are resubmission
        mask = ~contains({assigns.name}, 'resubmission', 'IgnoreCase', true) & ...
            ~contains({assigns.name}, 'grade', 'IgnoreCase', true) & ...
            (contains({assigns.name}, 'homework', 'IgnoreCase', true) | ...
            contains({assigns.name}, 'hw', 'IgnoreCase', true)) & ...
            contains({assigns.name}, [' ' num2str(hwNum) ' ']);
        other = assigns(mask);
    end
    % get the grades associated with other
    subs = getCanvasStudents(courseId, num2str(other.id), token, progress);
    related.other = struct('assignment', other, 'submissions', subs);
    % Find the corresponding collector
    mask = contains({assigns.name}, 'grade', 'IgnoreCase', true) & ...
        contains({assigns.name}, [' ' num2str(hwNum) ' ']);
    collector = assigns(mask);
    related.collector = collector;
end

function assign = sanitizeAssignment(raw)
    assign.id = raw.id;
    assign.name = raw.name;
    assign.workflow_state = raw.workflow_state;
end