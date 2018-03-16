%% getMessages Gets the default messages
%
%   messages = getMessages()
%
%   Input:
%       NONE
%
%   Output:
%       messages (struct)
%           - structure containing the default messages
%
%   Description:
%       Gets the default messages
function messages = getMessages()
    messages.compare.classMismatch     = 'CLASS MISMATCH';
    messages.compare.dimensionMismatch = 'DIMENSION MISMATCH';
    messages.compare.valueIncorrect    = 'VALUE INCORRECT';
    messages.compare.fileIncorrect     = 'FILE INCORRECT';
    
    messages.errors.timeout            = 'TIMEOUT';
    messages.errors.infiniteLoop       = 'INFINITE LOOP';
    messages.errors.unknownError       = 'AN ERROR OCCURED IN YOUR FUNCTION';

    messages.files.outputFileNotFound  = 'OUTPUT FILE NOT FOUND';

    messages.plots.plotNotFound        = 'PLOT NOT FOUND';

    messages.variables.incorrectNumberOfOutputs = 'INCORRECT NUMBER OF OUTPUTS';
end