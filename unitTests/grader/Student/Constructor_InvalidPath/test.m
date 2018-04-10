%% Invalid Path
%
% Given an invalid PATH (e.g. folder does not exist):
%   NAME = 'Hi';
%   this = Student(PATH, NAME);
%
%   Constructor threw exception
%   AUTOGRADER:Student:ctor:invalidPath

function [passed, message] = test()

    name = 'Hello';
    id = 'tuser3';
    p = [pwd filesep id];
    try
        S = Student(p, name);
    catch e
        if strcmp(e.identifier, 'AUTOGRADER:Student:ctor:invalidPath')
            passed = true;
            message = 'Exception correctly thrown';
        else
            passed = false;
            message = sprintf('Incorrect exception; expected ''AUTOGRADER:Student:ctor:invalidPath'', got ''%s'' instead', e.identifier);
        end
        return;
    end
    passed = false;
    message = 'Failed to throw exception for invalid path';
end