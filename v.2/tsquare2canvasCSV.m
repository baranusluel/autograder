function tsquare2canvasCSV(tsquareCSV,canvasCSV,hwName)
    hwNumStr = hwName(hwName <= '9' & hwName >= '0');
    resub = contains(hwName,'Resubmission');
    [~,~,tsquare] = xlsread(tsquareCSV);
    [~,~,canvas] = xlsread(canvasCSV);
    tsquareDimvec = size(tsquare);
    canvasDimvec = size(canvas);
    mask = contains(canvas(1,:),hwName);
    if sum(mask) ~= 1
        assignmentNames = canvas(1,6:end);
        assignment = listdlg('ListString',assignmentNames,'SelectionMode','single',...
                             'PromptString','Which Assignment is this?','OKString','Select');
        mask = strcmp(canvas(1,:),assignmentNames{assignment});
    end
%     if resub
%         mask = contains(canvas(1,:),hwNumStr) & contains(canvas(1,:),'Resub');
%     else
%         mask = contains(canvas(1,:),hwNumStr) & ~contains(canvas(1,:),'Resub');
%     end
    for r = 4:tsquareDimvec(1)
        id = tsquare{r,1};
        t2mask = cellfun(@(x) isequal(x,id),canvas(:,4));
        grade = tsquare{r,5};
        canvas{t2mask,mask} = grade;
    end
    parentPath = fileparts(canvasCSV);
    fh = fopen([parentPath '\writtenGrades.csv'],'w');
    for r = 1:canvasDimvec(1)
        fprintf(fh,'"%s"',canvas{r,1});
        for c = 2:canvasDimvec(2)
            if isnan(canvas{r,c})
                fprintf(fh,',');
            elseif isnumeric(canvas{r,c})
                fprintf(fh,',%.1f',canvas{r,c});
            elseif ischar(canvas{r,c})
                fprintf(fh,',%s',canvas{r,c});
            end
        end
        fprintf(fh,'\n');
    end
    fclose(fh);
end