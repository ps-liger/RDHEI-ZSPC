function [typeI1,typeI2,typeI3,typeI4,typeI5,typeI6,typeI7,typeI8,compress_type_len,recover_start_ub,Predict_error_I,judge_predict,compress_predict,tag_preprocess,finalem,f,Process_bitplane1,Process_bitplane2,Process_bitplane3,Process_bitplane4,Process_bitplane5,Process_bitplane6,Process_bitplane7,Process_bitplane8] = Preprocess1(Origin_I,block_size)
% Preprocess1
% Main fix:
% 1) finalem is no longer estimated by f + ceil(ftypeI/16).
% 2) The compressed type stream is written by an explicit UB cursor.
% 3) finalem is the actual next UB block after type bits are written.

[Predict_error_I,judge_predict,compress_predict] = Predict_error(Origin_I);

[PE_bitplane1,PE_bitplane2,PE_bitplane3,PE_bitplane4,PE_bitplane5,PE_bitplane6,PE_bitplane7,PE_bitplane8] = One_to_eight(Predict_error_I,judge_predict);

[compress_type_len1,typeI1,Process_bitplane1,tag1,f1,recover_start_ubx1,recover_start_uby1,finalem_x1,finalem_y1] = Rearrange(PE_bitplane1,block_size);
[compress_type_len2,typeI2,Process_bitplane2,tag2,f2,recover_start_ubx2,recover_start_uby2,finalem_x2,finalem_y2] = Rearrange(PE_bitplane2,block_size);
[compress_type_len3,typeI3,Process_bitplane3,tag3,f3,recover_start_ubx3,recover_start_uby3,finalem_x3,finalem_y3] = Rearrange(PE_bitplane3,block_size);
[compress_type_len4,typeI4,Process_bitplane4,tag4,f4,recover_start_ubx4,recover_start_uby4,finalem_x4,finalem_y4] = Rearrange(PE_bitplane4,block_size);
[compress_type_len5,typeI5,Process_bitplane5,tag5,f5,recover_start_ubx5,recover_start_uby5,finalem_x5,finalem_y5] = Rearrange(PE_bitplane5,block_size);
[compress_type_len6,typeI6,Process_bitplane6,tag6,f6,recover_start_ubx6,recover_start_uby6,finalem_x6,finalem_y6] = Rearrange(PE_bitplane6,block_size);
[compress_type_len7,typeI7,Process_bitplane7,tag7,f7,recover_start_ubx7,recover_start_uby7,finalem_x7,finalem_y7] = Rearrange(PE_bitplane7,block_size);
[compress_type_len8,typeI8,Process_bitplane8,tag8,f8,recover_start_ubx8,recover_start_uby8,finalem_x8,finalem_y8] = Rearrange(PE_bitplane8,block_size);

tag_preprocess=zeros(1,8);
tag_preprocess(1:8)=[tag1 tag2 tag3 tag4 tag5 tag6 tag7 tag8];

finalem=zeros(8,2);
finalem(1,1)=finalem_x1;finalem(1,2)=finalem_y1;
finalem(2,1)=finalem_x2;finalem(2,2)=finalem_y2;
finalem(3,1)=finalem_x3;finalem(3,2)=finalem_y3;
finalem(4,1)=finalem_x4;finalem(4,2)=finalem_y4;
finalem(5,1)=finalem_x5;finalem(5,2)=finalem_y5;
finalem(6,1)=finalem_x6;finalem(6,2)=finalem_y6;
finalem(7,1)=finalem_x7;finalem(7,2)=finalem_y7;
finalem(8,1)=finalem_x8;finalem(8,2)=finalem_y8;

f=zeros(1,8);
f(1:8)=[f1 f2 f3 f4 f5 f6 f7 f8];

recover_start_ub=zeros(8,2);
recover_start_ub(1,1)=recover_start_ubx1;recover_start_ub(1,2)=recover_start_uby1;
recover_start_ub(2,1)=recover_start_ubx2;recover_start_ub(2,2)=recover_start_uby2;
recover_start_ub(3,1)=recover_start_ubx3;recover_start_ub(3,2)=recover_start_uby3;
recover_start_ub(4,1)=recover_start_ubx4;recover_start_ub(4,2)=recover_start_uby4;
recover_start_ub(5,1)=recover_start_ubx5;recover_start_ub(5,2)=recover_start_uby5;
recover_start_ub(6,1)=recover_start_ubx6;recover_start_ub(6,2)=recover_start_uby6;
recover_start_ub(7,1)=recover_start_ubx7;recover_start_ub(7,2)=recover_start_uby7;
recover_start_ub(8,1)=recover_start_ubx8;recover_start_ub(8,2)=recover_start_uby8;

compress_type_len=zeros(1,8);
compress_type_len(1)=compress_type_len1;compress_type_len(2)=compress_type_len2;
compress_type_len(3)=compress_type_len3;compress_type_len(4)=compress_type_len4;
compress_type_len(5)=compress_type_len5;compress_type_len(6)=compress_type_len6;
compress_type_len(7)=compress_type_len7;compress_type_len(8)=compress_type_len8;
end

function [Predict_error_I,judge_predict,compress_predict] = Predict_error(Origin_I)
[row,col] = size(Origin_I);

Predict_error_I = zeros(row,col);
judge_predict   = ones(row,col);

Predict_error_I(1,1) = Origin_I(1,1);
judge_predict(1,1)   = 1;

for j = 2:col
    pe = Origin_I(1,j) - Origin_I(1,j-1);
    if (pe > 64) || (pe < -64)
        Predict_error_I(1,j) = Origin_I(1,j);
        judge_predict(1,j) = 1;
    else
        Predict_error_I(1,j) = pe;
        judge_predict(1,j) = 0;
    end
end

for i = 2:row
    pe = Origin_I(i,1) - Origin_I(i-1,1);
    if (pe > 64) || (pe < -64)
        Predict_error_I(i,1) = Origin_I(i,1);
        judge_predict(i,1) = 1;
    else
        Predict_error_I(i,1) = pe;
        judge_predict(i,1) = 0;
    end
end

for i = 2:row
    for j = 2:col
        x1 = Origin_I(i-1,j-1);
        x2 = Origin_I(i-1,j);
        x3 = Origin_I(i,j-1);

        if j == col
            pred = MED_pred(x1,x2,x3);
        else
            x4 = Origin_I(i-1,j+1);
            pred = SGAP_pred(x1,x2,x3,x4);
        end

        pe = Origin_I(i,j) - pred;

        if (pe > 64) || (pe < -64)
            Predict_error_I(i,j) = Origin_I(i,j);
            judge_predict(i,j) = 1;
        else
            Predict_error_I(i,j) = pe;
            judge_predict(i,j) = 0;
        end
    end
end

flow_map = judge_predict;
cPos_x = cell(1,1);
cPos_x{1} = flow_map;
loc_Com = arith07(cPos_x);
bin_index = 8;
[compress_predict, ~] = dec_transform_bin(loc_Com, bin_index);
end

function pred = MED_pred(x1,x2,x3)
if x1 <= min(x2,x3)
    pred = max(x2,x3);
elseif x1 >= max(x2,x3)
    pred = min(x2,x3);
else
    pred = x2 + x3 - x1;
end
end

function pred = SGAP_pred(x1,x2,x3,x4)
pred = round((x2 + x3)/2 + (x4 - x1)/4);
pred = min(255, max(0, pred));
end

function [PE_bitplane1,PE_bitplane2,PE_bitplane3,PE_bitplane4,PE_bitplane5,PE_bitplane6,PE_bitplane7,PE_bitplane8] = One_to_eight(Predict_error_I,judge_predict)
[row,col] = size(Predict_error_I);

PE_bitplane1 = zeros(row,col); PE_bitplane2 = zeros(row,col);
PE_bitplane3 = zeros(row,col); PE_bitplane4 = zeros(row,col);
PE_bitplane5 = zeros(row,col); PE_bitplane6 = zeros(row,col);
PE_bitplane7 = zeros(row,col); PE_bitplane8 = zeros(row,col);

for i = 1:row
    for j = 1:col
        if judge_predict(i,j) == 0
            bin2 = zf_Decimalism_Binary(Predict_error_I(i,j));
        else
            bin2 = Decimalism_Binary(Predict_error_I(i,j));
        end

        PE_bitplane1(i,j)= bin2(1);
        PE_bitplane2(i,j)= bin2(2);
        PE_bitplane3(i,j)= bin2(3);
        PE_bitplane4(i,j)= bin2(4);
        PE_bitplane5(i,j)= bin2(5);
        PE_bitplane6(i,j)= bin2(6);
        PE_bitplane7(i,j)= bin2(7);
        PE_bitplane8(i,j)= bin2(8);
    end
end
end

function [compress_type_len,typeI,Process_bitplane1,tag,f,recover_start_ubx,recover_start_uby,finalem_x1,finalem_y1] = Rearrange(PE_bitplane1,block_size)
[row,col] = size(PE_bitplane1);
block_m = floor(row/block_size);
block_n = floor(col/block_size);

typeI = ones(block_m,block_n)*Inf;
Process_bitplane1 = PE_bitplane1;
tag = 0;

for i = 1:block_m
    for j = 1:block_n
        start_x = (i-1)*block_size + 1;
        start_y = (j-1)*block_size + 1;
        block = PE_bitplane1(start_x:start_x+block_size-1, start_y:start_y+block_size-1);
        if sum(block(:)) == 0
            typeI(i,j) = 0;
        else
            typeI(i,j) = 1;
        end
    end
end

f = sum(typeI(:) == 1);

flow_map = typeI;
cPos_x = cell(1,1);
cPos_x{1} = flow_map;
loc_Com = arith07(cPos_x);
bin_index = 8;
[compress_type,compress_type_len] = dec_transform_bin(loc_Com, bin_index);
ftypeI = compress_type_len;

start_nubx = 1;
start_nuby = 1;
[recover_start_ubx, recover_start_uby] = linear_block_to_coord(f, block_n, block_size);

for i = 1:block_m
    for j = 1:block_n
        start_x = (i-1)*block_size + 1;
        start_y = (j-1)*block_size + 1;

        if typeI(i,j) == 1
            Process_bitplane1(start_nubx:start_nubx+block_size-1, start_nuby:start_nuby+block_size-1) = ...
                PE_bitplane1(start_x:start_x+block_size-1, start_y:start_y+block_size-1);
            [start_nubx, start_nuby] = advance_block_cursor(start_nubx, start_nuby, block_n, block_size);
        else
            [start_ubx, start_uby] = linear_block_to_coord(f + find_ub_rank(typeI, i, j) - 1, block_n, block_size);
            Process_bitplane1(start_ubx:start_ubx+block_size-1, start_uby:start_uby+block_size-1) = ...
                PE_bitplane1(start_x:start_x+block_size-1, start_y:start_y+block_size-1);
        end
    end
end

tag_NUB = NUBjudge(Process_bitplane1,block_size,f);
flow_map = tag_NUB;
cPos_x = cell(1,1);
cPos_x{1} = flow_map;
loc_Com = arith07(cPos_x);
[~, compress_NUB_len] = dec_transform_bin(loc_Com, bin_index);

if (block_m*block_n-f)*(block_size*block_size) <= (ftypeI + compress_NUB_len + 15)
    tag = 0;
    recover_start_ubx = 0;
    recover_start_uby = 0;
    Process_bitplane1 = PE_bitplane1;
    compress_type_len = 0;
    finalem_x1 = 0;
    finalem_y1 = 0;
    return;
end

tag = 1;

[Process_bitplane1, finalem_x1, finalem_y1] = write_bits_by_blocks( ...
    Process_bitplane1, compress_type, recover_start_ubx, recover_start_uby, block_n, block_size);
end

function rank = find_ub_rank(typeI, ii, jj)
rank = 0;
for r = 1:size(typeI,1)
    for c = 1:size(typeI,2)
        if typeI(r,c) == 0
            rank = rank + 1;
        end
        if r == ii && c == jj
            return;
        end
    end
end
end

function [bitplane, next_x, next_y] = write_bits_by_blocks(bitplane, bits, start_x, start_y, block_n, block_size)
if isempty(bits)
    next_x = start_x;
    next_y = start_y;
    return;
end

cur_x = start_x;
cur_y = start_y;
t = 1;
nbits = length(bits);

while t <= nbits
    for p = 0:block_size-1
        for q = 0:block_size-1
            if t > nbits
                break;
            end
            bitplane(cur_x + p, cur_y + q) = bits(t);
            t = t + 1;
        end
        if t > nbits
            break;
        end
    end
    [cur_x, cur_y] = advance_block_cursor(cur_x, cur_y, block_n, block_size);
end

next_x = cur_x;
next_y = cur_y;
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

function [x, y] = linear_block_to_coord(block_idx_zero_based, block_n, block_size)
x = floor(block_idx_zero_based / block_n) * block_size + 1;
y = mod(block_idx_zero_based, block_n) * block_size + 1;
end
