classdef MarkdownHelper < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        Markdown                       matlab.ui.Figure
        Label                          matlab.ui.control.Label
        BoldTexttoBoldLabel            matlab.ui.control.Label
        Italics_TexttoItalicize_Label  matlab.ui.control.Label
        HeadingsHeader1Header2Header3Label  matlab.ui.control.Label
        LinksTexttoDisplaylinktosourceLabel  matlab.ui.control.Label
        CodeTextasCodeORmultiplelinesofcodeLabel  matlab.ui.control.Label
        BulletPointsTexttobulletLabel  matlab.ui.control.Label
    end

    % App initialization and construction
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create Markdown
            app.Markdown = uifigure;
            app.Markdown.Position = [100 100 421 591];
            app.Markdown.Name = 'Markdown';

            % Create Label
            app.Label = uilabel(app.Markdown);
            app.Label.FontSize = 22;
            app.Label.FontWeight = 'bold';
            app.Label.Position = [6 426 425 166];
            app.Label.Text = {'When the Markdown checkbox is'; 'checked, this text box supports'; 'a limited set of the Markdown'; 'language, as shown below. Otherwise,'; 'it is assumed to be HTML or plain text'};

            % Create BoldTexttoBoldLabel
            app.BoldTexttoBoldLabel = uilabel(app.Markdown);
            app.BoldTexttoBoldLabel.FontSize = 22;
            app.BoldTexttoBoldLabel.Position = [9 398 239 29];
            app.BoldTexttoBoldLabel.Text = '1. Bold: **Text to Bold**';

            % Create Italics_TexttoItalicize_Label
            app.Italics_TexttoItalicize_Label = uilabel(app.Markdown);
            app.Italics_TexttoItalicize_Label.FontSize = 22;
            app.Italics_TexttoItalicize_Label.Position = [9 352 270 29];
            app.Italics_TexttoItalicize_Label.Text = '2. Italics: _Text to Italicize_';

            % Create HeadingsHeader1Header2Header3Label
            app.HeadingsHeader1Header2Header3Label = uilabel(app.Markdown);
            app.HeadingsHeader1Header2Header3Label.FontSize = 22;
            app.HeadingsHeader1Header2Header3Label.Position = [9 9 264 81];
            app.HeadingsHeader1Header2Header3Label.Text = {'6. Headings: # Header1'; '                     ## Header2'; '                     ### Header3'};

            % Create LinksTexttoDisplaylinktosourceLabel
            app.LinksTexttoDisplaylinktosourceLabel = uilabel(app.Markdown);
            app.LinksTexttoDisplaylinktosourceLabel.FontSize = 22;
            app.LinksTexttoDisplaylinktosourceLabel.Position = [9 167 402 29];
            app.LinksTexttoDisplaylinktosourceLabel.Text = '4. Links: [Text to Display](link/to/source)';

            % Create CodeTextasCodeORmultiplelinesofcodeLabel
            app.CodeTextasCodeORmultiplelinesofcodeLabel = uilabel(app.Markdown);
            app.CodeTextasCodeORmultiplelinesofcodeLabel.FontSize = 22;
            app.CodeTextasCodeORmultiplelinesofcodeLabel.Position = [9 195 310 135];
            app.CodeTextasCodeORmultiplelinesofcodeLabel.Text = {'3. Code: `Text as Code`'; '               OR'; '               ```'; '               multiple lines of code'; '              ```'};

            % Create BulletPointsTexttobulletLabel
            app.BulletPointsTexttobulletLabel = uilabel(app.Markdown);
            app.BulletPointsTexttobulletLabel.FontSize = 22;
            app.BulletPointsTexttobulletLabel.Position = [9 113 311 29];
            app.BulletPointsTexttobulletLabel.Text = '5. Bullet Points: - Text to bullet';
        end
    end

    methods (Access = public)

        % Construct app
        function app = MarkdownHelper

            % Create and configure components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.Markdown)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.Markdown)
        end
    end
end