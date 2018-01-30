function ca = canvasCsv2cell(csvFile)
    fh = fopen(csvFile);
    firstLine = fgetl(fh);
    fclose(fh);
    numComma = sum(firstLine == ',');
    txtExp = cell(1, numComma + 1);
    txtExp(:) = {'%s'};
    txtExp = strjoin(txtExp,' ');
    fh = fopen(csvFile);
    ca = textscan(fh, txtExp,'Delimiter',',');
    ca = [ca{:}];
    fclose(fh);
end