%% BannedOperation: Student uses banned operation

function [passed, msg] = test()

try
    [isBanned, ops] = checkBanned('myGlobalFunction.m', {}, pwd);
catch e
    passed = false;
    msg = sprintf('Expected true; got exception %s', e.message);
    return;
end

if ~isBanned
    passed = false;
    msg = 'Expected true; got false';
elseif ~strcmp(ops, 'GLOBAL')
    passed = false;
    msg = sprintf('Expected GLOBAL; got %s', ops);
else
    passed = true;
    msg = '';
end