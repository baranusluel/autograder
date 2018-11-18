%% autograder: Main responsibility for running the autograder
%
% autograder is called by the Autograder class - it is responsible for running the
% actual steps needed to grade students automatically.
%
%%% Remarks
%
% Main is the entry point for the Autograder. Main will handle any
% exceptions, and will always clean up after itself - the user's folder
% will not be changed!
%
% Documentation is available. Please go the the autograder's website, at
%
% <https://github.gatech.edu/pages/CS1371/autograder Documentation>
%
% This function should not be called directly, though its help manual
% may be useful
%
%%% Exceptions
%
% This is guaranteed to never throw an exception; instead, exceptions are reported through the GUI
%
%%% Unit Tests
%
% Unfortunately, there are no "Unit Tests" for this function
%
function autograder(app)
    % Implementation Notes:
    %
    % Main() will provide initial checking, and set up all necessary
    % processes and environment settings:
    %
    % *Startup*
    %
    % * Start the Parallel Pool
    % * Create the SENTINEL file; assign to the File class
    % * Apply the factory default path, and remove the user's MATLAB path
    % * Create a temporary folder, and copy the student and solution files
    % there. If they're zips, deal with accordingly
    % * Ensure figures don't become visible
    %
    % *Cleanup*
    %
    % * Shut down the parallel pool
    % * Close and delete the SENTINEL file
    % * Reapply the path of the original user
    % * Copy any necessary data back from temp folder (?)
    % * Reapply user's settings for figures

    % Parse inputs

    % Show the app. After it's done (uiresume), we'll extract necessary
    % info and then change to updating. If it's cancelled, we'll exit
    % gracefully.

    %%% Constants
    % add to path
    % The number of students to wait between before redrawing the histogram
    DRAW_INTERVAL = 10;
    % The label for inspecting students
    INSPECT_LABEL = 'Inspect the Students';
    % The label for continuing on
    CONTINUE_LABEL = 'Continue';

    % actually grade if ANY of the following is set:
    %   * Upload Grades -> canvas
    %   * Uplaod Feedback -> canvas
    %   * Email Feedback
    %   * Store Output Locally
    shouldGrade = app.UploadGradesToCanvas.Value ...
        || app.UploadFeedbackToCanvas.Value ...
        || app.EmailFeedback.Value ...
        || ~isempty(app.localOutputPath);

    settings.userPath = {path(), userpath()};
    % change name of overloaded files
    overloaders = fileparts(mfilename('fullpath'));
    files = dir([overloaders filesep 'overloader' filesep '*.txt']);
    for f = 1:numel(files)
        [~, name, ~] = fileparts(files(f).name);
        movefile([files(f).folder filesep files(f).name], ...
            [files(f).folder filesep name '.m']);
    end
    addpath(genpath(fileparts(fileparts(mfilename('fullpath')))));
    clear Student;
    Student.resetPath();
    javaaddpath([fileparts(fileparts(mfilename('fullpath'))) filesep 'networking' filesep 'StudentDownloader.jar']);

    % start up application
    settings.app = app;
    try
        if app.isDebug
            logger = Logger(pwd);
        else
            logger = Logger();
        end
    catch e
        if debugger(app, 'Logger initialization Failed')
            keyboard;
        else
            alert(app, e);
            return;
        end
    end
    settings.logger = logger;
    % Start up parallel pool
    progress = uiprogressdlg(app.UIFigure, 'Title', 'Autograder Progress', ...
        'Message', 'Starting Parallel Pool', 'Cancelable', 'on', ...
        'ShowPercentage', true, 'Indeterminate', 'on');
    Logger.log('Starting up parallel pool');
    settings.progress = progress;
    evalc('gcp');
    app.UIFigure.Visible = 'off';
    app.UIFigure.Visible = 'on';
    if progress.CancelRequested
        return;
    end
    progress.Message = 'Loading Dictionaries & Setting up Environment';
    Logger.log('Setting up new directory');
    % Get temporary directory
    settings.workingDir = [tempname filesep];
    mkdir(settings.workingDir);
    settings.userDir = cd(settings.workingDir);
    % Create SENTINEL file
    Logger.log('Creating Sentinel');
    sentinel = [tempname '.lock'];
    fid = fopen(sentinel, 'wt');
    fwrite(fid, 'SENTINEL');
    fclose(fid);
    File.SENTINEL(sentinel);
    Logger.log('Loading Dictionary');
    worker = [parfevalOnAll(@File.SENTINEL, 0, sentinel), ...
        parfevalOnAll(@gradeComments, 0)];
    % Set on cleanup
    cleaner = onCleanup(@() cleanup(settings));
    worker.wait();

    % close all files and plots
    wait(parfevalOnAll(@()(fclose('all')), 0));
    wait(parfevalOnAll(@()(delete(findall(0, 'type', 'figure'))), 0));
    % For solution, what are we doing?
    % if downloading, call, otherwise, unzip
    mkdir('Solutions');
    if app.SolutionChoice.Value == 1
        % downloading
        try
            Logger.log('Exchanging refresh token for access token');
            token = refresh2access(app.driveToken, ...
                app.googleClientId, app.googleClientSecret);
            Logger.log('Starting download of solution archive from Google Drive');
            downloadFromDrive(app.driveFolderId, token, ...
                [pwd filesep 'Solutions'], app.driveKey, progress);
        catch e
            if debugger(app, 'Failed to download solution archive from Google Drive')
                keyboard;
            else
                alert(app, e);
                return;
            end
        end
    else
        % unzip the archive
        progress.Indeterminate = 'on';
        progress.Message = 'Unzipping Rubric';
        Logger.log('Unzipping Solution Archive');
        try
            unzipArchive(app.solutionArchivePath, [pwd filesep 'Solutions']);
        catch e
            if debugger(app, 'Failed to unzip the solution archive')
                keyboard;
            else
                alert(app, e);
                return;
            end
        end
    end

    % Generate solutions
    try
        orig = cd('Solutions');
        Logger.log('Generating Solutions');
        solutions = generateSolutions(app.isResubmission, progress);
        cd(orig);
    catch e
        % Display to user that we failed
        if debugger(app, 'Failed to generate solutions')
            keyboard;
        else
            cd(orig);
            alert(app, e);
            return;
        end
    end
    if app.isResubmission
        serverBasePath = sprintf('https://cs1371.gatech.edu/homework/homework%02d/original/', app.homeworkNum);
    else
        serverBasePath = sprintf('https://cs1371.gatech.edu/homework/homework%02d/resubmission/', app.homeworkNum);
    end
    setupRecs(solutions, serverBasePath);
    wait(parfevalOnAll(@setupRecs, 0, solutions, serverBasePath));
    % For submission, what are we doing?
    % if downloading, call, otherwise, unzip
    mkdir('Students');
    if app.HomeworkChoice.Value == 1
        % downloading. We should create new Students folder and download
        % there.
        try
            if isempty(app.selectedStudents)
                app.selectedStudents = getCanvasStudents(app.canvasCourseId, app.canvasHomeworkId, ...
                    app.canvasToken, progress);
            end
            downloadFromCanvas(app.selectedStudents, [pwd filesep 'Students'], progress);
        catch e
            % alert in some way and return
            if debugger(app, 'Failed to download student submissions from Canvas')
                keyboard;
            else
                alert(app, e);
                return;
            end
        end
    else
        progress.Message = 'Unzipping Student Archive';
        progress.Indeterminate = 'on';
        % unzip the archive
        try
            canvas2autograder(app.homeworkArchivePath, app.homeworkGradebookPath, [pwd filesep 'Students'], progress);
            if ~isempty(app.selectedStudents)
                % delete folders not listed
                flds = dir([pwd filesep 'Students']);
                flds(~[flds.isdir]) = [];
                flds(strncmp('.', {flds.name}, 1)) = [];
                flds = flds(~contains({flds.name}, {app.selectedStudents.login_id}));
                for f = 1:numel(flds)
                    [~] = rmdir([flds(f).folder filesep flds(f).name], 's');
                end
            end
        catch e
            if debugger(app, 'Failed to unzip the Student Submission Archive')
                keyboard;
            else
                alert(app, e);
                return;
            end
        end
    end

    % We have downloaded students. If the user wants to edit files, give
    % them a chance to do so.
    % The question is, should they be able to use MATLAB to do it, or
    % should they do it via File Explorer/Finder/etc.
    %
    % We won't give some kind of UI to do it. This would entail much more
    % internal complexity.
    %
    % For now, break into keyboard, and give the standard "Continue"
    % message.
    if app.isEditingSubmissions
        safeDir = cd('Students');
        % Break. Before we do, print to screen what to do.
        fprintf(1, strjoin({'You have elected to edit student submissions. ', ...
            'To view or edit files, use the "current folder". ', ...
            'Students are organized by their GT Username; i.e., gburdell3, ', ...
            'so to edit their submission, just open their folder. ', ...
            'Once you are done editing, click "Continue" to proceed with grading\n'}, newline));
        filebrowser;
        keyboard;
        cd(safeDir);
    end

    % Generate students
    try
        Logger.log('Generating Students');
        students = generateStudents([pwd filesep 'Students'], progress);
    catch e
        if debugger(app, 'Failed to generate students from submissions')
            keyboard;
        else
            alert(app, e);
            return;
        end
    end

    % Create Plot
    setupRecs(solutions, serverBasePath);
    if shouldGrade
        plotter = uifigure('Name', 'Grade Report', 'Visible', 'off');
        ax = uiaxes(plotter);
        ax.Position = [10 10 550 400]; % as suggested in example on MATLAB ref page
        title(ax, 'Histogram of Student Grades');
        xlabel(ax, 'Grade');
        ylabel(ax, 'Number of Students');
        h = histogram(ax);
        totalPoints = [solutions.testCases];
        totalPoints = sum([totalPoints.points]);
        h.BinEdges = 0:10:max([totalPoints (ceil(totalPoints / 10) * 10)]);
        h.BinLimits = [0 h.BinEdges(end)];
        h.Data = zeros(1, numel(students)) - 1;
        ax.YLim = [0 numel(students)];
        ax.XLim = [0 h.BinLimits(end)];

        plotter.Visible = 'on';

        drawnow;

        progress.Indeterminate = 'off';
        progress.Value = 0;
        progress.Message = 'Student Grading Progress';
        Logger.log('Starting student assessment');
        setupRecs(solutions, serverBasePath);
        checker = java.io.File('/');
        for s = 1:numel(students)
            student = students(s);
            progress.Message = sprintf('Assessing Student %s', student.name);
            if checker.getFreeSpace() < 5e9
                % pause - we are taking up too much space!
                fprintf(2, 'You are low on disk space (%0.2f GB remaining). Please clear more space, then continue.\n', ...
                    (checker.getFreeSpace() / (1024 ^ 3)));
                keyboard;
            end
            try
                Logger.log(sprintf('Assessing Student %s (%s)', student.name, student.id));
                student.assess();
            catch e
                if debugger(app, 'Failed to assess student')
                    keyboard;
                else
                    alert(e);
                    return;
                end
            end
            progress.Value = s/numel(students);
            h.Data(s) = student.grade;
            if mod(s, DRAW_INTERVAL) == 0
                drawnow;
            end
            if progress.CancelRequested
                e = MException('AUTOGRADER:userCancelled', 'User Cancelled Operation');
                alert(app, e);
                return;
            end
        end

        drawnow;

        % Before we do anything else, examine the grades. There should be a
        % good distribution - if not, ask the user

        % What exactly "is" a good distribution? No idea. For now, we will flag
        % if:
        %   Nobody got 100
        %   Nobody got > 90
        %   Nobody got a 0
        %   All values are either 0 or 100
        %   All values are the same
        if ~any(h.Data > (.9 * totalPoints))
            msg = 'No student scored above 90%.';
        elseif ~any(h.Data == totalPoints)
            msg = 'No student scored a 100%.';
        elseif ~any(h.Data == 0)
            msg = sprintf('Every student scored above 0%%; the minimum was %0.2f%%.', ...
                min(h.Data));
        elseif all(h.Data == totalPoints | h.Data == 0)
            msg = 'All students scored either a 0% or a 100%';
        else
            % we have passed... for now.
            msg = '';
        end
        % if empty, see if we should debug first
        if ~isempty(msg) && isempty(app.delay)
            msg = [msg ' Would you like to inspect the students, or continue?'];
            debugger(app, msg);
            selection = uiconfirm(app.UIFigure, msg, 'Autograder', ...
                'Options', {INSPECT_LABEL, CONTINUE_LABEL}, ...
                'DefaultOption', 1, 'Icon', 'warning', 'CancelOption', 2);
            if strcmp(selection, INSPECT_LABEL)
                stop = true;
            else
                stop = false;
            end
        else
            stop = false;
        end
        if stop
            keyboard;
        end
    end
    % respond to caught errors
    caughtErrors = struct('task', '', 'exception', []);
    caughtErrors = caughtErrors(false);

    % If the user requested uploading, do it

    if app.UploadGradesToCanvas.Value
        try
            Logger.log('Starting upload of student grades');
            uploadGrades(students, app.canvasCourseId, ...
                app.canvasHomeworkId, app.canvasToken, progress);
        catch e
            if debugger(app, 'Failed to upload grades to Canvas')
                keyboard;
            end
            caughtErrors(end+1).task = 'Uploading student grades to Canvas';
            caughtErrors(end).exception = e;
        end
    end
    if app.UploadFeedbackToCanvas.Value
        try
            Logger.log('Starting upload of student feedback');
            uploadFeedback(students, app.canvasCourseId, ...
                app.canvasHomeworkId, app.canvasToken, progress);
        catch e
            if debugger(app, 'Failed to upload feedback to Canvas')
                keyboard;
            end
            caughtErrors(end+1).task = 'Uploading student feedback to Canvas';
            caughtErrors(end).exception = e;
        end
    end
    if app.UploadToServer.Value
        Logger.log('Starting upload of homework files');
        if app.isResubmission
            name = sprintf('homework%02d_resubmission', app.homeworkNum);
        else
            name = sprintf('homework%02d', app.homeworkNum);
        end
        try
            uploadToServer(app.canvasToken, name, progress, Student.resources.supportingFiles);
        catch e
            if debugger(app, 'Failed to upload files to server')
                keyboard;
            end
            caughtErrors(end+1).task = 'Uploading Files to the Server';
            caughtErrors(end).exception = e;
        end
    end
    if app.EmailFeedback.Value
        Logger.log('Emailing Feedback');
        progress.Message = 'Emailing Feedback';
        progress.Indeterminate = 'on';
        try
            emailFeedback(app.notifierToken, app.driveKey, ...
                app.googleClientId, app.googleClientSecret, ...
                students, strjoin(app.emailMessage, newline), progress);
        catch e
            if debugger(app, 'Failed to email feedback files')
                keyboard;
            end
            caughtErrors(end+1).task = 'Emailing student feedback';
            caughtErrors(end).exception = e;
        end
    end
    if app.PostToCanvas.Value
        Logger.log('Posting to Canvas');
        progress.Message = 'Posting to Canvas';
        progress.Indeterminate = 'on';
        try
            postToCanvas(app.canvasCourseId, app.canvasToken, app.canvasTitle, ...
                app.canvasHtml);
        catch e
            if debugger(app, 'Failed to post announcement')
                keyboard;
            end
            caughtErrors(end+1).task = 'Posting announcement to Canvas';
            caughtErrors(end).exception = e;
        end
    end
    % if they want the output, do it
    if ~isempty(app.localOutputPath)
        try
            progress.Indeterminate = 'on';
            progress.Message = 'Saving Output';
            % save canvas info in path
            % copy csv, then change accordingly
            % move student folders to output path
            Logger.log('Starting copy of local information');
            % Create local grades
            names = {students.name};
            ids = {students.id};
            canvasIds = {students.canvasId};
            grades = arrayfun(@num2str, [students.grade], 'uni', false);
            raw = [names; ids; canvasIds; grades]';
            raw = join([{'Name', 'GT Username', 'ID', 'Grade'}; raw], '", "');
            raw = unicode2native(['"', strjoin(raw, '"\n"'), '"'], 'UTF-8');
            fid = fopen(fullfile(app.localOutputPath, 'grades.csv'), 'wt', 'native', 'UTF-8');
            fwrite(fid, raw);
            fclose(fid);
            copyfile(settings.workingDir, app.localOutputPath);
        catch e
            if debugger(app, 'Failed to create local output')
                keyboard;
            end
            caughtErrors(end+1).task = 'Creating local output';
            caughtErrors(end).exception = e;
        end
    end

    if app.AnalyzeForCheating.Value
        try
            progress.Message = 'Reading Student Submissions';
            progress.Indeterminate = 'on';
            progress.Cancelable = 'off';

            txts = cell(1, numel(students));
            for s = numel(students):-1:1
                workers(s) = parfeval(@getText, 1, students(s).problemPaths);
            end

            progress.Value = 0;
            progress.Indeterminate = 'off';
            progress.Cancelable = 'on';
            num = numel(workers);

            while ~all([workers.Read])
                if progress.CancelRequested
                    cancel(workers);
                    return;
                end
                [idx, txt] = workers.fetchNext();
                txts{idx} = txt;
                progress.Value = min([progress.Value + 1/num, 1]);
            end

            wait(parfevalOnAll(@getScores, 0, [], txts));
            progress.Value = 0;
            progress.Message = 'Analyzing Submissions... This will take a while';
            % for each student, we need to compare to all other students.
            scores = cell(1, numel(students));
            for s1 = numel(students):-1:1
                workers(s1) = parfeval(@getScores, 1, s1);
            end

            num = numel(workers);

            while ~all([workers.Read])
                [idx, score] = workers.fetchNext();
                scores{idx} = score;
                progress.Value = min([progress.Value + 1/num, 1]);
                if progress.CancelRequested
                    cancel(workers);
                    return;
                end
            end

            % generate Report
            progress.Message = 'Generating Report';
            progress.Indeterminate = 'on';
            progress.Cancelable = 'off';

            % move resources
            recSource = [fileparts(mfilename('fullpath')) filesep 'resources'];
            mkdir('resources');
            copyfile(recSource, [pwd filesep 'resources']);
            cheat = CheatDetector(students, solutions, scores, settings.workingDir);
            % if user has local output, go ahead and export
            if ~isempty(app.localCheatPath)
                if ~isfolder(app.localCheatPath)
                    mkdir(app.localCheatPath)
                end
                exportCheaters(cheat.students, cheat.cheaterStudents, cheat.cheaterScores, {cheat.problems.name}, app.localCheatPath, progress);
                if ~isempty(app.slackRecipients)
                    % create ZIP archive to ship
                    zipPath = tempname;
                    mkdir(zipPath);

                    if app.isResubmission
                        name = sprintf('cheaters_%02d_resub.zip', app.homeworkNum);
                    else
                        name = sprintf('cheaters_%02d.zip', app.homeworkNum);
                    end

                    zip(fullfile(zipPath, name), app.localCheatPath);
                    slackMessenger(app.slackToken, ...
                        {app.slackRecipients.id}, ...
                        'Cheat Detection finished; attached is the summary', ...
                        fullfile(zipPath, name));
                    rmdir(zipPath, 's');
                end
            end
        catch e
            if debugger(app, 'Failed to analyze submissions for cheating')
                keyboard;
            end
            caughtErrors(end+1).task = 'Analyzing submissions for cheating';
            caughtErrors(end).exception = e;
        end
    end
    % Notify
    progress.Indeterminate = 'on';
    progress.Message = 'Sending Notifications';
    Logger.log('Start Sending of Notifications');
    try
        % if graded, use messenger; otherwise, just send that we finished
        if shouldGrade
            messenger(app, students);
        else
            if ~isempty(app.email)
                emailMessenger(app.email, 'Autograder Finished', ...
                    'Autograder Finished!', ...
                    app.notifierToken, app.googleClientId, app.googleClientSecret, ...
                    app.driveKey);
            end
            if ~isempty(app.phoneNumber)
                textMessenger(app.phoneNumber, 'Autograder Finished... See your computer for more information', ...
                    app.twilioSid, app.twilioToken, app.twilioOrigin);
            end
            if ~isempty(app.slackRecipients)
                slackMessenger(app.slackToken, {app.slackRecipients.id}, 'Autograder Finished... See your computer for more information');
            end
            desktopMessenger('Autograder Finished... See MATLAB for more information');
        end
    catch
        if debugger(app, 'Error Sending Notifications')
            keyboard;
        end
    end

    if ~isempty(caughtErrors) && ~isempty(app.delay)
        DEATH_MESSAGE = ['We successfully graded student submissions. However, ', ...
            'we ran into some problems during post-grading tasks. These problems ', ...
            'have been detailed below, and the Autograder is in BREAK mode so ', ...
            'that you can inspect the state. To look at a specific exception, ', ...
            'use that error''s list order as an index for `caughtErrors`.', ...
            newline, ...
            'Errors:', ...
            newline, ...
            '%s'];
        tasks = {caughtErrors.task};
        orders = arrayfun(@num2str, 1:numel(tasks), 'uni', false);
        msg = strjoin(join([orders; tasks]', '. '), newline);

        message = sprintf(DEATH_MESSAGE, msg);
        if ~isempty(app.slackRecipients)
            slackMessenger(app.slackToken, {app.slackRecipients.id}, message);
        end
        keyboard;

    end
end

function alert(app, e)
    uialert(app.UIFigure, sprintf('Exception %s: "%s" encountered', ...
        e.identifier, e.message), 'Autograder Error');
end

function cleanup(settings)
    if isvalid(settings.progress)
        settings.progress.Message = 'Cleaning Up';
        settings.progress.Indeterminate = 'on';
        settings.progress.Cancelable = 'off';
    end
    javarmpath([fileparts(fileparts(mfilename('fullpath'))) filesep 'networking' filesep 'StudentDownloader.jar']);
    % Cleanup
    Logger.log('Deleting Sentinel file');
    delete(File.SENTINEL);
    % Restore user's path
    Logger.log('Restoring User Path settings');
    path(settings.userPath{1}, '');
    if ~isempty(settings.userPath{2})
        userpath(settings.userPath{2});
    end
    % change name of overloaded files
    overloaders = fileparts(mfilename('fullpath'));
    files = dir([overloaders filesep 'overloader' filesep '*.m']);
    for f = 1:numel(files)
        [~, name, ~] = fileparts(files(f).name);
        movefile([files(f).folder filesep files(f).name], ...
            [files(f).folder filesep name '.txt']);
    end

    % cd to user's dir
    cd(settings.userDir);
    Logger.log('Removing Working Directory');
    % Delete our working directory - UNLESS cheat detection is on!
    [~] = rmdir(settings.workingDir, 's');
    if isvalid(settings.progress)
        close(settings.progress);
    end
    settings.logger.delete();
end

function shouldDebug = debugger(app, msg)
    EMAIL_MESSAGE_FORMAT = 'Hello,\n\nIt appears the autograder failed to finish. Here''s the error message:\n\n%s\n\nBest Regards,\n~The CS 1371 Technology Team';

    shouldDebug = app.isDebug && isempty(app.delay);
    % notify
    try
        if ~isempty(app.email)
            emailMessenger(app.email, 'Autograder Failure', ...
                sprintf(EMAIL_MESSAGE_FORMAT, msg), ...
                app.notifierToken, app.googleClientId, app.googleClientSecret, ...
                app.driveKey);
        end
        if ~isempty(app.phoneNumber)
            textMessenger(app.phoneNumber, 'Autograder Failed... See your computer for more information', ...
                app.twilioSid, app.twilioToken, app.twilioOrigin);
        end
        if ~isempty(app.slackRecipients)
            slackMessenger(app.slackToken, {app.slackRecipients.id}, 'Autograder Failed... See your computer for more information');
        end
        desktopMessenger('Autograder Failed... See MATLAB for more information');
    catch
    end
    beep;
end