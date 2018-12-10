%% Autograder: Main UI
%
% The Autograder functions as the main User Interface for the autograder.
classdef Autograder < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                matlab.ui.Figure
        SettingsMenu            matlab.ui.container.Menu
        SaveConfiguration       matlab.ui.container.Menu
        LoadConfigurationMenu   matlab.ui.container.Menu
        Exit                    matlab.ui.container.Menu
        Notifications           matlab.ui.container.Menu
        Schedule                matlab.ui.container.Menu
        Update                  matlab.ui.container.Menu
        PostProcess             matlab.ui.container.Menu
        AuthorizationsMenu      matlab.ui.container.Menu
        Canvas                  matlab.ui.container.Menu
        Drive                   matlab.ui.container.Menu
        Github                  matlab.ui.container.Menu
        AcknowledgementsMenu    matlab.ui.container.Menu
        LicenseMenu             matlab.ui.container.Menu
        DocumentationMenu       matlab.ui.container.Menu
        HomeworkPanel           matlab.ui.container.Panel
        IsResubmission          matlab.ui.control.CheckBox
        HomeworkNumberLabel     matlab.ui.control.Label
        HomeworkNumber          matlab.ui.control.NumericEditField
        HomeworkChoiceLabel     matlab.ui.control.Label
        HomeworkChoice          matlab.ui.control.DropDown
        HomeworkBrowser         matlab.ui.control.Button
        CanvasBrowser           matlab.ui.control.Button
        ButtonGroup             matlab.ui.container.ButtonGroup
        AllButton               matlab.ui.control.RadioButton
        SelectButton            matlab.ui.control.RadioButton
        GradeallstudentsLabel   matlab.ui.control.Label
        IsLeaky                 matlab.ui.control.CheckBox
        SolutionPanel           matlab.ui.container.Panel
        SolutionChoiceLabel     matlab.ui.control.Label
        SolutionChoice          matlab.ui.control.DropDown
        SolutionBrowser         matlab.ui.control.Button
        DriveBrowser            matlab.ui.control.Button
        OutputPanel             matlab.ui.container.Panel
        UploadFeedbackToCanvas  matlab.ui.control.CheckBox
        UploadToServer          matlab.ui.control.CheckBox
        StoreLocally            matlab.ui.control.CheckBox
        EditSubmissions         matlab.ui.control.CheckBox
        PostToCanvas            matlab.ui.control.CheckBox
        OutputBrowser           matlab.ui.control.Button
        AnalyzeForCheating      matlab.ui.control.CheckBox
        PostOptions             matlab.ui.control.Button
        EmailFeedback           matlab.ui.control.CheckBox
        EmailFeedbackOptions    matlab.ui.control.Button
        UploadGradesToCanvas    matlab.ui.control.CheckBox
        Go                      matlab.ui.control.Button
        Cancel                  matlab.ui.control.Button
    end
    
    properties (Constant)
        ORIGINAL_SIZE = [100 100 640 581];
    end


    properties (Access = public)
        % Credentials
        canvasToken char
        driveToken char
        driveKey char
        
        % Homework Information
        homeworkArchivePath char
        homeworkGradebookPath char
        canvasCourseId char
        canvasHomeworkId char
        homeworkNum double
        isResubmission logical
        postProcessPath char = '';
        
        % Student Information
        selectedStudents
        isEditingSubmissions logical = false;

        % Solution Information
        solutionArchivePath char
        driveFolderId char
        
        % API Information
        googleClientId;
        googleClientSecret;
        githubToken;
        slackToken;
        twilioToken;
        twilioSid;
        twilioOrigin;
        notifierToken;
        
        % Options
        localOutputPath char;
        localCheatPath char;
        homeworkName char;
        delay timer;
        
        % Notifications
        slackRecipients struct;
        email char;
        phoneNumber char;
        canvasTitle char;
        canvasMessage = '';
        canvasHtml char;
        canvasMode double = 1;
        emailMessage = {''};
        
        % Debugging
        settingsPath = [fileparts(mfilename('fullpath')) filesep 'settings.autograde'];
        settingsFormat = '%s: %s\n';
    end
    methods (Access = private)
        % Get a ZIP archive
        function results = getZip(app, prompt)
            [name, path] = uigetfile({'*.zip', 'ZIP Archives (*.zip)'}, prompt);
            if isequal(name, 0)
                results = false;
            else
                results = [path name];
            end
            app.UIFigure.Visible = 'off';
            app.UIFigure.Visible = 'on';
        end
        % Get a file
        function results = getFile(app, prompt, filter)
            [name, path] = uigetfile(filter, prompt);
            if isequal(name, 0)
                results = false;
            else
                results = [path name];
            end
            app.UIFigure.Visible = 'off';
            app.UIFigure.Visible = 'on';
        end
        % Get a folder
        function results = getFolder(app, prompt)
            path = uigetdir(userpath(), prompt);
            if isequal(path, 0)
                results = false;
            else
                results = path;
            end
            app.UIFigure.Visible = 'off';
            app.UIFigure.Visible = 'on';
        end
        
        
        
        function cleaner(~, safeDir, workDir)
            cd(safeDir);
            rmdir(workDir, 's');
        end
    end

    methods (Access = public)
        % Save a specific preference
        function savePreferences(app, path)
            if nargin == 2
                fid = fopen(path, 'wt');
            else
                fid = fopen(app.settingsPath, 'wt');
            end
            if fid == -1
                throw(MException('AUTOGRADER:settings:fileIO', ...
                    'Unable to open file for writing'));
            end
            % for each preference, print name: value. SPACE IS REQUIRED
            % drive token
            fprintf(fid, app.settingsFormat, 'driveToken', app.driveToken);
            % drive key
            fprintf(fid, app.settingsFormat, 'driveKey', app.driveKey);
            % canvas token
            fprintf(fid, app.settingsFormat, 'canvasToken', app.canvasToken);
            % server username
            % fprintf(fid, app.settingsFormat, 'serverUsername', app.serverUsername);
            % server password
            % fprintf(fid, app.settingsFormat, 'serverPassword', app.serverPassword);
            % Google Client ID
            fprintf(fid, app.settingsFormat, 'clientId', app.googleClientId);
            % Google Client Secret
            fprintf(fid, app.settingsFormat, 'clientSecret', app.googleClientSecret);
            % Github API Token
            fprintf(fid, app.settingsFormat, 'githubToken', app.githubToken);
            % TWILIO API Token
            fprintf(fid, app.settingsFormat, 'twilioToken', app.twilioToken);
            % TWILIO SID
            fprintf(fid, app.settingsFormat, 'twilioSid', app.twilioSid);
            % TWILIO origin number
            fprintf(fid, app.settingsFormat, 'twilioOrigin', app.twilioOrigin);
            % Notifier GMail API Token
            fprintf(fid, app.settingsFormat, 'notifierToken', app.notifierToken);
            % Slack API Token
            fprintf(fid, app.settingsFormat, 'slackToken', app.slackToken);
            fclose(fid);
        end
    
        function parsePreferences(app, path)
            if nargin == 1
                fid = fopen(app.settingsPath, 'rt');
                if fid == -1
                    % first time: Create first time and wait
                    init = Initializer(app);
                    uiwait(init.UIFigure);
                    if isvalid(init)
                        close(init.UIFigure);
                    else
                        % Error; close down shop
                        close(app.UIFigure);
                        return;
                    end
                    fid = fopen(app.settingsPath, 'rt');
                end
            else
                fid = fopen(path, 'rt');
                if fid == -1
                    throw(MException('AUTOGRADER:settings:fileIO', ...
                        'Unable to open settings for reading'));
                end
            end
            data = textscan(fid, '%s%s', 'Delimiter', ':');
            fclose(fid);
            fields = data{1};
            values = data{2};
            for f = 1:numel(fields)
                switch lower(fields{f})
                    case 'drivetoken'
                        app.driveToken = values{f};
                    case 'drivekey'
                        app.driveKey = values{f};
                    case 'canvastoken'
                        app.canvasToken = values{f};
                    case 'serverusername'
                        % app.serverUsername = values{f};
                    case 'serverpassword'
                        % app.serverPassword = values{f};
                    case 'clientid'
                        app.googleClientId = values{f};
                    case 'clientsecret'
                        app.googleClientSecret = values{f};
                    case 'githubtoken'
                        app.githubToken = values{f};
                    case 'twiliotoken'
                        app.twilioToken = values{f};
                    case 'slacktoken'
                        app.slackToken = values{f};
                    case 'twiliosid'
                        app.twilioSid = values{f};
                    case 'twilioorigin'
                        app.twilioOrigin = values{f};
                    case 'notifiertoken'
                        app.notifierToken = values{f};
                end
            end
        end
        function isAvailable = updateAvailable(app)
            uiprogressdlg(app.UIFigure, ...
                'Message', 'Checking for new Releases', ...
                'Title', 'Update', ...
                'Indeterminate', 'on');
            ENDPOINT = 'https://github.gatech.edu/api/v3/repos/CS1371/autograder/releases/latest';
            opts = weboptions;
            opts.HeaderFields = {'Authorization', ['Bearer ' app.githubToken]};
            latest = webread(ENDPOINT, opts);
            releaseDate = datestr(datetime(latest.published_at, 'InputFormat', 'uuuu-MM-dd''T''HH:mm:ss''Z'''), 'mmmm dd');
            p = fileparts(mfilename('fullpath'));
            p = fullfile(p, '..', 'resources', 'addons_core.xml');
            if isfile(p)
                xml = xmlread(p);
                current = char(xml.getDocumentElement().getElementsByTagName('version').item(0).item(0).getData());
                % compare. first compare major, then minor, then patch
                current = strsplit(current, '.');
                latest = strsplit(latest.tag_name(2:end), '.');
                current = cellfun(@str2num, current);
                latest = cellfun(@str2num, latest);
                isAvailable = false;
                if latest(1) > current(1)
                    isAvailable = true;
                elseif latest(1) == current(1) && latest(2) > current(2)
                    isAvailable = true;
                elseif latest(1) == current(1) && latest(2) == current(2) && latest(3) > current(3)
                    isAvailable = true;
                end
            else
                isAvailable = false;
            end
            if isAvailable
                % show update screen
                latest = ['v' strjoin(arrayfun(@num2str, latest, 'uni', false), '.')];
                current = ['v' strjoin(arrayfun(@num2str, current, 'uni', false), '.')];
                shouldUpdate = uiconfirm(app.UIFigure, ...
                    sprintf('Version %s was released on %s. You''re currently running version %s - would you like to upgrade?', ...
                    latest, releaseDate, current), ...
                    'Update Available');
                if strcmpi(shouldUpdate, 'OK')
                    token = app.githubToken;
                    evalc('gcp;');
                    fig = app.UIFigure;
                    worker = parfeval(@(t)(updater(t)), 1, token);
                    printer = worker.afterAll(@(v)(fprintf('Updated to version %s\n', v)), 0);
                    printer.afterAll(@()(close(fig)), 0);
                end
            end
        end
    end


    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            % hide optionals
            app.CanvasBrowser.Visible = false;
            
            app.HomeworkBrowser.Visible = false;
            app.SolutionBrowser.Visible = false;
            
            app.DriveBrowser.Visible = false;
            
            app.OutputBrowser.Visible = false;
            
            app.HomeworkChoice.ItemsData = [0 1 2];
            app.SolutionChoice.ItemsData = [0 1 2];
            
            app.isResubmission = false;
            
            app.PostOptions.Visible = false;
            
            app.EmailFeedbackOptions.Visible = false;
            
            t = timer;
            app.delay = t(false);
            
            % Add correct path
            addpath(genpath(fileparts(fileparts(mfilename('fullpath')))));
            
            app.parsePreferences();
            if ~isempty(app.githubToken) && app.updateAvailable() 
            end
        end

        % Value changed function: HomeworkChoice
        function HomeworkChoiceSelected(app, ~)
            value = app.HomeworkChoice.Value;
            app.selectedStudents = [];
            app.AllButton.Value = true;
            if value == 1
                % hide zip browser
                app.HomeworkBrowser.Visible = false;
                % check if we have canvasToken, if we do, go straight to CanvasHomeworkSelector.
                % otherwise, authorize first
                if isempty(app.canvasCourseId)
                    if isempty(app.canvasToken)
                        % authorize first
                        p = uiprogressdlg(app.UIFigure, 'Title', 'Authorization', ...
                            'Message', 'Authorizing with Canvas', 'Indeterminate', 'on');
                        auth = CanvasAuthorizer(app);
                        uiwait(auth.UIFigure);
                        delete(auth);
                        close(p);
                    end
                    if isempty(app.canvasToken)
                        app.HomeworkChoice.Value = 0;
                        app.HomeworkChoiceSelected();
                        return;
                    else
                        try
                            p = uiprogressdlg(app.UIFigure, 'Title', 'Connecting', ...
                                'Message', 'Connecting with Canvas', 'Indeterminate', 'on');
                            browser = CanvasHomeworkSelector(app);
                        catch
                            uialert(app.UIFigure, 'Unable to contact Canvas', 'Canvas Selector');
                            app.HomeworkChoice.Value = 0;
                            app.HomeworkChoiceSelected();
                            close(p);
                            return;
                        end
                        uiwait(browser.UIFigure);
                        delete(browser);
                        close(p);
                        % if no answer given (cancelled), then revert to 0
                        if isempty(app.canvasHomeworkId)
                            app.HomeworkChoice.Value = 0;
                            app.HomeworkChoiceSelected();
                            return;
                        end
                        app.CanvasBrowser.Visible = true;
                    end
                end
            elseif value == 2
                % get zip
                p = uiprogressdlg(app.UIFigure, ...
                    'Message', ...
                    ['You will be asked to select two files. ', newline, ...
                    'The first is the submission archive (submission.zip).', newline, ...,
                    'The second is the gradebook (gradebook.csv).', newline, newline, ...,
                    'Both can be downloaded from Canvas'], ...
                    'Title', 'Homework Archive', ...
                    'Indeterminate', 'on', ...
                    'Cancelable','off', ...
                    'Value', 0, ...
                    'Icon', 'info');
                archive = app.getZip('Select the HW Zipped Archive');
                if ~islogical(archive)
                    csv = app.getFile('Select the Homework Gradebook', {'*.csv', 'CSV files (*.csv)'});
                    if ~islogical(csv)
                        app.homeworkArchivePath = archive;
                        app.homeworkGradebookPath = csv;
                        app.HomeworkBrowser.Visible = true;
                        app.CanvasBrowser.Visible = false;
                    else
                        app.HomeworkChoice.Value = 0;
                        app.HomeworkChoiceSelected();
                    end
                else
                    app.HomeworkChoice.Value = 0;
                    app.HomeworkChoiceSelected(); 
                end
                delete(p);
                drawnow;
                app.UIFigure.Visible = 'off';
                app.UIFigure.Visible = 'on';
            else
                % hide everything
                app.HomeworkBrowser.Visible = false;
                app.CanvasBrowser.Visible = false;
            end
        end

        % Button pushed function: HomeworkBrowser
        function HomeworkBrowserButtonPushed(app, ~)
            app.selectedStudents = [];
            app.AllButton.Value = true;
            res = app.getZip('Select your Homework ZIP');
            if ~islogical(res)
                app.homeworkArchivePath = res;
            end
            res = app.getFile('Select the Homework Gradebook', {'*.csv', 'CSV files (*.csv)'});
            if ~islogical(res)
                app.homeworkGradebookPath = res;
            end
        end

        % Button pushed function: SolutionBrowser
        function SolutionBrowserPushed(app, ~)
            res = app.getZip('Select the solution archive');
            if ~islogical(res)
                app.solutionArchivePath = res;
            end
        end

        % Value changed function: UploadFeedbackToCanvas
        function UploadFeedbackToCanvasValueChanged(app, ~)
            value = app.UploadFeedbackToCanvas.Value;
            if value
                if isempty(app.canvasCourseId)
                    if isempty(app.canvasToken)
                        auth = CanvasAuthorizer(app);
                        uiwait(auth.UIFigure);
                        delete(auth);
                    end
                    if isempty(app.canvasToken)
                        app.UploadFeedbackToCanvas.Value = false;
                        return;
                    end
                    try
                        p = uiprogressdlg(app.UIFigure, 'Title', 'Connecting', ...
                            'Message', 'Connecting with Canvas', 'Indeterminate', 'on');
                        browser = CanvasHomeworkSelector(app);
                    catch
                        uialert(app.UIFigure, 'Unable to contact Canvas', 'Canvas Selector');
                        app.UploadFeedbackToCanvas.Value = false;
                        close(p);
                        return;
                    end
                    uiwait(browser.UIFigure);
                    delete(browser);
                    close(p);
                    % if no answer given (cancelled), then revert to 0
                    if isempty(app.canvasHomeworkId)
                        app.UploadFeedbackToCanvas.Value = false;
                        return;
                    end
                end
            end
        end

        % Value changed function: UploadToServer
        function UploadToServerValueChanged(app, ~)
            value = app.UploadToServer.Value;
            if value
                if isempty(app.canvasToken)
                    p = uiprogressdlg(app.UIFigure, 'Indeterminate', 'on', ...
                        'Title', 'Authorization', 'Message', 'Authorizing with Canvas');
                    try
                        auth = CanvasAuthorizer(app);
                    catch
                        close(p);
                        app.UploadToServer.Value = false;
                        app.UploadToServerValueChanged();
                        return;
                    end
                    uiwait(auth.UIFigure);
                    close(auth.UIFigure);
                    delete(auth);
                    if isempty(app.canvasToken)
                        app.UploadToServer.Value = false;
                        app.UploadToServerValueChanged();
                    end
                    close(p);
                end
            end
        end

        % Value changed function: StoreLocally
        function StoreLocallyValueChanged(app, ~)
            value = app.StoreLocally.Value;
            if value
                res = app.getFolder('Where should we store the output?');
                if ~islogical(res)
                    app.localOutputPath = res;
                    app.OutputBrowser.Visible = true;
                else
                    app.StoreLocally.Value = false;
                    app.localOutputPath = '';
                    app.OutputBrowser.Visible = false;
                end
            else
                app.localOutputPath = '';
                app.OutputBrowser.Visible = false;
            end
        end

        % Button pushed function: OutputBrowser
        function OutputBrowserButtonPushed(app, ~)
            res = app.getFolder('Where should we store the output?');
            if ~islogical(res)
                app.localOutputPath = res;
            end
        end

        % Value changed function: EditSubmissions
        function EditSubmissionsValueChanged(app, ~)
            app.isEditingSubmissions = app.EditSubmissions.Value;
        end

        % Value changed function: SolutionChoice
        function SolutionChoiceValueChanged(app, ~)
            value = app.SolutionChoice.Value;
            if value == 1
                % hide zip browser
                app.SolutionBrowser.Visible = false;
                % check if we have canvasToken, if we do, go straight to CanvasHomeworkSelector.
                % otherwise, authorize first
                if isempty(app.driveToken)
                    % authorize first
                    try
                        p = uiprogressdlg(app.UIFigure, 'Title', 'Authorization', ...
                            'Message', 'Authorize With Google', 'Indeterminate', 'on');
                        app.driveToken = authorizeWithGoogle(app.googleClientId, ...
                            app.googleClientSecret);
                    catch
                        drawnow;
                        app.UIFigure.Visible = 'off';
                        app.UIFigure.Visible = 'on';
                        uialert(app.UIFigure, 'Authorization Failure', ...
                            'Please Try Again Later...');
                        app.driveToken = ''; % take care of undoing below (since empty)
                    end
                    drawnow;
                    app.UIFigure.Visible = 'off';
                    app.UIFigure.Visible = 'on';
                    close(p);
                end
                if isempty(app.driveToken)
                    app.SolutionChoice.Value = 0;
                    app.SolutionChoiceValueChanged();
                    return;
                else
                    app.savePreferences();
                    browser = [];
                    try
                        p = uiprogressdlg(app.UIFigure, 'Title', 'Connecting', ...
                            'Message', 'Connecting to Google Drive', 'Indeterminate', 'on');
                        browser = GoogleDriveBrowser(app);
                    catch
                        if ~isempty(browser)
                            delete(browser);
                        end
                        uialert(app.UIFigure, 'Connection Failure', ...
                            'We were unable to contact Google''s Servers (Are you connected to the internet?)');
                        app.SolutionChoice.Value = 0;
                        app.SolutionChoiceValueChanged();
                        close(p);
                        return;
                    end
                    uiwait(browser.UIFigure);
                    delete(browser);
                    close(p);
                    % if no answer given (cancelled), then revert to 0
                    if isempty(app.driveFolderId)
                        app.SolutionChoice.Value = 0;
                        app.SolutionChoiceValueChanged();
                        return;
                    end
                    app.DriveBrowser.Visible = true;
                end
            elseif value == 2
                % get zip
                p = uiprogressdlg(app.UIFigure, ...
                    'Message', ...
                    ['You will be asked to select the zipped archive for the grader folder.', newline, ...
                    'When you download it from Google Drive, make sure you highlight all of its contents, and click "download" - don''t just download the grader folder itself!'], ...
                    'Value', 0, ...
                    'Indeterminate', 'on', ...
                    'Title','Solution Archive', ...
                    'Cancelable', 'off', ...
                    'Icon', 'info');
                res = app.getZip('Select the Zipped Solution Archive');
                delete(p);
                drawnow;
                app.UIFigure.Visible = 'off';
                app.UIFigure.Visible = 'on';
                if ~islogical(res)
                    app.solutionArchivePath = res;
                    app.SolutionBrowser.Visible = true;
                    app.DriveBrowser.Visible = false;
                else
                    app.SolutionChoice.Value = 0;
                    app.SolutionChoiceValueChanged();
                    return;
                end
            else
                % hide everything
                app.SolutionBrowser.Visible = false;
                app.DriveBrowser.Visible = false;
            end
        end

        % Callback function: Cancel, Exit
        function CancelButtonPushed(app, ~)
            delete(app);
        end

        % Value changed function: PostToCanvas
        function PostToCanvasValueChanged(app, event)
            value = app.PostToCanvas.Value;
            if value
                app.PostOptionsButtonPushed(event);
                app.PostOptions.Visible = true;
            else
                app.PostOptions.Visible = false;
            end
        end

        % Button pushed function: CanvasBrowser
        function CanvasBrowserButtonPushed(app, ~)
            p = uiprogressdlg(app.UIFigure, 'Title', 'Connecting', ...
                'Message', 'Conencting with Canvas', 'Indeterminate', 'on');
            app.selectedStudents = [];
            app.AllButton.Value = true;
            try
                canvasSelector = CanvasHomeworkSelector(app);
            catch
                uialert(app.UIFigure, 'We''re having trouble connecting to Canvas', 'Connection Error');
                close(p);
                return;
            end
            uiwait(canvasSelector.UIFigure);
            delete(canvasSelector);
            close(p);
            app.HomeworkNumber.Value = app.homeworkNum;
            app.IsResubmission.Value = app.isResubmission;
        end

        % Button pushed function: DriveBrowser
        function DriveBrowserButtonPushed(app, ~)
            p = uiprogressdlg(app.UIFigure, 'Title', 'Connecting', ...
                'Message', 'Connecting with Google Drive', 'Indeterminate', 'on');
            try
                browser = GoogleDriveBrowser(app);
            catch
                uialert(app.UIFigure, 'We''re having trouble connecting to Google Drive', 'Connection Error');
                close(p);
                return;
            end
            uiwait(browser.UIFigure);
            delete(browser);
            close(p);
        end

        % Menu selected function: SaveConfiguration
        function SaveConfigurationMenuSelected(app, ~)

            [name, path] = uiputfile({'*.autograde', 'Autograder Configuration Files (*.autograde)'}, 'Where shall we save your configuration file?');
            if ~isequal(name, 0)
                try
                    app.savePreferences([path name]);
                catch
                    uialert(app.UIFigure, 'We were unable to save your settings', 'Settings Error');
                end
            end
        end

        % Menu selected function: LoadConfigurationMenu
        function LoadConfigurationMenuSelected(app, ~)
            % ask for file; if given, load data
            [name, path] = uigetfile({'*.autograde', 'Autograder Configuration Files (*.autograde)'}, 'Select the Autograder Configuration File...');
            if ~isequal(name, 0)
                try
                    app.parsePreferences([path name]);
                catch
                    uialert(app.UIFigure, 'We were unable to load your settings', 'Settings Error');
                end
            end
        end

        % Menu selected function: LicenseMenu
        function LicenseMenuSelected(~, ~)
            web('https://github.gatech.edu/CS1371/autograder/blob/master/LICENSE', '-browser');
        end

        % Menu selected function: DocumentationMenu
        function DocumentationMenuSelected(~, ~)
            web('https://github.gatech.edu/pages/CS1371/autograder/', '-browser');
        end

        % Menu selected function: Canvas
        function CanvasSelected(app, ~)
            generator = CanvasAuthorizer(app);
            uiwait(generator.UIFigure);
            delete(generator);
        end

        % Menu selected function: Drive
        function DriveSelected(app, ~)
            app.driveToken = authorizeWithGoogle(app.googleClientId, app.googleClientSecret);
            app.savePreferences();
        end

        % Button pushed function: Go
        function GoButtonPushed(app, ~)
            % validate settings
            % if nothing selected, we are post processing. Show
            % confirmation dialogue!
            if ~isempty(app.postProcessPath)
                % post processor
                resp = uiconfirm(app.UIFigure, ...
                    ['You have elected to Post Process.', ...
                    newline, ...
                    'No grading will be done - only uploading, etc. Click continue to proceed, or cancel to select different options'], ...
                    'Post Processing', ...
                    'Options', {'Continue', 'Cancel'}, ...
                    'CancelOption', 'Cancel', ...
                    'DefaultOption', 'Cancel', ...
                    'Icon', 'info');
                if strcmpi(resp, 'cancel')
                    return;
                end
            % homework choice - had to pick ZIP or Canvas
            elseif app.HomeworkChoice.Value == 0
                uialert(app.UIFigure, 'Pick a Homework Submission', 'Autograder Error');
                return;
                % Solution choice - had to pick something
            elseif app.SolutionChoice.Value == 0
                uialert(app.UIFigure, 'Pick a Solution', 'Autograder Error');
                return;
            end
            
            try
                autograder(app);
            catch e
                uialert(app.UIFigure, sprintf('Error in Main Method: %s: %s', e.identifier, e.message), 'Error');
            end
        end

        % Value changed function: IsResubmission
        function IsResubmissionButtonPushed(app, ~)
            value = app.IsResubmission.Value;
            app.isResubmission = value;
        end

        % Button pushed function: PostOptions
        function PostOptionsButtonPushed(app, ~)
            poster = CanvasPoster;
            poster.Title.Value = app.canvasTitle;
            poster.html = app.canvasHtml;
            poster.Message.Value = app.canvasMessage;
            if app.canvasMode == 1
                poster.IsMarkdown.Value = true;
            elseif app.canvasMode == 2
                poster.IsPlain.Value = true;
            else
                poster.IsHTML.Value = true;
            end
            uiwait(poster.UIFigure);
            % get stuff and delete
            if isvalid(poster)
                app.canvasTitle = poster.Title.Value;
                app.canvasMessage = poster.Message.Value;
                app.canvasHtml = poster.html;
                if poster.IsMarkdown.Value
                    app.canvasMode = 1;
                elseif poster.IsPlain.Value
                    app.canvasMode = 2;
                else
                    app.canvasMode = 3;
                end
            end
            delete(poster);
            
            if isempty(app.canvasCourseId)
                if isempty(app.canvasToken)
                    auth = CanvasAuthorizer(app);
                    uiwait(auth.UIFigure);
                    delete(auth);
                end
                if isempty(app.canvasToken)
                    app.canvasMessage = '';
                    app.canvasTitle = '';
                else
                    try
                        p = uiprogressdlg(app.UIFigure, 'Title', 'Connecting', ...
                            'Message', 'Connecting with Canvas', 'Indeterminate', 'on');
                        browser = CanvasHomeworkSelector(app);
                        uiwait(browser.UIFigure);
                        delete(browser);
                        close(p);
                        % if no answer given (cancelled), then revert to 0
                        if isempty(app.canvasHomeworkId)
                            app.canvasMessage = '';
                            app.canvasTitle = '';
                        end
                    catch
                        uialert(app.UIFigure, 'Unable to contact Canvas', 'Canvas Selector');
                        app.canvasMessage = '';
                        app.canvasTitle = '';
                        close(p);
                    end
                end
            end
        end

        % Menu selected function: Notifications
        function NotificationsMenuSelected(app, ~)
            p = uiprogressdlg(app.UIFigure, 'Cancelable', 'off', 'Indeterminate', 'on', ...
                'ShowPercentage', 'off', 'Title', 'Notifications', 'Message', 'Preparing Notification Options...');
            not = Notifier(app);
            uiwait(not.UIFigure);
            close(p);
        end

        % Value changed function: EmailFeedback
        function EmailFeedbackValueChanged(app, ~)
            value = app.EmailFeedback.Value;
            if value
                p = uiprogressdlg(app.UIFigure, 'Cancelable', 'off', ...
                    'Indeterminate', 'on', 'Title', 'Email Composer', ...
                    'Message', 'Waiting for confirmation of email');
                composer = EmailComposer(app);
                uiwait(composer.UIFigure);
                if isvalid(composer)
                    close(composer.UIFigure);
                end
                app.EmailFeedbackOptions.Visible = true;
                close(p);
            else
                app.EmailFeedbackOptions.Visible = false;
            end
        end

        % Button pushed function: EmailFeedbackOptions
        function EmailFeedbackOptionsButtonPushed(app, ~)
            p = uiprogressdlg(app.UIFigure, 'Cancelable', 'off', ...
                    'Indeterminate', 'on', 'Title', 'Email Composer', ...
                    'Message', 'Waiting for confirmation of email');
            composer = EmailComposer(app);
            uiwait(composer.UIFigure);
            if isvalid(composer)
                close(composer.UIFigure);
            end
            close(p);
        end

        % Selection changed function: ButtonGroup
        function StudentSelectAllChanged(app, ~)
            if app.HomeworkChoice.Value == 0
                app.ButtonGroup.SelectedObject = app.AllButton;
                return
            end
            selectedButton = app.ButtonGroup.SelectedObject;
            if strcmp(selectedButton.Text, "Select")
                selector = StudentSelector(app);
                uiwait(selector.UIFigure);
                delete(selector);
            end
        end

        % Value changed function: UploadGradesToCanvas
        function UploadGradesToCanvasValueChanged(app, ~)
            value = app.UploadGradesToCanvas.Value;
            if value
                if isempty(app.canvasCourseId)
                    if isempty(app.canvasToken)
                        auth = CanvasAuthorizer(app);
                        uiwait(auth.UIFigure);
                        delete(auth);
                    end
                    if isempty(app.canvasToken)
                        app.UploadGradesToCanvas.Value = false;
                        return;
                    end
                    try
                        p = uiprogressdlg(app.UIFigure, 'Title', 'Connecting', ...
                            'Message', 'Connecting with Canvas', 'Indeterminate', 'on');
                        browser = CanvasHomeworkSelector(app);
                    catch
                        uialert(app.UIFigure, 'Unable to contact Canvas', 'Canvas Selector');
                        app.UploadGradesToCanvas.Value = false;
                        close(p);
                        return;
                    end
                    uiwait(browser.UIFigure);
                    delete(browser);
                    close(p);
                    % if no answer given (cancelled), then revert to 0
                    if isempty(app.canvasHomeworkId)
                        app.UploadGradesToCanvas.Value = false;
                        return;
                    end
                end
            end
        end

        % Menu selected function: Schedule
        function ScheduleMenuSelected(app, ~)
            if isvalid(app.delay)
                stop(app.delay);
                delete(app.delay);
                app.delay = app.delay(false);
                app.Schedule.Text = 'Schedule';
                app.Go.Enable = true;
                app.EditSubmissions.Enable = true;
            else
                progress = uiprogressdlg(app.UIFigure, ...
                    'Title', 'Scheduler Progress', ...
                    'Value', 0, ...
                    'Message', 'Scheduling Autograder', ...
                    'Indeterminate', 'on', ...
                    'Cancelable', 'off');
                % make sure pool is active
                evalc('gcp;');
                sentinel = [tempname '.lock'];
                worker = parfevalOnAll(@File.SENTINEL, 0, sentinel);
                worker.wait();
                % before we do ANYTHING, check
                workDir = tempname;
                mkdir(workDir);
                safeDir = cd(workDir);
                clean = onCleanup(@()(cleaner(app, safeDir, workDir)));
                try
                    token = refresh2access(app.driveToken, ...
                        app.googleClientId, app.googleClientSecret);
                catch
                    uialert(app.UIFigure, 'Make sure your Google Drive Token is correct', 'Scheduler');
                    return;
                end
                try
                    downloadFromDrive(app.driveFolderId, token, ...
                        pwd, app.driveKey, progress);
                catch
                    uialert(app.UIFigure, 'Unable to download solution files', 'Scheduler');
                    return;
                end
                try
                    generateSolutions(app.isResubmission, progress);
                catch
                    uialert(app.UIFigure, 'Unable to generate solutions... Try running the autograder normally to investigate', 'Scheduler');
                    return;
                end
                
                % Check homework choice
                if app.HomeworkChoice.Value == 0
                    uialert(app.UIFigure, 'Pick a Homework Submission', 'Scheduler');
                    return;
                end
                
                % add dictionary
                worker = parfevalOnAll(@gradeComments, 0);
                
                app.delay = timer('Name', 'Autograder', ...
                'TimerFcn', @(varargin)(autograder(app)), ...
                'ObjectVisibility', 'off');
                d = datetime;
                d.Day = d.Day + 1;
                d.Hour = 0;
                d.Minute = 5;
                d.Second = 0;
                app.delay.startat(d);
                app.Schedule.Text = 'Remove from Schedule';
                app.Go.Enable = false;
                % disable edit
                app.EditSubmissions.Value = false;
                app.EditSubmissions.Enable = false;
                progress.Message = 'Waiting for dictionaries to finish loading';
                worker.wait();
                delete(progress);
            end
        end

        % Close request function: UIFigure
        function UIFigureCloseRequest(app, ~)
            if isvalid(app.delay)
                stop(app.delay);
            end
            delete(app)
            
        end

        % Value changed function: AnalyzeForCheating
        function AnalyzeForCheatingValueChanged(app, ~)
            value = app.AnalyzeForCheating.Value;
            if value
                if ~isempty(app.localOutputPath)
                    app.localCheatPath = fullfile(app.localOutputPath, 'Cheaters');
                elseif isempty(app.postProcessPath)
                    res = app.getFolder('Where should we store the Cheat Detection?');
                    if ~islogical(res)
                        app.localCheatPath = res;
                    else
                        app.localCheatPath = '';
                        app.AnalyzeForCheating.Value = false;
                    end
                end
            else
                app.localCheatPath = '';
            end
                
        end

        % Menu selected function: Update
        function UpdateMenuSelected(app, ~)
            p = uiprogressdlg(app.UIFigure, ...
                'Message', 'Checking for new Releases', ...
                'Title', 'Update', ...
                'Indeterminate', 'on');
            if isempty(app.githubToken)
                auth = GithubAuthorizer(app);
                uiwait(auth.UIFigure);
                if ~isvalid(auth) || ~isvalid(auth.UIFigure)
                    uialert(app.UIFigure, 'You must provide your GitHub Credentials to check for updates', 'Update Failure');
                else
                    close(auth.UIFigure);
                end 
            end
            if isempty(app.githubToken)
                uialert(app.UIFigure, 'You must provide your GitHub Credentials to check for updates', 'Update Failure');
            elseif ~app.updateAvailable()
                uialert(app.UIFigure, 'You are up to date!', 'Update Success', 'Icon', 'success');
            end
            close(p);
        end
        
        % Menu selected function: PostProcess
        function PostProcessMenuSelected(app, ~)
            % tell user what is going to happen
            if isempty(app.postProcessPath)
                
                resp = uiconfirm(app.UIFigure, ...
                    ['Post Processing is exclusively the step 3 options - ', ...
                    'You will be asked to select an archive from a previous grading session', ...
                    newline, ...
                    'Then, you can select whatever post-grading options you want. When you''re ready, click "Go"'], ...
                    'Post Processor', ...
                    'Options', {'OK', 'Cancel'}, ...
                    'CancelOption', 'Cancel', ...
                    'DefaultOption', 'Cancel', ...
                    'Icon', 'info');
                if strcmpi(resp, 'Cancel')
                    return;
                end
                % ask for folder
                path = app.getFolder('Select the grading archive');
                if islogical(path)
                    return;
                end
                % determine number & resub status
                try
                    fid = fopen(fullfile(path, 'info.txt'), 'rt');
                    data = textscan(fid, '%d - %d');
                    fclose(fid);
                    app.homeworkNum = data{1};
                    app.isResubmission = data{2} == 1;
                catch
                    uialert(app.UIFigure, 'Invalid archive chosen', 'Post Process', 'icon', 'error');
                    return;
                end
                % blank out steps 1 and 2, change Go to be Post Process
                app.HomeworkPanel.Visible = false;
                app.SolutionPanel.Visible = false;
                app.Go.Text = 'Post Process';
                app.PostProcess.Text = 'Cancel Post Processing';
                app.UIFigure.Position(4) = sum(app.OutputPanel.Position([2 4]));
                app.Schedule.Enable = false;
                app.localOutputPath = '';
                app.StoreLocally.Value = false;
                app.StoreLocallyValueChanged();
                app.StoreLocally.Enable = false;
                app.EditSubmissions.Value = false;
                app.EditSubmissions.Enable = false;
                app.EditSubmissionsValueChanged();
                app.postProcessPath = path;
            else
                app.PostProcess.Text = 'Post Processing...';
                app.Go.Text = 'Go!';
                app.HomeworkPanel.Visible = true;
                app.SolutionPanel.Visible = true;
                app.UIFigure.Position(4) = app.ORIGINAL_SIZE(4);
                app.Schedule.Enable = true;
                app.StoreLocally.Enable = true;
                app.EditSubmissions.Enable = true;
                app.postProcessPath = '';
            end
        end

        % Menu selected function: Github
        function GithubMenuSelected(app, ~)
            auth = GithubAuthorizer(app);
            uiwait(auth.UIFigure);
        end
    end

    % App initialization and construction
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure
            app.UIFigure = uifigure;
            app.UIFigure.Color = [0.9412 0.9412 0.9412];
            app.UIFigure.Position = app.ORIGINAL_SIZE;
            app.UIFigure.Name = 'Autograder';
            app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @UIFigureCloseRequest, true);

            % Create SettingsMenu
            app.SettingsMenu = uimenu(app.UIFigure);
            app.SettingsMenu.Text = 'Settings';

            % Create SaveConfiguration
            app.SaveConfiguration = uimenu(app.SettingsMenu);
            app.SaveConfiguration.MenuSelectedFcn = createCallbackFcn(app, @SaveConfigurationMenuSelected, true);
            app.SaveConfiguration.Accelerator = 'S';
            app.SaveConfiguration.Text = 'Save Configuration...';

            % Create LoadConfigurationMenu
            app.LoadConfigurationMenu = uimenu(app.SettingsMenu);
            app.LoadConfigurationMenu.MenuSelectedFcn = createCallbackFcn(app, @LoadConfigurationMenuSelected, true);
            app.LoadConfigurationMenu.Accelerator = 'L';
            app.LoadConfigurationMenu.Text = 'Load Configuration...';

            % Create Exit
            app.Exit = uimenu(app.SettingsMenu);
            app.Exit.MenuSelectedFcn = createCallbackFcn(app, @CancelButtonPushed, true);
            app.Exit.Accelerator = 'W';
            app.Exit.Text = 'Exit';

            % Create Notifications
            app.Notifications = uimenu(app.SettingsMenu);
            app.Notifications.MenuSelectedFcn = createCallbackFcn(app, @NotificationsMenuSelected, true);
            app.Notifications.Text = 'Notifications...';

            % Create Schedule
            app.Schedule = uimenu(app.SettingsMenu);
            app.Schedule.MenuSelectedFcn = createCallbackFcn(app, @ScheduleMenuSelected, true);
            app.Schedule.Text = 'Schedule for Midnight...';

            % Create Update
            app.Update = uimenu(app.SettingsMenu);
            app.Update.MenuSelectedFcn = createCallbackFcn(app, @UpdateMenuSelected, true);
            app.Update.Text = 'Update';
            
            % Create PostProcess
            app.PostProcess = uimenu(app.SettingsMenu);
            app.PostProcess.MenuSelectedFcn = createCallbackFcn(app, @PostProcessMenuSelected, true);
            app.PostProcess.Text = 'Post Processing...';

            % Create AuthorizationsMenu
            app.AuthorizationsMenu = uimenu(app.UIFigure);
            app.AuthorizationsMenu.Text = 'Authorizations';

            % Create Canvas
            app.Canvas = uimenu(app.AuthorizationsMenu);
            app.Canvas.MenuSelectedFcn = createCallbackFcn(app, @CanvasSelected, true);
            app.Canvas.Text = 'Canvas...';

            % Create Drive
            app.Drive = uimenu(app.AuthorizationsMenu);
            app.Drive.MenuSelectedFcn = createCallbackFcn(app, @DriveSelected, true);
            app.Drive.Text = 'Drive...';

            % Create Github
            app.Github = uimenu(app.AuthorizationsMenu);
            app.Github.MenuSelectedFcn = createCallbackFcn(app, @GithubMenuSelected, true);
            app.Github.Text = 'GitHub...';

            % Create AcknowledgementsMenu
            app.AcknowledgementsMenu = uimenu(app.UIFigure);
            app.AcknowledgementsMenu.Text = 'Acknowledgements';

            % Create LicenseMenu
            app.LicenseMenu = uimenu(app.AcknowledgementsMenu);
            app.LicenseMenu.MenuSelectedFcn = createCallbackFcn(app, @LicenseMenuSelected, true);
            app.LicenseMenu.Text = 'License';

            % Create DocumentationMenu
            app.DocumentationMenu = uimenu(app.AcknowledgementsMenu);
            app.DocumentationMenu.MenuSelectedFcn = createCallbackFcn(app, @DocumentationMenuSelected, true);
            app.DocumentationMenu.Text = 'Documentation';

            % Create HomeworkPanel
            app.HomeworkPanel = uipanel(app.UIFigure);
            app.HomeworkPanel.Title = '1. Homework Submission';
            app.HomeworkPanel.BackgroundColor = [0.9412 0.9412 0.9412];
            app.HomeworkPanel.FontAngle = 'italic';
            app.HomeworkPanel.FontWeight = 'bold';
            app.HomeworkPanel.Position = [1 431 640 151];

            % Create IsResubmission
            app.IsResubmission = uicheckbox(app.HomeworkPanel);
            app.IsResubmission.ValueChangedFcn = createCallbackFcn(app, @IsResubmissionButtonPushed, true);
            app.IsResubmission.Text = 'Resubmission';
            app.IsResubmission.Position = [195 13 98 22];

            % Create HomeworkNumberLabel
            app.HomeworkNumberLabel = uilabel(app.HomeworkPanel);
            app.HomeworkNumberLabel.HorizontalAlignment = 'right';
            app.HomeworkNumberLabel.Position = [21 13 110 22];
            app.HomeworkNumberLabel.Text = 'Homework Number';

            % Create HomeworkNumber
            app.HomeworkNumber = uieditfield(app.HomeworkPanel, 'numeric');
            app.HomeworkNumber.Position = [152 13 27 22];

            % Create HomeworkChoiceLabel
            app.HomeworkChoiceLabel = uilabel(app.HomeworkPanel);
            app.HomeworkChoiceLabel.HorizontalAlignment = 'right';
            app.HomeworkChoiceLabel.Position = [19 94 90 22];
            app.HomeworkChoiceLabel.Text = 'I would like to...';

            % Create HomeworkChoice
            app.HomeworkChoice = uidropdown(app.HomeworkPanel);
            app.HomeworkChoice.Items = {'', 'Select the submission from Canvas', 'Browse locally for a submission archive'};
            app.HomeworkChoice.ValueChangedFcn = createCallbackFcn(app, @HomeworkChoiceSelected, true);
            app.HomeworkChoice.Position = [124 94 356 22];
            app.HomeworkChoice.Value = '';

            % Create HomeworkBrowser
            app.HomeworkBrowser = uibutton(app.HomeworkPanel, 'push');
            app.HomeworkBrowser.ButtonPushedFcn = createCallbackFcn(app, @HomeworkBrowserButtonPushed, true);
            app.HomeworkBrowser.Position = [494 94 100 22];
            app.HomeworkBrowser.Text = 'Browse...';

            % Create CanvasBrowser
            app.CanvasBrowser = uibutton(app.HomeworkPanel, 'push');
            app.CanvasBrowser.ButtonPushedFcn = createCallbackFcn(app, @CanvasBrowserButtonPushed, true);
            app.CanvasBrowser.Position = [494 94 100 22];
            app.CanvasBrowser.Text = 'Browse...';

            % Create ButtonGroup
            app.ButtonGroup = uibuttongroup(app.HomeworkPanel);
            app.ButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @StudentSelectAllChanged, true);
            app.ButtonGroup.BorderType = 'none';
            app.ButtonGroup.Position = [146 48 120 33];

            % Create AllButton
            app.AllButton = uiradiobutton(app.ButtonGroup);
            app.AllButton.Text = 'All';
            app.AllButton.Position = [6 7 35 22];
            app.AllButton.Value = true;

            % Create SelectButton
            app.SelectButton = uiradiobutton(app.ButtonGroup);
            app.SelectButton.Text = 'Select';
            app.SelectButton.Position = [56 7 65 22];

            % Create GradeallstudentsLabel
            app.GradeallstudentsLabel = uilabel(app.HomeworkPanel);
            app.GradeallstudentsLabel.Position = [26 53 110 22];
            app.GradeallstudentsLabel.Text = 'Grade all students?';

            % Create IsLeaky
            app.IsLeaky = uicheckbox(app.HomeworkPanel);
            app.IsLeaky.Text = 'Leaky';
            app.IsLeaky.Position = [296 13 54 22];

            % Create SolutionPanel
            app.SolutionPanel = uipanel(app.UIFigure);
            app.SolutionPanel.Title = '2. Solution Archive';
            app.SolutionPanel.FontAngle = 'italic';
            app.SolutionPanel.FontWeight = 'bold';
            app.SolutionPanel.Position = [1 346 640 86];

            % Create SolutionChoiceLabel
            app.SolutionChoiceLabel = uilabel(app.SolutionPanel);
            app.SolutionChoiceLabel.HorizontalAlignment = 'right';
            app.SolutionChoiceLabel.Position = [19 18 90 22];
            app.SolutionChoiceLabel.Text = 'I would like to...';

            % Create SolutionChoice
            app.SolutionChoice = uidropdown(app.SolutionPanel);
            app.SolutionChoice.Items = {'', 'Select the Solution Archive from Google Drive', 'Browse for a local Solution Archive'};
            app.SolutionChoice.ValueChangedFcn = createCallbackFcn(app, @SolutionChoiceValueChanged, true);
            app.SolutionChoice.Position = [124 18 356 22];
            app.SolutionChoice.Value = '';

            % Create SolutionBrowser
            app.SolutionBrowser = uibutton(app.SolutionPanel, 'push');
            app.SolutionBrowser.ButtonPushedFcn = createCallbackFcn(app, @SolutionBrowserPushed, true);
            app.SolutionBrowser.Position = [494 18 100 22];
            app.SolutionBrowser.Text = 'Browse...';

            % Create DriveBrowser
            app.DriveBrowser = uibutton(app.SolutionPanel, 'push');
            app.DriveBrowser.ButtonPushedFcn = createCallbackFcn(app, @DriveBrowserButtonPushed, true);
            app.DriveBrowser.Position = [494 18 100 22];
            app.DriveBrowser.Text = 'Browse...';

            % Create OutputPanel
            app.OutputPanel = uipanel(app.UIFigure);
            app.OutputPanel.Title = '3. Outputs';
            app.OutputPanel.FontAngle = 'italic';
            app.OutputPanel.FontWeight = 'bold';
            app.OutputPanel.Position = [1 71 640 276];

            % Create UploadFeedbackToCanvas
            app.UploadFeedbackToCanvas = uicheckbox(app.OutputPanel);
            app.UploadFeedbackToCanvas.ValueChangedFcn = createCallbackFcn(app, @UploadFeedbackToCanvasValueChanged, true);
            app.UploadFeedbackToCanvas.Text = 'Upload Feedback to Canvas';
            app.UploadFeedbackToCanvas.Position = [19 193 175 33];

            % Create UploadToServer
            app.UploadToServer = uicheckbox(app.OutputPanel);
            app.UploadToServer.ValueChangedFcn = createCallbackFcn(app, @UploadToServerValueChanged, true);
            app.UploadToServer.Text = 'Upload Files to Server';
            app.UploadToServer.Position = [19 130 192 33];

            % Create StoreLocally
            app.StoreLocally = uicheckbox(app.OutputPanel);
            app.StoreLocally.ValueChangedFcn = createCallbackFcn(app, @StoreLocallyValueChanged, true);
            app.StoreLocally.Text = 'Store Output Locally...';
            app.StoreLocally.Position = [19 98 141 33];

            % Create EditSubmissions
            app.EditSubmissions = uicheckbox(app.OutputPanel);
            app.EditSubmissions.ValueChangedFcn = createCallbackFcn(app, @EditSubmissionsValueChanged, true);
            app.EditSubmissions.Tooltip = {'If you would like to alter the student''s submission before it''s graded'; ' checking this will give you a chance to alter any student you wish'};
            app.EditSubmissions.Text = 'Edit Student Submissions';
            app.EditSubmissions.Position = [19 66 171 33];

            % Create PostToCanvas
            app.PostToCanvas = uicheckbox(app.OutputPanel);
            app.PostToCanvas.ValueChangedFcn = createCallbackFcn(app, @PostToCanvasValueChanged, true);
            app.PostToCanvas.Text = 'Post Announcement...';
            app.PostToCanvas.Position = [19 34 141 33];

            % Create OutputBrowser
            app.OutputBrowser = uibutton(app.OutputPanel, 'push');
            app.OutputBrowser.ButtonPushedFcn = createCallbackFcn(app, @OutputBrowserButtonPushed, true);
            app.OutputBrowser.Position = [175 103 100 22];
            app.OutputBrowser.Text = 'Browse...';

            % Create AnalyzeForCheating
            app.AnalyzeForCheating = uicheckbox(app.OutputPanel);
            app.AnalyzeForCheating.ValueChangedFcn = createCallbackFcn(app, @AnalyzeForCheatingValueChanged, true);
            app.AnalyzeForCheating.Text = 'Analyze for Cheating...';
            app.AnalyzeForCheating.Position = [19 7 143 22];

            % Create PostOptions
            app.PostOptions = uibutton(app.OutputPanel, 'push');
            app.PostOptions.ButtonPushedFcn = createCallbackFcn(app, @PostOptionsButtonPushed, true);
            app.PostOptions.Position = [175 39 100 22];
            app.PostOptions.Text = 'Configure...';

            % Create EmailFeedback
            app.EmailFeedback = uicheckbox(app.OutputPanel);
            app.EmailFeedback.ValueChangedFcn = createCallbackFcn(app, @EmailFeedbackValueChanged, true);
            app.EmailFeedback.Text = 'Email Feedback...';
            app.EmailFeedback.Position = [19 167 118 22];

            % Create EmailFeedbackOptions
            app.EmailFeedbackOptions = uibutton(app.OutputPanel, 'push');
            app.EmailFeedbackOptions.ButtonPushedFcn = createCallbackFcn(app, @EmailFeedbackOptionsButtonPushed, true);
            app.EmailFeedbackOptions.Position = [175 167 100 22];
            app.EmailFeedbackOptions.Text = 'Configure...';

            % Create UploadGradesToCanvas
            app.UploadGradesToCanvas = uicheckbox(app.OutputPanel);
            app.UploadGradesToCanvas.ValueChangedFcn = createCallbackFcn(app, @UploadGradesToCanvasValueChanged, true);
            app.UploadGradesToCanvas.Text = 'Upload Grades to Canvas';
            app.UploadGradesToCanvas.Position = [19 225 175 33];

            % Create Go
            app.Go = uibutton(app.UIFigure, 'push');
            app.Go.ButtonPushedFcn = createCallbackFcn(app, @GoButtonPushed, true);
            app.Go.BackgroundColor = [0.4706 0.6706 0.1882];
            app.Go.FontSize = 18;
            app.Go.FontColor = [1 1 1];
            app.Go.Position = [404 19 222 30];
            app.Go.Text = 'Go!';

            % Create Cancel
            app.Cancel = uibutton(app.UIFigure, 'push');
            app.Cancel.ButtonPushedFcn = createCallbackFcn(app, @CancelButtonPushed, true);
            app.Cancel.FontSize = 18;
            app.Cancel.Position = [297 19 100 30];
            app.Cancel.Text = 'Cancel';
        end
    end

    methods (Access = public)

        % Construct app
        function app = Autograder

            % Create and configure components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end