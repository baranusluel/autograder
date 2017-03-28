function [hw_num, file_names, prob_weights, prob_preConds, file_tests, file_vars, file_vars_types, prob_test_weights] = rubricParser(rubric_name)
% Open rubric and binary read in file
fh = fopen(rubric_name);
% fprintf('Reading Rubric File...\n');
rubric_text = fread(fh);
fclose(fh);
% Cast binary to character and tranpose so that it will be a row vector
rubric_text = char(rubric_text');

% Identify which homework is being graded
hw_num = regexp(rubric_text, 'Homework ([0-9]+) Grading Rubric', 'tokens');
hw_num = str2double(hw_num{1}{1});

% Identify 
% Find the starting indices of the string that contains the text describing
% each problem in the rubric. It is expected that each problem has a header
% of Problem <Number> surrounded by at least one equal sign. The variable
% probs contains a vector of indices identify at what point in the string
% each problem starts. If a problem starts at probs(i), then it's text
% should end some time before probs(i+1)-1
fprintf('Identifying Number of Problems...\n');
probs = regexp(rubric_text, '=+Problem [0-9]+=+');
num_probs = length(probs);
fprintf('\t- %d Problems Identified\n', num_probs);

% Initialize variables to hold file names, prob weights, test cases, and
% test case variables, and test case weights.
file_names = cell(1, num_probs);
prob_weights = zeros(1, num_probs);
prob_preConds = cell(1, num_probs);
file_tests = cell(1, num_probs);
file_vars = cell(1, num_probs);
file_vars_types = cell(1, num_probs);
prob_test_weights = cell(1, num_probs);

% Add the position indicating the point where the last problem should end
probs(end+1)= length(rubric_text)+1;
fprintf('Beginning Problem Parsing...\n');

% Run through and parse each problem for the following information
%   - File Name
%   - Problem Value
%   - Test Case Value
%   - Test Case Code
for i = 1:num_probs
    % Pull out the problem text from the string
    prob_text = rubric_text(probs(i):probs(i+1)-1);
    % Identify the File Name of the problem and the Problem Value
    token = regexp(prob_text, 'File Name: (.*\.m).*Problem Value: ([0-9]*\.?[0-9]*) points? *', 'tokens'); 
    file_names(i) = token{1}(1);
    prob_weights(i) = str2double(token{1}{2});
    
    %Identify Problem Preconditions
    token = regexp(prob_text, '- *([^\r?\n]+)(?<!Test Case.*)', 'tokens');
    % If no preconditions given, set default for checking if file exists
    if isempty(token) || isempty(token{1})
       prob_preConds{i} = {'File Exists'}; 
    else
       prob_preConds{i} = [token{:}];
    end
    % Identify the test cases for the given problem
    [tokens indices] = regexp(prob_text, 'Test Case ?[0-9]*: ([0-9]*\.?[0-9]*) points? *\r?\n([^\r?\n]+\r?\n)+\r?\n', 'tokens', 'start');
    indices = [indices length(prob_text)];
        
    % Initialize variables to holds the test cases, the weights of the
    % cases, and the variables of the test cases
    test_cases = cell(1, length(tokens));
    test_weights = zeros(1, length(tokens));
    test_vars = cell(1, length(tokens));
    test_vars_types = cell(1, length(tokens));
    
    % Loop through the tokens, where each token contains the varying
    % information describing a test case
    for j = 1:length(tokens)
        % Set the weight of the test case
        test_weights(j) = str2double(tokens{j}{1});
        % Store the test case
        test_cases(j) = tokens{j}(2);
        % Identify the variables in the test case and store them
        fun_call = regexp(tokens{j}{2}, '[^\r?\n]+\r?\n$', 'match');
        vars = regexp(fun_call{1}, '([^\[\] ,=]+)(?<!=[^=].*)(?=[^\r?\n]*=[^=])', 'tokens');
        vars = [vars{:}];
        var_types = {};
        if ~isempty(vars)
            if strcmp(vars{1},'~')
                vars =[];
                test_cases{j} = tokens{j}{2}(7:end);
             end
        end
        var_types(1:length(vars)) = {'default'};
        
        % Identify any output files that should have been written
        variables = regexp(prob_text(indices(j):indices(j+1)-1), '- *([^\r?\n]+): *([^\r?\n]+)\r?\n(?<=Variables:? *\r?\n(?:- *[^\r?\n]+\r?\n)*)', 'tokens');
        for k = 1:length(variables)
           var = variables{k}{1};
           var_type = variables{k}{2};
           ind = find(strcmp(var, vars), 1);
           if isempty(ind)
               vars{end+1} = var;
               var_types{end+1} = var_type;
           else
               vars{ind} = var;
               var_types{ind} = var_type;
           end
        end
        
        % Identify any output files that should have been written
        output_files = regexp(prob_text(indices(j):indices(j+1)-1), '- *([^\r?\n]+)\r?\n(?<=Output Files:? *\r?\n(?:- *[^\r?\n]+\r?\n)*)', 'tokens');
        output_files = [output_files{:}];
        for k = 1:length(output_files)
           output_files{k} = ['''' output_files{k} '''']; 
        end
        file_type = {};
        file_type(1:length(output_files)) = {'file'};
        
        % Identify any special tests
        special_tests = regexp(prob_text(indices(j):indices(j+1)-1), '- *([^\r?\n]+)\r?\n(?<=Special Tests:? *\r?\n(?:- *[^\r?\n]+\r?\n)*)', 'tokens');
        special_tests = [special_tests{:}];
        for k = 1:length(special_tests)
           switch special_tests{k}
               case 'Grade Plot'
                   vars{end+1} = 'plotGrader()';
                   var_types{end+1} = 'plot';                   
               otherwise
                   vars{end+1} = 'issue';
                   var_types{end+1} = 'issue';
           end                   
        end
        test_vars{j} = [vars output_files];
        test_vars_types{j} = [var_types file_type];
    end
    
    % Store the Problem test case data in the varying cell arrays
    prob_test_weights{i} = test_weights;
    file_tests{i} = test_cases;
    file_vars{i} = test_vars;
    file_vars_types{i} = test_vars_types;
    fprintf('\t- Problem %d Parsing Complete\n', i);
end
fprintf('Problem Parsing Complete\n');

fprintf('Verifying Rubric...\n');
numHard_errors = 0;
hard_errors = cell(1, num_probs*5);
numSoft_errors = 0;
soft_errors = cell(1, num_probs*5);
% Check to see that the problem weights add to 100
% If not, ask for user input. Sum of greater than a 100 may have been
% deliberate
if sum(prob_weights) == 100
    fprintf('Problem Weights Add to 100: PASS\n');
else
    numSoft_errors = numSoft_errors+1;
    soft_errors{numSoft_errors} = sprintf('Problem Weights Add to 100: FAIL - Weights add to %d', sum(prob_weights)); 
end

for i = 1:num_probs
    if length(file_tests{i}) ~= length(prob_test_weights{i})
        numHard_errors = numHard_errors+1;
        hard_errors{numHard_errors} = sprintf('Problem %d: Number of Test Cases and Number of Weights Did Not Match', i);
    end
    
    if prob_weights(i) ~= sum(prob_test_weights{i})
        numSoft_errors = numSoft_errors+1;
        soft_errors{numSoft_errors} = sprintf('Problem %d: Problem Weight and Sum of Test Weights Did Not Match', i);
    else
        fprintf('\t - Problem %d Weight Equals Test Weights Sum: PASS\n', i);
    end
end

if ~numHard_errors && ~numSoft_errors
    fprintf('No Inconsiticies Found\n');
else
    if numHard_errors
        fprintf(2, 'ERRORS: \n');
        for i = 1:numHard_errors
            fprintf(2,'- %s\n', hard_errors{i});
        end
    else
       fprintf('ERRORS: NONE\n'); 
    end
    
    if numSoft_errors
        fprintf('WARNINGS: \n')
        for i = 1:numSoft_errors
            fprintf(2,'- %s\n', soft_errors{i});
        end
        
        in = input('Would you like to continue?\n>> ', 's');
        if ~(isempty(in) || in(1) == 'y' || in(1) == 'Y')
            error('RUBRIC INCOMPLETE - USER TERMINATED');
        end
    else
        fprintf('WARNINGS: NONE\n');
    end
    
    if numHard_errors
        error('RUBRIC CONTAINS ERRORS - PROGRAM TERMINATED');
    end
end

