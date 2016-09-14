% CALLED BY:
%       getRubric.m
%       getStudentSubmissions.m
function functionHandles = getFunctionHandles(location)

    functions = getFunctions(location);
    currentDirectory = cd;
    cd(location);
    functionHandles = struct();
    for ndx = 1:length(functions);
        functionHandles.(functions{ndx}) = str2func(functions{ndx});
    end
    cd(currentDirectory);

end