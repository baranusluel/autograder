%% exportCheaters: Export cheating students and their data
%
% exportCheaters is used to export all the cheaters to a nice,
% human-readable format.
%
% exportCheaters(S, C, P) will export the students in S with scores C to
% path P. If P does not exist, it will be created. An assumed threshold of
% 0.95 will be used
%
% exportCheaters(S, C, P, T) will do the same as above, but use the
% threshold T, where T lies between 0 and 1, inclusive.
%
%%% Remarks
%
%
%%% Exceptions
%
% This function will never throw an exception
function exportCheaters(students, problems, scores, path, threshold)
    if nargin < 4
        threshold = 0.95;
    end
    if ~isfolder(path)
        mkdir(path);
    end
    
    orig = cd(path);
    
    % for each student, get worker
    for s = numel(students):-1:1
        sPath = [pwd filesep students(s).name];
        % for each problem (except ABCs), if we have cheaters that meet
        % threshold, engage.
        
        
    end
    cd(orig);
    
end

function exportStudent(studentPath, problems, names, paths)
    % for each problem in problems, export the files
    mkdir(studentPath);
    orig = cd(studentPath);
    for p = 1:numel(problems)
        mkdir(problems{p});
        cd(problems{p});
        % for each file, copy it with name of student
        for f = 1:numel(paths{p})
            copyfile(paths{p}{f}, names{p}{f});
        end
        cd('..');
    end
    cd(orig);
end