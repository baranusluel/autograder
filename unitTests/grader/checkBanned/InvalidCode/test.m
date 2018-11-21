%% InvalidCode: Student code does not work
%
function [passed, msg] = test()
    try
        [isBanned, fns] = checkBanned('myBrokenFunction.m', {'eval'}, pwd);
    catch e
        passed = false;
        msg = sprintf('Expected false; got exception %s', e.message);
        return;
    end
    if ~isBanned
        passed = true;
        msg = '';
    else
        msg = sprintf('Excpected false; got true and %s', fns);
        passed = false;
    end
end