function tsquare2canvasCSV(tsquareCSV,canvasCSV,hwName)
    hwNumStr = hwName(hwName <= '9' && hwName >= '0');
    resub = contains(hwName,'Resubmission');
    [~,~,tsquare] = xlsread(tsquareCSV);
    [~,~,canvas] = xlsread(canvasCSV);
    canvas = canvas(:,1:22);
    canvasDimvec = size(canvas);
    if resub
        mask = contains(canvas(1,:),hwNumStr) & contains(canvas(1,:),'Resub');
    else
        mask = contains(canvas(1,:),hwNumStr) & ~contains(canvas(1,:),'Resub');
    end
    for r = 3:canvasDimvec(1)
        id = canvas{r,2};
        t2mask = cellfun(@(x) isequal(x,id),tsquare(:,2));
        grade = tsquare{t2mask,5};
        canvas{r,mask} = grade;
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