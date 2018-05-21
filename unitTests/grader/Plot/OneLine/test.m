%% One Line
%
% Plot five lines; there should be 5 XData and YData
function [passed, msg] = test()
    f = figure;
    ax = axes(f);
    plot(ax, 1:100, 1:100, 'b--');
    try
        P = Plot(ax);
    catch e
        passed = false;
        msg = sprintf('Expected success; got %s - "%s"', e.identifier, ...
            e.message);
        return;
    end
    if numel(P.XData) ~= 1
        passed = false;
        msg = sprintf('Expected 1 data; got %d', numel(P.XData));
        return;
    else
        passed = true;
        msg = 'Successfully created plot';
        return;
    end