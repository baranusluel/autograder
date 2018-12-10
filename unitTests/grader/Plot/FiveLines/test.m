%% Five Lines: Plot five lines (different order)

function [passed, msg] = test()
    xx1 = 1:100;
    yy1 = 1:100;
    xx2 = 1:10;
    yy2 = (1:10).^2;
    xx3 = xx1 ./ 5;
    yy3 = yy1 .* 4;
    xx4 = rand(1, 100);
    yy4 = xx4(end:-1:1);
    xx5 = 1;
    yy5 = 2;
    
    % Plot 1
    ax = axes;
    plot(xx1, yy1, 'r-*', ...
        xx2, yy2, 'b*', ...
        xx3, yy3, 'gp--', ...
        xx4, yy4, '--k*', ...
        xx5, yy5, 'c*');
    
    try
        P1 = Plot(ax);
    catch e
        passed = false;
        msg = sprintf('Expected Success; got "%s"', e.identifier);
        return;
    end
    
    % Plot 2
    
    ax = axes;
    hold on;
    plot(xx1(end:-1:1), yy1(end:-1:1), 'r-*');
    plot(xx2, yy2, 'b*');
    plot(xx3, yy3, 'gp--');
    plot(xx4, yy4, '--k*');
    plot(xx5, yy5, 'c*');
    
    try
        P2 = Plot(ax);
    catch e
        passed = false;
        msg = sprintf('Expected Success; got "%s"', e.identifier);
        return;
    end
    
    if P1.equals(P2)
        passed = true;
        msg = '';
    else
        passed = false;
        msg = 'Five lines differ';
    end
end