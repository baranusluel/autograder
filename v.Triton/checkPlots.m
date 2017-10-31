function log = checkPlots(funcName, varargin)
    adata = getPlot(funcName,varargin{:});
    bdata = getPlot([funcName '_soln'],varargin{:});
    difference = sum(sum(sum(adata-bdata)))/numel(bdata);
    log = difference < .001;%threshold percentage (maybe start with .001?)
    if ~log
        figure('Visible','off')
        imshow(~any(adata-bdata ~= 0,3))
        title Differences
        figure('Visible','on')
    end
end

function data = getPlot(funcName,varargin)
    handle = str2func(funcName);
    figure('Visible','off')
    handle(varargin{:});
    plot = gcf;
    frame = getframe(plot);
    close all
    data = frame.cdata;
end
