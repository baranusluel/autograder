%% ValidTestCase
% Given a valid PATH to a student folder containing submissions
% (with filenames FILE1, FILE2, ...):
%
%   INFO = struct('call', '[out1, out2] = myFunction(in1, in2);', 'initializer', [], 'points', 3, 'supportingFiles', {{'values.mat'}}, 'banned', '')
%   this = TestCase(INFO, PATH)
%
%   this.call = '[out1, out2] = myFunction(in1, in2);'
%   this.initializer = []
%   this.points -> 3;
%   this.supportingFiles -> [];
%   this.loadFiles -> {'values.mat'};
%   this.banned -> [];
%   this.path -> PATH
%   this.outputs -> struct('out1', 'hello', 'out2', 'world');
function [passed, message] = test()
    info = struct('call', '[out1, out2] = myFunction(in1, in2);', 'initializer', [], 'points', 3, 'supportingFiles', {{[pwd filesep 'values_rubrica.mat']}}, 'banned', '');
    id = 'tuser3';
    path = [pwd filesep id];
    try
        tc = TestCase(info, path);
        tc = engine(tc);
    catch e
        passed = false;
        message = sprintf('Exception Thrown: %s (%s)', e.identifier, e.message);
        return;
    end
    if ~strcmp(tc.call, '[out1, out2] = myFunction(in1, in2);')
        passed = false;
        message = sprintf('Incorrect call; expected %s, got %s', '[out1, out2] = myFunction(1, 2);', tc.call);
        return;
    elseif ~isempty(tc.initializer)
        passed = false;
        message = 'initializer not empty, when should be empty';
        return;
    elseif ~isequal(tc.points, 3)
        passed = false;
        message = sprintf('Incorrect points; expected %d, got %d', 3, tc.call);
        return;
    elseif ~isempty(tc.supportingFiles)
        passed = false;
        message = 'supportingFiles not empty, when should be empty';
        return;
    elseif sum(endsWith(tc.loadFiles, 'values_rubrica.mat')) ~= 1
        passed = false;
        message = 'loadFiles does not have values_rubrica.mat';
        return;
    elseif ~isempty(tc.banned)
        passed = false;
        message = 'banned not empty, when should be empty';
        return;
    elseif ~strcmp(tc.path, path)
        passed = false;
        message = sprintf('Incorrect path; expected %s, got %s', path, tc.path);
        return;
    elseif isempty(tc.outputs) || ~isstruct(tc.outputs)
        passed = false;
        message = sprintf('outputs not a structure, but should be');
        return;
    elseif ~isfield(tc.outputs, 'out1') || ~isequal(tc.outputs.out1, 'hello')
        passed = false;
        message = sprintf('outputs.out1 incorrect; expected %d, got %d', 1, tc.outputs.out1);
        return;
    elseif ~isfield(tc.outputs, 'out2') || ~isequal(tc.outputs.out2, 'world')
        passed = false;
        message = sprintf('outputs.out2 incorrect; expected %d, got %d', 2, tc.outputs.out2);
        return;
    end
    message = 'TestCase correctly constructed';
    passed = true;
end

