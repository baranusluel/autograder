% CALLED BY:
%       loadRubric.m
function newRubric = parseRubricPreconditions(rubric)

    for ndxRubric = 1:length(rubric)
        problem = rubric(ndxRubric);
        problem.preconditions = {};
        fields = fieldnames(problem);
        for ndxFields = 1:length(fields)
            field = fields{ndxFields};
            % check if there is "expect" in the name AND that the field is true
            if ~isempty(strfind(field, 'expect'))
                if problem.(field)
                    problem.preconditions = [problem.preconditions, fields{ndxFields}];
                end
                problem = rmfield(problem, field);
            end
        end
        newRubric(ndxRubric) = problem;
    end

end