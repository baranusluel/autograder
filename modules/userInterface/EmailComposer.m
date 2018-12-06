classdef EmailComposer < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure              matlab.ui.Figure
        MessageTextAreaLabel  matlab.ui.control.Label
        Message               matlab.ui.control.TextArea
        Confirm               matlab.ui.control.Button
    end


    properties (Access = private)
        base Autograder; % Description
    end


    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, baseApp)
            app.base = baseApp;
            app.Message.Value = app.base.emailMessage;
        end

        % Button pushed function: Confirm
        function ConfirmButtonPushed(app, ~)
            app.base.emailMessage = app.Message.Value;
            uiresume(app.UIFigure);
        end
    end

    % App initialization and construction
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure
            app.UIFigure = uifigure;
            app.UIFigure.Position = [100 100 640 455];
            app.UIFigure.Name = 'Email Composer';

            % Create MessageTextAreaLabel
            app.MessageTextAreaLabel = uilabel(app.UIFigure);
            app.MessageTextAreaLabel.HorizontalAlignment = 'right';
            app.MessageTextAreaLabel.FontSize = 20;
            app.MessageTextAreaLabel.Position = [289 430 87 26];
            app.MessageTextAreaLabel.Text = 'Message';

            % Create Message
            app.Message = uitextarea(app.UIFigure);
            app.Message.FontSize = 20;
            app.Message.Position = [1 65 640 357];

            % Create Confirm
            app.Confirm = uibutton(app.UIFigure, 'push');
            app.Confirm.ButtonPushedFcn = createCallbackFcn(app, @ConfirmButtonPushed, true);
            app.Confirm.FontSize = 26;
            app.Confirm.Position = [507 15 108 41];
            app.Confirm.Text = 'Confirm';
        end
    end

    methods (Access = public)

        % Construct app
        function app = EmailComposer(varargin)

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