function copy_files()
% Save the current path 
path = cd; 
sep = filesep; % Identify File separator for current platform


students = dir('*(*)');
students = {students.name};

cd('Copy Files');
file_names = dir();
non_dirs = ~[file_names.isdir];
file_names = {file_names.name};
file_names = file_names(non_dirs);

disp('Start Copy Sequence')
% Loop through files and copy each file to the 'Solutions' folder
for j = 1:length(file_names)
    status = copyfile(file_names{j}, [path, sep, 'Solutions', sep]);
    % If a file copy failed, display to screen and set success to fail
    if ~status
        success = false;
        disp(file_names(j).name);
    end
end

% The full path to a Student's submission's directory can be formed as a
% combination of the first portion of the path that is static for all
% students, then the student's directory name, followed by the second
% portion of the path that is static for all students. 
% The first portion of the path that is same for all students
path_first = [path sep];
% The second portion of the path that is the same for all students
path_second = [sep, 'Submission attachment(s)', sep];

% Loop through the student directories and copy each file to the student's
% submission directory
for i = 1:length(students)
    status = ones(1, length(file_names));
    % Copy Files Into Student Directories
    for j = 1:length(file_names)
        status(j) = copyfile(file_names{j}, [path_first students{i} path_second]);
    end
    % If any file copy failed, display to user and set success to fail
    if ~all(status)
        disp(students{i});
        success = false;
    end
end
cd(path) % Return back to home directory
disp('Copying Complete');
end