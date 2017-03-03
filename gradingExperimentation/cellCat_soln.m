function str = cellCat_soln(ca)
str = '';
for i = 1:numel(ca) % accounts for arrays even though guaranteed vector
    if iscell(ca{i})
        str = [str, cellCat_soln(ca{i})];
    elseif ischar(ca{i})
        str = [str, ca{i}(:)']; % accounts for character arrays even though guaranteed vectors
    end
end
end