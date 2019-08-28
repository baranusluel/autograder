%% uploadOverallGrades: Uploads the overall grades to Canvas
%
% uploadOverallGrades(S, R, I, M, C, T, P) will use student array S,
% related course information R, resubmission flag I, maximum flag M, course
% ID C, Canvas token T, and progress bar P to upload overall grades to
% Canvas.
%
%%% Remarks
%
% It is imperative to be careful with this function - it will overwrite any
% grades for the given "collector"
function uploadOverallGrades(students, related, isResubmission, isMax, courseId, token, progress)
    % uploadGrades only needs Grade (we calc here) and id, which we already
    % have! So create
    otherSubs = related.other.submissions;
    for i = length(students):-1:1
        studs(i).canvasId = students(i).canvasId;
        stud = otherSubs([otherSubs.id] == str2double(students(i).canvasId));
        if isMax
            studs(i).Grade = max([students(i).Grade, stud.submission.score]);
        elseif isResubmission
            if ~isempty(stud.submission.score) && stud.submission.score > students(i).Grade
                studs(i).Grade = mean([students(i).Grade, stud.submission.score]);
            else
                studs(i).Grade = students(i).Grade;
            end
        else
            % not max and not resubmission - it's just our grade
            studs(i).Grade = students(i).Grade;
        end
    end
    % uploadGrades is fooled! Just feed
    uploadGrades(studs, courseId, num2str(related.collector.id), token, progress);
end