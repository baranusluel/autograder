function strTable = cell2txt(cellData)
if isempty(cellData)
    strTable = 'Empty Cell Array';
    if nargout == 0
        clear strTable
    end
    return;
end
if ~iscell(cellData)
    cellData = {cellData};
end
cellData = cellfun(@cell2text, cellData, 'uni', false);
[h, w] = cellfun(@size, cellData);
if size(w, 1) == 1
    w = [w; zeros(1, size(w, 2))];
end
if size(h, 2) == 1
    h = [h zeros(size(h, 1), 1)];
end
vecHeights = max(h, [], 2);
vecWidths = max(w);
cellArr = cell(size(cellData, 1), 1);
for r = 1:size(cellData, 1)
    intH = vecHeights(r);
    strRow = zeros(intH, sum(vecWidths) + 1 + 2 * numel(vecWidths));
    cEnd = 0;
    for c = 1:size(cellData, 2)
        cStart = cEnd + 1;
        cEnd = cStart + vecWidths(c) + 1;
        intW = vecWidths(c) + 1;
        strData = cellData{r, c};
        strData = strVSize(strData, intH);
        strData = strHSize(strData, intW);
        strData = strPad(strData, '|');
        strRow(:, cStart:cEnd) = strData;
    end
    strRow(:, end) = '|';
    cellArr{r} = char([strRow; zeros(1, size(strRow, 2)) + 45]);
end
strTable = vertcat(cellArr{:});
strPd = zeros(1, size(strTable, 2));
strPd(:) = '-';
strTable = [strPd; strTable];
if nargout == 0
    clear strTable
end
end

function strDatum = cell2text(varDatum)
    if isempty(varDatum)
        strDatum = ['EMPTY ', upper(class(varDatum))];
    elseif ischar(varDatum)
        strDatum = varDatum;
    elseif isnumeric(varDatum)
        strDatum = num2str(varDatum);
    elseif iscell(varDatum)
        strDatum = cell2txt(varDatum);
    elseif isa(varDatum, 'function_handle')
        if numel(varDatum) > 1
            varDatum = num2cell(varDatum);
            strDatum = cell2txt(varDatum);
        else
            strDatum = func2str(varDatum);
        end
    elseif isa(varDatum, 'matlab.ui.Figure')
        if numel(varDatum) > 1
            varDatum = num2cell(varDatum);
            strDatum = cell2txt(varDatum);
        else
            strDatum = ['Fig: ', varDatum.Name];
        end
    elseif isstruct(varDatum)
        varDatum = num2cell(varDatum);
        varDatum = cellfun(@dispStc, varDatum, 'uni', false);
        if numel(varDatum) == 1
            varDatum = varDatum{1};
        end
        strDatum = cell2txt(varDatum);
        strDatum = [zeros(1, size(strDatum, 2)); strDatum];
        strDatum(1, 1:7) = 'Struct:';
    else
        strDatum = evalc('disp(varDatum)');
        strDatum = strsplit(strDatum, '\n');
        [c1, c2] = cellfun(@(str)(strtok(str, ' ')), strDatum, 'uni', false);
        strDatum = cellfun(@(str1, str2)([str1 str2]), c1, c2, 'uni', false);
        vecCols = cellfun(@(str)(size(str, 2)), strDatum);
        intC = max(vecCols);
        strDatum = cellfun(@(str)(strHSize(str, intC)), strDatum, 'uni', false);
        strDatum = vertcat(strDatum{:});
        strDesc = ['DATA OF TYPE: ', upper(class(varDatum))];
        if size(strDatum, 2) > size(strDesc, 2)
            strDesc = strHSize(strDesc, size(strDatum, 2));
        elseif size(strDatum, 2) < size(strDesc, 2)
            strDatum = strHSize(strDatum, size(strDesc, 2));
        end
        strDatum = [strDesc; strDatum];
    end
    strDatum = strPad(strDatum, ' ');
end

function strOut = strPad(strIn, chrPad)
    strPd = zeros(size(strIn, 1), 1);
    strPd(:) = chrPad;
    strOut = [strPd strIn];
end

function strOut = strVSize(strIn, intS)
    intPad = intS - size(strIn, 1);
    strP = zeros(intPad, size(strIn, 2));
    strP(:) = ' ';
    strOut = [strIn; strP];
end

function strOut = strHSize(strIn, intS)
    intPad = intS - size(strIn, 2);
    strP = zeros(size(strIn, 1), intPad);
    strP(:) = ' ';
    strOut = [strIn strP];
end