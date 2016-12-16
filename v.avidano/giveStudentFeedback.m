function giveStudentFeedback(student,sa,studentName,overallGrade,homeworkName)
%% Move to feedback directory, open file
fid = fopen('feedback.html','w');


%% Header
fprintf(fid,'<div style="font-family: Tahoma, Verdana, Segoe, sans-serif;"><style>p {font-size:12px}</style>');
fprintf(fid,'<h1>%s</h1>',homeworkName);
fprintf(fid,'<p>%s</p>',studentName);


%% Table
fprintf(fid,'<table border="1" style="border-collapse:collapse">');


%PRINT FIRST ROW
firstRow = {'<strong>Problem</strong>',...
            '<strong>Points Received</strong>',...
            '<strong>Out Of</strong>'};
htmlRowEntry(fid,firstRow);


%For each row
for i = 1:length(sa)
    ca{1} = sa(i).funcName;
    ca{2} = sprintf('%.2f',student(i).problemScore);
    ca{3} = sprintf('%.2f',sum(sa(i).points));
    htmlRowEntry(fid,ca);
end


%PRINT LAST ROW
overallGrade = sprintf('%.2f',overallGrade);
lastRow = {'<strong>Total Grade</strong>',...
            overallGrade,...
            '100.00'};
htmlRowEntry(fid,lastRow);


fprintf(fid,'</table>\n');

%% Problems

%Get check and cross HTML
check = getFile('check.html');
cross = getFile('cross.html');

for i = 1:length(sa)
    fprintf(fid,'<hr/>');
    fprintf(fid,'<h2>%s.m</h2>',sa(i).funcName);
    fprintf(fid,'<p><strong>Problem Score:</strong> %.2f/%.2f</p>',...
                student(i).problemScore,sum(sa(i).points));
    for j = 1:length(sa(i).tests)
        fprintf(fid,'<h3>Test Case %d</h3>',j);
        %Print code that is run to obtain solution
        fprintf(fid,'<pre>');
        if ~isempty(sa(i).matFiles)
            fprintf(fid,'load(''%s'');<br/>',sa(i).matFiles);
        end
        fprintf(fid,'%s<br/>',sa(i).tests{j});
        fprintf(fid,'</pre>');
        
        %% Return Results
        if student(i).success{j} %No errors occurred during runtime
            
            %Return Results for values
            if any(strcmp(student(i).outType{j},'value'))
                for k = 1:length(sa(i).outNames{j})
                    outName = sa(i).outNames{j}{k};
                    points = student(i).points{j}(k);
                    outputValue  = sa(i).outValues{j}{k};
                    fprintf(fid,'<pre style="display:inline">%s</pre>',outName);
                    
                    %If output correct
                    if points > 0
                        fprintf(fid,'<p style="display:inline">: PASS (%.2f points)</p> %s',...
                            points, check);
                    
                    %if output incorrect
                    else
                        fprintf(fid,'<p style="display:inline">: FAIL - VALUE INCORRECT %s</p>', cross);
                        studentValue = student(i).outValues{j}{k};
                        outputValue  = sa(i).outValues{j}{k};
                        makeFailureTable(fid,studentValue,outputValue);
                    end
                    fprintf(fid,'<br/>');
                end
            end
            
            % TODO Make work for figures, files
            
            
            
            
            
            
            
        else %Error occurred during runtime
            %return errors
            fprintf(fid,'<p style="display:inline">ERROR: %s %s</p>',...
                student(i).errorMessage{j}, cross);
        end
        
        % Return Test Case Score
        studentScore = sum(student(i).points{j});
        solutionScore = sa(i).points(j);
        fprintf(fid,'<p><em>Test Case Score:</em> %.2f/%.2f</p>',studentScore,solutionScore);
        
    end
end




%% Close file, move to original directory
fclose(fid);
end


function htmlRowEntry(fid,ca)
% Given a 1xN cell array describing the contents of a html row, print the
% html row to a text document
fprintf(fid,'<tr>');
fprintf(fid,'<td style="padding:5px"><p>%s</p></td>',ca{1});
for i = 2:length(ca)
    fprintf(fid,'<td style="text-align:right;padding:5px"><p>%s</p></td>',ca{i});
end
fprintf(fid,'</tr>');
end

function makeFailureTable(fid,studentValue,outputValue)

fprintf(fid,'<table>');
title = {'Function Value','Solution Value'};
value = {studentValue,outputValue};
for i = 1:2
    fprintf(fid,'<tr>');
    fprintf(fid,'<td style="vertical-align:top;width:50px"><p>%s</p></td>',...
            title{i});
    switch class(value{i})
        case 'char'
            [r,c] = size(value{i});
            if r == 1
                value_converted = ['''' value{i} ''''];
            else
                value_converted = sprintf('%dx%d char array',r,c);
            end
        case 'double'
            value_converted = num2str(value{i});
        case 'logical'
            %TODO extend to logical values
            value_converted = '';
        otherwise
            %TODO extend to any size cell array
            [r,c] = size(value{i});
            value_converted = sprintf('%dx%d %s',r,c,class(value{i}));
    end
    
    fprintf(fid,'<td style="padding-left:10px;word-wrap:break-word">%s</td>',...
            value_converted);
    fprintf(fid,'</tr>');
end
fprintf(fid,'</table>');

end

function s = getFile(name)
    p = which('autograder.m');
    [~,p] = strtok(p(end:-1:1),'/');
    p = [p(end:-1:1) name];
    fid = fopen(p);
    s = fgetl(fid);
end
