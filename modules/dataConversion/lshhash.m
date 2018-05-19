%% lshHash: Locale Sensitive Hash
%
% Written by Greg Shkhnarovich (2008).
%
% H = lshHash(K) will use the values in K to create hash H.
%
% H = lshHash(K, P) will use the values in K and the prime number P to
% create hash H.
%
%%% Remarks
%
% A Locale Sensitive Hash is one where similar values lead to similar
% hashes - it is designed to encourage a collision.
%
function hkey = lshHash(keys, pNum)
    if nargin < 2
        pNum = 59;
    end
    P = primes(pNum);

    [~, m] = size(keys);
    M = min(length(P), m);

    hpos = zeros(1,M); % indices of positions used to hash
    for i = 1:M
        if mod(i,2) == 1
            hpos(i) = (i + 1)/2;
        else
            hpos(i) = m - (i/2) + 1;
        end
    end

    % now compute for each row the dot product of a sub-row with the primes
    hkey = sum(bsxfun(@times, double(keys(:, hpos)), P(1:M)), 2) + 1;
end