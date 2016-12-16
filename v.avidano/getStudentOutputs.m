function [student] = getStudentOutputs(student,sa,functionNames)
%TODO
%emptyStudent has the following fields:
%   success: logical
%   errorMessage: char
%   outValue: cell w/ values (varying types)
%   outType: cell w/ string of 'value','file', and/or 'figure'
%   outFiles: string of filenames


%% Initialization: Initialize variables
old_files = dir;
old_files = {old_files.name};
old_figHandles = get(0,'Children');

functionsToRun = []; %tracks all functions the student actually wrote
for i = 1:length(sa)
    %% Initialization: check if student submitted problem
    if isempty(functionNames) || ~any(strcmp(sa(i).funcName,strtok(functionNames,'.')))
        for j = 1:length(student(i).success)
            student(i).success{j} = false;
            %TODO better error message
            student(i).errorMessage{j} = 'File does not exist';
        end
        continue;
    else
        functionsToRun = [functionsToRun i];
    end


    %% Initialization: block any banned files
    for banned = sa(i).banned
        makeBannedFunctionFile(banned{1});
    end
end


%% Parallel: Add all feval calls to parallel pool
p = gcp('nocreate');
p.FevalQueue.QueuedFutures.cancel;
fevalCalls = [];
indexList = {};
for i = functionsToRun
    
    %parfeval Parsing Issue Handling: only cell array inputs
    cloned = false;
    
    for j = 1:length(sa(i).tests)
        student(i).success{j} = false;
        try
            fun = str2func(sa(i).funcName);
            inputs = sa(i).inputs{j};
            
            
            %parfeval Parsing Issue Handling: only cell array inputs
            if all(cellfun(@iscell, inputs(:)))
                %add extra input to chosen input
                inputs = [inputs, 1];
                if ~cloned
                    cloneWithNewInput(sa(i).funcName);
                end
            end
            
            
            fevalCall = parfeval(p,fun,nargout(fun),inputs{:});
            fevalCalls = [fevalCalls, fevalCall];
            indexList = [indexList, {{i,j}}];
        catch ME1
            % Catch any errors that occur
            errorMessage = processMException(ME1);
            student(i).errorMessage{j} = errorMessage;
        end
    end
end



%% Get result from parallel pool
% the function completes within TIMEOUT seconds. TIMEOUT can be
% tweaked if most functions take less time to complete.
TIMEOUT = 20;
timeoutVec = ones(1,p.NumWorkers)*TIMEOUT;
for null = 1:length(indexList)
    try
        %Get next available function
        startTime = toc;
        [index,~] = fetchNext(fevalCalls,timeoutVec(1));%Throws errors
        endTime = toc;
        timeElapsed = endTime - startTime;
        timeoutVec = [timeoutVec(2:end) - timeElapsed, TIMEOUT];


        if isempty(index)
            %if no feval command completes before timeout:
                %get first feval command on queue
                %cancel first running file on queue
            fevalCall = p.FevalQueue.RunningFutures(1);
            fevalCall.cancel;
            mask = arrayfun(@isequal,fevalCalls,repmat(fevalCall,1,length(fevalCalls))); %find location of fevalCall in queue
            [i,j] = indexList{mask}{:};
            fevalCalls(mask) = [];
            indexList(mask) = [];
            
            msgID = 'MATLAB:timeout';
            msg = sprintf('Evaluation timed out after %.0f seconds.',TIMEOUT);
            throwAsCaller(MException(msgID,msg));
        else
            %Get function to evaluate
            fevalCall = fevalCalls(index);
            [i,j] = indexList{index}{:};
            fevalCalls(index) = [];
            indexList(index) = [];
        end

        %Since figures don't show in parallel workers, rerun function using
        %feval to get any figures
        if any(strcmp(sa(i).outType{j},'figure'))
            figure;
            feval(fun,inputs{:});
        end


        %TODO only get outputs that should be created based on solution
        %function knowledge.
        %% check if any output values returned
        if sa(i).outCount(j) > 0
            c = cell(1,sa(i).outCount(j));
            [c{:}] = fetchOutputs(fevalCall);
            student(i).outValues{j} = c;
            student(i).outType{j} = [student(i).outType{j}, {'value'}];
        end

        %% check if new files created
        new_files = dir;
        new_files = {new_files.name};
        if length(old_files) < length(new_files)
            student(i).outFiles{j} = findChanges(old_files,new_files);
            old_files = new_files;
            student(i).outType{j} = [student(i).outType{j}, {'file'}];
        end

        %% check if new figures created
        new_figHandles = get(0,'Children');
        if length(old_figHandles) < length(new_figHandles)
            student(i).outFigure{j} = findChanges(old_figHandles,new_figHandles);
            old_figHandles = new_figHandles;
            student(i).outType{j} = [student(i).outType{j}, {'figure'}];
        end

        student(i).success{j} = true;
    catch ME1
        %check if an error occurred at runtime
        %Get index for first error if found
        potentialFevalCallErrors = ~cellfun(@isempty,{fevalCalls(:).Error});
        if any(potentialFevalCallErrors)
            index = find(potentialFevalCallErrors);
            index = index(1);
            [i,j] = indexList{index}{:};
            fevalCalls(index) = [];
            indexList(index) = [];
        end
        %% Catch any errors that occur
        errorMessage = processMException(ME1);
        student(i).errorMessage{j} = errorMessage;
    end
end

p.FevalQueue.QueuedFutures.cancel;

end


function makeBannedFunctionFile(banned)
% Get path to actual banned function
filePath = which(banned);
if strcmp(strtok(filePath,' ('),'built-in')
    filePath = filePath(find(filePath=='(')+1:find(filePath==')')-1);
end
filePath = fileparts(filePath);%remove function name
curPath = pwd;


%Print file
fid = fopen([banned '.m'],'w');
fprintf(fid,'function varargout=%s(varargin)',banned);
fprintf(fid,'\ns=dbstack;');
fprintf(fid,'\nif ~strcmp(strtok(s(1).file,''.''),''%s'')',banned);
fprintf(fid,'\ncurPath = pwd;');
fprintf(fid,'\ncd(''%s'');',filePath);
fprintf(fid,'\nfh=str2func(''%s'');',banned);
fprintf(fid,'\ncd(curPath);');
fprintf(fid,'\nvarargout=fh(varargin);');
fprintf(fid,'\nelse');
fprintf(fid,'\nthrowAsCaller(MException(''%s:bannedFunction'',''Banned function %s used.''));',...
    banned,banned);
fprintf(fid,'\nend');


fclose(fid);

end


function errorMessage = processMException(ME1)
if strcmp(ME1.identifier,'parallel:fevalqueue:FetchNextFutureErrored')
    ME1 = ME1.cause{1};
end


if isempty(ME1.stack)
    %Assignment / Timeout errors
    errorMessage = ME1.message;

    
elseif strcmp('MATLAB:m_unexpected_sep',ME1.identifier)
    %Critical code failure

    %Remove hyperlink, get info out
    [~,rest] =strtok(ME1.message,'>');
    [fileInfo,rest] = strtok(rest,'<>');
    %fileInfo Format:
    %File: FUNCNAME.m Line: LINENUM Column: COLNUM
    spaces = find(fileInfo == ' ');
    funcName = strtok(fileInfo(spaces(1)+1:spaces(2)-1),'.');
    funcLine = fileInfo(spaces(3)+1:spaces(4)-1);
    [~,message] = strtok(rest,'<>');
    message = message(2:end);
    errorMessage = sprintf('"%s" in %s at line %s',...
    message,funcName,funcLine);


else
    %Runtime Error during parfeval
    funcName = ME1.stack.name;
    funcLine = ME1.stack.line;
    message = ME1.message ;
    errorMessage = sprintf('"%s" in %s at line %d',...
    message,funcName,funcLine);

end
end

