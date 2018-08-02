%% Blank Axes: A blank axes handle

function [passed, msg] = test()
    ax = axes;
    try
        P = Plot(ax);
    catch e
        passed = false;
        msg = sprintf('Expected Success; got "%s" instead', e.identifier);
        return;
    end
    passed = true;
    msg = 'Null Plot created successfully';
end