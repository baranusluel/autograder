%% Feedback: Represents Feedback 
%
% This class represents feedback for a specific TestCase.
%
%%% Fields
%
% * testCase: The TestCase for this feedback
%
% * hasPassed: True if the student passed this test completely
%
% * path: The fully qualified path for this student's directory
%
% * outputs: A structure where the field name is the name of the output, 
%            and the field value is the value of the output
%
% * files: A File array that represents all the files produced by the
%          student
%
% * plots: A Plot array that represents all the plots generated by the
%          student
%
% * points: The number of points earned for this test case
%
% * exception: The MException raised by the student's code.
%
% * isRecursive: True if the student's code was recursive
%
%%% Methods
%
% * Feedback
%
% * generateFeedback
%
%%% Constants
%
% * CORRECT_MARK: The HTML markup for a checkmark
%
% * INCORRECT_MARK: The HTML markup for an x (incorrect)
%
%%% Remarks
%
% The Feedback class represents a complete feedback for this specific Test 
% Case. It does not make sense to have a Feedback without a corresponding 
% Student, especially considering that the student's code is what is used 
% to create the initial run.
%
% These other fields are only filled when a Student's gradeProblem method 
% has successfully completed!
%
% Additionally, this class also has many constants that aid when generating 
% feedback. Of note are |CORRECT_MARK| and |INCORRECT_MARK|, which are the 
% marks we use to show passing or failing, respectively.

%#ok<*AGROW>
classdef Feedback < handle
    properties (Constant)
        CORRECT_MARK = '<i class="fas fa-check"></i>';
        INCORRECT_MARK = '<i class="fas fa-times"></i>';
    end
    properties (Access = public)
        testCase;
        hasPassed;
        path;
        outputs = struct();
        files;
        plots;
        exception;
        points = 0;
        isRecursive = false;
    end
    methods
        %% Constructor
        %
        % The constructor creates a new Feedback from a TestCase and path. 
        %
        % this = Feedback(T,P) will return a Feedback with the
        % T and P field assigned. The rest of the fields will be
        % assigned by the gradeProblem function
        %
        %%% Remarks
        %
        % The constructor creates a new Feedback for the given TestCase T.
        % To actually _generate_ feedback, the Feedback class will need to 
        % be initialized correctly.
        %
        %%% Unit Tests
        %
        %   T = testCase; % Given a valid TestCase
        %   P = '...'; % valid student path
        %   F = Feedback(T, P);
        %
        %   F.testCase -> T;
        %
        function [this] = Feedback(testCase, path)
            if nargin == 0
                return;
            end
            this.testCase = testCase;
            this.path = path;
        end
    end
    methods (Access = public)
        %% generateFeedback: Generates HTML feedback 
        %
        % The function generates complete HTML feedback for the specific
        % feedback 
        %
        % H = generateFeedback(S) generates the complete html
        % feedback for this based on the information stored in the
        % properties. It uses the logical S to determine what to print - if
        % S is true, then correct outputs are also printed; otherwise, only
        % incorrect ones are printed. This is especially useful for the
        % "ABCs"
        %
        %%% Remarks
        %
        % generateFeedback is used to create the HTML feedback for this single test case.
        % Since this class possesses all information about the test case and the student's
        % response, this method can always generate compleete feedback about a run.
        %
        % generateFeedback is guaranteed to never error so long as it has been correctly 
        % initialized.
        %
        %%% Unit Tests
        %
        %   F = Feedback(T); % T is valid Test Case
        %   ... % Assume F has been correctly initialized
        %   H = F.generateFeedback();
        %
        %   The correct HTML feedback is returned.
        % a correct and complete html feedback will be output based on the
        % properties of the feedback file
        %
        %
        function html = generateFeedback(this, showCorrect)
            if nargin == 1
                showCorrect = true;
            end
            %Check if testCase was passed and output empty div
            if ~isempty(this.exception)
                if isempty(this.exception.cause)
                    this.exception = this.exception.addCause(this.exception);
                end
                html = ['<div class="container-fluid"><div class="feedback"><p class="exception">', ... 
                        this.exception.cause{1}.identifier ' - ', ...
                        this.exception.cause{1}.message '</p>'];
            else
                html = '<div class="container-fluid"><div class="feedback">';
                %Get solution outputs for testCase
                solnOutputs = this.testCase.outputs;
                solnFiles = this.testCase.files;
                solnPlots = this.testCase.plots;
                
                %Check whether regular outputs should have been produced
                %by student
                if ~isempty(solnOutputs)
                    fn = fieldnames(this.outputs);
                    fnSoln = fieldnames(solnOutputs);
                    if length(fn) ~= length(fnSoln)
                        html = [html '<p>Number of outputs don''t match.</p>'];
                    else
                        for i = 1:length(fnSoln)
                            if showCorrect || ~isequaln(this.outputs.(fnSoln{i}), solnOutputs.(fnSoln{i}))
                                html = [html, ...
                                    '<div><span class="variable-name">', ...
                                    fnSoln{i} ': </span>', ...
                                    generateFeedback(this.outputs.(fnSoln{i}), ...
                                    solnOutputs.(fnSoln{i})) '</div>'];
                            end
                        end
                    end
                end
                
                %Check whether files should have been produced by student
                if ~isempty(solnFiles)
                    if length(solnFiles) > length(this.files)
                        for i = 1:length(this.files)                            
                            if ~this.files(i).equals(solnFiles(i))
                                html = [html this.files(i).generateFeedback(solnFiles(i))];
                            end
                        end
                        for i = length(this.files)+1:length(solnFiles)
                            html = [html '<p>Your code did not produce a file to match ', ...
                                    solnFiles(i).name '</p>'];
                        end
                    elseif length(solnFiles) < length(this.files)
                        for i = 1:length(solnFiles)
                            if ~this.files(i).equals(solnFiles(i))
                                html = [html this.files(i).generateFeedback(solnFiles(i))];
                            end
                        end
                        for i = length(solnFiles)+1:length(this.files)
                            html = [html '<p>The solution did not produce a file to match ', ...
                                    this.files(i).name '</p>'];
                        end
                    else
                        for i = 1:length(solnFiles)
                            if ~this.files(i).equals(solnFiles(i))
                                html = [html this.files(i).generateFeedback(solnFiles(i))];
                            end
                        end
                    end
                end
                
                %Check whether plots should have been produced by student
                if ~isempty(solnPlots)
                    if length(solnPlots) > length(this.plots)
                        for i = 1:length(this.plots)
                            if ~this.plots(i).equals(solnPlots(i))
                                html = [html this.plots(i).generateFeedback(solnPlots(i))];
                            end
                        end
                        for i = length(this.plots)+1:length(solnPlots)
                            html = [html '<div class="row">', ...
                                sprintf(['<div class="col-md-6 text-center">', ...
                                '<h2 class="text-center">Your Plot</h2>', ...
                                '<p class="not-found">You didn''t plot anything for this plot</p>', ...
                                '</div><div class="col-md-6 text-center"><h2 class="text-center">Solution Plot</h2>', ...
                                '<img class="img-fluid img-thumbnail" src="%s"></div></div>'], ...
                                img2base64(solnPlots(i).Image))];
                        end
                    elseif length(solnPlots) < length(this.plots)
                        for i = 1:length(solnPlots)
                            if ~this.plots(i).equals(solnPlots(i))
                                html = [html this.plots(i).generateFeedback(solnPlots(i))];
                            end
                        end
                        for i = length(solnPlots)+1:length(this.plots)
                            html = [html '<div class="row">', ...
                                sprintf(['<div class="col-md-6 text-center">', ...
                                '<h2 class="text-center">Your Plot</h2>', ...
                                '<img class="img-fluid img-thumbnail" src="%s">', ...
                                '</div><div class="col-md-6 text-center"><h2 class="text-center">Solution Plot</h2>', ...
                                '<p class="not-found">The solution didn''t plot anything for this plot</p></div></div>'], ...
                                img2base64(this.plots(i).Image))];
                        end
                    else
                        for i = 1:length(solnPlots)
                            if ~this.plots(i).equals(solnPlots(i))
                                html = [html this.plots(i).generateFeedback(solnPlots(i))];
                            end
                        end
                    end
                end
            end
            html = sprintf('%s</div><p>Points earned for this test case: %0.1f/%0.1f</p></div>',...
                            html, this.points, this.testCase.points);
        end
    end
end