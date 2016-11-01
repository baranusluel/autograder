%% compare Compares student answer and solution
%
%   [isEqual,message] = compare(studentAnswer,solutionAnswer,isFile)
%
%   Inputs:
%       studentAnswer (any)
%           - student's answer
%       solutionAnswer (any)
%           - solution's answer
%       isFile (logical)
%           - true if files are being compared
%
%   Output(s):
%       isEqual (logical)
%           - whether or not the student answer matches the solution answer
%       message (char)
%           - output message
%
%   Description:
%       Compares student answer with solution and outputs message
function [isEqual,message] = compare(studentAnswer,solutionAnswer,isFile)

    messages = getMessages();

    if isFile

        [isEqual,message] = compareValue(studentAnswer,solutionAnswer,messages);

        if false == isEqual

            message = messages.compare.fileIncorrect;

        end

    else

        [isEqual,message] = compareClass(studentAnswer,solutionAnswer,messages);

        if isEqual

            if ischar(solutionAnswer)

                [isEqual,message] = compareValue(studentAnswer,solutionAnswer,messages);

            else

                [isEqual,message] = compareDimensions(studentAnswer,solutionAnswer,messages);

                if isEqual

                    if isnumeric(solutionAnswer)

                        [isEqual,message] = compareNumeric(studentAnswer,solutionAnswer,messages);

                    else
                        [isEqual,message] = compareValue(studentAnswer,solutionAnswer,messages);

                    end

                end

            end

        end

    end

end

function [isEqual,message] = compareClass(studentAnswer,solutionAnswer,messages)

    isEqual = strcmp(class(studentAnswer),class(solutionAnswer));
    message  = '';

    if false == isEqual
        message = messages.compare.classMismatch;
    end

end

function [isEqual,message] = compareDimensions(studentAnswer,solutionAnswer,messages)

    isEqual = (isempty(solutionAnswer) && isempty(studentAnswer)) || isequal(size(studentAnswer),size(solutionAnswer));
    message = '';

    if false == isEqual
        message = messages.compare.dimensionMismatch;
    end

end

function [isEqual,message] = compareValue(studentAnswer,solutionAnswer,messages)

    isEqual = isequaln(studentAnswer,solutionAnswer);
    message = '';

    if false == isEqual
        message = messages.compare.valueIncorrect;
    end

end

function [isEqual,message] = compareNumeric(studentAnswer,solutionAnswer,messages)

    % check if student answer is within +/- 0.01 of the solution answer
    isEqual = all(abs(studentAnswer(:) - solutionAnswer(:)) < 0.01);

    % check if student answer is correct if there are NaN values. Using ||
    % because NaN values would cause the above conditional to return false
    % since NaNs always propagate (i.e. NaN == NaN -> false)
    isEqual = isEqual || isequaln(studentAnswer,solutionAnswer);

    message = '';

    if false == isEqual
        message = messages.compare.valueIncorrect;
    end

end