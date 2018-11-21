%% MultipleBanned: Multiple banned functions across files
%
function [passed, msg] = test

cd('student');
try
    [isBanned, funs] = checkBanned('student.m', {'eval', 'pwd', 'gcp'}, pwd);
catch e
    cd('..');
    passed = false;
    msg = sprintf('Expected true; got exception %s', e.message);
    return;
end
cd('..');

if ~isBanned
    passed = false;
    msg = 'Expected true; got false';
    return;
end

if ~contains(funs, 'eval')
    passed = false;
    msg = sprintf('Expected eval in list; got %s', funs);
    return;
elseif ~contains(funs, 'pwd')
    passed = false;
    msg = sprintf('Expected pwd in list; got %s', funs);
    return;
elseif ~contains(funs, 'PARFOR')
    passed = false;
    msg = sprintf('Expected PARFOR in list; got %s', funs);
    return;
end
passed = true;
msg = '';
end