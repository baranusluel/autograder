%% Multiple Valid Test Case
%
%   Assume T is a valid TestCase that does NOT error.
%   T = TestCase(...);
%   engine(T);
%
%   T now has files, outputs, etc. filled in correctly
function [passed, msg] = test()
    p = [pwd filesep 'testcase1'];
    info.call = '[out] = helloWorld(in);';
    info.initializer = '';
    info.points = 3;
    info.banned = {};
    info.supportingFiles = {'vars_rubrica.mat'};
    T1 = TestCase(info, p);
    
    p = [pwd filesep 'testcase2'];
    info.call = '[out] = goodbyeWorld(in);';
    info.initializer = '';
    info.points = 3;
    info.banned = {};
    info.supportingFiles = {'vars_rubricb.mat'};
    T2 = TestCase(info, p);
    
    try
        T1Out = engine(T1);
        T2Out = engine(T2);
        % output should be input (1)
        if ~isfield(T1Out.outputs, 'out')
            passed = false;
            msg = 'Output field "out" not created';
            return;
        elseif ~isequal(T1Out.outputs.out, 1)
            passed = false;
            msg = 'Output not correctly set; expected 1';
            return;
        elseif ~isfield(T2Out.outputs, 'out')
            passed = false;
            msg = 'Output field "out" not created';
            return;
        elseif ~isequal(T2Out.outputs.out, 1)
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
