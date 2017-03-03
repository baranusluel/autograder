function detectInfinteLoop

t = timer('TimerFcn',@watch,'StartDelay',1);
try
    start(t);
    notInfinteLoop();
    stop(t);
catch e
    fprintf(1,'There was a timeout');
end

try
    start(t);
    infinteLoop();
    stop(t);
catch e
    fprintf(1,'There was a timeout');
end

delete(t);
end

function watch(handle, data)
% c = onCleanup(@() error('timeout!'));
error('timeout!');
end