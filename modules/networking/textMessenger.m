%% textMessenger: Send a text to a phone number
%
% textMessenger(N, C, J, M, T, K, I, S) will send a text to the phone
% number N on carrier C, using subject line J and message M. Additionally,
% it will use token T, key K, ID I, and secret S.
%
%%% Remarks
%
% N can be in a variety of formats; however, it must represent a valid 
% 10-digit number. 'String' represents a character vector or a string.
%
% * Numeric -> 5555555555
% * String -> "5555555555"
% * String -> "(555) 555-5555"
% * String -> "(555)555-5555"
%
% This will only work for numbers based in the US.
%
% The carrier is pre-selected; however, it can be any one of the following
% strings:
%
% * AT&T
% * Verizon
% * T-Mobile
% * Virgin
% * Sprint
%
%%% Exceptions
%
% An AUTOGRADER:networking:textMessenger:invalidNumber exception if the
% number is invalid
function textMessenger(number, carrier, subject, message, gmailToken, gmailKey, id, secret)
CARRIERS = containers.Map({'AT&T', 'Verizon', 'T-Mobile', ...
    'Virgin', 'Sprint', 'Republic'}, ...
    {'%s@txt.att.net', '%s@vtext.com', '%s@@tmomail.net', ...
    '%s@vmobl.com', '%s@messaging.sprintpcs.com', '%s@text.republicwireless.com'});

    if isnumeric(number)
        number = num2str(number);
    elseif isstring(number)
        number = char(number);
    end
    if any(number == '+')
        throw(MException('AUTOGRADER:networking:textMessenger:invalidNumber', ...
            'Number "%s" is invalid (Did you include a country code?', number));
    end
    number(number == '(') = '';
    number(number == ')') = '';
    number(number == ' ') = '';
    number(number == '-') = '';
    if length(number) ~= 10
        throw(MException('AUTOGRADER:networking:textMessenger:invalidNumber', ...
            'Number "%s" is invalid (are you sure you included area code?)', number));
    end
    if any(number < '0' | number > '9')
        throw(MException('AUTOGRADER:networking:textMessenger:invalidNumber', ...
            'Number "%s" is invalid (did you include illegal characters?)', number));
    end
    
    keys = CARRIERS.keys;
    mask = contains(keys, carrier, 'IgnoreCase', true);
    if ~any(mask)
        throw(MException('AUTOGRADER:networking:textMessenger:invalidNumber', ...
            'Carrier "%s" isn''t recognized...', data.carrier));
    else
        email = sprintf(CARRIERS(keys{find(mask, 1)}), number);
    end
    if isempty(email)
        throw(MException('AUTOGRADER:networking:textMessenger:invalidNumber', ...
            'Carrier "%s" isn''t recognized...', data.carrier));
    end
    message = strrep(message, '&', '&amp;');
    message = strrep(message, '<', '&lt;');
    message = strrep(message, '>', '&gt;');
    emailMessenger(email, subject, message, gmailToken, id, secret, gmailKey);
end