%% Student: Class Representing a Student
%
% Represents a single student in the grader.
% 
% Holds student's relevant information (identification, submissions,
% feedback, etc.) as fields.
%
% Has methods to grade student's submissions and generate Feedback.
%
%%% Fields
%
% * name: Full name of the student
%
% * id: The ID (GT username) of the student (e.g. busluel3)
%
% * path: The fully qualified path for this student's directory
%
% * submissions: A string array of file names that represent all names
% of submitted files.
%
% * feedbacks: A cell array of Feedback arrays. Each cell is a Feedback
% array representing all test cases for a specific problem.
%
% * isGraded: A logical that indicates whether a student has been graded
%
%%% Methods
%
% * Student
% 
% * gradeProblem
%
% * generateFeedback
%
%%% Remarks
%
% The Student class represents a single student in the eyes of the
% autograder. Each student maps to one (and only one) folder in the
% submission archive.
%
% The student is considered the center of data transfer within the 
% autograder. Each Student is given a problem to grade at runtime, and
% students are finished one at a time - in other words, the first student
% is graded, then the second, and so on.
%
% Grading is done via the parallel pool and parfeval.

 %#ok<*PROP>
classdef Student < handle
    properties (Constant)
        TIMEOUT = 30;
    end
    properties (Access = public)
        name;
        id;
        path;
        submissions;
        feedbacks = {};
        % why is this necessary?
        isGraded = false;
    end
    properties (Access=private)
        problems = [];
        html = {};
    end
    methods
        %% Constructor
        %
        % Creates an instance of the Student class from the student's
        % submission path.
        %
        % this = Student(PATH, NAME) returns an instance of Student.
        % PATH should be a character vector representing the fully
        % qualified (absolute) path to the student's folder. NAME is a 
        % character vector or string of the full name of the student.
        %
        %%% Remarks
        %
        % The Student Constructor is the primary means of creating a
        % |Student|. It takes in a single name and path, and creates a
        % single |Student|. This constructor may implicitly call
        % |unpackStudentSubmissions| when running - this is so after a
        % |Student| is constructed, their directory is completely compliant
        % with what the autograder will expect.
        % 
        %%% Exceptions
        %
        % An AUTOGRADER:STUDENT:DIRECTORYNOTFOUND exception will be thrown
        % if the PATH input is missing, invalid (e.g. empty or
        % incorrect class) or the directory does not exist.
        %
        % An AUTOGRADER:STUDENT:ARGUMENTEXCEPTION exception will be thrown
        % if NAME is empty or only white space.
        %
        %%% Unit Tests
        %
        % Given a valid PATH to a student folder containing submissions
        % (with filenames FILE1, FILE2, ...):
        %
        %   NAME = 'Hello';
        %   this = Student(PATH, NAME);
        % 
        %   this.name -> "Hello"
        %   this.id -> Student's GT username (from name of folder)
        %   this.path -> PATH;
        %   this.submissions -> ["FILE1", "FILE2", ...];
        %   this.feedbacks -> Feedback[];
        %   this.isGraded -> false;
        %
        % Given a valid PATH to a student folder containing no submissions:
        %   NAME = 'Hi';
        %   this = Student(PATH, NAME);
        %
        %   this.name -> "Hi";
        %   this.id -> Student's GT username (from name of folder);
        %   this.path -> PATH;
        %   this.submissions -> ["FILE1", "FILE2", ...]
        %   this.feedbacks -> Feeback[];
        %   this.isGraded -> false;
        %
        % Given an invalid PATH (e.g. folder does not exist):
        %   NAME = 'Hi';
        %   this = Student(PATH, NAME);
        %
        %   Constructor threw exception 
        %   AUTOGRADER:STUDENT:DIRECTORYNOTFOUND
        %
        % Given a valid PATH:
        %   NAME = '';
        %   this = Student(PATH, NAME);
        %
        %   Constructor threw exception
        %   AUTOGRADER:STUDENT:ARGUMENTEXCEPTION
        %
        % Given a valid PATH:
        %   NAME = '    ';
        %   this = Student(PATH, NAME);
        %
        %   Constructor threw exception
        %   AUTOGRADER:STUDENT:ARGUMENTEXCEPTION
        %
        function this = Student(path, name)
            this.path = path;
            this.name = name;
            % We can safely assume that student has been processed (zip
            % unpacked, etc.)
            
            % Sanitize path to use correct file separator
            
            path(path == '/' | path == '\') = filesep;
            
            % Path should always have last file separator
            
            if path(end) ~= filesep
                path = [path filesep];
            end
            
            % Get all submissions
            subs = dir([path '*.m']);
            this.submissions = {subs.name};
            
            % ID is folder name:
            this.id = regexp(path, '[A-Za-z0-9_]+(?=\\$)', 'match');
            this.id = this.id{1};
        end
    end
    methods (Access=public)
        %% gradeProblem: Grades the given problem and records the results
        %   
        % gradeProblem is used to evaluate the student code for a given
        % problem and record the results in the feedbacks field.
        %
        % gradeProblem(PROBLEM) takes in a valid PROBLEM class,
        % evaluates the student code, creates a Feedback instance for each
        % TestCase, which it adds to the feedbacks field. It finally
        % sets the isGraded field to true.
        %
        %%% Remarks
        %
        % The function will return without making any changes to the class
        % if the isGraded field is already true.
        % 
        % The feedback field should always be populated, even if
        % the submissions field is empty.
        %
        % If MATLAB throws an exception, this function will catch the
        % exception and output it to the reason field in Feedback. If the
        % reason field already has content in it, the exception ID will be
        % concatenated to the data already found in reason.
        %
        % If the student code contains an infinite loop, gradeProblem will
        % detect it and add a statement to the reason field of Feedback.
        %
        %%% Exceptions
        %
        % An AUTOGRADER:STUDENT:GRADEPROBLEM:INVALIDPROBLEM exception will
        % be thrown if PROBLEM is invalid (i.e. if it is empty or
        % if name or testcases fields of PROBLEM are empty).
        %
        %%% Unit Tests
        %
        % Given a student who had submitted all files:
        % The student code is evaluated and a Feedback instance is created.
        % The Feedback class will then be added to the feedbacks field.
        %
        % Given a student who had only partially submitted files:
        % The student code is evaluated normally for non-empty submissions
        % and Feedback instances are created. Empty submissions will
        % give appropritate score and reason values in the Feedback class. 
        % The Feedback classes will then be added to the feedbacks field.
        %
        % Given a student who had no submitted files:
        % Empty submissions will give appropritate score and reason values
        % in the Feedback class.
        % The Feedback classes will then be added to the feedbacks field.
        function gradeProblem(this, problem)
            % For each testCase, create Feedback, run engine.
            if ~isvalid(problem)
                throw(MException('AUTOGRADER:STUDENT:GRADEPROBLEM:INVALIDPROBLEM', ...
                    'Given problem was not a valid Problem object'));
            elseif numel(problem.testCases) == 0
                throw(MException('AUTOGRADER:STUDENT:GRADEPROBLEM:INVALIDPROBLEM', ...
                    'Expected non-zero number of Test Cases; got 0'));
            end
            % Add problem to end of our list
            this.problems = [this.problems problem];
            for i = numel(problem.testCases):-1:1
                feeds(i) = Feedback(problem.testCases(i));
                % check if even submitted
                % assume name is problem name
                if any(strncmp(problem.name, this.submissions, length(problem.name)))
                    engine(feeds(i));
                else
                    feeds(i).exception = MEXCEPTION('AUTOGRADER:STUDENT:FILENOTSUBMITTED', ...
                        'File %s wasn''t submitted, so the engine was not run.', [problem.name '.m']);
                end
            end
            this.feedbacks = [this.feedbacks {feeds}];
        end
        
        %% generateFeedback: Generate HTML feedback for student
        %
        % generateFeedback is used to create an HTML file containing the
        % homework feedback for a student.
        %
        % generateFeedback() will write the 
        % containing the markup representing the student's feedback.
        %
        %%% Remarks
        %
        % Calls the generateFeedback method of the Feedback class, for each
        % Feedback in Student's feedbacks cell array, to get the HTML
        % feedback for individual TestCase's. Puts together a complete,
        % personalized HTML webpage for the student using this data and the
        % name and id fields.
        %
        %%% Exceptions
        %
        % An AUTOGRADER:STUDENT:GENERATEFEEDBACK:MISSINGFEEDBACK exception
        % will be thrown if the feedbacks field of the Student is empty
        % (i.e. if gradeProblem wasn't invoked first).
        %
        % An AUTOGRADER:STUDENT:GENERATEFEEDBACK:FILEIO exception will be
        % thrown if there is an error when opening the student's feedback
        % file for writing
        %
        %%% Unit Tests
        %
        % When invoked in a Student class containing a valid (non-empty)
        % feedbacks field, generateFeedback will generate an HTML page
        % with:
        % * A header, containing the name of the homework as the title, and
        % the student's name and ID.
        % * A table with the student's points on each problem and total
        % score.
        % * A section for each individual problem, where every test case
        % and the result (including points received, reason for losing
        % points, visual comparison of file outputs) is listed.
        function generateFeedback(this)
            % Check feedbacks is correct
            if isempty(this.feedbacks)
                throw(MException('AUTOGRADER:STUDENT:GENERATEFEEDBACK:MISSINGFEEDBACK', ...
                    'No feedbacks present (did you forget to invoke gradeProblem?)'));
            end
            % Header info
            this.html = {'<!DOCTYPE html>', '<html>', '<head>', '</head>', ...
                '<body>', '</body>', '</html>'};
            resources = {
                '<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css">', ...
                '<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>', ...
                '<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.12.9/umd/popper.min.js"></script>', ...
                '<script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/js/bootstrap.min.js"></script>', ...
                '<script defer src="https://use.fontawesome.com/releases/v5.0.8/js/all.js"></script>'
                };
            styles = {
                '<style>', ...
                '</style>'
                };
            scripts = {
                '<script>', ...
                '</script>'
                };
            % Splice recs, styles, and scripts:
            spliceHead(resources, styles, scripts);
            
            % Add Student's name
            name = {'<div class="row text-left">', '<div class="col-12">', ...
                '<h1 class="display-1">', ...
                ['Feedback for ' this.name ' (' this.id ')'], '</h1>', ...
                '</div>', '</div>'};
            this.appendRow(name);

            % Generate Table
            generateTable();
            
            % For each problem, gen feedback
            for i = 1:numel(this.problems)
                generateProblem(this.problems(i), this.feedbacks{i});
            end
            
            % Join with new lines and write to feedback.html
            [fid, msg] = fopen([this.path 'feedback.html'], 'wt');
            if fid == -1
                % throw error
                throw(MException('AUTOGRADER:STUDENT:GENERATEFEEDBACK:FILEIO', ...
                    'Unable to create the feedback file. Received message %s', msg));
            end
            html = strjoin(this.html, newline);
            fwrite(fid, html);
            fclose(fid);
            
        end
    end
    methods (Access=private)
        % Splice elements to the end of HEAD
        function spliceHead(this, varargin)
            % Find the header
            ind = find(strcmpi(this.html, '</head>'));
            this.html = [this.html(1:(ind-1)) varargin{:} this.html(ind:end)];
        end
        % Splice elements to the end of BODY
        function appendRow(this, varargin)
            % Find the end of container
            ind = find(strcmpi(this.html, '</div>'), 1, 'last');
            this.html = [this.html(1:(ind-1)) varargin{:} this.html(ind:end)];
        end
        
        function generateTable(this)
            % Table will have following columns:
            %   Problem #
            %   Problem Name
            %   Pts Possible
            %   Pts Earned
            table = {'<table>', '<thead>', '<tr>' '<th>', '', '</th>', ...
                '<th>', 'Problem', '</th>', '<th>', 'Points Possible', ...
                '</th>', '<th>', 'Points Earned', '</th>', '</tr>', ...
                '</thead>', '</table>'};
            
            totalPts = 0;
            totalEarn = 0;
            % For each problem, list:
            for i = 1:numel(this.problems)
                tCases = [this.problems(i).testCases];
                feeds = this.feedbacks(i);
                num = {'<td>', '<p>', num2str(i), '</p>', '</td>'};
                name = {'<td>', '<p>', this.problems(i).name, '</p>', '</td>'};
                poss = {'<td>', '<p>', num2str(sum([tCases.points])), '</p>', '</td>'};
                earn = {'<td>', '<p>', num2str(sum([feeds.points])), '</p>', '</td>'};
                
                row = [{'<tr>'}, num, name, poss, earn, {'</tr>'}];
                appendRow(row);
                
                totalPts = totalPts + sum([tCases.points]);
                totalEarn = totalEarn + sum([feeds.points]);
            end
            
            % Add totals row
            totals = {'<tr>', '<td>', '</td>', '<td>', '</td>', '<td>', ...
                '<p>', num2str(totalPts), '</p>', '</td>', '<td>', ...
                '<p>', num2str(totalEarn), '</p>', '</td>', '</tr>'};
            appendRow(totals);
            
            % Splice table into body
            table = [{'<div class="row text-center">', '<div class="col-12">'}, ...
                table, {'</div>', '</div>'}];
            this.appendRow(table);
            % Appends a row
            function appendRow(row)
                % Always insert right before </table>, which is at end
                table = [table(1:(end-1)) row table(end)];
            end
        end
        
        % Create feedback for specific problem
        function generateProblem(this, problem, feedbacks)
            prob = {'<div class="problem col-12">', '<h2>', problem.name, ...
                '</h2>', '<div class="tests">', '</div>', '</div>'};
            
            for i = 1:numel(feedbacks)
                feed = feedbacks(i);
               
                % if passed, marker is green
                if feed.isPassed
                    marker = {'<div class="col-1">', ...
                        Feedback.CORRECT_MARK, '</div>'};
                else
                    marker = {'<div class="col-1">', ...
                        Feedback.INCORRECT_MARK, '</div>'};
                end
                
                % Show call
                call = [marker {'<div class="col-md-4">', '<pre class="call">', ...
                    feed.testCase.call, '</pre>', '</div>'}];
                headerRow = [{'<div class="row test-header">'}, call, {'</div>'}];
                
                % Get feedback message
                msg = {feed.generateFeedback()};
                test = [{'<div class="row test-case">'}, headerRow, msg, {'</div>'}];
                appendTest(test);
            end
            
            % Append this problem to end of html
            prob = [{'<div class="row">'}, prob, {'</div>'}];
            this.appendRow(prob);
            
            function appendTest(test)
                % Append to end
                prob = [prob(1:(end-2)) test prob((end-1):end)];
            end
        end
    end
end