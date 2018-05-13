%% exportCheaters: Export cheating students and their data
%
% exportCheaters is used to export all the cheaters to a nice,
% human-readable format.
%
% exportCheaters(S, C, P, D, G) will use the student array S, cheater array
% C, problem name array P, directory path D, and progress bar G to export
% cheater code files to their respective folders.
%
%%% Remarks
%
%
%%% Exceptions
%
% This function will never throw an exception
function exportCheaters(students, cheaters, problems, path, progress)
    if ~isfolder(path)
        mkdir(path);
    end
    
    orig = cd(path);
    progress.Message = 'Preparing to export';
    progress.Value = 0;
    % for each student, get worker
    for s = numel(students):-1:1
        sPath = [pwd filesep students(s).id];
        % construct names & paths
        for p = numel(problems):-1:1
            if isempty(cheaters{s}{p})
                names{p} = {};
                paths{p} = {};
            else
                names{p} = [{cheaters{s}{p}.id}, {students(s).id}];
                paths{p} = [cellfun(@(pSet)(pSet(p)), {cheaters{s}{p}.problemPaths}), students(s).problemPaths(p)];
            end
        end
        if ~all(cellfun(@isempty, names))
            workers(s) = parfeval(@exportStudent, 0, sPath, problems, names, paths);
        end
        progress.Value = min([progress.Value + 1/numel(students), 1]);
    end
    
    workers([workers.ID] == -1) = [];
    progress.Message = 'Exporting Student Code';
    progress.Value = 0;
    while ~all([workers.Read])
        workers.fetchNext();
        progress.Value = min([progress.Value + 1/numel(workers), 1]);
    end
    cd(orig);
    
end

function exportStudent(studentPath, problems, names, paths)
    % for each problem in problems, export the files
    mkdir(studentPath);
    orig = cd(studentPath);
    for p = 1:numel(problems)
        if ~isempty(names{p})
            mkdir(problems{p});
            cd(problems{p});
            % for each file, copy it with name of student
            for f = 1:numel(paths{p})
                copyfile(paths{p}{f}, [names{p}{f} '.m']);
            end
            cd('..');
        end
    end
    cd(orig);
end