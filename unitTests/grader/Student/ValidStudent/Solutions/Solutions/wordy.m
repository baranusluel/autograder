function str = wordy(int)
if int == 0
    str = 'zero';
    return;
end
if int < 0
    neg = 'negative ';
    int = abs(int);
else
    neg = '';
end
lows = {'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine', 'ten', 'eleven', 'twelve', 'thirteen', 'fourteen', 'fifteen', 'sixteen', 'seventeen', 'eighteen', 'nineteen'};
if int >= 100
    str = [lows{floor(int/100)}, ' ', 'hundred'];
    if mod(int, 100) ~= 0
        str = [str, ' and'];
    end
    str = [str, ' ', twoDigs2str(mod(int, 100), lows)];
else
    str = twoDigs2str(int, lows);
end
str = strtrim([neg, str]);


end

function str = twoDigs2str(int, lows)
    str = '';
    tens = {'', 'twenty', 'thirty', 'forty', 'fifty', 'sixty', 'seventy', 'eighty', 'ninety'};
    if int >= 20
        if mod(int, 10) == 0
            str = tens{floor(int/10)};
        else
            str = [tens{floor(int/10)}, '-', lows{mod(int, 10)}];
        end
    elseif int > 0
        str = [lows{int}];
    end
 end


%% Alternative Solution
% function word = int2word(int)
% if int == 0
%     word = 'zero';
%     return;
% end
% single = {'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine', 'ten', 'eleven', 'twelve', 'thirteen' ,'fourteen', 'fifteen', 'sixteen', 'seventeen', 'eighteen', 'nineteen'};
% dec = {'', 'twenty', 'thirty', 'fourty', 'fifty', 'sixty', 'seventy', 'eighty', 'ninety'};
% word = '';
% w = '';
% int=num2str(int);
% checkNeg = int(1) == '-';
% if checkNeg
%     int(1) = [];
%     % word = [word, 'negative '];
% end
% x = length(int);
% if x == 3
%     w = [single{str2num(int(1))}, ' hundred'];
%     if ~strcmp(int(2:3), '00')
%         x = x-1;
%         int(1) = [];
%     end
%     word = [word, w];
% end
% if x == 2
%     if ~isempty(word)
%         word = [word, ' and '];
%     end
%     if int(1) == '0'
%         w = ''
%     elseif int(1) == '1'
%         ind = str2num(int(2)) + 10;
%         w = single{ind};
%         x = 0;
%     else
%         w = dec{str2num(int(1))};
%     end
%     word = [word, w];
%     if int(2) ~= '0'
%         x = x-1;
%         int(1) = [];
%     end
% end
% if x == 1
%     if ~isempty(w)
%         word = [word, '-'];
%     end
%     w = single{str2num(int)};
%     word = [word, w];
% end
% if checkNeg
%     word = ['negative ' word];
% end
% end