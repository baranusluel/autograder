function xls2mat()
% Create .mat files for the autograder to run on .xls files so that xlsread
% is possible when autograding in bypassing Microsoft Office because Office
% takes just about forever.

% Save the current path
path = cd;
% Assume that file separator is '/'

% Operate in the Copy Files folder
cd './Copy Files';

% Find the files in the directory and change only the Excel files
% accordingly.
copyfile_path = cd;
directory = dir;
filenames = {directory.name};

% Run through each directory and narrow down the Excel files that will be
% used for testing.
for i = 1:length(directory)
    if strfind(filenames{i},'.xls')
        [num txt raw] = xlsread(filenames{i});
        % Added to account for xlsx files
		[file_name,extension] = strtok(filenames{i},'.');
        save([file_name '_' extension(2:end) '.mat'],'num','txt','raw');
        % Delete the old .xls entry, since it is unnecessary for the Copy
        % Files directory
        delete(filenames{i});
    end
end

% Make sure to cd back to the correct directory before finishing
cd ..;

% Include the substitute xlsread and xlswrite now
copyfile([path '/xlsread_opt.m'],[copyfile_path '/xlsread.m']);
copyfile([path '/xlswrite_opt.m'],[copyfile_path '/xlswrite.m']);

end
        