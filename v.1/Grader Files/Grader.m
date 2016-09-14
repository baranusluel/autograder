function [studentIDs final_grades] = Grader(hw_num, file_names, prob_weights, prob_preConds, file_tests, file_vars, file_vars_types, prob_test_weights)

prob_num = length(file_names); % Find number of problems
var_solutions = cell(1, prob_num); % Initialize solutions

cd('Solutions');
% Check to see if solution files in folder
dir_mfiles = dir('*.m');
dir_mfiles = {dir_mfiles.name};
% Run solution files and store solutions for each script at index
fh = fopen('soln_errors.txt', 'w');
errors = false;
for i = 1:prob_num
    if ~any(strcmp(file_names{i}, dir_mfiles))
        error('Solution file %s is missing.', file_names{i});
    else
        test_cases = file_tests{i};
        var_solutions{i} = cell(1, length(test_cases));
        for j = 1:length(test_cases)
            [var_exist var_solutions{i}{j} Merror] = runTestCase(test_cases{j}, file_vars{i}{j});
            fh = fopen('soln_errors.txt', 'a');
            if ~isempty(Merror)
                fprintf(fh, 'Solution File %s produced the following error on Test Case %d:\r\n %s\r\n', file_names{i}, j, Merror.message);
                errors = true;
            elseif ~all(var_exist)
                fprintf(fh, 'Solution File %s did not have the indicated variables on Test Case %d\r\n', file_names{i}, j);
                errors = true;
            end
        end
    end
end
fclose(fh);
if errors
    error('Solution Files contained Errors. Consult soln_errors.txt');
end
cd('..');
students = dir('*(*)'); % Find Student Directories
num_students = length(students);
student_names = {students.name};
% Parse out T-square IDs of students
par_indexes = strfind(student_names, '(');
studentIDs = cell(1, num_students);
studentNames = cell(1, num_students);
for i = 1:num_students
    studentIDs{i} = student_names{i}(par_indexes{i}+1:end-1);
    studentNames{i} = student_names{i}(1:par_indexes{i}-1);
end
[studentNames, i] = sort(studentNames);
students = students(i);
studentIDs = studentIDs(i);
final_grades = zeros(1, num_students);

%Set up the grade report as a cell array.
gradeReport = cell(num_students+2, prob_num+1);  
gradeReport(:) = {0};
gradeReport(2:end-1, 1) = {students.name};
gradeReport(1, 2:end) = file_names;
gradeReport(end,1) = {'Averages'};
gradeReport(1,1) = {[]};
for i = 1:num_students
    cd([students(i).name filesep 'Submission attachment(s)']);
    student_fid = fopen(['..' filesep 'Feedback Attachment(s)' ...
        filesep 'grade.txt'], 'w');
    disp(students(i).name);
    fprintf(student_fid, '%s - Homework %d\r\n', studentNames{i}, hw_num);
    grades = zeros(1, prob_num);
    student_mfiles = dir('*.m');
    student_mfiles = {student_mfiles.name};
    for j = 1:prob_num
        preConds = prob_preConds{j};
        test_cases = file_tests{j};
        variables = file_vars{j};
        variables_types = file_vars_types{j};
        test_case_solns = var_solutions{j};
        test_case_weights = prob_test_weights{j};
        
        prob_score = 0;
        fprintf(student_fid, '\r\n=====================Problem %d======================\r\n', j);
        fprintf(student_fid, 'File Name: %s\r\n', file_names{j});
        
        % Check Problem Preconditions
        fprintf(student_fid, 'Preconditions:\r\n');
        tests = checkPreconditions(preConds, student_mfiles, file_names{j}, test_cases);
        for p = 1:length(tests);
            if tests(p)
                fprintf(student_fid,'- %s: PASS\r\n', preConds{p});
            else
                fprintf(student_fid,'- %s: FAIL\r\n', preConds{p});
            end
        end
        fprintf(student_fid,'\r\n');
        if all(tests)
            for k = 1:length(test_cases)
                fprintf(student_fid, 'Test Case %d:\r\n%s\r\n', k, test_cases{k});
                
                % Update (Nov. 1, 2011) -- Brad Farr
                % Delete existing solution files in student directory.
                for t = test_case_solns{k}
                    item = t{1};
                    if ischar(item)
                        [~, ext] = strtok(item, '.');
                        
                        if any(strcmpi(ext, {'.xls', '.xlsx'}))
                            file_name = item;
                            file_name(file_name == '.') = '_';
                            mat_file = [file_name, '.mat'];
                            
                            if exist(mat_file, 'file')
                                delete(mat_file);
                            end
                        elseif any(strcmpi(ext, {'.csv', '.dlm', '.txt', '.png', '.jpg', '.jpeg', '.bmp', '.wav'}))
                            if exist(item, 'file')
                                delete(item);
                            end
                        end
                    end
                end
                
                [var_exist student_vals Merror] = runTestCase(test_cases{k}, variables{k});
                student_fid = fopen(['..' filesep 'Feedback Attachment(s)' filesep 'grade.txt'], 'a');
                if isempty(Merror)
                    test_soln = test_case_solns{k};
                    test_weight = test_case_weights(k);
                    var_weight = test_weight/length(test_soln);
                    vars = variables{k};
                    var_types = variables_types{k};
                    for x = 1:length(test_soln)
                        if ~var_exist(x)
                            fprintf(student_fid,'- %s: FAIL - Variable did not exist\r\n',vars{x});
                        else
                            [match message] = gradeVar(test_soln{x}, student_vals{x}, var_types{x});
                            switch var_types{x}
                                case 'file'
                                    if match
                                        prob_score = prob_score + var_weight;
                                        fprintf(student_fid, '- Analyzing File %s: PASS (%.2f points)\r\n', vars{x}, var_weight);
                                    else
                                        fprintf(student_fid, '- Analyzing File %s: FAIL - %s\r\n', vars{x}, message);
                                    end
                                case 'plot'
                                    prob_score = prob_score + var_weight.*match(1)./match(2);
                                    fprintf(student_fid, '- Analyzing Plot: %.2f of %.2f PASS:\r\n', match(1), match(2));
                                    if iscell(message)
                                        for l = 1:length(message)
                                            fprintf(student_fid, message{l});
                                        end
                                    end
                                otherwise
                                    if match
                                        prob_score = prob_score + var_weight;
                                        fprintf(student_fid, '- %s: PASS (%.2f points)\r\n', variables{k}{x}, var_weight);
                                    else
                                        fprintf(student_fid, '- %s: FAIL - %s\r\n', variables{k}{x}, message);
                                    end
                            end
                        end
                    end
                    fprintf(student_fid, '\r\n\r\n');
                else
                    fprintf(student_fid,'Error:\r\n%s\r\n\r\n\r\n', Merror.message);
                end
            end
        end
        grades(j) = prob_score;
        fprintf(student_fid, 'Problem Score: %.2f/%.2f\r\n',grades(j),prob_weights(j));
        fprintf(student_fid, '====================================================\r\n');
        gradeReport(i+1, j+1) = {100*prob_score/prob_weights(j)};
    end
    final_grades(i) = sum(grades);
    fprintf(student_fid, '\r\nFinal Grade: %.2f\r\n', final_grades(i));
    fclose(student_fid);
    save('grade.mat', 'grades');
    cd ..;
    cd ..;
end
for i = 1:prob_num
    gradeReport{end, i+1} = mean([gradeReport{2:end-1, i+1}]);
end

if ispc % xlswrite depends on windows-only com server
    xlswrite('Grade Report.xls', gradeReport);
end
save('autograder.mat', 'final_grades', 'studentIDs');
disp('Grade Computation Complete');
end

%% Run Test Case
function [val_exist out_vals ME] = runTestCase(test_case, variables)
% Initialize storage for variable values
val_exist = false(1, length(variables));
out_vals = cell(1, length(variables));
ME = [];

% Error out certain functions
clear = @(vargin) error('Used the clear function');
clc = @(vargin) error('Used the clc function');
input = @(vargin) error('Used the input function');
solve = @(vargin) error('Used the solve function');
% Set state of rand to 0
rand('twister',0);
% Close all images
close('all');

% Run script
try
    set(0, 'RecursionLimit', 250);
    evalc(test_case);
    set(0, 'RecursionLimit', 500);
    % Store variable values in cell array. If variable produces error, state it
    % does not exist
    for i = 1:length(variables);
        try
            out_vals{i} = eval(variables{i});
            val_exist(i) = true;
        catch ME2
        end
    end
catch ME
    set(0, 'RecursionLimit', 500);
end
fclose('all');

end

%% gradeVar
% ret = gradeVariable(student_ans, soln_ans, fh, type)
% Inputs
%   1. soln_ans - value from solution function call
%   2. student_ans - value from student function call
%   3. type - the variable type, aka, integer, floating-point, string, etc.
%   Type can be grown and modified to allow better feedback report. Empty
%   brackets will lead to default comparison
% Outputs
%   1. correct - boolean on whether variable values matched
%   2. message - reason why variable values mismatched
%
% The gradeVar function
function [match message] = gradeVar(soln_ans, student_ans, type)
match = false;
message = 'NONE';

if iscell(soln_ans)
    type = 'cell';
end

switch type
    case 'sound'
        [match message] = grader_CompareSounds(student_ans, soln_ans);
    case 'image'
        [match message] = compareImage(student_ans, soln_ans);
    case 'cell'
        [match message] = compareCell(student_ans, soln_ans);
    case 'file'
        % Send file_name to grade file code
        [match message] = gradeFile(soln_ans);
    case 'empty'
        if isempty(student_ans)
            match = true;
        else
            message = 'Output value was not empty.';
        end
    case 'file handle'
        if isnumeric(student_ans) && student_ans > 0
            match = true;
        else
            message = 'Invalid File Handle';
        end
    case 'plot'
        message = '';
        match = [0 0]; %First is accumulated, second is possible
        
        studentL = length(student_ans);
        solutionL = length(soln_ans);
        
        if (studentL ~= solutionL)
            match(1) = 0;
            match(2) = 9 * solutionL;
            message = sprintf('Incorrect Number of Plots. Expected %d but found %d', solutionL, studentL);
            return;
        end
        
        for i = 1:length(student_ans)
            message{end+1} = sprintf('\r\nPlot %d of %d:\r\n', i, length(student_ans));
            [m mess] = comparePlot(student_ans(i), soln_ans(i));
            match(1) = match(1) + m;
            match(2) = match(2) + 9;
            message = [message mess];
        end
        if match(2) == 0
            match(2) = 1;
        end
    otherwise
        [match message] = compareDefault(student_ans, soln_ans);
end
end

%% Grade Files
function [match message] = gradeFile(file_name)
message = 'File Did Not Match Solution File';
dot_loc = find(file_name == '.');
switch file_name(dot_loc:end)
    case {'.xls', '.xlsx'}
        file_name(file_name == '.') = '_';
        mat_file = [file_name '.mat'];
        if ~exist([cd filesep mat_file], 'file')
            match = false;
            message = 'File Did Not Exist';
            return;
        end
        load(mat_file);
        stud_ans = raw;
        load(['..' filesep '..' filesep 'Solutions' filesep mat_file]);
        soln_ans = raw;
        [match message] = compareCell(stud_ans, soln_ans);
        return;
    case '.csv'
        if ~exist([cd filesep file_name], 'file')
            match = false;
            message = 'File Did Not Exist';
            return;
        end
        try
            stud_ans = csvread(file_name);
        catch ME
            match = false;
            message = ME.message;
            return;
        end
        soln_ans = csvread(['..' filesep '..' filesep 'Solutions' filesep file_name]);
    case '.dlm'
        if ~exist([cd filesep file_name], 'file')
            match = false;
            message = 'File Did Not Exist';
            return;
        end
        % FIXME: hardcoded delimiter usage
        try
            stud_ans = dlmread(file_name, '^');
        catch ME
            match = false;
            message = ME.message;
            return;
        end
        soln_ans = dlmread(['..' filesep '..' filesep 'Solutions' filesep file_name], '^');
    case '.txt'
        if ~exist([cd filesep file_name], 'file')
            match = false;
            message = 'File Did Not Exist';
            return;
        end
        fh = fopen(file_name);
        stud_ans = textscan(fh, '%s', 'delimiter', '\n');
        fclose(fh);
        fh = fopen(['..' filesep '..' filesep 'Solutions' filesep file_name]);
        soln_ans = textscan(fh, '%s', 'delimiter', '\n');
        fclose(fh);
        
        % Temporary remove \r function
        
        for ndx = 1:length(stud_ans)
            stud_ans{ndx} = strrep(stud_ans{ndx}, char(13), '');
        end
        
        for ndx = 1:length(soln_ans)
            soln_ans{ndx} = strrep(soln_ans{ndx}, char(13), '');
        end
        
        % 
        
        stud_ans = stud_ans{1};
        soln_ans = soln_ans{1};
    case {'.png', '.jpg', '.jpeg', '.bmp'}
        if exist(file_name, 'file')
            stud_img = imread(file_name);
            soln_img = imread(['..' filesep '..' filesep 'Solutions' filesep file_name]);
            [match message] = compareImage(stud_img, soln_img);
        else
            match = false;
            message = 'Image File Did Not Exist';
        end
        return;
    case '.wav'
        if exist(file_name, 'file')
            [stud_data stud_fs] = wavread(file_name);
            [soln_data soln_fs] = wavread(['..' filesep '..' filesep 'Solutions' filesep file_name]);
            [match message] = grader_CompareSounds({stud_data, stud_fs}, {soln_data, soln_fs});
        else
            match = false;
            message = 'Sound File Did Not Exist';
        end
        return;
    otherwise
        error('File Type Not Recognized');
end
match = isequaln(stud_ans, soln_ans);
end

%% Check Preconditions
function tests = checkPreconditions(preConds, student_files, problem, test_cases)
tests = false(1, length(preConds));
for i = 1:length(preConds)
    switch preConds{i}
        case 'File Exists'
            tests(i) = any(strcmp(student_files, problem));
        case {'Recursive' 'Recursion'}
            set(0, 'RecursionLimit', 4);
            try
                for j = 1:length(test_cases)
                    eval(test_cases{j})
                end
            catch ME
                if strcmp(ME.identifier, 'MATLAB:recursionLimit');
                    tests(i) = true;
                end
            end
            set(0, 'RecursionLimit', 500);
        otherwise
            error('Given Precondition Does Not Exist');
    end
end
end

%% Plot Grader
function plotData = plotGrader()
h = gcf;
if isempty(get(h, 'Children'))
    plotData = {};
    return
end

s = get(h, 'Children');

for i = 1:length(s)
    if strcmp('',get(s(i),'Tag'))
        plotData(i) = buildStructFromPlot(s(i));
    else
        plotData(i) = [];
    end
end
end

function data = buildStructFromPlot(h)
data.xdata = [];
data.ydata = [];
data.zdata = [];
data.color = [];
data.xlbl = [];
data.ylbl = [];
data.zlbl = [];
data.xlim = [];
data.ylim = [];
data.zlim = [];
data.title = [];
data.hasZData = true;
data.hasColor = true;

if strcmp('',get(h,'Tag'))
    xdata = get(get(h,'Children'),'XData');  %Grab all of the data from the plot.
    ydata = get(get(h,'Children'),'YData');

    % Spring 2016 patch to account for bar graphs (they don't have z-data)
    try
        zdata = get(get(h,'Children'),'ZData');
    catch ME
        data.hasZData = false;
    end
    
    
    %We need to sort all of this data.  Students could plot it in a different
    %order, we need to take that into account.
    if iscell(xdata)  %More than one thing was plotted
        for i = 1:length(xdata)
            [xdata{i}, ind] = sort(xdata{i});
            if length(ydata{i}) == length(xdata{i})
                ydata{i} = ydata{i}(ind);
            end
            if data.hasZData && length(zdata{i}) == length(xdata{i})
                zdata{i} = zdata{i}(ind);
            end
        end
    else %One thing was plotted
        [xdata ind] = sort(xdata);
        if length(ydata) == length(xdata)
            ydata = ydata(ind);
        end
        if data.hasZData && length(zdata) == length(xdata)
            zdata = zdata(ind);
        end
    end
    
    data.xdata = xdata;
    data.ydata = ydata;
    
    data.xlbl = get(get(h,'XLabel'), 'String'); %Labels
    data.ylbl = get(get(h, 'YLabel'), 'String');
    
    data.xlim = get(h, 'XLim'); %Axes
    data.ylim = get(h, 'YLim');

    %% Spring 2016 patch to account for bar graphs (they don't have z-data or color)
    try
        data.color = get(get(h,'Children'),'Color');
    catch ME
        data.hasColor = false;
    end

    if data.hasZData
        data.zdata = zdata;
        data.zlbl = get(get(h, 'ZLabel'), 'String');
        data.zlim = get(h, 'ZLim');
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    data.title = get(get(h, 'Title'),'String');

    frame = getframe(h);
    [img ~] = frame2im(frame);
    data.img = img;
else
    j = 1;
    C = get(h,'Children');
    for i = 1:length(C)
       if ~strcmp('',get(C(i),'Tag'))
            leg(j).String = get(C(i),'Tag');
            leg(j).Color = get(C(i),'Color');
            leg(j).Marker = get(C(i),'Color');
       end
    end
end
end

%% Default Comparison
function [match message] = compareDefault(student_ans, soln_ans)
match = false;
message = 'NONE';
if strcmp(class(soln_ans), class(student_ans))
    if isnumeric(soln_ans)
        if isequal(size(student_ans), size(soln_ans))
            if all(abs(student_ans - soln_ans) < .01)
                match = true;
            elseif isequalwithequalnans(student_ans, soln_ans)
                match = true;
            else
                % TODO: Values do not agree mismatch text
                message = 'Value Incorrect';
            end
        else
            % TODO: Fill in dimensions do not agree mismatch text
            message = 'Dimensions do not match';
        end
    else
        match = isequaln(student_ans, soln_ans);
        if ~match
            % Values do not agree mismatch text
            message = 'Value Incorrect';
        end
    end
else
    % Class mismatch text
    message = sprintf('Class Mismatch - Expected %s not %s', class(soln_ans), class(student_ans));
end
end

%% Cell Comparison
function [match message] = compareCell(student_cell, soln_cell)
match = false;
message = 'NONE';
student_class = class(student_cell);
soln_class = class(soln_cell);

if isempty(soln_cell) && isempty(student_cell)
    match = true;
    return;
end

if strcmp(student_class, soln_class)
    dim_student = size(student_cell);
    dim_soln = size(soln_cell);
    
    if length(dim_student) ~= length(dim_soln) || any(dim_student ~= dim_soln);
        message = sprintf('Dimensions Incorrect. Expected %s, not %s.', ...
            dim2str(dim_soln), dim2str(dim_student));
    else
        for i = 1:prod(dim_soln);
            student_cell_val = student_cell{i};
            soln_cell_val = soln_cell{i};
            
            student_type = class(student_cell_val);
            soln_type = class(soln_cell_val);
            
            if strcmp(student_type, soln_type)
                switch soln_type
                    case 'double'
                        dim_student_val = size(student_cell_val);
                        dim_soln_val = size(soln_cell_val);
                        if length(dim_student_val) ~= length(dim_soln_val) || any(dim_student_val ~= dim_soln_val);
                            message = sprintf('Dimensions of content at index %s incorrect. Expected %s, not %s.', ...
                                ind2str(ind2subv(dim_soln, i)), dim2str(dim_soln), dim2str(dim_student));
                            return;
                        elseif isnan(soln_cell_val)
                            match = isnan(student_cell_val);
                            if ~match
                                message = sprintf('Value at index %s incorrect. Other values may also be incorrect.', ...
                                    ind2str(ind2subv(dim_soln, i)));
                                return;
                            end
                        else
                            match = all(abs(student_cell_val - soln_cell_val) <= 0.01);
                            if ~match
                                message = sprintf('Value at index %s incorrect. Other values may also be incorrect.', ...
                                    ind2str(ind2subv(dim_soln, i)));
                                return;
                            end
                        end
                    otherwise
                        match = isequal(student_cell_val, soln_cell_val);
                        if ~match
                            message = sprintf('Value at index %s incorrect. Other values may also be incorrect.', ...
                                ind2str(ind2subv(dim_soln, i)));
                            return;
                        end
                end
            else
                message = sprintf('Class Mismatch at index %s. Expected %s, not %s.', ...
                    ind2str(ind2subv(dim_soln, i)), soln_type, student_type);
                return;
            end
        end
    end
else
    message = sprintf('Class Mismatch - Expected %s not %s', soln_class, student_class);
end
end

%% dim2str
function dim_str = dim2str(dimensions)
dim_str = sprintf('%dx', dimensions);
dim_str(end) = []; % Delete the last x character
end

%% ind2str
function ind_str = ind2str(index)
ind_str = sprintf('%d, ', index);
ind_str(end-1:end) = []; % Delete the last comma and space
ind_str = sprintf('(%s)', ind_str);
end

%% ind2subv
function vec = ind2subv(dim, i)
[cA{1:length(dim)}] = ind2sub(dim, i);
vec = cell2mat(cA);
end



%% Compare Images
function [match message] = compareImage(student_ans, soln_ans)
match = false;
message = 'NONE';
% Comparing two image matrices
if strcmp(class(student_ans), 'uint8')
    stud_size = size(student_ans);
    if length(stud_size) == 3
        if stud_size(3) == 3
            if all(size(soln_ans)==stud_size)
                if all(abs(double(student_ans) - double(soln_ans)) < 2)
                    match = true;
                else
                    message = 'Pixel Values Incorrect';
                end
            else
                message = 'Dimensions of Image Incorrect';
            end
        else
            message = 'Image does not contain three layers for RGB';
        end
    else
        message = 'Image Array not 3-Dimensional';
    end
else
    message = 'Array not of class UINT8';
end
end


%% Compare Plots
function [out printout] = comparePlot(sdata, tdata)
out = 0;
printout = {};

if ~isstruct(sdata)
    out = 9;
    printout = 'Success';
else
    % %First, test the number of lines
    % if false == plotIM(sdata.img,tdata.img) && (iscell(sdata.xdata) && ~iscell(tdata.xdata) || iscell(sdata.ydata) && ~iscell(tdata.ydata) || iscell(sdata.zdata) && ~iscell(tdata.zdata))
    %     printout{end+1} = sprintf('Incorrect Number of Lines Plotted. Expected %d, got %d.\r\n', 1, length(sdata.xdata));
    % elseif false == plotIM(sdata.img,tdata.img) && (~iscell(sdata.xdata) && iscell(tdata.xdata) || ~iscell(sdata.ydata) && iscell(tdata.ydata) || ~iscell(sdata.zdata) && iscell(tdata.zdata))
    %     printout{end+1} = sprintf('Incorrect Number of Lines Plotted. Expected %d, got %d.\r\n', length(tdata.xdata), 1);
    % elseif false == plotIM(sdata.img,tdata.img) && (iscell(sdata.xdata) && iscell(tdata.xdata) && ~isequal(length(sdata.xdata), length(tdata.xdata)))
    %     printout{end+1} = sprintf('Incorrect Number of Lines Plotted. Expected %d, got %d.\r\n', length(tdata.xdata), length(sdata.xdata));
    % else
        % printout{end+1} = sprintf('Number of Lines Plotted Passed.\r\n');
        out = out + .5;
    % end
    % %Next, test the number of data points
    % len = true;
    % if false == plotIM(sdata.img,tdata.img) && length(sdata.xdata) ~= length(tdata.xdata)
    %     printout{end+1} = sprintf('Incorrect Number of X Data Points.\r\n');
    %     len = false;
    % end
    % if false == plotIM(sdata.img,tdata.img) && length(sdata.ydata) ~= length(tdata.ydata)
    %     printout{end+1} = sprintf('Incorrect Number of Y Data Points.\r\n');
    %     len = false;
    % end
    % if tdata.hasZData && false == plotIM(sdata.img,tdata.img) && length(sdata.zdata) ~= length(tdata.zdata)
    %     printout{end+1} = sprintf('Incorrect Number of Z Data Points.\r\n');
    %     len = false;
    % end
    
    % if len
    %     printout{end+1} = sprintf('Number of Data Points Passed.\r\n');
        out = out + .5;
    % end
    %Now, check the actual values
    %X data
    if false == plotIM(sdata.img,tdata.img) && ~myisequal(sdata.xdata, tdata.xdata)
        printout{end+1} = 'Incorrect Values For X Data Points.\r\n';
    else
        printout{end+1} = 'X Data Passed.\r\n';
        out = out + 2;
    end
    
    %Y data
    if false == plotIM(sdata.img,tdata.img) && ~myisequal(sdata.ydata, tdata.ydata)
        printout{end+1} = 'Incorrect Values For Y Data Points.\r\n';
    else
        printout{end+1} = 'Y Data Passed.\r\n';
        out = out + 2;
    end
    
    %Z data
    if tdata.hasZData
        if false == plotIM(sdata.img,tdata.img) && ~myisequal(sdata.zdata, tdata.zdata)
            printout{end+1} = 'Incorrect Values For Z Data Points.\r\n';
        else
            printout{end+1} = 'Z Data Passed.\r\n';
            out = out + 2;
        end
    else
        out = out + 2;
    end
    
    %Color checking
    if tdata.hasColor && ~myisequal(sdata.color, tdata.color)
        printout{end+1} = 'Incorrect Color Values.\r\n';
    else
        printout{end+1} = 'Color Values Passed.\r\n';
        out = out + .5;
    end
    
    %Check the labels
    lbl = true;
    if ~strcmp(sdata.xlbl, tdata.xlbl)
        printout{end+1} = 'X-Axis Incorrectly Labeled.\r\n';
        lbl = false;
    end
    if ~strcmp(sdata.ylbl, tdata.ylbl)
        printout{end+1} = 'Y-Axis Incorrectly Labeled.\r\n';
        lbl = false;
    end
    if tdata.hasZData && ~strcmp(sdata.zlbl, tdata.zlbl)
        printout{end+1} = 'Z-Axis Incorrectly Labeled.\r\n';
        lbl = false;
    end
    
    if lbl
        printout{end+1} = 'Labels Passed.\r\n';
        out = out + .5;
    end
    
    % if false == plotIM(sdata.img,tdata.img) ...
    %     && (any(sdata.xlim ~= tdata.xlim) || any(sdata.ylim ~= tdata.ylim) || any(sdata.zlim ~= tdata.zlim))
    %     && (any(abs(sdata.xlim - tdata.xlim) > 0.01) || any(abs(sdata.ylim ~= tdata.ylim) > 0.01) || any(abs(sdata.zlim ~= tdata.zlim) > 0.01))
    %     printout{end+1} = 'Axes Incorrect.\r\n';
    % else
        % printout{end+1} = 'Axes Passed.\r\n';
        out = out + .5;
    % end
    
    if ~strcmp(sdata.title, tdata.title)
        printout{end+1} = 'Title Incorrect.\r\n';
    else
        printout{end+1} = 'Title Passed.\r\n';
        out = out + .5;
    end
end
end

function [out] = plotIM(studIM,solnIM)
    if size(studIM(:)) == size(solnIM(:))
        diffe = abs(double(studIM) - double(solnIM)) < 2;
        out = all(all(all(diffe)));
        if ~out
            if length(find(diffe(:,:,:) == false)) <= 200
                out = true;
            end
        end
    else
        out = false;
    end
end

function out = myisequal(sdata, tdata)
out = 0;
if ~strcmp(class(sdata),class(tdata))
    out = 0;
elseif isnumeric(sdata)
    out = isequal(sdata,tdata);
elseif iscell(sdata)
    for i = length(sdata):-1:1
        for j = length(tdata):-1:1
            %We're giving 5% leeway
            if isequal([sdata{i}], [tdata{j}]) || ((length(sdata{i}) == length(tdata{j})) &&  all(abs(mean([sdata{i}] - [tdata{j}])) < abs(mean([tdata{j}])*.05)))
                tdata(j) = [];
                sdata(i) = [];
                out = out + 1;
                break
            end
        end
    end
    out = (out / length(tdata));
end
end


%% Compare Sounds
function [match message] = grader_CompareSounds(stud_sound, soln_sound)
match = false;
message = 'NONE';

% Patch (Dec. 6, 2011) -- Brad Farr
% Allow grading of raw amplitude data with default fs.

if ~iscell(stud_sound)
    stud_data = stud_sound;
    soln_data = soln_sound;
    stud_Fs = 44100;
    soln_Fs = 44100;
else
    stud_data = stud_sound{1};
    soln_data = soln_sound{1};
    stud_Fs = stud_sound{2};
    soln_Fs = soln_sound{2};
end

if stud_Fs == soln_Fs
    [stud_len c1] = size(stud_data);
    [soln_len c2] = size(soln_data);
    if c1 == 1
        if abs(stud_len/soln_Fs - soln_len/stud_Fs) <= 0.05
            if stud_len < soln_len
                soln_data = soln_data(1:stud_len);
            else
                stud_data = stud_data(1:soln_len);
            end
            
            if all(abs(soln_data-stud_data) < .1)
                match = true;
                return;
            end
            
            
            soln_y = 2*abs(fft(soln_data))/length(soln_data);
            stud_y = 2*abs(fft(stud_data))/length(stud_data);
            soln_y = soln_y(1:round(end/2));
            stud_y = stud_y(1:round(end/2));
            
            num_max_freqs = 10;
            soln_max = zeros(1, num_max_freqs);
            stud_max = zeros(1, num_max_freqs);
            soln_ind = zeros(1, num_max_freqs);
            stud_ind= zeros(1, num_max_freqs);
            for i = 1:num_max_freqs
                [temp_y temp_ind] = max(soln_y);
                soln_max(i) = temp_y;
                soln_ind(i) = temp_ind;
                soln_y(temp_ind) = -1;
                [temp_y temp_ind] = max(stud_y);
                stud_max(i) = temp_y;
                stud_ind(i) = temp_ind;
                stud_y(temp_ind) = -1;
            end
            if all(abs(soln_max - stud_max) < .05) && all(soln_ind == stud_ind)
                match = true;
            else
                message = 'Sound Values Incorrect';
            end
        else            
            message = 'Sound Duration Incorrect';            
        end
    else
        message = 'Sound Was Not A Column Vector';
    end
else
    message = 'Sampling Frequency Value was Incorrect';
end
end
