function [passed, message] = studentFileChecker(expect, check)
    if numel(expect) ~= numel(S.submissions)
        passed = false;
        message = sprintf('Submission number mismatch; expected %d, got %d', numel(expect), numel(check));
        return;
    end
    for f = 1:numel(expect)
        if sum(strcmp(expect{f}, check)) ~= 1
            passed = false;
            message = sprintf('File "%s" was not correctly recorded as a submission', expect{f});
            return;
        end
    end
    passed = true;
    message = '';