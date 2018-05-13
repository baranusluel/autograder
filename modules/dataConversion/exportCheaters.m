%% exportCheaters: Export cheating students and their data
%
% exportCheaters is used to export all the cheaters to a nice,
% human-readable format.
%
% exportCheaters(S, C, R, P, D, G) will use the student array S, cheater array
% C, score array R, problem name array P, directory path D, and progress bar G to export
% cheater code files to their respective folders.
%
%%% Remarks
%
%
%%% Exceptions
%
% This function will never throw an exception
function exportCheaters(students, cheaters, scores, problems, path, progress)
    if ~isfolder(path)
        mkdir(path);
    end
    
    orig = cd(path);
    progress.Message = 'Preparing to export';
    progress.Value = 0;
    % for each student, get worker
    mask = false(1, numel(students));
    for s = numel(students):-1:1
        sPath = [pwd filesep students(s).id];
        % construct names & paths
        for p = numel(problems):-1:1
            if isempty(cheaters{s}{p})
                names{p} = {};
                paths{p} = {};
                cScores{p} = {};
            else
                names{p} = [{cheaters{s}{p}.id}, {students(s).id}];
                paths{p} = [cellfun(@(pSet)(pSet(p)), {cheaters{s}{p}.problemPaths}), students(s).problemPaths(p)];
                cScores{p} = scores{s}{p};
            end
        end
        if ~all(cellfun(@isempty, names))
            mask(s) = true;
            workers(s) = parfeval(@exportStudent, 0, sPath, problems, names, paths, cScores);
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
    
    suspects = students(mask);
    links = cell(size(suspects));
    for s = 1:numel(suspects)
        links{s} = {'<div class="row"><div class="col-12 text-center">', ['<a href="./' suspects(s).id '/details.html">'], ...
            '<code>', suspects(s).id, '</code>', '</a>', '</div></div>'};
    end
    HEADER = {'<!DOCTYPE html>', '<html>', '<head>', ...
            '<meta charset="utf-8">', ...
            '<meta name="viewport" content="width=device-width, initial-scale=1">', ...
            '<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.1.0/css/bootstrap.min.css">', ...
            '<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>', ...
            '<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.0/umd/popper.min.js"></script>', ...
            '<script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.1.0/js/bootstrap.min.js"></script>', ...
            '<title>', 'Cheating Analysis Details', '</title>', ...
            '</head>', '<body>', '<div class="container">', '<h1 class="text-center display-1">', ...
            'Cheating Analysis', '</h1>', '<div class="container-fluid">'};
    markup = [HEADER links{:} {'</div></div></body></html>'}];
    fid = fopen('summary.html', 'wt');
    fwrite(fid, strjoin(markup, newline));
    fclose(fid);
    cd(orig);
end

function exportStudent(studentPath, problems, names, paths, scores)
    % for each problem in problems, export the files
    [~, myName, ~] = fileparts(studentPath);
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
            names{p}(strcmp(names{p}, myName)) = [];
            cd('..');
        end
    end
    % create HTML file
    writeHtml(problems, names, scores, myName);
    
    cd(orig);
end

function writeHtml(problems, names, scores, myName)
    % for each problem, capture it
    problemMarkup = cell(size(problems));
    for p = 1:numel(problems)
        if ~isempty(names{p})
            list = cell(size(names{p}));
            [~, inds] = sort(scores{p});
            inds = inds(end:-1:1);
            scores{p} = scores{p}(inds);
            names{p} = names{p}(inds);
            for n = 1:numel(names{p})
                if scores{p}(n) == Inf
                    list{n} = {'<li class="cheater"><code>', ...
                        '<a href="../' names{p}{n} '/details.html">', ...
                        [names{p}{n} ' - Exact Match'], '</a></code></li>'};
                else
                    list{n} = {'<li class="cheater">', '<a href="../' names{p}{n} '/details.html">', ...
                        [names{p}{n} ' - ' sprintf('%0.2f', 100*scores{p}(n)) '% Match'], '</a></li>'};
                end
            end
            problemMarkup{p} = [{'<hr />', '<div class="problem-header row"><div class="col-12">', ...
                ['<h2><pre>' problems{p} '</pre></h2></div></div><div class="problem row"><div class="col-12">'], '<ul>'}, list{:}, {'</ul>', '</div></div>'}];
        end
    end
    if ~isempty(myName)
        problemMarkup = [problemMarkup{:}];
        HEADER = {'<!DOCTYPE html>', '<html lang="en">', '<head>', ...
            '<meta charset="utf-8">', ...
            '<meta name="viewport" content="width=device-width, initial-scale=1">', ...
            '<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.1.0/css/bootstrap.min.css">', ...
            '<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>', ...
            '<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.0/umd/popper.min.js"></script>', ...
            '<script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.1.0/js/bootstrap.min.js"></script>', ...
            '<title>', ['Cheating Analysis Details for ' myName], '</title>', ...
            '<style>', 'code a {color: #e83e8c; font-size: 100%;}', '</style>', '</head>', '<body>', '<div class="container">', '<h1 class="display-3 text-center">', ...
            ['Cheating Analysis for ' myName], '</h1>'};
        markup = [HEADER problemMarkup {'</div>', '</body>', '</html>'}];
        fid = fopen('details.html', 'wt');
        fwrite(fid, strjoin(markup, newline));
        fclose(fid);
    end
end