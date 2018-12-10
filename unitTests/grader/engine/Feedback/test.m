%% Valid Feedback
%
%   Assume F is a valid Feedback with a valid TestCase
%   F = Feedback(...);
%   engine(F);
%
%   F now has files, outputs, etc. filled in correctly
function [passed, msg] = test()
    p = [pwd filesep 'feedback'];
    info.call = '[out] = helloWorld(in);';
    info.initializer = '';
    info.points = 3;
    info.banned = {};
    info.supportingFiles = {[p filesep 'vars_rubrica.mat']};
    T = TestCase(info, p);
    cd(p);
    T = engine(T);
    cd('..');
    F = Feedback(T, p);
    try
        cd(p);
        F2 = engine(F);
        cd('..');
        % output should be input (1)
        if ~isfield(F2.outputs, 'out')
            passed = false;
            msg = 'Output field "out" not created';
            return;
        elseif ~isequal(F2.outputs.out, 1)
            passed = false;
            msg = 'Output not correctly set; expected 1';
            return;
        else
            passed = true;
            msg = '';
        end 
    catch e
        passed = false;
        msg = sprintf('Expected success; got exception %s', e.identifier);
    end
end
