%% Circle: Plot a circle and see what happens
%
function [passed, msg] = test()

    ax = axes;
    % Plot 1: Plot 100 points
    r = 5;
    th = linspace(0, 2 * pi);
    xx = r * cos(th);
    yy = r * sin(th);
    
    % First
    plot(xx, yy, 'b*');
    try
        p1 = Plot(ax);
    catch e
        passed = false;
        msg = sprintf('Expected success; got "%s"', e.identifier);
        return;
    end
    ax = axes;
    hold on;
    for i = 1:numel(xx)
        plot(xx(i), yy(i), 'b*');
    end
    try
        p2 = Plot(ax);
    catch e
        passed = false;
        msg = sprintf('Expected success; got "%s"', e.identifier);
        return;
    end
    
    if ~p1.equals(p2)
        passed = false;
        msg = 'Expected equality; got inequality';
    else
        passed = true;
        msg = 'Different circles compare equal';
    end
end