D = dir;
D(~[D.isdir]) = [];
D(strcmp({D.name}, '.') | strcmp({D.name}, '..')) = [];
for d = 1:numel(D)
    d = D(d);
    name = d.name;
    cd([name '\Submission attachment(s)']);
    delete('*.mat');
    cd ..\..
end