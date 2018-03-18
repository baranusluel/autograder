%% Timeout: A simple class to keep track of timeouts
%
% The Timeout class has one property: isTimeout. If this 
% property is false, then the code finished; otherwise, 
% the code was killed prematurely. This class is used 
% exclusively by the engine method.
%
%%% Fields
%
% * isTimeout: Whether or not the code timed out.
%
%%% Remarks
%
% Again, this class should only be used by the engine method.
%
classdef Timeout < handle
    properties (Access=public)
        isTimeout = true;
    end
end