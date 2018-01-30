function parsedCanvasPath = canvasParser(canvasZipPath, canvasGradebookPath, hwName)
    
    % Get the fileparts of the zip path
    [parentPath, ~, ~] = fileparts(canvasZipPath);
    
    % Create a temp dir and populate with submissions
    mkdir([parentPath 'canvasParserTemp']);
    unzip(canvasZipPath, [parentPath 'canvasParserTemp\submissions']);
    
    students = containers.Map('KeyType','double','ValueType','any');
    
    % Read the gradebook into students and create individual student
    % directories
    [~,~,gradebookRaw] = xlsread(canvasGradebookPath);
    dimvec = size(gradeboodRaw);
    for i = 3:dimvec(1)
        [lastname, firstname] = strtok(gradebookRaw{r,1},',');
        lastname(lastname == '?') = [];
        firstname(firstname == '?') = [];
        firstname = firstname(3:end);
        id = gradebookRaw{r,2};
        gtid = gradebookRaw{r,4};
        students(id).firstName = firstName;
        students(id).lastName = lastName;
        students(id).gatechID = gtid;
        students(id).submissions = [];
        students(id).path = sprintf([parentPath 'canvasParserTemp\%s\%s, %s,(%d)'], hwName, lastname, firstname, id);
        if ~exist(studentPath,'dir')
            mkdir([students(id).path '\Submission attachment(s)\'])
            mkdir([student(id).path '\Feedback attachment(s)\'])
        end
    end
    
    % parse the student submissions to respective directories.
    allFiles = dir([parentPath 'canvasParserTemp\submissions\*.m']);
    for file = allFiles'
        tokens = strsplit(file.name, '_');
        if length(tokens) ~= 4
            if isnan(str2double(tokens{2}))
                tokens{1} = [tokens{1} '_' tokens{2}];
                tokens(2) = [];
            end
            if length(tokens) == 5
                tokens{4} = [tokens{4} '_' tokens{5}];
                tokens(5) = [];
            end
        end
        id = str2double(tokens{2});
        funcName = tokens{end};
        if contains(funcName,'-')
            nameTokens = strsplit(funcName, {'-', '.'});
            if length(nameTokens) == 3
                funcName = [nameTokens{1} nameTokens{3}];
                funcVersion = str2double(nameTokens{2});
            else
                funcVersion = 0;
            end
        end
        if ~isfield(students(id).submissions,nameTokens{1})
            students(id).submissions.(nameTokens{1}) = funcVersion;
            copyfile(fullfile(file.path, file.name), fullfile(students(id).path, funcName))
        else
            if student(id).submissions.(nameTokens{1}) < funcVersion
                delete(fullfile(students(id).path, funcName));
                students(id).submissions.(nameTokens{1}) = funcVersion;
                copyfile(fullfile(file.path, file.name), fullfile(students(id).path, funcName))
            end
        end
    end
    parsedCanvasPath = fullfile(parentPath, hwName);
    zip(parsedCanvasPath, hwName, fullfile(parentPath, 'canvasParserTemp'));
end