%% Valid Test Case
%
%   Assume T is a valid TestCase that does NOT error.
%   T = TestCase(...);
%   engine(T);
%
%   T now has files, outputs, etc. filled in correctly
function [passed, msg] = test()
    p = [pwd filesep 'testcase'];
    info.call = '[out] = helloWorld(in);';
    info.initializer = '';
    info.points = 3;
    info.banned = {};
    info.supportingFiles = {[pwd filesep 'testcase' filesep 'vars_rubrica.mat']};
    T = TestCase(info, p);

    try
        T2 = engine(T);
        % output should be input (1)
        if ~isfield(T2.outputs, 'out')
            passed = false;
            msg = 'Output field "out" not created';
            return;
        elseif ~isequal(T2.outputs.out, 1)
            passed = false;
            msg = 'Output not correctly set; expected 1';
            return;
        else
            passed = true;
            msg = 'Output correctly created';
        end
    catch e
        passed = false;
        msg = sprintf('Expected success; got exception %s', e.identifier);
    end
end
