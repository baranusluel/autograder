classdef student
    properties
        Name char
        ID char
        Submissions cell
        Feedback feedback
    end
    methods(Static)
        testCases = gradeProblem(problem)
        
        feedbackStr = generateResponse()
        
    end
end