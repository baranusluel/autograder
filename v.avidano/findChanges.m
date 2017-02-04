function changes = findChanges(old,new)
changes = [];
for i = 1:length(new)
    matches = false(1,length(old));
    for j = 1:length(old)
        matches(j) = isequal(old(j),new(i));
    end
    if ~any(matches)
        changes = [changes new(i)];
    end
end
end