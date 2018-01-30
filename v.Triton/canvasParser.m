function parsedCanvasPath = canvasParser(canvasZipPath, canvasGradebookPath, hwName, resub)
    
    % Get the fileparts of the zip path
    [parentPath, name, ext] = fileparts(canvasZipPath);
    
    % Create a temp dir and populate with submissions
    mkdir([parentPath 'canvasParserTemp']);
    unzip(canvasZipPath, 'canvasParserTemp\submissions');
    
    students = containers.Map('KeyType','double','ValueType','any');
    
    % Read the gradebook into students
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
        studentPath = sprintf('canvasParserTemp\%s\%s, %s,(%d)', hwName, lastname, firstname, id);
        if ~exist(studentPath,'dir')
            mkdir([studentPath '\Submission attachment(s)\'])
            mkdir([studentPath '\Feedback attachment(s)\'])
        end
    end
    
end