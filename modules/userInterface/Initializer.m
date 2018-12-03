classdef Initializer < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure  matlab.ui.Figure
        Title     matlab.ui.control.Label
        Start     matlab.ui.control.Button
        Cancel    matlab.ui.control.Button
    end


    properties (Access = private)
        base Autograder;
        INIT_PATH = 'https://cs1371.gatech.edu/autograder.php';
        auth;
    end

    methods (Access = private)
    
        function downloadSettings(app, token)
            websave(app.base.settingsPath, app.INIT_PATH, 'token', token);
        end
        
    end


    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, baseApp)
            app.base = baseApp;
        end

        % Button pushed function: Start
        function StartButtonPushed(app, ~)
            % authorize with the server
            app.auth = CanvasAuthorizer(app.base);
            uiwait(app.auth.UIFigure);
            if ~isvalid(app)
                return;
            elseif ~isvalid(app.auth)
                % closed; just close ourselves too
                close(app.UIFigure);
                return
            end
            delete(app.auth);
            app.auth = GithubAuthorizer(app.base);
            uiwait(app.auth.UIFigure);
            delete(app.auth);
            % we don't really care if we got it or not...
            token = app.base.canvasToken;
            % download settings
            p = uiprogressdlg(app.UIFigure, 'Cancelable', 'off', 'Indeterminate', 'on', ...
                'Title', 'Contacting Server...', 'Message', 'Downloading Initial Settings...', ...
                'ShowPercentage', 'off');
            try
                app.downloadSettings(token);
            catch
                uialert(app.UIFigure, ...
                    'Either the given credentials are incorrect, or there''s something wrong with your connection', ...
                    'Authentication Failure');
                return;
            end
            close(p);
            % reload settings
            app.base.parsePreferences();
            app.base.canvasToken = token;
            app.base.savePreferences();
            uiresume(app.UIFigure);
        end

        % Button pushed function: Cancel
        function CancelButtonPushed(app, ~)
            if isvalid(app) && ~isempty(app.auth) && isvalid(app.auth) && isvalid(app.auth.UIFigure)
                close(app.auth.UIFigure);
            end
            if isvalid(app) && isvalid(app.UIFigure)
                delete(app.UIFigure);
            end
        end

        % Close request function: UIFigure
        function UIFigureCloseRequest(app, ~)
            app.CancelButtonPushed();
            delete(app)
        end
    end

    % App initialization and construction
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure
            app.UIFigure = uifigure;
            app.UIFigure.Position = [100 100 635 258];
            app.UIFigure.Name = 'Welcome';
            app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @UIFigureCloseRequest, true);

            % Create Title
            app.Title = uilabel(app.UIFigure);
            app.Title.HorizontalAlignment = 'center';
            app.Title.FontSize = 48;
            app.Title.FontAngle = 'italic';
            app.Title.FontColor = [0 0.451 0.7412];
            app.Title.Position = [13 88 612 171];
            app.Title.Text = {'Welcome to the autograder!'; 'To get started, you''ll need'; 'to authenticate first...'};

            % Create Start
            app.Start = uibutton(app.UIFigure, 'push');
            app.Start.ButtonPushedFcn = createCallbackFcn(app, @StartButtonPushed, true);
            app.Start.BackgroundColor = [0.4706 0.6706 0.1882];
            app.Start.FontSize = 36;
            app.Start.FontColor = [1 1 1];
            app.Start.Position = [336 23 203 53];
            app.Start.Text = 'Get Started';

            % Create Cancel
            app.Cancel = uibutton(app.UIFigure, 'push');
            app.Cancel.ButtonPushedFcn = createCallbackFcn(app, @CancelButtonPushed, true);
            app.Cancel.BackgroundColor = [0.6392 0.0784 0.1804];
            app.Cancel.FontSize = 36;
            app.Cancel.FontColor = [1 1 1];
            app.Cancel.Position = [108 23 127 53];
            app.Cancel.Text = 'Cancel';
        end
    end

    methods (Access = public)

        % Construct app
        function app = Initializer(varargin)

            % Create and configure components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @(app)startupFcn(app, varargin{:}))

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