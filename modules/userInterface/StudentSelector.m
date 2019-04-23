%% StudentSelector: Graphically Select Student
%
% This allows the user to graphically select students from an archive or
% Canvas.
classdef StudentSelector < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                      matlab.ui.Figure
        StudentswithSubmissionsListBoxLabel  matlab.ui.control.Label
        AvailableListBox              matlab.ui.control.ListBox
        SelectedStudentsListBoxLabel  matlab.ui.control.Label
        SelectedListBox               matlab.ui.control.ListBox
        AddButton                     matlab.ui.control.Button
        RemoveButton                  matlab.ui.control.Button
        SearchLabel                   matlab.ui.control.Label
        SearchField                   matlab.ui.control.EditField
        SelectAllButton               matlab.ui.control.Button
        DeselectAllButton             matlab.ui.control.Button
        CancelButton                  matlab.ui.control.Button
        SubmitButton                  matlab.ui.control.Button
    end


    properties (Access = private)
        students
        base Autograder;
    end

    methods (Access = private)
    
        function getStudents(app)
            p = uiprogressdlg(app.UIFigure, 'Title', 'Acquiring Students', ...
                            'Message', 'Acquiring student information', 'Indeterminate', 'on');
            if ~isempty(app.base.homeworkArchivePath)
                % create a temporary folder
                sortedPath = tempname;
                mkdir(sortedPath);
                canvas2autograder(app.base.homeworkArchivePath, ...
                    app.base.homeworkGradebookPath, ...
                    sortedPath, ...
                    p);
                app.students = generateStudents(sortedPath, p);
                app.students = struct('name', {app.students.name}, ...
                    'login_id', {app.students.id}, ...
                    'section', {app.students.section}, ...
                    'id', {app.students.canvasId});
                [~] = rmdir(sortedPath, 's');
            elseif ~isempty(app.base.canvasCourseId) && ~isempty(app.base.canvasHomeworkId) && ~isempty(app.base.canvasToken)
                app.students = getCanvasStudents(app.base.canvasCourseId, app.base.canvasHomeworkId, ...
                    app.base.canvasToken, p);
            else
                delete(app);
                return;
            end
            [~, inds] = sort({app.students.login_id});
            app.students = app.students(inds);
            app.AvailableListBox.ItemsData = app.students;
            names = string({app.students.name});
            ids = string({app.students.login_id});
            app.AvailableListBox.Items = compose('%s (%s)', names', ids');
            close(p);
        end
        
    end


    methods (Access = private)

        % Code that executes after component creation
        function onStartup(app, mainapp)
            app.base = mainapp;
            addpath(genpath(fileparts(fileparts(mfilename('fullpath')))));
            getStudents(app);
        end

        % Button pushed function: SelectAllButton
        function SelectAllPressed(app, ~)
            app.AvailableListBox.Value = app.AvailableListBox.ItemsData;
        end

        % Button pushed function: DeselectAllButton
        function DeselectAllPressed(app, ~)
            app.AvailableListBox.Value = {};
        end

        % Button pushed function: AddButton
        function AddButtonPressed(app, ~)
            app.SelectedListBox.ItemsData = [app.SelectedListBox.ItemsData ...
                    app.AvailableListBox.Value];
            names = string({app.AvailableListBox.Value.name});
            ids = string({app.AvailableListBox.Value.login_id});
            vals = compose('%s (%s)', names', ids');
            app.SelectedListBox.Items = [app.SelectedListBox.Items vals];
            [app.SelectedListBox.Items, inds] = sort(app.SelectedListBox.Items);
            app.SelectedListBox.ItemsData = app.SelectedListBox.ItemsData(inds);
            mask = contains(app.AvailableListBox.Items, vals);
            app.AvailableListBox.Value = {};
            app.AvailableListBox.Items(mask) = [];
            app.AvailableListBox.ItemsData(mask) = [];
        end

        % Button pushed function: RemoveButton
        function RemoveButtonPressed(app, ~)
            names = string({app.SelectedListBox.Value.name});
            ids = string({app.SelectedListBox.Value.login_id});
            vals = compose('%s (%s)', names', ids');
            mask  = contains(app.SelectedListBox.Items, vals);
            app.AvailableListBox.Items = [app.AvailableListBox.Items ...
                vals];
            app.AvailableListBox.ItemsData = [app.AvailableListBox.ItemsData ...
                app.SelectedListBox.ItemsData(mask)];
            [app.AvailableListBox.Items, inds] = sort(app.AvailableListBox.Items);
            app.AvailableListBox.ItemsData = app.AvailableListBox.ItemsData(inds);
            app.SelectedListBox.Value = {};
            app.SelectedListBox.Items(mask) = [];
            app.SelectedListBox.ItemsData(mask) = [];
        end

        % Button pushed function: CancelButton
        function CancelButtonPressed(app, ~)
            delete(app);
        end

        % Value changing function: SearchField
        function SearchFieldChanged(app, event)
            app.AvailableListBox.BackgroundColor = [0.9 0.9 0.9];
            drawnow;
            changingValue = event.Value;
            mask = contains({app.students.name}, changingValue, 'IgnoreCase', true) | ...
                contains({app.students.login_id}, changingValue, 'IgnoreCase', true);
            
            studs = app.students(mask);
            names = string({studs.name});
            ids = string({studs.login_id});
            app.AvailableListBox.ItemsData = studs;
            app.AvailableListBox.Items = compose('%s (%s)', names', ids');
            app.AvailableListBox.BackgroundColor = [1 1 1];
        end

        % Button pushed function: SubmitButton
        function SubmitButtonPressed(app, ~)
            app.base.selectedStudents = app.SelectedListBox.ItemsData;
            uiresume(app.UIFigure);
        end
    end

    % App initialization and construction
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure
            app.UIFigure = uifigure;
            app.UIFigure.Position = [100 100 640 480];
            app.UIFigure.Name = 'Student Selector';

            % Create StudentswithSubmissionsListBoxLabel
            app.StudentswithSubmissionsListBoxLabel = uilabel(app.UIFigure);
            app.StudentswithSubmissionsListBoxLabel.HorizontalAlignment = 'right';
            app.StudentswithSubmissionsListBoxLabel.Position = [23 441 149 22];
            app.StudentswithSubmissionsListBoxLabel.Text = 'Students with Submissions';

            % Create AvailableListBox
            app.AvailableListBox = uilistbox(app.UIFigure);
            app.AvailableListBox.Items = {};
            app.AvailableListBox.Multiselect = 'on';
            app.AvailableListBox.Position = [23 102 256 340];
            app.AvailableListBox.Value = {};

            % Create SelectedStudentsListBoxLabel
            app.SelectedStudentsListBoxLabel = uilabel(app.UIFigure);
            app.SelectedStudentsListBoxLabel.HorizontalAlignment = 'right';
            app.SelectedStudentsListBoxLabel.Position = [368 441 103 22];
            app.SelectedStudentsListBoxLabel.Text = 'Selected Students';

            % Create SelectedListBox
            app.SelectedListBox = uilistbox(app.UIFigure);
            app.SelectedListBox.Items = {};
            app.SelectedListBox.Multiselect = 'on';
            app.SelectedListBox.Position = [368 102 256 340];
            app.SelectedListBox.Value = {};

            % Create AddButton
            app.AddButton = uibutton(app.UIFigure, 'push');
            app.AddButton.ButtonPushedFcn = createCallbackFcn(app, @AddButtonPressed, true);
            app.AddButton.Position = [287 344 72 22];
            app.AddButton.Text = '>>';

            % Create RemoveButton
            app.RemoveButton = uibutton(app.UIFigure, 'push');
            app.RemoveButton.ButtonPushedFcn = createCallbackFcn(app, @RemoveButtonPressed, true);
            app.RemoveButton.Position = [287 296 72 22];
            app.RemoveButton.Text = '<<';

            % Create SearchLabel
            app.SearchLabel = uilabel(app.UIFigure);
            app.SearchLabel.HorizontalAlignment = 'right';
            app.SearchLabel.Position = [23 69 43 22];
            app.SearchLabel.Text = 'Search';

            % Create SearchField
            app.SearchField = uieditfield(app.UIFigure, 'text');
            app.SearchField.ValueChangingFcn = createCallbackFcn(app, @SearchFieldChanged, true);
            app.SearchField.Position = [81 69 198 22];

            % Create SelectAllButton
            app.SelectAllButton = uibutton(app.UIFigure, 'push');
            app.SelectAllButton.ButtonPushedFcn = createCallbackFcn(app, @SelectAllPressed, true);
            app.SelectAllButton.Position = [23 35 100 22];
            app.SelectAllButton.Text = 'Select All';

            % Create DeselectAllButton
            app.DeselectAllButton = uibutton(app.UIFigure, 'push');
            app.DeselectAllButton.ButtonPushedFcn = createCallbackFcn(app, @DeselectAllPressed, true);
            app.DeselectAllButton.Position = [179 35 100 22];
            app.DeselectAllButton.Text = 'Deselect All';

            % Create CancelButton
            app.CancelButton = uibutton(app.UIFigure, 'push');
            app.CancelButton.ButtonPushedFcn = createCallbackFcn(app, @CancelButtonPressed, true);
            app.CancelButton.Position = [410 14 100 22];
            app.CancelButton.Text = 'Cancel';

            % Create SubmitButton
            app.SubmitButton = uibutton(app.UIFigure, 'push');
            app.SubmitButton.ButtonPushedFcn = createCallbackFcn(app, @SubmitButtonPressed, true);
            app.SubmitButton.BackgroundColor = [0.4 0.702 0.1882];
            app.SubmitButton.Position = [524 14 100 22];
            app.SubmitButton.FontColor = [1 1 1];
            app.SubmitButton.Text = 'Submit';
        end
    end

    methods (Access = public)

        % Construct app
        function app = StudentSelector(varargin)

            % Create and configure components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @(app)onStartup(app, varargin{:}))

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