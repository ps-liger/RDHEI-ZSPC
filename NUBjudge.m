function [tag_NUB, case_id] = NUBjudge(Process_bitplane, block_size, fnub)
% NUBjudge
% The first fnub compacted blocks in the rearranged plane are the NUB area.
% We scan only those first fnub block positions in row-major order.

[~, col] = size(Process_bitplane);
block_n  = floor(col / block_size);
half     = block_size / 2;

tag_NUB = ones(1, fnub);
case_id = zeros(1, fnub);

startx = 1;
starty = 1;

for i = 1 : fnub
    bx = startx;
    by = starty;

    s    = zeros(1, 4);
    s(1) = all(all(Process_bitplane(bx      : bx+half-1,       by      : by+half-1)       == 0));
    s(2) = all(all(Process_bitplane(bx      : bx+half-1,       by+half : by+block_size-1) == 0));
    s(3) = all(all(Process_bitplane(bx+half : bx+block_size-1, by      : by+half-1)       == 0));
    s(4) = all(all(Process_bitplane(bx+half : bx+block_size-1, by+half : by+block_size-1) == 0));

    zero_cnt = sum(s);

    if zero_cnt == 2 || zero_cnt == 3
        tag_NUB(i) = 0;
        case_id(i) = get_NUB_case(s);
    else
        tag_NUB(i) = 1;
        case_id(i) = 0;
    end

    [startx, starty] = advance_block_cursor(startx, starty, block_n, block_size);
end
end

function [next_x, next_y] = advance_block_cursor(cur_x, cur_y, block_n, block_size)
if cur_y + block_size > block_n * block_size
    next_x = cur_x + block_size;
    next_y = 1;
else
    next_x = cur_x;
    next_y = cur_y + block_size;
end
end

function cid = get_NUB_case(s)
if     isequal(s, [0,1,1,1]),  cid = 1;
elseif isequal(s, [1,0,1,1]),  cid = 2;
elseif isequal(s, [1,1,0,1]),  cid = 3;
elseif isequal(s, [1,1,1,0]),  cid = 4;
elseif isequal(s, [1,1,0,0]),  cid = 5;
elseif isequal(s, [0,0,1,1]),  cid = 6;
elseif isequal(s, [1,0,1,0]),  cid = 7;
elseif isequal(s, [0,1,0,1]),  cid = 8;
elseif isequal(s, [1,0,0,1]),  cid = 9;
elseif isequal(s, [0,1,1,0]),  cid = 10;
else,                           cid = 0;
end
end
