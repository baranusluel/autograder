classdef Notifier < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                 matlab.ui.Figure
        Title                    matlab.ui.control.Label
        EmailPanel               matlab.ui.container.Panel
        Email                    matlab.ui.control.Switch
        ToLabel                  matlab.ui.control.Label
        To                       matlab.ui.control.EditField
        SlackPanel               matlab.ui.container.Panel
        Slack                    matlab.ui.control.Switch
        ChannelsListBoxLabel     matlab.ui.control.Label
        Channels                 matlab.ui.control.ListBox
        UsersListBoxLabel        matlab.ui.control.Label
        Users                    matlab.ui.control.ListBox
        TextMessagingPanel       matlab.ui.container.Panel
        Text                     matlab.ui.control.Switch
        NumberLabel              matlab.ui.control.Label
        Number                   matlab.ui.control.EditField
        SaveButton               matlab.ui.control.Button
        TestConfigurationButton  matlab.ui.control.Button
    end


    properties (Access = private)
        base Autograder % Description
        
        slackUsers struct;
        slackChannels;
    end


    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, baseApp)
            app.base = baseApp;
            % Email
            if ~isempty(app.base.email)
                app.Email.Value = 'On';
                app.To.Value = app.base.email;
                app.To.Visible = true;
                app.ToLabel.Visible = true;
            else
                app.Email.Value = 'Off';
                app.To.Visible = false';
                app.ToLabel.Visible = false;
            end
            % Slack
            if ~isempty(app.base.slackRecipients)
                % fill users AND groups. If ID matches, select
                choices = slackMessenger(app.base.slackToken);
                app.slackUsers = choices(strcmp({choices.type}, 'user'));
                app.slackChannels = choices(strcmp({choices.type}, 'channel'));
                
                userNames = {app.slackUsers.name};
                channelNames = {app.slackChannels.name};
                app.Channels.Items = channelNames;
                app.Channels.ItemsData = 1:numel(channelNames);
                app.Users.Items = userNames;
                app.Users.ItemsData = 1:numel(userNames);
            
                app.Slack.Value = 'On';
                app.Channels.Visible = true;
                app.ChannelsListBoxLabel.Visible = true;
                app.Users.Visible = true;
                app.UsersListBoxLabel.Visible = true;
                % for each channel and/or user, engage
                % for each recipient, engage (select)
                
                selectedChannels = zeros(1, numel(app.base.slackRecipients));
                selectedUsers = zeros(1, numel(app.base.slackRecipients));
                for s = 1:numel(app.base.slackRecipients)
                    % find id
                    if contains(app.base.slackRecipients(s).id, {app.slackChannels.id})
                        selectedChannels(s) = find(strcmp(app.base.slackRecipients(s).id, {app.slackChannels.id}));
                    end
                    if contains(app.base.slackRecipients(s).id, {app.slackUsers.id})
                        selectedUsers(s) = find(strcmp(app.base.slackRecipients(s).id, {app.slackUsers.id}));
                    end
                end
                selectedChannels(selectedChannels == 0) = [];
                selectedUsers(selectedUsers == 0) = [];
                app.Channels.Value = selectedChannels;
                app.Users.Value = selectedUsers;
            else
                app.Slack.Value = 'Off';
                app.Channels.Visible = false;
                app.ChannelsListBoxLabel.Visible = false;
                app.Users.Visible = false;
                app.UsersListBoxLabel.Visible = false;
            end
            % Text
            if ~isempty(app.base.phoneNumber)
                app.Text.Value = 'On';
                app.Number.Value = app.base.phoneNumber;
                app.Number.Visible = true;
                app.NumberLabel.Visible = true;
            else
                app.Text.Value = 'Off';
                app.Number.Visible = false;
                app.NumberLabel.Visible = false;
            end
        end

        % Button pushed function: SaveButton
        function SaveButtonPushed(app, ~)
            if strcmp(app.Email.Value, 'On')
                app.base.email = app.To.Value;
            else
                app.base.email = '';
            end
            
            if strcmp(app.Slack.Value, 'On')
                % get inds
                inds = app.Channels.Value;
                if isempty(inds)
                    inds = [];
                end
                channels = app.slackChannels(inds);
                inds = app.Users.Value;
                if isempty(inds)
                    inds = [];
                end
                users = app.slackUsers(inds);
                app.base.slackRecipients = [channels users];
            else
                app.base.slackRecipients = app.slackUsers([]);
            end
            
            if strcmp(app.Text.Value, 'On')
                app.base.phoneNumber = app.Number.Value;
            else
                app.base.phoneNumber = '';
            end
            uiresume(app.UIFigure);
            delete(app);
        end

        % Button pushed function: TestConfigurationButton
        function TestConfigurationButtonPushed(app, ~)
            % for each option (except canvas), send a notification if it's turned on
            try
                if strcmp(app.Email.Value, 'On')
                    emailMessenger(app.To.Value, 'Test', 'This is just a test notification from the Autograder!', ...
                        app.base.notifierToken, app.base.googleClientId, app.base.googleClientSecret, ...
                        app.base.driveKey);
                end
            catch
                uialert(app.UIFigure, 'Email failed to send', 'Email Failure');
                return;
            end
            try
                if strcmp(app.Slack.Value, 'On')
                    inds = app.Channels.Value;
                    if isempty(inds)
                        inds = [];
                    end
                    channels = app.slackChannels(inds);
                    inds = app.Users.Value;
                    if isempty(inds)
                        inds = [];
                    end
                    users = app.slackUsers(inds);
                    app.base.slackRecipients = [channels users];
                    slackMessenger(app.base.slackToken, {app.base.slackRecipients.id}, 'This is just a test notification from the Autograder!');
                end
            catch
                uialert(app.UIFigure, 'Slack Message failed to send', 'Slack Failure');
                return;
            end
            try
                if strcmp(app.Text.Value, 'On')
                    textMessenger(app.Number.Value, 'This is just a test notification from the Autograder!', ...
                        app.base.twilioSid, app.base.twilioToken, app.base.twilioOrigin);
                end
            catch
                uialert(app.UIFigure, 'Text failed to send', 'Text Failure');
                return;
            end
        end

        % Value changed function: Email
        function EmailValueChanged(app, ~)
            value = app.Email.Value;
            if strcmp(value, 'On')
                app.To.Visible = true;
                app.ToLabel.Visible = true;
            else
                app.To.Visible = false;
                app.ToLabel.Visible = false;
            end
        end

        % Value changed function: Text
        function TextValueChanged(app, ~)
            value = app.Text.Value;
            if strcmp(value, 'On')
                app.Number.Visible = true;
                app.NumberLabel.Visible = true;
            else
                app.Number.Visible = false;
                app.NumberLabel.Visible = false;
            end
        end

        % Value changed function: Slack
        function SlackValueChanged(app, ~)
            value = app.Slack.Value;
            if strcmp(value, 'On')
                p = uiprogressdlg(app.UIFigure, 'Cancelable', 'off', 'Indeterminate', 'on', ...
                    'Message', 'Loading Slack Options...', 'ShowPercentage', 'off', 'Title', 'Notifications');
                app.Channels.Visible = true;
                app.ChannelsListBoxLabel.Visible = true;
                app.Users.Visible = true;
                app.UsersListBoxLabel.Visible = true;
                
                choices = slackMessenger(app.base.slackToken);
                app.slackUsers = choices(strcmp({choices.type}, 'user'));
                app.slackChannels = choices(strcmp({choices.type}, 'channel'));
                
                userNames = {app.slackUsers.name};
                channelNames = {app.slackChannels.name};
                app.Channels.Items = channelNames;
                app.Channels.ItemsData = 1:numel(channelNames);
                app.Users.Items = userNames;
                app.Users.ItemsData = 1:numel(userNames);
            
                app.Channels.Visible = true;
                app.ChannelsListBoxLabel.Visible = true;
                app.Users.Visible = true;
                app.UsersListBoxLabel.Visible = true;
                % for each channel and/or user, engage
                % for each recipient, engage (select)
                
                selectedChannels = zeros(1, numel(app.base.slackRecipients));
                selectedUsers = zeros(1, numel(app.base.slackRecipients));
                for s = 1:numel(app.base.slackRecipients)
                    % find id
                    if contains(app.base.slackRecipients(s).id, {app.slackChannels.id})
                        selectedChannels(s) = find(strcmp(app.base.slackRecipients(s).id, {app.slackChannels.id}));
                    end
                    if contains(app.base.slackRecipients(s).id, {app.slackUsers.id})
                        selectedUsers(s) = find(strcmp(app.base.slackRecipients(s).id, {app.slackUsers.id}));
                    end
                end
                selectedChannels(selectedChannels == 0) = [];
                selectedUsers(selectedUsers == 0) = [];
                app.Channels.Value = selectedChannels;
                app.Users.Value = selectedUsers;
                close(p);
            else
                app.Channels.Visible = false;
                app.ChannelsListBoxLabel.Visible = false;
                app.Users.Visible = false;
                app.UsersListBoxLabel.Visible = false;
            end
        end
    end

    % App initialization and construction
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure
            app.UIFigure = uifigure;
            app.UIFigure.Position = [100 100 473 524];
            app.UIFigure.Name = 'Notifications';

            % Create Title
            app.Title = uilabel(app.UIFigure);
            app.Title.FontSize = 36;
            app.Title.FontWeight = 'bold';
            app.Title.Position = [60 477 356 48];
            app.Title.Text = 'Notification Settings';

            % Create EmailPanel
            app.EmailPanel = uipanel(app.UIFigure);
            app.EmailPanel.Title = 'Email';
            app.EmailPanel.FontWeight = 'bold';
            app.EmailPanel.FontSize = 20;
            app.EmailPanel.Position = [1 408 474 70];

            % Create Email
            app.Email = uiswitch(app.EmailPanel, 'slider');
            app.Email.ValueChangedFcn = createCallbackFcn(app, @EmailValueChanged, true);
            app.Email.Position = [29 12 45 20];

            % Create ToLabel
            app.ToLabel = uilabel(app.EmailPanel);
            app.ToLabel.HorizontalAlignment = 'right';
            app.ToLabel.Position = [169 11 25 22];
            app.ToLabel.Text = 'To:';

            % Create To
            app.To = uieditfield(app.EmailPanel, 'text');
            app.To.Position = [209 11 241 22];

            % Create SlackPanel
            app.SlackPanel = uipanel(app.UIFigure);
            app.SlackPanel.Title = 'Slack';
            app.SlackPanel.FontWeight = 'bold';
            app.SlackPanel.FontSize = 20;
            app.SlackPanel.Position = [1 71 474 262];

            % Create Slack
            app.Slack = uiswitch(app.SlackPanel, 'slider');
            app.Slack.ValueChangedFcn = createCallbackFcn(app, @SlackValueChanged, true);
            app.Slack.Position = [29 206 45 20];

            % Create ChannelsListBoxLabel
            app.ChannelsListBoxLabel = uilabel(app.SlackPanel);
            app.ChannelsListBoxLabel.HorizontalAlignment = 'right';
            app.ChannelsListBoxLabel.Position = [273 205 56 22];
            app.ChannelsListBoxLabel.Text = 'Channels';

            % Create Channels
            app.Channels = uilistbox(app.SlackPanel);
            app.Channels.Items = {};
            app.Channels.Multiselect = 'on';
            app.Channels.Position = [272 12 190 194];
            app.Channels.Value = {};

            % Create UsersListBoxLabel
            app.UsersListBoxLabel = uilabel(app.SlackPanel);
            app.UsersListBoxLabel.HorizontalAlignment = 'right';
            app.UsersListBoxLabel.Position = [118 205 37 22];
            app.UsersListBoxLabel.Text = 'Users';

            % Create Users
            app.Users = uilistbox(app.SlackPanel);
            app.Users.Items = {};
            app.Users.Multiselect = 'on';
            app.Users.Position = [115 12 148 194];
            app.Users.Value = {};

            % Create TextMessagingPanel
            app.TextMessagingPanel = uipanel(app.UIFigure);
            app.TextMessagingPanel.Title = 'Text Messaging';
            app.TextMessagingPanel.FontWeight = 'bold';
            app.TextMessagingPanel.FontSize = 20;
            app.TextMessagingPanel.Position = [1 332 474 77];

            % Create Text
            app.Text = uiswitch(app.TextMessagingPanel, 'slider');
            app.Text.ValueChangedFcn = createCallbackFcn(app, @TextValueChanged, true);
            app.Text.Position = [29 21 45 20];

            % Create NumberLabel
            app.NumberLabel = uilabel(app.TextMessagingPanel);
            app.NumberLabel.HorizontalAlignment = 'right';
            app.NumberLabel.Position = [115 20 86 22];
            app.NumberLabel.Text = 'Phone Number';

            % Create Number
            app.Number = uieditfield(app.TextMessagingPanel, 'text');
            app.Number.Position = [211 20 239 22];

            % Create SaveButton
            app.SaveButton = uibutton(app.UIFigure, 'push');
            app.SaveButton.ButtonPushedFcn = createCallbackFcn(app, @SaveButtonPushed, true);
            app.SaveButton.BackgroundColor = [0.4706 0.6706 0.1882];
            app.SaveButton.FontSize = 24;
            app.SaveButton.FontColor = [1 1 1];
            app.SaveButton.Position = [351 24 100 38];
            app.SaveButton.Text = 'Save';

            % Create TestConfigurationButton
            app.TestConfigurationButton = uibutton(app.UIFigure, 'push');
            app.TestConfigurationButton.ButtonPushedFcn = createCallbackFcn(app, @TestConfigurationButtonPushed, true);
            app.TestConfigurationButton.BackgroundColor = [0 0.451 0.7412];
            app.TestConfigurationButton.FontSize = 24;
            app.TestConfigurationButton.FontColor = [1 1 1];
            app.TestConfigurationButton.Position = [87 24 233 38];
            app.TestConfigurationButton.Text = 'Test Configuration...';
        end
    end

    methods (Access = public)

        % Construct app
        function app = Notifier(varargin)

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