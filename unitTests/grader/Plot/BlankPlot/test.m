%% Blank Plot
%
% A blank plot shouldn't error, but there should be no x, y, or z data
function [passed, msg] = test()
    f = figure;
    a = axes(f);
    try
        P = Plot(a);
    catch e
        passed = false;
        msg = sprintf('Expected success; got %s - "%s"', e.identifier, ...
            e.message);
        return;
    end
    if numel(P.XData) ~= 0
        passed = false;
        msg = sprintf('Expected no data; got %d data', numel(P.XData));
        return;
    else
        passed = true;
        msg = 'Successfully created blank plot';
    end
end