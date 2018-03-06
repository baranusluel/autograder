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
% **TBD**
%
classdef Student
    properties (Access = public)
        name;
        id;
        path;
        submissions;
        feedbacks;
        isGraded;
    end
    methods
        %% Constructor: Instantiates a Student
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
        % with what the autograder will expect
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
            
        end
        
        %% generateFeedback: Generate HTML feedback for student
        %
        % generateFeedback is used to create an HTML file containing the
        % homework feedback for a student.
        %
        % HTML = generateFeedback() will return a char vector HTML
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
        function html = generateFeedback(this)
            
        end
    end
end