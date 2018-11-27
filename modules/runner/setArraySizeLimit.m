%% setArraySizeLimit: Set array size limits
%
% Sets the user preference for array size limits
%
% setArraySizeLimit(P, E) will use integer percent P and enable logical E
% to set the array size limit.
%
% setArraySizeLimit(P) will use percent P to enable the array size limit,
% and set it to P.
%
% setArraySizeLimit() will do the same as above, with P=10 and E=true.
%
%%% Remarks
%
% This uses the settings function.
function setArraySizeLimit(percent, enable)
    if nargin == 0
        percent = 10;
        enable = true;
    elseif nargin == 1
        enable = true;
    end
    percent = uint8(percent);
    s = settings;
    s.matlab.desktop.workspace.ArraySizeLimitEnabled.PersonalValue = enable;
    s.matlab.desktop.workspace.ArraySizeLimit.PersonalValue = percent;
end