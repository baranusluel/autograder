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
% * canvasId: The Canvas ID of the student, as a string.
%
% * path: The fully qualified path for this student's directory
%
% * submissions: A string array of file names that represent all names
% of submitted files.
%
% * feedbacks: A cell array of Feedback arrays. Each cell is a Feedback
% array representing all test cases for a specific problem.
%
% * grade: The overall score for this student (read-only)
%
%%% Methods
%
% * Student
%
% * assess
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
        TIMEOUT double = 30;
        ROUNDOFF_ERROR double = 5;
        FCLOSE_PERCENTAGE_OFF double = 0.5;
    end
    properties (Access = public)
        name char;
        id char;
        canvasId char;
        section char = 'U';
        path char;
        submissions cell;
        feedbacks cell = {};
        grade double;
        problemPaths cell;
        commentGrades double;
    end
    properties (Access=private)
        html cell = {};
        resources Resources;
    end
    methods (Static)
        function resetPath()
            persistent PATH;
            if isempty(PATH)
                restoredefaultpath();
                userpath('clear');
                addpath(genpath(fileparts(fileparts(mfilename('fullpath')))));
                PATH = path();
            else
                path(PATH, '');
            end
        end
    end
    methods
        function grade = get.grade(this)
            if isempty(this.feedbacks)
                throw(MException('AUTOGRADER:Student:grade:noFeedbacks', 'No feedbacks were found (did you call assess?)'));
            end
            grade = sum(cellfun(@(f) sum([f.points]), this.feedbacks));
        end
        function this = Student(path, name, canvas, recs)
        %% Constructor
        %
        % Creates an instance of the Student class from the student's
        % submission path.
        %
        % this = Student(P, N, C) returns an instance of Student.
        % P should be a character vector representing the fully
        % qualified (absolute) path to the student's folder. N is a
        % character vector or string of the full name of the student. C is
        % the Canvas ID, as a character vector
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
        % An AUTOGRADER:Student:invalidPath exception will be thrown
        % if the PATH input is missing, invalid (e.g. empty or
        % incorrect class) or the directory does not exist.
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
        %   this.submissions -> []
        %   this.feedbacks -> Feeback[];
        %   this.isGraded -> false;
        %
        % Given an invalid PATH (e.g. folder does not exist):
        %   NAME = 'Hi';
        %   this = Student(PATH, NAME);
        %
        %   Constructor threw exception
        %   AUTOGRADER:Student:ctor:invalidPath
        %
            if nargin == 0
                return;
            end
            this.resources = recs;
            if ~isfolder(path)
                e = MException('AUTOGRADER:Student:ctor:invalidPath', ...
                'Path %s is not a valid path', path);
                throw(e);
            end
            this.name = name;
            this.canvasId = canvas;
            % We can safely assume that student has been processed (zip
            % unpacked, etc.)

            % Sanitize path to use correct file separator

            path(path == '/' | path == '\') = filesep;

            % Path should never have last file separator

            if path(end) == filesep
                path(end) = [];
            end

            % Get all submissions
            subs = dir([path filesep '*.m']);
            this.submissions = {subs.name};
            
            paths = cell(1, numel(this.resources.Problems));
            for p = 1:numel(this.resources.Problems)
                prob = this.resources.Problems(p);
                % see if found
                if any(strcmp(this.submissions, [prob.name '.m']))
                    paths{p} = [path filesep prob.name '.m'];
                end
            end
            this.problemPaths = paths;
            this.commentGrades = zeros(1, numel(paths));
            % ID is folder name:
            [~, this.id, ~] = fileparts(path);
            this.path = path;
        end
    end
    methods (Access=public)
        function assess(this)
        %% assess: Grades the student and records the results
        %
        % assess is used to evaluate the student code for a given
        % problem and record the results in the feedbacks field.
        %
        % assess() evaluates the student code, creates a Feedback 
        % instance for each TestCase, which it adds to the feedbacks field.
        %
        %%% Remarks
        %
        % The feedback field should always be populated, even if
        % the submissions field is empty.
        %
        % If MATLAB throws an exception, this function will catch the
        % exception and output it to the reason field in Feedback. If the
        % reason field already has content in it, the exception ID will be
        % concatenated to the data already found in reason.
        %
        % If the student code contains an infinite loop, assess will
        % detect it and add a statement to the reason field of Feedback.
        %
        %%% Exceptions
        %
        % This method will not throw an exception.
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
        % give appropriate score and reason values in the Feedback class.
        % The Feedback classes will then be added to the feedbacks field.
        %
        % Given a student who had no submitted files:
        % Empty submissions will give appropriate score and reason values
        % in the Feedback class.
        % The Feedback classes will then be added to the feedbacks field.
            problems = this.resources.Problems;
            % for each problem, create ends
            counter = numel([problems.testCases]);
            inds = zeros(1, counter);
            isRecursive = false(1, counter);
            isSubmitted = false(1, numel(problems));
            for p = numel(problems):-1:1
                prob = problems(p);
                for t = numel(prob.testCases):-1:1
                    % check if even submitted
                    feeds(counter) = Feedback(prob.testCases(t), this.path);
                    if any(strcmp([prob.name '.m'], this.submissions))
                        isRunnable(counter) = true;
                        isSubmitted(p) = true;
                    else
                        isRunnable(counter) = false;
                        e = MException('AUTOGRADER:Student:fileNotSubmitted', ...
                            'Student did not submit file');
                        feeds(counter).exception = ...
                            e.addCause(MException('STUDENT:fileNotSubmitted', ...
                            'File <code>%s</code> wasn''t submitted, so the function was not graded.', [prob.name '.m']));
                    end
                    inds(counter) = p;
                    isRecursive(counter) = prob.isRecursive;
                    counter = counter - 1;
                end
            end
            feeds(isRunnable) = engine(feeds(isRunnable));
            try
                sanityWorker = parfevalOnAll(@()([]), 0);
                isSane = sanityWorker.wait('finished', 5);
                if ~isSane
                    sanityWorker.cancel();
                end
            catch
                isSane = false;
            end
                
            % while we fill out feedbacks, grade comments
            % sanity check. If we can't run a parallel job, kill the pool,
            % restart!

            if ~isSane
                % parallel pool is dead (at least one worker...)
                % kill the pool, start it up, set up dictionary, and
                % resources.
                evalc('delete(gcp);');
                evalc('gcp;');
                wait(parfevalOnAll(@gradeComments, 0));
                setArraySizeLimit;
                wait(parfevalOnAll(@setArraySizeLimit, 0));
                wait(parfevalOnAll(@warning, 0, 'off'));
            end
            for p = numel(problems):-1:1
                workers(p) = parfeval(@gradeComments, 1, this.problemPaths{p});
            end
            % fill out feedbacks
            for i = 1:numel(feeds)
                feedback = feeds(i);
                % if exception, hasPassed = false;
                if ~isempty(feedback.exception) && ...
                    ~any(strcmp(feedback.exception.identifier, ...
                        {'AUTOGADER:fileNotClosed', 'AUTOGRADER:fcloseAll'}))
                    feedback.hasPassed = false;
                    feedback.points = 0;
                elseif isRecursive(i) && ~feedback.isRecursive
                    feedback.hasPassed = false;
                    feedback.points = 0;
                    feedback.exception = MException('AUTOGRADER:studentDidNotRecurse', ...
                        'Your code didn''t use recursion, so you did not receive credit.');
                else
                    % split points evenly among outputs, files, and plots?
                    solnOutputs = feedback.testCase.outputs;
                    solnFiles = feedback.testCase.files;
                    solnPlots = feedback.testCase.plots;
                    
                    numTotal = sum([numel(fieldnames(solnOutputs)), ...
                        numel(solnFiles), numel(solnPlots)]);
                    numCorrect = 0;
                    % for each output, if isequaln returns true, then give
                    % partial
                    outs = fieldnames(solnOutputs);
                    for o = 1:numel(outs)
                        soln = solnOutputs.(outs{o});
                        try
                            stud = feedback.outputs.(outs{o});
                            % if numeric, round to 6
                            if isfloat(soln)
                                soln = round(soln, this.ROUNDOFF_ERROR);
                                stud = round(stud, this.ROUNDOFF_ERROR);
                            end
                            if isequaln(soln, stud)
                                numCorrect = numCorrect + 1;
                            end
                        catch
                        end
                    end
                    
                    % for each file, we need to see what file matches.
                    % to do this, for each soln, we'll see if any student
                    % equals it. If it does, then we take it out of both
                    studFiles = cell(1, numel(solnFiles));
                    solnFiles = cell(1, numel(solnFiles));
                    matching  = false(1, numel(solnFiles));
                    studInds = 1:numel(feedback.files);
                    for f = 1:numel(solnFiles)
                        solnFiles{f} = feedback.testCase.files(f);
                        % for each student file, try to find an equal one.
                        % If found, add both to cell array, and then remove
                        % from studInds
                        for s = 1:numel(studInds)
                            if solnFiles{f}.equals(feedback.files(studInds(s)))
                                studFiles{f} = feedback.files(studInds(s));
                                matching(f) = true;
                                numCorrect = numCorrect + 1;
                                studInds(s) = [];
                                break;
                            end
                        end
                        % if not matching, redo the search, but instead of
                        % using equals, just check the name and extension
                        if ~matching(f)
                            for s = 1:numel(studInds)
                                if strcmpi(solnFiles{f}.name, ...
                                        feedback.files(studInds(s)).name)
                                    studFiles{f} = feedback.files(studInds(s));
                                    matching(f) = true;
                                    studInds(s) = [];
                                    break;
                                end
                            end
                        end
                    end
                    % for each matching file, place it in line for checking
                    solnFound = [solnFiles{matching}];
                    studFound = [studFiles{matching}];
                    solnNotFound = [solnFiles{~matching}];
                    studNotFound = feedback.files(studInds);
                    % since they are matching (matching == true), we know
                    % that length(solnFound) == length(studFound). So, we
                    % place them first
                    % now, place the REST of them afterwards. We don't have
                    % to make any guarantee about length here
                    feedback.testCase.files = [solnFound solnNotFound];
                    feedback.files = [studFound studNotFound];
                    
                    % for each plot, we need to see what plot matches.
                    % to do this, for each soln, we'll see if any student
                    % equals it. If it does, then we take it out of both
                    studPlots = cell(1, numel(solnPlots));
                    solnPlots = cell(1, numel(solnPlots));
                    matching  = false(1, numel(solnPlots));
                    studInds = 1:numel(feedback.plots);
                    for p = 1:numel(solnPlots)
                        solnPlots{p} = feedback.testCase.plots(p);
                        % for each student file, try to find an equal one.
                        % If found, add both to cell array, and then remove
                        % from studInds
                        for s = 1:numel(studInds)
                            if solnPlots{p}.equals(feedback.plots(studInds(s)))
                                studPlots{p} = feedback.plots(studInds(s));
                                matching(p) = true;
                                numCorrect = numCorrect + 1;
                                studInds(s) = [];
                                break;
                            end
                        end
                        % if no perfect match, redo just for title
                        if ~matching(p)
                            for s = 1:numel(studInds)
                                if strcmpi(solnPlots{p}.Title, ...
                                        feedback.plots(studInds(s)).Title)
                                    studPlots{p} = feedback.plots(studInds(s));
                                    matching(p) = true;
                                    studInds(s) = [];
                                    break;
                                end
                            end
                        end
                    end
                    % for each matching file, place it in line for checking
                    solnFound = [solnPlots{matching}];
                    studFound = [studPlots{matching}];
                    solnNotFound = [solnPlots{~matching}];
                    studNotFound = feedback.plots(studInds);
                    % since they are matching (matching == true), we know
                    % that length(solnFound) == length(studFound). So, we
                    % place them first
                    % now, place the REST of them afterwards. We don't have
                    % to make any guarantee about length here
                    feedback.testCase.plots = [solnFound solnNotFound];
                    feedback.plots = [studFound studNotFound];
                    
                    if numCorrect == numTotal
                        feedback.hasPassed = true;
                        feedback.points = feedback.testCase.points;
                    else
                        feedback.hasPassed = false;
                        feedback.points = feedback.testCase.points*numCorrect/numTotal;
                    end
                    if ~isempty(feedback.exception)
                        % only got here if no fclose
                        feedback.points = feedback.points * Student.FCLOSE_PERCENTAGE_OFF;
                    end
                        
                end
            end
            this.feedbacks = cell(1, numel(problems));
            for p = 1:numel(problems)
                this.feedbacks{p} = feeds(inds == p);
            end
            % get comment grades
            for w = numel(workers):-1:1
                if ~contains(problems(w).name, 'ABCs')
                    commentGrades(w) = workers(w).fetchOutputs();
                else
                    commentGrades(w) = 0;
                end
            end
            delete(workers);
            this.commentGrades = commentGrades;
            this.generateFeedback();
        end
    end
    methods (Access=private)
        function generateFeedback(this)
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
        % An AUTOGRADER:Student:generateFeedback:missingFeedback exception
        % will be thrown if the feedbacks field of the Student is empty
        % (i.e. if assess wasn't invoked first).
        %
        % An AUTOGRADER:Student:generateFeedback:fileIO exception will be
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
            % Check feedbacks is correct
            if isempty(this.feedbacks)
                throw(MException('AUTOGRADER:Student:generateFeedback:missingFeedback', ...
                    'No feedbacks present (did you forget to invoke assess()?)'));
            end
            % Header info
            this.html = {'<!DOCTYPE html>', '<html>', '<head>', '</head>', ...
                '<body>', '<div class="container-fluid">', '</div>', '</body>', '</html>'};
            resources = {
                '<link href="https://fonts.googleapis.com/css?family=Open+Sans" rel="stylesheet">', ...
                '<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css">', ...
                '<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>', ...
                '<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.12.9/umd/popper.min.js"></script>', ...
                '<script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/js/bootstrap.min.js"></script>', ...
                '<script defer src="https://use.fontawesome.com/releases/v5.0.8/js/all.js"></script>'
                };
            styles = {
                '<style>', ...
                'html {', ...
                '    font-family: ''Open Sans'';', ...
                '}', ...
                '.fa-check {', ...
                '    color: forestgreen;', ...
                '}', ...
                '.fa-times {', ...
                '    color: darkred;', ...
                '}', ...
                '.display-1 {', ...
                '    font-size: 2.5em;', ...
                '}', ...
                '.flex-container {', ...
                '    display: flex;', ...
                '    flex-wrap: wrap;', ...
                '}', ...
                '.flex-element {', ...
                '    margin-right: 30px;', ...
                '}', ...
                '.test-case {', ...
                '    margin-left: 20px;', ...
                '    margin-bottom: 20px;', ...
                '}', ...
                '.test-header {', ...
                '    margin-left: -50px;', ...
                '}', ...
                '.call {', ...
                '    font-family: "Courier New";', ...
                '}', ...
                '.variable-name {', ...
                '    font-family: "Courier New";', ...
                '}', ...
                '.variable-value {', ...
                '    font-family: "Courier New";', ...
                '}', ...
                '.problem div {', ...
                '    padding-left: 10px;', ...
                '    padding-right: 10px;', ...
                '}', ...
                '.exception {', ...
                '    color: darkred;', ...
                '    font-family: "Courier New";', ...
                '    margin-bottom: 0px;', ...
                '}', ...
                '.problem-row:hover {', ...
                '    cursor: pointer;', ...
                '}', ...
                '.table-responsive {', ...
                '    padding-left: 5%;', ...
                '    padding-right: 5%;', ...
                '}', ...
                'h1 {', ...
                '    margin: 20px;', ...
                '}', ...
                'h3 {', ...
                '    font-size: 130%;', ...
                '}', ...
                '.warning {', ...
                '    color: #c94f00;', ...
                '}', ...
                '.feedback-points {', ...
                '    font-size: 110%;', ...
                '}', ...
                '.feedback {', ...
                '    margin-top: 5px;', ...
                '    margin-bottom: 5px;', ...
                '    margin-left: 5%;', ...
                '}', ...
                'pre {', ...
                     'display:inline;', ...
                '}', ...
                '.diffnomatch {', ...
                '    background: #e5d5e8;', ...
                '}', ...
                '.right {', ...
                '    background: #dbf2fc;', ...
                '}', ...
                '.left {', ...
                '    background: #f3e9d1;', ...
                '}', ...
                '.diffsoft {', ...
                '    color: #888;', ...
                '}', ...
                '.diffskip {', ...
                '    color: #888;', ...
                '    background: #e0e0e0;', ...
                '}', ...
                '.bold {', ...
                '    font-weight:bold;', ...
                '}', ...
                '.problem-name {', ...
                '    font-family: ''Courier New'', monospace;', ...
                '}', ...
                '.merged {', ...
                '    background-color: #eaeaea;', ...
                '}', ...
                'span {', ...
                '    font-family: "Courier New";', ...
                '}', ...
                '.diff-equal {', ...
                '    background-color: white;', ...
                '}', ...
                '.diff-delete {', ...
                '    background-color: #FF8A8A;', ...
                '    text-decoration: line-through;', ...
                '}', ...
                '.diff-insert {', ...
                '    background-color: lightgreen;', ...
                '}', ...
                '.diff-invisible {', ...
                '    color: white;', ...
                '}', ...
                '.diff-omitted {', ...
                '    color:#b5b5b5;', ...
                '}', ...
                '</style>'
                };
            scripts = {
                '<script>', ...
                '$(document).ready(function() {', ...
                '    $(".problem-row").on("click",function(){', ...
                '        window.location = $(this).data("href");', ...
                '        return false;', ...
                '    });', ...
                '});', ...
                '</script>'
                };
            % Splice recs, styles, and scripts:
            this.spliceHead(resources, styles, scripts);

            % Add Student's name
            name = {'<div class="row text-center">', '<div class="col-12">', ...
                '<h1 class="display-1">', ...
                ['Feedback for ' this.name ' (' this.id ')'], '</h1>', ...
                '</div>', '</div>'};
            this.appendRow(name);

            % Generate Table
            this.generateTable();

            % For each problem, gen feedback
            for i = 1:numel(this.resources.Problems)
                this.generateProblem(this.resources.Problems(i), this.feedbacks{i}, i);
            end

            % Join with new lines and write to feedback.html
            [fid, msg] = fopen([this.path filesep 'feedback.html'], 'wt');
            if fid == -1
                % throw error
                throw(MException('AUTOGRADER:Student:generateFeedback:fileIO', ...
                    'Unable to create the feedback file. Received message %s', msg));
            end
            html = strjoin(this.html, newline);
            fwrite(fid, html);
            fclose(fid);
        end
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
            table = {'<table class="table table-striped table-bordered table-hover">', ...
                '<thead>', '<tr>' '<th>', '#', '</th>', ...
                '<th>', 'Problem', '</th>', '<th>', 'Points Earned (Plus Comments)', ...
                '</th>', '<th>', 'Points Possible', '</th>', '</tr>', ...
                '</thead>', '</table>'};

            totalPts = 0;
            totalEarn = 0;
            totalComments = 0;
            % For each problem, list:
            for i = 1:numel(this.resources.Problems)
                tCases = [this.resources.Problems(i).testCases];
                feeds = this.feedbacks{i};
                num = {'<td>', '<p>', num2str(i), '</p>', '</td>'};
                name = {'<td>', '<p>', this.resources.Problems(i).name, '</p>', '</td>'};
                poss = {'<td>', '<p>', sprintf('%0.1f', sum([tCases.points])), '</p>', '</td>'};
                earn = {'<td>', '<p>', sprintf('%0.1f (+%0.1f)', sum([feeds.points]), this.commentGrades(i)), '</p>', '</td>'};
                
                row = [{['<tr class="problem-row" data-href="#problem' num2str(i) '">']}, num, name, earn, poss, {'</a>', '</tr>'}];
                appendRow(row);

                totalPts = totalPts + sum([tCases.points]);
                totalEarn = totalEarn + sum([feeds.points]);
                totalComments = totalComments + this.commentGrades(i);
                
            end

            % Add totals row
            totals = {'<tr>', '<td>', '</td>', ...
                '<td>', '<strong>Total</strong>', '</td>', '<td>', ...
                '<p>', sprintf('%0.1f (+%0.1f)', totalEarn, totalComments), '</p>', '</td>', '<td>', ...
                '<p>', sprintf('%0.1f', totalPts), '</p>', '</td>', '</tr>'};
            appendRow(totals);

            % Splice table into body
            table = [{'<div class="row text-center">', '<div class="col-12">', '<div class="table-responsive">'}, ...
                table, {'</div>', '</div>', '</div>'}];
            this.appendRow(table);
            % Appends a row
            function appendRow(row)
                % Always insert right before </table>, which is at end
                table = [table(1:(end-1)) row table(end)];
            end
        end

        % Create feedback for specific problem
        function generateProblem(this, problem, feedbacks, num)
            % print the resources
            % for each resource, print a link
            files = this.resources.supportingFiles(num).files;
            links = cell(1, numel(files));
            for f = 1:numel(files)
                file = files(f);
                links{f} = ['<li class="link">', '<a href="' file.dataURI '" download="', ...
                    file.name, '">' file.name '</a>', '</li>'];
            end
            prob = [{['<div id="problem' num2str(num) '" class="problem col-12">'], '<h2 class="problem-name">', problem.name, ...
                '</h2>', '<div class="supporting-files"><h3>Supporting Files</h3>'}, ...
                {'<ul class="links">'}, links, {'</ul>'}, ...
                {'</div>', '<div class="tests">', '<h3 class="test-cases">Test Cases</h3>', ...
                '</div>', '</div>'}];
            for i = 1:numel(feedbacks)
                feed = feedbacks(i);

                % if passed, marker is green
                if feed.hasPassed
                    marker = Feedback.CORRECT_MARK;
                else
                    marker = Feedback.INCORRECT_MARK;
                end

                % Show call
                call = {'<div class="col-12">', '<div class="call">', ...
                    marker, ' ', feed.testCase.call, '</div>', '</div>'};
                headerRow = [{'<div class="row test-header">'}, call, {'</div>'}];

                % Get feedback message
                if strncmp(problem.name, 'ABCs', 4)
                    msg = {feed.generateFeedback(false)};
                else
                    msg = {feed.generateFeedback()};
                end
                test = [{'<div class="row test-case">'}, headerRow, msg, {'</div>'}];
                appendTest(test);
            end

            % Append this problem to end of html
            prob = [{'<hr /><div class="row">'}, prob, {'</div>'}];
            this.appendRow(prob);

            function appendTest(test)
                % Append to end
                prob = [prob(1:(end-2)) test prob((end-1):end)];
            end
        end
    end
end
