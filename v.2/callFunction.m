function [varargout] = callFunction(functionHandle, numberOfOutputs, varargin)
    fclose('all');
    close all;
    figure('Visible', 'Off');
    outputs = [];
    [outputs{1:numberOfOutputs}] = feval(functionHandle, varargin{:});
    outputs{end+1} = gcf;
    varargout = outputs;
    %fclose('all');
end