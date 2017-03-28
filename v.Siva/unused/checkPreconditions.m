% CALLED BY:
%       gradeSubmission.m
function isSatisfied = checkPreconditions(problem, functionHandles)

    isSatisfied = true;
    % check if function exists
    functions = cellfun(@func2str, functionHandles, 'UniformOutput', false);
    functionExists = any(strcmp(functions, problem.name));
    isSatisfied = isSatisfied & functionExists;
    % check if there are any preconditions
    preconditionsExist = ~isempty(problem.preconditions);
    if isSatisfied && preconditionsExist
        % % if expecting recursion
        % if any(strcmp(problem.preconditions,'expectRecursion'))
        %     % change recursion limit
        %     % 6 to account for the stack of problems being called
        %     set(0, 'RecursionLimit', 5);
        %     % initialize variables
        %     isRecursive = false;
        %     ndx = 1;
        %     % while not recursive and still have test cases
        %     while (false == isRecursive) && (ndx <= length(problem.testcases))
        %         % run eval on function and see if it crashes (try catch)
        %         try
        %             eval(problem.testcases{ndx});
        %         catch e
        %             % check if error caught is recursion
        %             if strcmp('MATLAB:recursionLimit',e.identifier)
        %                 isRecursive = true;
        %             end
        %         end
        %         ndx = ndx + 1;
        %     end
        %     % reset recursion limit
        %     set(0, 'RecursionLimit', 500);
        %     isSatisfied = isSatisfied && isRecursive;

        % end
    end
end