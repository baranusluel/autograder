%% Alien Object: Plot an image (imshow)
%
function [passed, msg] = test()
    ax = axes;
    img = randi([0 255], 100, 100, 3, 'uint8');
    imshow(img);
    try
        [~] = Plot(ax);
    catch e
        passed = false;
        msg = sprintf('Expected Success; got "%s"', e.identifier);
        return;
    end
    
    passed = true;
    msg = '';
end