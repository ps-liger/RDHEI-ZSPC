function [exUB_Data, exUB_numData] = Extract_UBdata(tag_preprocess, num_emubD, data_start, block_size, ...
    final_Stego1, final_Stego2, final_Stego3, final_Stego4, ...
    final_Stego5, final_Stego6, final_Stego7, final_Stego8)

if num_emubD <= 0
    exUB_Data = [];
    exUB_numData = 0;
    return;
end

Stego_all = {final_Stego1, final_Stego2, final_Stego3, final_Stego4, ...
             final_Stego5, final_Stego6, final_Stego7, final_Stego8};

remaining = num_emubD;
num_extract = zeros(1, 8);

for bp = 1:8
    if tag_preprocess(bp) == 1 && remaining > 0
        [row, col] = size(Stego_all{bp});
        capacity = compute_ub_capacity(row, col, data_start(bp,1), data_start(bp,2), block_size);
        num_extract(bp) = min(remaining, capacity);
        remaining = remaining - num_extract(bp);
    end
end

exUB_Data = [];
for bp = 1:8
    if tag_preprocess(bp) == 1 && num_extract(bp) > 0
        [exUBD_bp, ~] = extract(Stego_all{bp}, num_extract(bp), ...
            data_start(bp,1), data_start(bp,2), block_size);
        exUB_Data = [exUB_Data, exUBD_bp];
    end
end

exUB_numData = length(exUB_Data);
end


function capacity = compute_ub_capacity(row, col, start_x, start_y, block_size)
if start_x <= 0 || start_y <= 0
    capacity = 0;
    return;
end
block_m = floor(row / block_size);
block_n = floor(col / block_size);
start_block_row = (start_x - 1) / block_size;
start_block_col = (start_y - 1) / block_size;
remaining_blocks = (block_m - start_block_row) * block_n - start_block_col;
capacity = max(0, remaining_blocks * block_size * block_size);
end


function [exUBD, exUB_t] = extract(Stego_bitplane, num_extract, start_x, start_y, block_size)
[row, col] = size(Stego_bitplane);
block_m = floor(row / block_size);
block_n = floor(col / block_size);

exUBD = zeros(1, num_extract);
exUB_t = 0;

cur_x = start_x;
cur_y = start_y;

while exUB_t < num_extract
    for p = 0:block_size-1
        for q = 0:block_size-1
            if exUB_t >= num_extract
                break;
            end
            exUB_t = exUB_t + 1;
            vx = cur_x + p;
            vy = cur_y + q;
            exUBD(exUB_t) = Stego_bitplane(vx, vy);
        end
        if exUB_t >= num_extract
            break;
        end
    end

    if exUB_t >= num_extract
        break;
    end

    if cur_y + block_size > block_n * block_size
        cur_x = cur_x + block_size;
        cur_y = 1;
    else
        cur_y = cur_y + block_size;
    end

    if cur_x > block_m * block_size
        break;
    end
end
end
