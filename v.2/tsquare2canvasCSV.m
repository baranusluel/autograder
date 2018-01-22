function tsquare2canvasCSV(tsquareCSV,canvasCSV,hwNumStr,resub)
    [~,~,tsquare] = xlsread(tsquareCSV);
    [~,~,canvas] = xlsread(canvasCSV);
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
    xlswrite('grades1.xlsx',canvas);
end