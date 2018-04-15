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
classdef Feedback < handle
    properties (Constant)
        CORRECT_MARK = '<i class="fas fa-check"></i>';
        INCORRECT_MARK = '<i class="fas fa-times"></i>';
    end
    properties (Access = public)
        testCase;
        hasPassed;
        path;
        outputs;
        files;
        plots;
        reason;
        points;
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
        %%% Exceptions
        %
        % An AUTOGRADER:FEEDBACK:INVALIDTESTCASE exception will be thrown
        % if the testCase is incorrectly formatted or missing information
        %
        %%% Unit Tests
        %
        %   T = testCase; % Given a valid TestCase:
        %   F = Feedback(T);
        %
        %   F.testCase -> T;
        %
        %   T = [];
        %   F = Feedback(T);
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
        % H = generateFeedback() generates the complete html
        % feedback for this based on the information stored in the
        % properties
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
        %%% Exceptions
        %
        % An AUTOGRADER:FEEDBACK:GENERATEFEEDBACK:INVALIDFEEDBACK exception
        % will be thrown if no Feedback is given or the given Feedback has
        % insufficient or missing data
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
        % Given an invalid Feedback: 
        % an AUTOGRADER:FEEDBACK:GENERATEFEEDBACK:INVALIDFEEDBACK exception
        % will be thrown
        %
        %
        function html = generateFeedback(this)
            %Check if testCase was passed and output empty div
            if this.hasPassed
                html = '<div></div>';
            else
                %Get solution outputs for testCase
                solnOutputs = this.testCase.outputs;
                solnFiles = this.testCase.outputs;
                solnPlots = this.testCase.plots;
                
                %Check whether regular outputs should have been produced
                %by student
                if ~isempty(solnOutputs)
                    fn = fieldnames(solnOutputs);
                    for i = 1:length(fn)
                        str = generateFeedback(this.outputs.(fn{i}),solnOutputs.(fn{i}));
                    end
                end
                
                %Check whether files should have been produced by student
                if ~isempty(solnFiles)
                    for i = 1:length(solnFiles)
                        str = File.generateFeedback(this.files(i),solnFiles(i));
                    end
                end
                
                %Check whether plots should have been produced by student
                if ~isempty(solnPlots)
                    for i = 1:length(solnPlots)
                        str = Plot.generateFeedback(this.plots(i),solnPlots(i));
                    end
                end
            end
            html = sprintf('<div class="container feedback"><p>%s</p><p>%s</p></div>',this.reason,str);
        end
    end
end