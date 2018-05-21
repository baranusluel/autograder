%% Five Lines
%
% Plot five lines; there should be 5 XData and YData
function [passed, msg] = test()
    f = figure;
    ax = axes(f);
    hold(ax, 'on');
    plot(ax, 1:100, 1:100, 'b--');
    plot(ax, [1 0], [1 2], 'k');
    plot(ax, 90, 90, '*');
    plot(ax, 1:88, 1:88, 'p');
    plot(ax, [6 5 6 7], [1 2 2 3], 'o');
    axis(ax, [-10 10 -5 5]);
    xlabel(ax, 'Hello');
    ylabel(ax, 'Wassup');
    title(ax, 'Hi');
    try
        P = Plot(ax);
    catch e
        passed = false;
        msg = sprintf('Expected success; got %s - "%s"', e.identifier, ...
            e.message);
        return;
    end
    if numel(P.XData) ~= 5
        passed = false;
        msg = sprintf('Expected 5 data; got %d', numel(P.XData));
        return;
    elseif ~isequal([-10 10 -5 5], P.Limits(1:4))
        passed = false;
        msg = sprintf('Expected [-10 10 -5 5] for limits; got %s', ...
            num2str(P.Limits(1:4)));
        return;
        % Check title
    elseif ~strcmp(P.Title, 'Hi')
        passed = false;
        msg = sprintf('Expected title "Hi"; got "%s"', P.Title);
        return;
        % check XLabel
    elseif ~strcmp(P.XLabel, 'Hello')
        passed = false;
        msg = sprintf('Expected XLabel "Hello"; got "%s"', P.XLabel);
        return;
    elseif ~strcmp(P.YLabel, 'Wassup')
        passed = false;
        msg = sprintf('Expected YLabel "Wassup"; got "%s"', P.YLabel);
        return;
    else
        passed = true;
        msg = 'Successfully created plot';
        return;
    end