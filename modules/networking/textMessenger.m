%% textMessenger: Send a text to a phone number
%
% textMessenger(N, M, S, T, O) will send a message with content M to number
% N, using Twilio SID S, Token T, and origin number O.
%
%%% Remarks
%
% N must be a valid phone number; optionally, it can include the country
% code; however, it must be at LEAST 10 digits long. It can be given as
% either a string or a character vector.
%
%%% Exceptions
%
% An AUTOGRADER:networking:textMessenger:invalidNumber exception if the
% number is invalid
function textMessenger(number, message, sid, token, origin)
TWILIO_API = sprintf('https://api.twilio.com/2010-04-01/Accounts/%s/Messages.json', sid);
    if isstring(number)
        number = char(number);
    end
    number(number ~= '+' & (number < '0' | number > '9')) = '';
    
    % Write to the twilio API
    opts = weboptions();
    opts.RequestMethod = 'POST';
    opts.Username = sid;
    opts.Password = token;
    webwrite(TWILIO_API, 'To', number, 'From', origin, 'Body', message, opts);
end