%% Passing Files
%
% This unit test has a solution which produces two files
function [passed, msg] = test()
    % set up test case
    info.call = '[] = helloWorld()';
    info.initializer = '';
    info.points = 10;
    info.banned = {};
    info.supportingFiles = {};
    T = TestCase(info, [pwd filesep 'soln']);
    try
        T2 = engine(T);
    catch e
        passed = false;
        msg = sprintf('Expected success; got exception "%s"', e.identifier);
        return;
    end
    if numel(T2.files) ~= 2
        passed = false;
        msg = sprintf('Expected 2 files; got %d', numel(T2.files));
        return;
    else
        % check that our files are correct
        F1 = T2.files(1);
        F2 = T2.files(2);
        if ~strcmp(F1.name, 'test1') && ~strcmp(F2.name, 'test1')
            passed = false;
            msg = 'Expected to find file test1; no file named test1 found';
            return;
        elseif ~strcmp(F1.name, 'test2') && ~strcmp(F2.name, 'test2')
            passed = false;
            msg = 'Expected to find file test2; not file named test2 found';
            return;
        end
        if ~strcmp(F1.extension, '.txt') || ~strcmp(F2.extension, '.txt')
            passed = false;
            msg = sprintf('Expected to find .txt extension; got "%s", "%s" instead', F1.extension, F2.extension);
            return;
        end
        % check results
        if strcmp(F1.name, 'test2')
            tmp = F1;
            F1 = F2;
            F2 = tmp;
        end

        if ~strcmp(F1.data, 'Hello World')
            passed = false;
            msg = sprintf('Expected to find "Hello World"; got "%s" instead', F1.data);
            return;
        elseif ~strcmp(F2.data, 'Wassup World')
            passed = false;
            msg = sprintf('Expected to find "Wassup World"; got "%s" instead', F2.data);
            return;
        else
            passed = true;
            msg = 'Files passed';
            return;
        end
    end
end