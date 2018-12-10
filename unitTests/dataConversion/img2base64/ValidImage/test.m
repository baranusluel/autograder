%% Default Format
%
% I = imread(...); % valid image
% B = img2base64(I);
%
% B -> 'data:image/png;base64,STRING...';
%
function [passed, msg] = test()
    img = imread('testImg.png');
    % Hardcoded base64 string
    try
        testStr = img2base64(img);
    catch reason
        msg = sprintf('Case errored: Expected string, got error %s: %s', ...
            reason.identifier, reason.message);
        passed = false;
        return;
    end
    compStr = 'data:image/bmp;base64,';
    if ~strncmp(compStr, testStr, length(compStr))
        passed = false;
        if length(testStr) >= length(compStr)
            msg = sprintf('Input string not a valid Data URI; Expected header %s, got %s', ...
                'data:image/png;base64,', testStr(1:length(compStr)));
        else
            msg = sprintf('Input string %s is not a valid data URI', testStr);
        end
        return;
    else
        passed = true;
        msg = '';
    end
end
