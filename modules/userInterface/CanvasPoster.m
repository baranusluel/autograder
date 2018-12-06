classdef CanvasPoster < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure      matlab.ui.Figure
        TitleLabel    matlab.ui.control.Label
        Title         matlab.ui.control.EditField
        MessageLabel  matlab.ui.control.Label
        Message       matlab.ui.control.TextArea
        Confirm       matlab.ui.control.Button
        Cancel        matlab.ui.control.Button
        Help          matlab.ui.control.Button
        Preview       matlab.ui.control.Button
        Format        matlab.ui.container.ButtonGroup
        IsMarkdown    matlab.ui.control.ToggleButton
        IsPlain       matlab.ui.control.ToggleButton
        IsHTML        matlab.ui.control.ToggleButton
    end


    properties (Access = public)
        html char;
    end

    methods (Access = private)
    
        function txt = encodeHtml(~, txt)
            txt = strrep(txt, '&', '&amp;');
            txt = strrep(txt, '<', '&lt;');
            txt = strrep(txt, '>', '&gt;');
            txt = strrep(txt, newline, '<br />');
        end
        
    end


    methods (Access = private)

        % Button pushed function: Help
        function HelpButtonPushed(~, ~)
            MarkdownHelper();
        end

        % Button pushed function: Preview
        function PreviewPushed(app, ~)
            % parse README; then, write HTML and preview in browser
            if app.IsMarkdown.Value
                txt = cellfun(@(ln)(app.encodeHtml(ln)), app.Message.Value, 'uni', false);
                app.html = strjoin(parseReadme(txt, false), newline);
                temp = strjoin(parseReadme(txt, true), newline);
            elseif app.IsPlain.Value
                app.html = app.encodeHtml(strjoin(app.Message.Value, newline));
                temp = app.html;
            else
                app.html = strjoin(app.Message.Value, '<br />');
                temp = app.html;
            end
            tName = [tempname '.html'];
            fid = fopen(tName, 'wt');
            fwrite(fid, temp);
            fclose(fid);
            web(['file:///' tName], '-browser');
        end

        % Button pushed function: Confirm
        function ConfirmButtonPushed(app, ~)
            if app.IsMarkdown.Value
                txt = cellfun(@(ln)(app.encodeHtml(ln)), app.Message.Value, 'uni', false);
                app.html = strjoin(parseReadme(txt, false), newline);
            elseif app.IsPlain.Value
                app.html = app.encodeHtml(strjoin(app.Message.Value, newline));
            else
                app.html = strjoin(app.Message.Value, '<br />');
            end
            
            uiresume(app.UIFigure);
        end

        % Button pushed function: Cancel
        function CancelButtonPushed(app, ~)
            delete(app);
        end
    end

    % App initialization and construction
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure
            app.UIFigure = uifigure;
            app.UIFigure.Position = [100 100 714 405];
            app.UIFigure.Name = 'Posting to Canvas...';

            % Create TitleLabel
            app.TitleLabel = uilabel(app.UIFigure);
            app.TitleLabel.HorizontalAlignment = 'right';
            app.TitleLabel.FontSize = 18;
            app.TitleLabel.Position = [1 383 39 23];
            app.TitleLabel.Text = 'Title';

            % Create Title
            app.Title = uieditfield(app.UIFigure, 'text');
            app.Title.FontSize = 18;
            app.Title.Position = [39 352 535 27];

            % Create MessageLabel
            app.MessageLabel = uilabel(app.UIFigure);
            app.MessageLabel.HorizontalAlignment = 'right';
            app.MessageLabel.FontSize = 18;
            app.MessageLabel.Position = [4 328 79 23];
            app.MessageLabel.Text = 'Message';

            % Create Message
            app.Message = uitextarea(app.UIFigure);
            app.Message.FontSize = 18;
            app.Message.Position = [39 16 538 307];

            % Create Confirm
            app.Confirm = uibutton(app.UIFigure, 'push');
            app.Confirm.ButtonPushedFcn = createCallbackFcn(app, @ConfirmButtonPushed, true);
            app.Confirm.BackgroundColor = [0.4706 0.6706 0.1882];
            app.Confirm.FontSize = 24;
            app.Confirm.FontColor = [1 1 1];
            app.Confirm.Position = [595 25 101 38];
            app.Confirm.Text = 'Confirm';

            % Create Cancel
            app.Cancel = uibutton(app.UIFigure, 'push');
            app.Cancel.ButtonPushedFcn = createCallbackFcn(app, @CancelButtonPushed, true);
            app.Cancel.FontSize = 18;
            app.Cancel.Position = [594 76 100 30];
            app.Cancel.Text = 'Cancel';

            % Create Help
            app.Help = uibutton(app.UIFigure, 'push');
            app.Help.ButtonPushedFcn = createCallbackFcn(app, @HelpButtonPushed, true);
            app.Help.FontSize = 18;
            app.Help.Position = [584 189 29 30];
            app.Help.Text = '?';

            % Create Preview
            app.Preview = uibutton(app.UIFigure, 'push');
            app.Preview.ButtonPushedFcn = createCallbackFcn(app, @PreviewPushed, true);
            app.Preview.FontSize = 18;
            app.Preview.Position = [589 151 100 30];
            app.Preview.Text = 'Preview...';

            % Create Format
            app.Format = uibuttongroup(app.UIFigure);
            app.Format.Title = 'Format';
            app.Format.Position = [583 226 123 106];

            % Create IsMarkdown
            app.IsMarkdown = uitogglebutton(app.Format);
            app.IsMarkdown.Text = 'Markdown';
            app.IsMarkdown.Position = [11 53 100 22];
            app.IsMarkdown.Value = true;

            % Create IsPlain
            app.IsPlain = uitogglebutton(app.Format);
            app.IsPlain.Text = 'Plain Text';
            app.IsPlain.Position = [11 32 100 22];

            % Create IsHTML
            app.IsHTML = uitogglebutton(app.Format);
            app.IsHTML.Text = 'HTML';
            app.IsHTML.Position = [11 11 100 22];
        end
    end

    methods (Access = public)

        % Construct app
        function app = CanvasPoster

            % Create and configure components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

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