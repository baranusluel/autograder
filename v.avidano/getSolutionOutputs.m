function sa = getSolutionOutputs(sa,solutionPath)
for i = 1:length(sa)

    %Initialize variables
    testCount = length(sa(i).tests);
    outValues = cell(1,testCount);
    outType = cell(1,testCount);
    outFiles = cell(1,testCount);
    old_files = dir;
    old_files = {old_files.name};

    for j = 1:testCount
        %Function call
        
        
        %check if any output values returned
        if sa(i).outCount(j) > 0
            c = cell(1,sa(i).outCount(j));
            [c{:}] = feval(sa(i).funcHandle,sa(i).inputs{j}{:});
            outValues{j} = c;
            outType{j} = [outType{j}, {'value'}];
        else
            feval(sa(i).funcHandle,sa(i).inputs{j}{:});
        end
        
        %check if new files created
        new_files = dir;
        new_files = {new_files.name};
        if length(old_files) < length(new_files)
            tmp = findChanges(old_files,new_files);
            outFiles{j} = cellfun(@(x,y)[x y],solutionPath,tmp,'UniformOutput',false);
            old_files = new_files;
            outType{j} = [outType{j}, {'file'}];
        end 
        
        %check if new figures created
        new_figHandles = get(0,'Children');
        if ~isempty(new_figHandles)
            %TODO consider saving all plots for increased efficiency
            close(new_figHandles); %close all figures
            outType{j} = [outType{j}, {'figure'}];
        end
    end
    sa(i).outValues = outValues;
    sa(i).outType = outType;
    sa(i).outFiles = outFiles;
end
end