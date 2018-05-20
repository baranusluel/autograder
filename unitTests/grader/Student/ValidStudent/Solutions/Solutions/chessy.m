function [board,desc] = chessy(board,fnm)
    fh = fopen(fnm);
    move = fgetl(fh);
    white = '';
    black = '';
    while ischar(move)
        curr = move(1:2);
        next = move(end-1:end);
        [r,c] = decodeMove(curr);
        [rnew,cnew] = decodeMove(next);
        piece = board(r,c);
        target = board(rnew,cnew);
        if target ~= ' '
            if lower(target) == target
                white = [white target];
            else
                black = [black target];
            end
        end
        board(rnew,cnew) = piece;
        board(r,c) = ' ';
        move = fgetl(fh);
    end
    fclose(fh);
    if isempty(white)
        white = 'none :(';
    end
    if isempty(black)
        black = 'none :(';
    end
    desc = sprintf('Pieces taken by white: %s. Pieces taken by black: %s.',white,black);
end

function [r,c] = decodeMove(move)
    r = 9 - str2num(move(2)); 
    c = move(1) - 96;
end