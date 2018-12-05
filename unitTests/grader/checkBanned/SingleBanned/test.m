%% SingleBanned: Uses a single function that's banned
%
function [passed, msg] = test
    try
        [isBanned, funs] = checkBanned('isBanner.m', {'parfeval', 'gcp'}, pwd);
    catch e
        passed = false;
        msg = sprintf('Expected true; got exception %s', e.message);
        return;
    end
    
    if ~isBanned
        passed = false;
        msg = 'Expected true; got false';
        return;
    end
    if ~strcmpi(funs, 'parfeval')
        passed = false;
        msg = sprintf('Expected parfeval; got %s', funs);
        return;
    else
        passed = true;
        msg = '';
        return;
    end
end