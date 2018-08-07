%% Multiple Valid Feedback
%
%   Assume F is a valid Feedback with a valid TestCase
%   F = Feedback(...);
%   engine(F);
%
%   F now has files, outputs, etc. filled in correctly
function [passed, msg] = test()
    p = [pwd filesep 'feedback1'];
    info.call = '[out] = helloWorld(in);';
    info.initializer = '';
    info.points = 3;
    info.banned = {};
    info.supportingFiles = {[p filesep 'vars_rubrica.mat']};
    cd(p);
    T = TestCase(info, p);
    T = engine(T);
    cd('..');
    F(1) = Feedback(T, p);
    F(2) = Feedback(T, [pwd filesep 'feedback2']);
    F(3) = Feedback(T, [pwd filesep 'feedback3']);
    try
        F = engine(F);
        for F2 = F
            % output should be input (1)
            if ~isfield(F2.outputs, 'out')
                passed = false;
                msg = 'Output field "out" not created';
                return;
            elseif ~isequal(F2.outputs.out, 'hello.txt')
                passed = false;
                msg = 'Output not correctly set; expected "hello.txt"';
                return;
            else
                passed = true;
                msg = 'Output correctly created';
            end
        end
    catch e
        passed = false;
        msg = sprintf('Expected success; got exception %s', e.identifier);
    end
end
