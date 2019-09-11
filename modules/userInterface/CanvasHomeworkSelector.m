%% CanvasHomeworkSelector: Select a Homework Submission
%
% This allows the user to select a specific homework submission directly
% from Canvas.
classdef CanvasHomeworkSelector < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure          matlab.ui.Figure
        AssignmentsLabel  matlab.ui.control.Label
        Assignments       matlab.ui.control.ListBox
        Select            matlab.ui.control.Button
        Cancel            matlab.ui.control.Button
        Course            matlab.ui.control.DropDown
        ShowPastCourses   matlab.ui.control.CheckBox
    end


    properties (Access = private)
        baseApp Autograder
        homeworkId char
        homeworkName char
        names;
    end
    
    properties (Constant)
        SPRING_MONTH double = 1; % Start month for spring semester
        SUMMER_MONTH double = 5; % Start month for summer semester
        LATE_SUMMER_MONTH double = 7; % Start month for late summer semester
        FALL_MONTH double = 8; % Start month for fall semester
    end


    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, base)
            app.baseApp = base;
            token = app.baseApp.canvasToken;
            p = uiprogressdlg(app.UIFigure);
            p.Title = 'Progress';
            p.Message = 'Loading Homeworks';
            p.Indeterminate = 'on';
            p.Cancelable = false;
            API = 'https://gatech.instructure.com/api/v1/';
            COURSE_CODE = {'CS 1371', 'CS-1371'};
            % request assignment details from canvas
            apiOpts = weboptions;
            apiOpts.RequestMethod = 'GET';
            apiOpts.HeaderFields = {'Authorization', ['Bearer ' token]};
            
            % get course ID
            % find course ID; it will be the only course active
            data = webread([API 'courses/'], 'per_page', '100', apiOpts);
            if isempty(data)
                % return
                return;
            end
            % data will PROBABLY be a cell array
            if ~iscell(data)
            % a stucture. num2cell it and proceed
                data = num2cell(data);
            end
            % anything that doesn't have a name field should die
            courses = data;
            courses(cellfun(@(s)(~isfield(s, 'name')), courses)) = [];
            courseIds = zeros(1, numel(courses));
            courseNames = cell(1, numel(courses));
            courseId = -1;
            % order courses by their start_at
            for c = numel(courses):-1:1
                if isempty(courses{c}.start_at)
                    starting{c} = datetime() - years(1);
                else
                    starting{c} = datetime(courses{c}.start_at, ...
                        'InputFormat','yyyy-MM-dd''T''HH:mm:ssXXX', ...
                        'TimeZone', 'America/New_York');
                end
                starting{c}.TimeZone = '';
            end
            starting = [starting{:}];
            [~, inds] = sort(starting, 'descend');
            courses = courses(inds);
            
            for c = numel(courses):-1:1
                if isempty(courses{c}.end_at)
                    % do datetime() + 
                    ending = datetime() + years(1);
                else
                    ending = datetime(courses{c}.end_at, ...
                        'InputFormat','yyyy-MM-dd''T''HH:mm:ssXXX', ...
                        'TimeZone', 'America/New_York');
                end
                if isempty(courses{c}.start_at)
                    starting = datetime() - years(1);
                else
                    starting = datetime(courses{c}.start_at, ...
                        'InputFormat','yyyy-MM-dd''T''HH:mm:ssXXX', ...
                        'TimeZone', 'America/New_York');
                end
                ending.TimeZone = '';
                starting.TimeZone = '';
                if ending >= datetime() || app.ShowPastCourses.Value
                    if any(contains(courses{c}.course_code, COURSE_CODE)) && ...
                            starting < datetime() && ending > datetime()
                        % This is our course!
                        courseId = courses{c}.id;
                    end
                    courseIds(c) = courses{c}.id;
                    switch starting.Month
                        case app.SPRING_MONTH
                            suffix = ' (Spring ';
                        case app.SUMMER_MONTH
                            suffix = ' (Summer ';
                        case app.LATE_SUMMER_MONTH
                            suffix = ' (Late Summer ';
                        case app.FALL_MONTH
                            suffix = ' (Fall ';
                        otherwise
                            suffix = ' (';
                    end
                    ending = [suffix num2str(starting.Year) ')'];
                    courseNames{c} = [courses{c}.course_code ending];
                else
                    courseIds(c) = [];
                    courseNames(c) = [];
                    courses(c) = [];
                end
            end
            if isempty(courseIds)
                return;
            end
            if courseId == -1
                courseId = courses{1}.id;
            end
            app.Course.Items = courseNames;
            app.Course.ItemsData = courseIds;
            app.Course.Value = courseId;
            app.baseApp.canvasCourseId = num2str(courseId);
            
            data = webread([API 'courses/' num2str(courseId) '/assignments'], 'per_page', '100', 'search_term', 'Homework', apiOpts);
            if ~iscell(data)
                data = num2cell(data);
            end
            % if it works, list all assignments
            items = cell(1, numel(data));
            app.names = cell(1, numel(data));
            for d = 1:numel(data)
                if ~contains(data{d}.name, 'Comment EC') && ~contains(data{d}.name, 'Grade')
                    items{d} = data{d}.name;
                    app.names{d} = {items{d}, num2str(data{d}.id)};
                end
            end
            app.names = app.names(~cellfun(@isempty, items));
            items = items(~cellfun(@isempty, items));
            app.Assignments.Items = items;
            app.Assignments.ItemsData = 1:numel(items);
            close(p);
        end

        % Button pushed function: Select
        function SelectButtonPushed(app, ~)
            % try to get num
            num = str2double(app.homeworkName(app.homeworkName <= '9' & app.homeworkName >= '0'));
            if isnan(num)
                num = 0;
            end
            % try to get resub
            if contains(lower(app.homeworkName), 'resubmission')
                resub = true;
            else
                resub = false;
            end
            
            if contains(lower(app.homeworkName), 'autograder')
                app.baseApp.IsLeaky.Value = true;
            else
                app.baseApp.IsLeaky.Value = false;
            end
            app.baseApp.homeworkNum = num;
            app.baseApp.HomeworkNumber.Value = num;
            app.baseApp.isResubmission = resub;
            app.baseApp.IsResubmission.Value = resub;
            app.baseApp.canvasHomeworkId = app.homeworkId;
            uiresume(app.UIFigure);
        end

        % Value changed function: Assignments
        function AssignmentsValueChanged(app, ~)
            value = app.Assignments.Value;
            app.homeworkId = app.names{value}{2};
            app.homeworkName = app.names{value}{1};
        end

        % Button pushed function: Cancel
        function CancelButtonPushed(app, ~)
            uiresume(app.UIFigure);
        end

        % Value changed function: Course
        function CourseValueChanged(app, ~)
            p = uiprogressdlg(app.UIFigure);
            p.Title = 'Progress';
            p.Message = 'Loading Homeworks';
            p.Indeterminate = 'on';
            p.Cancelable = false;
            courseId = app.Course.Value;
            token = app.baseApp.canvasToken;
            API = 'https://gatech.instructure.com/api/v1/';
            % request assignment details from canvas
            apiOpts = weboptions;
            apiOpts.RequestMethod = 'GET';
            apiOpts.HeaderFields = {'Authorization', ['Bearer ' token]};
            % requery Canvas with new course code
            app.baseApp.canvasCourseId = num2str(courseId);
            data = webread([API 'courses/' num2str(courseId) '/assignments'], 'per_page', '100', 'search_term', 'Homework', apiOpts);
            % if it works, list all assignments
            items = cell(1, numel(data));
            app.names = cell(1, numel(data));
            if ~iscell(data)
                data = num2cell(data);
            end
            for d = 1:numel(data)
                if ~contains(data{d}.name, 'Comment EC')
                    items{d} = data{d}.name;
                    app.names{d} = {items{d}, num2str(data{d}.id)};
                end
            end
            app.names = app.names(~cellfun(@isempty, items));
            items = items(~cellfun(@isempty, items));
            app.Assignments.Items = items;
            app.Assignments.ItemsData = 1:numel(items);
            close(p);
        end

        % Value changed function: ShowPastCourses
        function ShowPastCoursesValueChanged(app, ~)
            % requery list, showing new value
            app.startupFcn(app.baseApp);
        end
    end

    % App initialization and construction
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure
            app.UIFigure = uifigure;
            app.UIFigure.Position = [100 100 507 456];
            app.UIFigure.Name = 'Canvas Assignment Selector';

            % Create AssignmentsLabel
            app.AssignmentsLabel = uilabel(app.UIFigure);
            app.AssignmentsLabel.HorizontalAlignment = 'right';
            app.AssignmentsLabel.Position = [192 388 126 22];
            app.AssignmentsLabel.Text = 'Available Assignments';

            % Create Assignments
            app.Assignments = uilistbox(app.UIFigure);
            app.Assignments.Items = {};
            app.Assignments.ValueChangedFcn = createCallbackFcn(app, @AssignmentsValueChanged, true);
            app.Assignments.Position = [58 35 395 354];
            app.Assignments.Value = {};

            % Create Select
            app.Select = uibutton(app.UIFigure, 'push');
            app.Select.ButtonPushedFcn = createCallbackFcn(app, @SelectButtonPushed, true);
            app.Select.Position = [353 7 100 22];
            app.Select.Text = 'Select';

            % Create Cancel
            app.Cancel = uibutton(app.UIFigure, 'push');
            app.Cancel.ButtonPushedFcn = createCallbackFcn(app, @CancelButtonPushed, true);
            app.Cancel.Position = [58 7 100 22];
            app.Cancel.Text = 'Cancel';

            % Create Course
            app.Course = uidropdown(app.UIFigure);
            app.Course.Items = {};
            app.Course.ValueChangedFcn = createCallbackFcn(app, @CourseValueChanged, true);
            app.Course.Position = [80 435 288 22];
            app.Course.Value = {};

            % Create ShowPastCourses
            app.ShowPastCourses = uicheckbox(app.UIFigure);
            app.ShowPastCourses.ValueChangedFcn = createCallbackFcn(app, @ShowPastCoursesValueChanged, true);
            app.ShowPastCourses.Text = 'Show Past Courses';
            app.ShowPastCourses.Position = [380 435 128 22];
        end
    end

    methods (Access = public)

        % Construct app
        function app = CanvasHomeworkSelector(varargin)

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