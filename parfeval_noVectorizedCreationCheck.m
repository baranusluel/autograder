function f = parfeval_noVectorizedCreationCheck(aPool, varargin)
% WORK IN PROGRESS

try
    f = parfeval_FevalQueue(aPool.FevalQueue, varargin{:});
catch E
    throw(E);
end
end


%% FevalQueue Functions
%open('C:\Program Files\MATLAB\R2015a\toolbox\distcomp\cluster\+parallel\@FevalQueue\FevalQueue.m')

function t = parfeval_FevalQueue(Q, varargin)

%FEVAL create and submit a Future to this FevalQueue
    narginchk(3, Inf);
    nargoutchk(1, 1);
    fcn        = varargin{1};
    numArgsOut = varargin{2};
%     if isVectorizedCreation_FutureCreation(varargin(3:end))
%         error(message('parallel:fevalqueue:InvalidSubmitVectorizedCreation'));
%     end
%     errorIfQueueNotValid_FevalQueue(Q);
    try
        t = parallel.FevalFuture(fcn, numArgsOut, varargin(3:end));
        submitImpl_FutureCreation(t, Q, Q.JavaQueueObj);
    catch E
        throw(E);
    end
end

function errorIfQueueNotValid_FevalQueue(Q)
    if ~hIsValid_FevalQueue(Q)
        err = MException(message('parallel:fevalqueue:InvalidQueue'));
        throwAsCaller(err);
    end
end

function tf = hIsValid_FevalQueue(Q)
    tf = ~isempty(Q.JavaQueueObj) && Q.JavaQueueObj.isValid();
end


%% Future Creation
%open('C:\Program Files\MATLAB\R2015a\toolbox\distcomp\cluster\+parallel\+internal\+queue\FutureCreation.m')

function tf = isVectorizedCreation_FutureCreation(argsIn)
%CLONE: parallel.internal.queue.FutureCreation.isVectorizedCreation
    tf = ~isempty(argsIn) && all(cellfun(@iscell, argsIn(:)));
end

function submitImpl_FutureCreation(objOrObjs, queue, javaQueue)
%GOTO: 
%SUBMIT submit futures to queue for execution
    for idx = 1:numel(objOrObjs)
        submitScalar(objOrObjs(idx), javaQueue);
        objOrObjs(idx).Parent = queue;
    end
end