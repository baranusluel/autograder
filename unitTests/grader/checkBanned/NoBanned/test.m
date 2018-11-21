%% NoBanned: Student did not use a banned function
% Student did not use a banned function, but does it as a string and
% variable (i.e, 'banned', banned = 1;).
%
% Additionally, it has helper functions that recursively call themselves
% and each other, and calls other files.
function [passed, msg] = test()

%
BANNED = {'eval', 'hello'};
cd('student');
try
    [isBanned, fns] = checkBanned('myFunction.m', BANNED, pwd);
catch e
    cd('..');
    passed = false;
    msg = sprintf('Expected false; got exception %s', e.message);
    return;
end
cd('..');

if ~isBanned
    msg = '';
    passed = true;
    return;
end

passed = false;
msg = sprintf('Expected false; got true and %s', fns);
end