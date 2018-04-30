%% Multiple Plots
%
% Test Case which produces multiple plots
% Actual Plot checking is done via Plot Unit Tests
function [passed, msg] = test()
    info.supportingFiles = {};
    info.banned = {};
    info.call = '[] = helloWorld';
    info.initializer = '';
    info.points = 10;
    T = TestCase(info, [pwd filesep 'soln']);
    try
        T = engine(T);
    catch e
        passed = false;
        msg = sprintf('Expected success; got "%s: %s" instead', ...
            e.identifier, e.message);
        return;
    end
    % should have two plots
    if numel(T.plots) ~= 2
        passed = false;
        msg = sprintf('Expected 2 plots; got %d', numel(T.plots));
        return;
    else
        passed = true;
        msg = 'Two plots successfully recorded';
    end
end