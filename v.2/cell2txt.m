function strTable = cell2txt(cellData, logLines)
%CELL2TXT convert a cell array into a string representation.
%
%   T = cell2txt(C, L)
%
%   Given C, cell2txt will construct a character array that represents the
%   cell array given in C. If C is not a cell array, it is assumed that you
%   only want to show that data, and it is treated as a 1x1 cell array. The
%   output string is stored in T.
%
%   If T is not requested, cell2txt will instead print the answer onto the
%   command window.
%
%   If L is not present or present and false, the output will be an array,
%   with returns represented as rows. If L is true, then the output is a
%   1xN character array, with new lines represented by char(10).

if nargin == 0
    strTable = 'NO DATA FOUND';
    if nargout == 0
        disp(strTable);
        clear strTable;
    end
    return;
elseif nargin == 1
    logLines = false;
end
if isempty(cellData)
    strTable = 'NO DATA FOUND';
    if nargout == 0
        disp(strTable)
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
    % strRow = zeros(intH, 0);
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
        % strRow = [strRow strData];
        strRow(:, cStart:cEnd) = strData;
    end
    % strPd = zeros(intH, 1);
    % strPd(:) = '|';
    % strRow = [strRow strPd];
    strRow(:, end) = '|';
    % strPd = zeros(1, size(strRow, 2));
    % strPd(:) = '-';
    % strRow = [strRow; strPd];
    % cellArr{r} = strRow;
    cellArr{r} = char([strRow; zeros(1, size(strRow, 2)) + 45]);
end
strTable = vertcat(cellArr{:});
strPd = zeros(1, size(strTable, 2));
strPd(:) = '-';
strTable = [strPd; strTable];
if logLines
    strTable = num2cell(strTable);
    strTable = arrayfun(@(r)(horzcat(strTable{r, :})), 1:size(strTable, 1), 'uni', false)';
    strTable = strjoin(strTable, '\n');
end
if nargout == 0
    disp(strTable)
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