%% textMessenger: Send a text to a phone number
%
% textMessenger(N, S, M, T, G, K) will send a text to the phone number N
% with the subject S and message M, using the numverify token T, Google
% token G, and Google API Key K.
%
%%% Remarks
%
% This is based on the numverifier API, which allows us to programmatically
% determine the carrier for a phone number.
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
%%% Exceptions
%
% An AUTOGRADER:networking:textMessenger:invalidNumber exception if the
% number is invalid
function textMessenger(number, subject, message, numToken, gmailToken, gmailkey)
NUM_VERIFIER_API = 'http://apilayer.net/api/validate';
CARRIERS = containers.Map({'AT&T', 'Verizon', 'T-Mobile', 'Virgin', 'Sprint'}, ...
    {'%s@txt.att.net', '%s@vtext.com', '%s@@tmomail.net', ...
    '%s@vmobl.com', '%s@messaging.sprintpcs.com'});

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
    
    opts = weboptions('RequestMethod', 'GET');
    data = webread(NUM_VERIFIER_API, 'access_key', numToken, ...
        'number', number, 'country_code', 'US', opts);
    if data.valid
        keys = CARRIERS.keys;
        email = '';
        for k = keys
            if contains(data.carrier, k{1}, 'IgnoreCase', true)
                email = sprintf(CARRIERS(k{1}), number);
                break;
            end
        end
        if isempty(email)
            throw(MException('AUTOGRADER:networking:textMessenger:invalidNumber', ...
                'Carrier "%s" isn''t recognized...', data.carrier));
        end
        message = strrep(message, '&', '&amp;');
        message = strrep(message, '<', '&lt;');
        message = strrep(message, '>', '&gt;');
        emailMessenger(email, subject, message, gmailToken, gmailkey);
    else
        throw(MException('AUTOGRADER:networking:textMessenger:invalidNumber', ...
            'Number "%s" is invalid...', number));
    end