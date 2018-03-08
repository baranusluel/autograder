%% canvasConverter Converts Canvas submissions to T-Square format
%
% Inputs:
%   submissions_file: Name of zip file containing submissions from Canvas
%   gradebook: Name of gradebook xlsx file containing student info
%   out_file: Name of zip file to export to
%   hw_name: Name of homework. Eg: 'Homework 4 - Logicals'

function [out_file, gradebook, hw_name] = canvasConverter(submissions_file, gradebook, hw_name)
    
    if nargin < 3
        % UI input if fewer than 3 inputs.
        [submissions_file,sub_path] = uigetfile('*.zip','Select the .zip downloaded from canvas');
        [gradebook,gradebook_path] = uigetfile([sub_path '\*.csv'],'Select the .csv downloaded from canvas');
        
        
        f = figure('Name','Select Homework',...
                   'Visible','on',...
                   'Units','Normalized',...
                   'Position',[.4 .3 .25 .4]);
        list = uicontrol(f,'Style','listbox',...
                           'String',{'Homework 01 - Basics',...
                                     'Homework 02 - Functions',...
                                     'Homework 03 - Vectors and Strings',...
                                     'Homework 04 - Logicals and Masking',...
                                     'Homework 05 - Arrays and Images',...
                                     'Homework 06 - Conditionals',...
                                     'Homework 07 - Iteration',...
                                     'Homework 08 - Low Level IO',...
                                     'Homework 09 - High Level IO',...
                                     'Homework 10 - Structures',...
                                     'Homework 11 - Plotting and Numerical Methods',...
                                     'Homework 12 - Recursion'},...
                           'Units','Normalized',...
                           'Position',[.05 .35 .90 .60]);
        chkbx = uicontrol(f,'Style','checkbox',...
                            'String','Resubmission',...
                            'Units','Normalized',...
                            'Position',[.1 .25 .8,.1]);
        uicontrol(f,'Style','pushbutton',...
                    'String','Submit to grader',...
                    'Units','Normalized',...
                    'Position',[.25 .05 .5,.15],...
                    'Callback','uiresume(gcbf)');
        uiwait(f);
        hw_name = list.String{list.Value};
        resub = logical(chkbx.Value);
        close(f)
        if resub
            hw_name = [hw_name(1:find(hw_name == '-')+1) 'Resubmission'];
        end
    end
    
    out_file = ['formatted' upper(submissions_file(1)) submissions_file(2:end)];
    out_file = fullfile(sub_path,out_file);
    submissions_file = fullfile(sub_path,submissions_file);
    gradebook = fullfile(gradebook_path,gradebook);
    
    % Create temporary working directory
    mkdir('canvasConverter_tmp');
    % Unzip student submissions from Canvas
    unzip(submissions_file, 'canvasConverter_tmp/submissions');
    
    % Students is a containers map to track student names and submissions
    % Key: double, Student ID
    % Value: struct, Student structure, Fields: firstname, lastname, submissions
    % Submissions is a struct within every student's individual struct, 
    % with function names (without .m) as fields and submission versions
    % (from <func-name>-#.m) as values. It is its own struct to avoid
    % structure array contanenation mismatch.
    students = containers.Map('KeyType','double','ValueType','any');
    
    % Read the gradebook spreadsheet
    [~, ~, gradebook_raw] = xlsread(gradebook);
    [rows, ~] = size(gradebook_raw);
    % Iterate for every row except header (i.e. for every student)
    for r = 3:rows
        % Extract Names and IDs from canvas.csv
        id = gradebook_raw{r, 2};
        tsquareID = gradebook_raw{r,4};
        % Populate containers map with student's first and last names,
        % with a key of their student ID
        students(id) = struct('tsquareID', tsquareID, 'submissions', []);
        % Construct directory paths
        student_path = fullfile('canvasConverter_tmp/',hw_name,tsquareID);
        submission_path = [student_path, '/Submission attachment(s)/'];
        % If this student's folder hasn't been created yet
        if exist(submission_path, 'dir') == 0
            % Create student's directories
            mkdir(submission_path);
            mkdir([student_path, '/Feedback Attachment(s)/']);
        end
    end
    
    % cd is after the above because submissions_file and gradebook inputs
    % may be relative paths
    cd('canvasConverter_tmp');
    % Get list of all submitted files from all students
    files = dir('submissions/*.m');
    
    % Iterate for each file. 'Files' transposed because row vector required
    for file = files'
        % Extract student and function names from filename
        newName = strrep(file.name,'_late','');
        tokens = strsplit(newName, '_');
        % Account for ABCs_*.m and hyphenated student names
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
        student_id = str2double(tokens{2});
        func_name = tokens{end}; % Format: '<function>.m' OR '<function>-#.m'
        
        % Skip file if not .m
        if ~strcmpi(func_name(end-1:end), '.m')
            continue;
        end
        
        % If func name contains '-', extract version num from the name
        if contains(func_name, '-')
            func_name_toks = strsplit(func_name, {'-', '.'}); % Format: {function, version, 'm'}
            func_name = [func_name_toks{1}, '.m'];
            func_version = str2double(func_name_toks{2});
        else
            func_version = 0;
        end
        % Remove non-legal characters from function name
        % Format: func_name.m
        func_name = func_name(isstrprop(func_name, 'alpha') | func_name == '_' | func_name == '.');
        
        % Get the student's struct from containers map with their ID
        if isKey(students, student_id)
            student = students(student_id);
        else
            warning(['Couldn''t find student with ID ', student_id, ' in gradebook!']);
            continue;
        end
        
        % Construct directory paths
        student_path = fullfile(hw_name,student.tsquareID);
        submission_path = [student_path, '/Submission attachment(s)/'];
        
        % Get relevant student's submissions (processed so far)
        submissions = student.submissions;
        % Strip .m from func_name
        func_name_stripped = strtok(func_name, '.');
        % If given function wasn't been processed yet or was older version
        if ~isfield(submissions, func_name_stripped) || ...
            (isfield(submissions, func_name_stripped) && submissions.(func_name_stripped) < func_version)
            % Update function version in student's submissions
            submissions.(func_name_stripped) = func_version;
            student.submissions = submissions;
            students(student_id) = student;
            % Copy function file to student's submission directory
            copyfile(['submissions/', file.name], [submission_path, func_name]);
        end
    end
    
    % Export grades.csv by printing each line (csvwrite only takes nums)
    grades_file = fopen([hw_name, '/grades.csv'], 'w');
    
    % Start Writing t2.csv
    fprintf(grades_file, '%s,%s,,,\n', 'Homework','Points');
    fprintf(grades_file, '%s,%s,%s,%s,%s\n', 'Display ID','ID','Last Name','First Name','grade');
    csvdat = cell(rows-2,4);
    for r = 3:rows
        name = gradebook_raw{r,1};
        [lastname,firstname] = strtok(name,',');
        lastname(lastname == '?') = [];
        lastname = strtok(lastname,' ');
        firstname(firstname == '?') = [];
        firstname = strtok(firstname,', ');
        id = gradebook_raw{r, 2};
        tsquareID = gradebook_raw{r,4};
        csvdat(r-2,:) = {tsquareID, id, lastname, firstname};
    end
    % Ensure the order is the same as window's sorting.
    [~,inds] = sort(csvdat(:,1));
    csvdat = csvdat(inds,:);
    for i = 1:r-2
        fprintf(grades_file, '%s,%d,%s,%s,\n', csvdat{i,:});
    end
    
    fclose(grades_file);
    
    % Change back to original directory as out_file may be relative path
    cd('..');
    
    % Zip the output. Tmp directory given as 3rd input (the rootfolder)
    % instead of being prepended to 2nd input so that zip doesn't have an
    % extra directory layer
    zip(out_file, hw_name, 'canvasConverter_tmp');
    % Delete temp directory to clean up
    rmdir('canvasConverter_tmp', 's');
end