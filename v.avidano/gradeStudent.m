function student = gradeStudent(student,sa)

% for each problem
for i = 1:length(sa)
    % for each test case
    for j = 1:length(sa(i).tests)
        grade = struct('matchValues',[],'matchFiles',[],'matchFigures',[]);
        success = student(i).success{j};
        %% check student submission
        % Todo track any errorMessages
        if success && any(strcmp('value',sa(i).outType{j}))
            solutionOut = sa(i).outValues{j};
            studentOut  = student(i).outValues{j};
            grade.matchValues = checkValues(solutionOut,studentOut);
        end
        if success && any(strcmp('file',sa(i).outType{j}))
            solutionOut = sa(i).outFiles{j};
            studentOut  = student(i).outFiles{j};
            grade.matchFiles = checkFiles(solutionOut,studentOut,solutionPath);
        end
        if success && any(strcmp('figure',sa(i).outType{j}))
            old_functionHandles = get(0,'Children');
            feval(sa(i).funcHandle,sa(i).inputs{j}{:});
            new_functionHandles = get(0,'Children');
            solutionOut = findChanges(old_functionHandles,new_functionHandles);
            studentOut = studentSolution(i).outFigure{j};
            grade.matchFigures = checkFigures(solutionOut,studentOut);
        end
        
        %% assign student grade
        gradeCheck = [grade.matchValues grade.matchFiles grade.matchFigures];
        if ~isempty(gradeCheck)
            %TODO 
            points = sa(i).points(j);
            entries = [grade.matchValues grade.matchFiles grade.matchFigures];
            pointPerQuestion = points / length(entries);
            student(i).points{j} = pointPerQuestion .* entries;
        else
            student(i).points{j} = 0;
        end
    end
    student(i).problemScore = sum([student(i).points{:}]);
end
end




%% Check functions

function match = checkValues(solution,student)
match = false(1,length(solution));
for k = 1:length(solution)
    if ~isempty(student)
        solutionOut = solution{k};
        studentOut  = student{k};
        match(k) = (isequal(solutionOut,studentOut) && isa(studentOut,class(solutionOut))) | (isequaln(studentOut,solutionOut)) ;
    end
end
end




function [match,failureMessage] = checkFiles(solution,student)
% TODO
failureMessage = {};
match = false(1,length(solution));
for k = 1:length(solution)
    if isempty(student)
    else
        %Check if correct filename created
        solutionName = fullfile(solutionPath,solution{k});
        studentName  = solution{k};
        [name,extension] = strtok(studentName,'.');
        match(k) = strcmp(strtok(solutionName,'_'),name) && strcmp(extension,'.m');
        fid = fopen(studentName);
        fsoln = fopen(solutionName);
        studLine = fgets(fid);
        solnLine = fgets(fsoln);
        while match(k) && ischar(solnLine) && ischar(studLine)
            match(k) =  match(k) && strcmp(solnLine,studLine);
            studLine = fgets(fid);
            solnLine = fgets(fsoln);
        end
        fclose(fid);
        fclose(fsoln);
        
        %TODO copy failure line if needed
        if ~match(k)
            failureMessage{k} = 'TODO';
        end
    end
end
end




function [match,failureMessage] = checkFigures(solution,student)
% TODO
%What properties matter?
match = false(1,length(solution));
for k = 1:length(solution)
    if ~isempty(student)
        
    end
end
end