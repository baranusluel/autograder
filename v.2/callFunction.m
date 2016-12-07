function [varargout] = callFunction(functionHandle, numberOfOutputs, varargin)

    close all;
    figure('Visible', 'Off');
    outputs = [];
    [outputs{1:numberOfOutputs}] = feval(functionHandle, varargin{:});
    outputs{end+1} = gcf;
    varargout = outputs;

end