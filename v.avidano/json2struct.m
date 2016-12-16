function sa = json2struct(rubric)

fh = fopen(rubric);
lin = fgetl(fh);

%Parse json file
i = 1;
while ~all(lin == ']') && ischar(lin)
    if lin(end) == '{'
        lin = fgetl(fh);
        while ~any(lin(end-1:end) == '}')
            if lin(end) == '['
                ca = {};
                c = textscan(strtrim(lin),'%q','Delimiter',':');
                field = c{1}{1};
                lin = fgetl(fh);
                while lin(end-1)~= ']'
                    lin = strtrim(lin);
                    if lin(end) == ','
                        lin = lin(1:end-1);
                    end
                    ca = [ca {lin(2:end-1)}];
                    lin = fgetl(fh);
                end
                sa(i).(field) = ca;
            else
                if lin(end) == ','
                    lin = lin(1:end-1);
                end
                c = textscan(strtrim(lin),'%q %q','Delimiter',': ');
                val = c{1}{2};
                sa(i).(c{1}{1}) = val;
            end
            lin = fgetl(fh);
        end
        i = i + 1;
    end
    lin = fgetl(fh);
end

%convert strings of numbers to vectors
for i = 1:length(sa)
    sa(i).points = str2num(sa(i).points);
    %get input and output names for each eval call
    tests = sa(i).tests;
    if ~iscell(tests)
        sa(i).tests = {tests};
        tests = {tests};
    end
    if ~iscell(sa(i).banned) && ~isempty(sa(i).banned)
        sa(i).banned = {sa(i).banned};
    end
    outNames = cell(1,length(tests));
    for j = 1:length(tests)
        test = tests{j};
        
        %Special case: no outputs
        %   eval errors if empty brackets used when no outputs
        %   remove brackets
        if any([false test == '['] & [test == ']' false]);
            loc = find(test == '=');
            test = test(loc(1)+1:end);
        end
        
        %add brackets to single outputs in case someone forgot to
        [potentialFirstWord,rest] = strtok(test,'=');
        if ~isempty(rest) && ~any(potentialFirstWord == '[')
            [firstWord,other] = strtok(potentialFirstWord,' ');
            test = ['[' firstWord ']' other rest];
        end
        
        %get output names
        temp = {};
        if any(test == '=')
            [outputs,rest] = strtok(test,'[]');
            if ~isempty(rest)
                while ~isempty(outputs)
                    [word,outputs] = strtok(outputs,', ');
                    temp = [temp,{word}];
                end
            end
        end
        outNames{j} = temp;
        
        %supress any unsupressed function calls
        if test(end) ~= ';'
            test(end+1) = ';';
        end
        sa(i).tests{j} = test;
    end
    sa(i).outNames = outNames;
    sa(i).outCount = cellfun(@length,outNames);
end




fclose(fh);
end
