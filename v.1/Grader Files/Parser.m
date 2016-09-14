function Parser(files)

d = dir('*(*)');
names = {d.name};
str = '';
fh = fopen('Student_p_files.txt', 'w');
disp('Start Parsing');
pFilesSubmitted = false;
for i = 1:length(names);
	cd([names{i}, filesep 'Submission attachment(s)']);
	disp(names{i});
	for j = 1:length(files)
		if exist([cd filesep files{j}], 'file')
			grader_fileParse(files{j});
		end
    end
    submission_contents = dir;
    submission_contents = {submission_contents.name};
    for j = 1:length(submission_contents)
        if ~isempty(strfind(submission_contents{j}, '.p'))
            str = [str sprintf('Student %s submitted .p file %s\n', ...
                names{i}, submission_contents{j})];
            pFilesSubmitted = true;
        end
    end
	cd('..');
	cd('..');
end
disp('End Parsing');
if pFilesSubmitted
    fprintf(fh, str);
    warning('Check Student_p_files.txt for stuents who submitted p file');
end
fclose(fh);
end

function grader_fileParse(file)
FID=fopen(file, 'r');
mfile = textscan(FID, '%s', 'delimiter', '\n', 'whitespace', '');
fclose(FID);
mfile=mfile{1};
wfound=strfind(mfile,'while');
if isempty([wfound{:}])
    return;
end
FID=fopen(file,'w');
fun=strfind(mfile,'function');
dots=strfind(mfile,'...');
comments=strfind(mfile,'%');
i=1;
mfile=strrep(mfile,'%','%%');
mfile=strrep(mfile,'\','\\');
%     print var initialization at the beginning of the file
while i<=length(mfile)
    if ~isempty(fun{i})&&(isempty(comments{i})||(comments{i}(1)>fun{i}(1)))
        fprintf(FID,[mfile{i},'\n']);
        fprintf(FID,'ghaw9823490qvb02439ahjfv829=0;\n');
    elseif ~isempty(wfound{i})&&(isempty(comments{i})||comments{i}(1)>wfound{i}(1))
        fprintf(FID,[mfile{i},'\n']);
        while ~isempty(dots{i})&&(isempty(comments{i})||comments{i}(1)>dots{i}(1))
            i=i+1;
            fprintf(FID,[mfile{i},'\n']);
        end
        fprintf(FID,'ghaw9823490qvb02439ahjfv829=ghaw9823490qvb02439ahjfv829+1;\n');
        fprintf(FID,'if ghaw9823490qvb02439ahjfv829>2200;error(''Infinite While Loop'');end\n');
    else
        fprintf(FID,[mfile{i},'\n']);
    end
    i=i+1;
end
fclose(FID);
end

