function detectInfinteLoop

t = timer('TimerFcn',@watchDog,'StartDelay',3);
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

function watchDog(handle,data)
error('timeout!');
end