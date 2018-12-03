classdef GithubAuthorizer < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure             matlab.ui.Figure
        Title                matlab.ui.control.Label
        GithubToken          matlab.ui.control.EditField
        NoTokenBanner        matlab.ui.control.Label
        Directions           matlab.ui.control.Label
        Submit               matlab.ui.control.Button
        InvalidTokenWarning  matlab.ui.control.Label
        Cancel               matlab.ui.control.Button
    end


    properties (Access = private)
        baseApp Autograder;
    end

    methods (Access = private)
    
        function isValid = validateToken(~, token)
            API = 'https://github.gatech.edu/api/v3/repos/CS1371/autograder/releases/latest';
            opts = weboptions;
            opts.HeaderFields = {'Authorization', ['Bearer ' token]};
            try
                webread(API, opts);
                isValid = true;
            catch
                isValid= false;
            end
        end
        
    end


    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, base)
            app.baseApp = base;
            app.InvalidTokenWarning.Visible = false;
        end

        % Button pushed function: Submit
        function SubmitButtonPushed(app, ~)
            % check the token - if it works, store in base. Otherwise, tell user
            app.InvalidTokenWarning.Visible = false;
            if ~isempty(app.GithubToken.Value) && app.validateToken(app.GithubToken.Value)
                app.baseApp.githubToken = app.GithubToken.Value;
                app.baseApp.savePreferences();
                uiresume(app.UIFigure);
            else
                app.InvalidTokenWarning.Visible = true;
            end
        end

        % Button pushed function: Cancel
        function CancelButtonPushed(app, ~)
            uiresume(app.UIFigure);
        end
    end

    % App initialization and construction
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure
            app.UIFigure = uifigure;
            app.UIFigure.Position = [100 100 716 350];
            app.UIFigure.Name = 'GitHub Authorizer';

            % Create Title
            app.Title = uilabel(app.UIFigure);
            app.Title.HorizontalAlignment = 'center';
            app.Title.FontSize = 26;
            app.Title.FontAngle = 'italic';
            app.Title.Position = [1 291 716 60];
            app.Title.Text = 'To check for updates, we''ll need a token from GitHub';

            % Create GithubToken
            app.GithubToken = uieditfield(app.UIFigure, 'text');
            app.GithubToken.FontSize = 20;
            app.GithubToken.Position = [1 260 716 29];

            % Create NoTokenBanner
            app.NoTokenBanner = uilabel(app.UIFigure);
            app.NoTokenBanner.HorizontalAlignment = 'center';
            app.NoTokenBanner.FontSize = 24;
            app.NoTokenBanner.FontColor = [0.6392 0.0784 0.1804];
            app.NoTokenBanner.Position = [82 121 554 30];
            app.NoTokenBanner.Text = 'Dont'' have a Token? Follow the instructions below:';

            % Create Directions
            app.Directions = uilabel(app.UIFigure);
            app.Directions.FontSize = 18;
            app.Directions.Position = [11 12 658 110];
            app.Directions.Text = {'1. Go to your profile/account page on GitHub, and click Developer Settings'; '2. Go to the Personal Access Tokens, and click the Generate New Token button'; '3. Name it something - "Autograder" should be sufficient'; '4. You should only give it repo access.'; '5. Copy the token it provides, and paste it above.'};

            % Create Submit
            app.Submit = uibutton(app.UIFigure, 'push');
            app.Submit.ButtonPushedFcn = createCallbackFcn(app, @SubmitButtonPushed, true);
            app.Submit.BackgroundColor = [0.4706 0.6706 0.1882];
            app.Submit.FontSize = 18;
            app.Submit.FontAngle = 'italic';
            app.Submit.FontColor = [1 1 1];
            app.Submit.Position = [411 227 100 29];
            app.Submit.Text = 'Submit';

            % Create InvalidTokenWarning
            app.InvalidTokenWarning = uilabel(app.UIFigure);
            app.InvalidTokenWarning.HorizontalAlignment = 'center';
            app.InvalidTokenWarning.FontSize = 24;
            app.InvalidTokenWarning.FontWeight = 'bold';
            app.InvalidTokenWarning.FontColor = [0.6392 0.0784 0.1804];
            app.InvalidTokenWarning.Position = [1 160 716 55];
            app.InvalidTokenWarning.Text = {'Hmmm... That token didn''t seem to work.'; 'Make sure that you entered the token correctly, and try again'};

            % Create Cancel
            app.Cancel = uibutton(app.UIFigure, 'push');
            app.Cancel.ButtonPushedFcn = createCallbackFcn(app, @CancelButtonPushed, true);
            app.Cancel.BackgroundColor = [0.6392 0.0784 0.1804];
            app.Cancel.FontSize = 18;
            app.Cancel.FontAngle = 'italic';
            app.Cancel.FontColor = [1 1 1];
            app.Cancel.Position = [211 227 100 29];
            app.Cancel.Text = 'Cancel';
        end
    end

    methods (Access = public)

        % Construct app
        function app = GithubAuthorizer(varargin)

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