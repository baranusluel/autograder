function sa = eval2feval(sa,solutionPath,supportPath)
addpath(solutionPath);
for i = 1:length(sa)
    %Convert all input arrays to input cells for use with feval
%     matFile = sa(i).matFiles;
    if ~isempty(sa(i).matFiles)
        load(fullfile(supportPath,sa(i).matFiles));
    end
    for j = 1:length(sa(i).tests)
        t = sa(i).tests{j};
        [~,t] = strtok(t,'(');
        while ~isempty(t) && t(end)~= ')'
            t(end) = [];
        end
        t([1,end]) = [];
        sa(i).inputs{j} = eval(['{' t '}']);
    end
    
    %get function handle for use with feval
    sa(i).funcHandle = str2func(sa(i).funcName);
end
rmpath(solutionPath);
end