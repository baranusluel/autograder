
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Author: Peter Sebastian Koplik
%Version: 1.1
%This function relies on the files 'moji-1.0.1.jar' and 
%'mossinterface.jar' to be present in the same directory as 'moss.m'. It
%communicates with the MOSS similarity detection server at Stanford, and
%therefore requires an internet connection.
% 
%Check the README BEFORE YOU RUN THIS. SERIOUSLY.
%
%Call moss.m from the command line. The inputs are strings containing the
%names of any files you want the algorithm to ignore. This will usually be 
%'hw##.m' and the ABCs files, as the student submission contain largely 
%the same code in these files.



function varargout =  moss(varargin)
disp('You will probably see/hear/feel your computer plugging and chugging');
disp('If you have errors, tell Peter Koplik :)');
disp('Modifying directories for MOSS usage... Step 1/7');%moss doesn't understand spaces. fucking 32...
despace;
disp('Tagging files to ignore... Step 2/7');
ignoreTheseFiles(varargin);
currentDir = pwd;
baseDir = [currentDir filesep 'base'];
disp('Adding jarfiles to path... Step 3/7');
javaaddpath('mossinterface.jar');
javaaddpath('moji-1.0.1.jar');
disp('Uploading files to MOSS... Step 4/7');
disp('Notice your network usage. If you error here, you either');
disp('Need internet or something is wrong with your JVM boiii');
disp('Anyway, this is the long step. Don''t be on cellular data lol.');
url = javaMethod('similarityCheck','QuickStart',currentDir, baseDir);
disp('Opening webpage... Step 5/7');
disp('URL for results expires in 14 days!');
web(char(url));
disp('DO NOT KILL THE PROGRAM HERE OR YOU WILL HAVE TO RE-DOWNLOAD FROM T2');
disp('Untagging files... Step 6/7');
unignoreFiles;
disp('Remodifying directories back to normal... Step 7/7');
respace;
disp('DONE!');
end

function [valid] = isValidFolderName(name)
valid = strcmp(name(end),')');
end


function [varargout] = ignoreTheseFiles(in)
students = dir;
for i = 1:length(students)
    folderName = students(i).name;
    submissionsFolderName =[folderName filesep 'Submissionattachment(s)'];
    if isValidFolderName(folderName)
        cd(submissionsFolderName);
        files = dir;
        for j = 1:length(in)
            for k = 1:length(files)
                if strcmp(in{j},files(k).name)
                    movefile(files(k).name, [files(k).name 'ignore'])
                end
            end
        end
        cd(['..' filesep '..']);
    end
end
end

function [varargout] = unignoreFiles(varargin)
students = dir;
for i = 1:length(students)
    folderName = students(i).name;
    submissionsFolderName =[folderName filesep 'Submissionattachment(s)'];
    if isValidFolderName(folderName)
        cd(submissionsFolderName);
        files = dir;
        for j = 1:length(files)
            fileName = files(j).name;
            if length(fileName) > 8 &&...
                    strcmp(fileName(end - 5:end), 'ignore');
                movefile(files(j).name, files(j).name(1:end-6));
            end
        end
        cd(['..' filesep '..']);
    end
   
end


end

function varargout = despace(varargin)
students = dir;
for i = 1:length(students)
    folderName = students(i).name;
    if isValidFolderName(folderName)
        if any(isspace(folderName))
            newFolderName = folderName(~isspace(folderName));
            movefile(folderName, newFolderName);
            cd(newFolderName);
        else
            cd(folderName);
        end
        subFolders = dir;
        for j = 1:length(subFolders)
            subFolderName = subFolders(j).name;
            if any(isspace(subFolderName))
                newSubFolderName = subFolderName(~isspace(subFolderName));
                movefile(subFolderName, newSubFolderName);
            end
        end
        cd('..');
    end
end
end

function [varargout] = respace(varargin)
students = dir;
for i = 1:length(students)
    folderName = students(i).name;
    if isValidFolderName(folderName)
        if ~any(isspace(folderName))
            commaInd = strfind(folderName, ',');
            newFolderName = [folderName(1:commaInd) ' ' folderName(commaInd + 1:end)];
            capsInd = find(newFolderName >= 65 & newFolderName <= 90);
            if ~isempty(capsInd)
                capsInd = capsInd(2:end);
                capsInd = capsInd(capsInd ~= commaInd + 2);
                if ~isempty(capsInd)
                    spaceLogical = false(1,length(newFolderName) + length(capsInd));
                    spaceLogical(capsInd + (0:length(capsInd) - 1)) = true;
                    newFolderNameSpaced = zeros(1,length(spaceLogical));
                    newFolderNameSpaced(spaceLogical) = 32;
                    newFolderNameSpaced(~spaceLogical) = newFolderName;
                else
                    newFolderNameSpaced = newFolderName;
                end
            else
                newFolderNameSpaced = newFolderName;
            end
            dashLog = newFolderNameSpaced == 45;
            if any(dashLog)
                postDashSpaceLog = [false dashLog(1:end - 1)];
                newFolderNameSpaced = newFolderNameSpaced(~postDashSpaceLog);
            end
            newFolderNameSpaced = char(newFolderNameSpaced);
            movefile(folderName, newFolderNameSpaced);
            cd(newFolderNameSpaced);
        else
            cd(folderName);
        end
        subFolders = dir;
        for j = 1:length(subFolders)
            subFolderName = subFolders(j).name;
            if isValidFolderName(subFolderName) && ~any(isspace(subFolderName))
                if strcmpi(subFolderName,'FeedbackAttachment(s)') || ...
                        strcmpi(subFolderName, 'submissionattachment(s)')
                    newSubFolderNameSpaced = [subFolderName(1:end - 13)...
                        ' ' subFolderName(end - 12:end)];
                else
                    commaInd = strfind(subFolderName, ',');
                    newSubFolderName = [subFolderName(1:commaInd) ' ' subFolderName(commaInd + 1:end)];
                    capsInd = find(newSubFolderName >= 65 & newSubFolderName <= 90);
                    if ~isempty(capsInd)
                        capsInd = capsInd(2:end);
                        capsInd = capsInd(capsInd ~= commaInd + 2);
                        spaceLogical = false(1,length(newSubFolderName) + length(capsInd));
                        spaceLogical(capsInd + (0:length(capsInd) - 1)) = true;
                        newSubFolderNameSpaced = zeros(1,length(spaceLogical));
                        newSubFolderNameSpaced(spaceLogical) = 32;
                        newSubFolderNameSpaced(~spaceLogical) = newSubFolderName;
                    else
                         newSubFolderNameSpaced = newSubFolderName;
                    end
                    dashLog = newSubFolderNameSpaced == 45;
                    if any(dashLog)
                        postDashSpaceLog = [false dashLog(1:end - 1)];
                        newSubFolderNameSpaced = newSubFolderNameSpaced(~postDashSpaceLog);
                    end
                    newSubFolderNameSpaced = char(newSubFolderNameSpaced);
                end
                movefile(subFolderName, newSubFolderNameSpaced);
            end
        end
        cd('..');
    end
end     
end

function varargout = smushFolders(varargin)
students = dir;
for i = 1:length(students)
    folderName = students(i).name;
    submissionsFolderName =[folderName filesep 'Submissionattachment(s)' filesep];
    if isValidFolderName(folderName) && ... 
            ~isempty(dir(fullfile(submissionsFolderName, '*m')))
        copyfile([submissionsFolderName '*'], folderName);
    end
end
end
function varargout = unsmushFolders(varargin)
students = dir;
for i = 1:length(students)
    folderName = students(i).name;
    if isValidFolderName(folderName)
        delete([folderName filesep '*.m']);
    end
end
end



