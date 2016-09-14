function writeMessage(num)

if num < 1
    num = 1;
elseif num > 10
    num = 10;
end

[~, ~, studentInfo] = xlsread('grades.csv');

load('theMessages.mat');
message = messages{num};

for ndx = 4:length(studentInfo)
    studentIDs{ndx-3} = studentInfo{ndx,1};
    filePaths{ndx-3} = sprintf('%s, %s(%s)', studentInfo{ndx,3}, studentInfo{ndx,4}, studentInfo{ndx,2});
end

for ndx = 1:length(targets)
    loc = find(strcmp(targets{ndx}, studentIDs));
    
    if ~isempty(loc)
        curr_fid = fopen([filePaths{loc} '\Feedback Attachment(s)\grade.txt'], 'a');    
        
        
        fprintf(curr_fid, '\r\n');
        fprintf(curr_fid, '=============== Special Message ====================\r\n');
        
        for i = 1:length(message)
        fprintf(curr_fid, message{i});
        end
        
        fprintf(curr_fid, '====================================================\r\n');
        fclose(curr_fid);

    else
        
        fprintf('%s not found\n', targets{ndx});
        
    end
    
end
        
    








end