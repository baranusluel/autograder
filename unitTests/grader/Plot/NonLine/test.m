%% Non Line
%
% Plot something that isn't a line
%

function [passed, msg] = test
    f = figure;
    ax = axes(f);
    area(ax, 1:100, 1:100);
    try
        P = Plot(ax);
    catch e
        passed = false;
        msg = sprintf('Expected success; got %s - "%s"', ...
            e.identifier, e.message);
        return;
    end
    if numel(P.XData) ~= 0
        passed = false;
        msg = sprintf('Expected no XData; got %d instead', numel(P.XData));
        return;
    else
        warning('off');
        P = struct(P);
        if ~P.isAlien
            passed = false;
            msg = 'Expected Alien, but wasn''t';
            warning('on');
            return;
        end
        warning('on');
        passed = true;
        msg = 'Successfully constructed alien plot';
    end
end