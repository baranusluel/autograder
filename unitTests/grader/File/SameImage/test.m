%% SameImage: Two functions write the exact same image
function [passed, msg] = test
    img1 = randi([0 255], 100, 100, 3, 'uint8');
    img2 = img1;
    
    % write img1, wait 5 secs
    try
        imwrite(img1, [pwd filesep 'image1.png']);
        F1 = File([pwd filesep 'image1.png']);
        pause(5);
        imwrite(img2, [pwd filesep 'image1.png']);
        F2 = File([pwd filesep 'image1.png']);
        if ~(F1.equals(F2))
            passed = false;
            msg = 'Expected equality; got false';
        else
            passed = true;
            msg = '';
        end
    catch e
        passed = false;
        msg = sprintf('Expected success; got exception %s: %s', e.identifier, e.message);
        return;
    end
end
    