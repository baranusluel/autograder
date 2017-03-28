% CALLED BY:
%       getRubric.m
function rubric = addSolutionsToRubric(solutions, rubric)

    filenames = {rubric.name};
    for ndx = 1:length(filenames)
        [~, field] = fileparts(filenames{ndx});
        rubric(ndx).solution.functionHandle = solutions.(field);
    end

end