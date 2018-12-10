%% Infinite Open Files
%
% The autograder should not care if the student opens infinite files, and
% the parallel pool doesn't need to be deleted. ensure it's ok by trying to
% open a NEW file (fopen(tempname)) - if that works, then everything is ok.
function [passed, msg] = test()
    p = [pwd filesep 'testCase'];
    info.call = '[out] = helloWorld(in);';
    info.supportingFiles = {[p filesep 'vars_rubrica.mat']};
    info.initializer = '';
    info.points = 3;
    info.banned = {};
    T = TestCase(info, p);
    F = Feedback(T, [pwd filesep 'tuser3']);
    try
        F2 = engine(F);
        % try to open a new file
        fid = fopen(tempname, 'w');
        if fid == -1
            passed = false;
            msg = 'Unable to create a new file';
            return;
        else
            fclose(fid);
            passed = true;
            msg = '';
        end
    catch e
        passed = false;
        msg = sprintf('Expected success; got exception %s', e.identifier);
        return;
    end