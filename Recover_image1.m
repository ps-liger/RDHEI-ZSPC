function [recover_bitplane1,recover_bitplane2,recover_bitplane3,recover_bitplane4,...
          recover_bitplane5,recover_bitplane6,recover_bitplane7,recover_bitplane8] = ...
    Recover_image1(Decrypt_I,compress_type_len,tag_preprocess,recover_start_ub,block_size,...
    typeI1,typeI2,typeI3,typeI4,typeI5,typeI6,typeI7,typeI8,...
    tag_NUB1,tag_NUB2,tag_NUB3,tag_NUB4,tag_NUB5,tag_NUB6,tag_NUB7,tag_NUB8,...
    case_id1,case_id2,case_id3,case_id4,case_id5,case_id6,case_id7,case_id8,...
    final_Stego1,final_Stego2,final_Stego3,final_Stego4,...
    final_Stego5,final_Stego6,final_Stego7,final_Stego8)

[row,col] = size(Decrypt_I);


decrypt_bitplane1 = ones(row,col)*Inf; decrypt_bitplane2 = ones(row,col)*Inf;
decrypt_bitplane3 = ones(row,col)*Inf; decrypt_bitplane4 = ones(row,col)*Inf;
decrypt_bitplane5 = ones(row,col)*Inf; decrypt_bitplane6 = ones(row,col)*Inf;
decrypt_bitplane7 = ones(row,col)*Inf; decrypt_bitplane8 = ones(row,col)*Inf;
for i = 1:row
    for j = 1:col
        bin2 = Decimalism_Binary(Decrypt_I(i,j));
        decrypt_bitplane1(i,j)=bin2(1); decrypt_bitplane2(i,j)=bin2(2);
        decrypt_bitplane3(i,j)=bin2(3); decrypt_bitplane4(i,j)=bin2(4);
        decrypt_bitplane5(i,j)=bin2(5); decrypt_bitplane6(i,j)=bin2(6);
        decrypt_bitplane7(i,j)=bin2(7); decrypt_bitplane8(i,j)=bin2(8);
    end
end

recover_bitplane1=decrypt_bitplane1; recover_bitplane2=decrypt_bitplane2;
recover_bitplane3=decrypt_bitplane3; recover_bitplane4=decrypt_bitplane4;
recover_bitplane5=decrypt_bitplane5; recover_bitplane6=decrypt_bitplane6;
recover_bitplane7=decrypt_bitplane7; recover_bitplane8=decrypt_bitplane8;

if tag_preprocess(1)==1
    recover_bitplane1 = recover_onebitplane(typeI1,block_size,...
        tag_NUB1,case_id1,decrypt_bitplane1);
end
if tag_preprocess(2)==1
    recover_bitplane2 = recover_onebitplane(typeI2,block_size,...
        tag_NUB2,case_id2,decrypt_bitplane2);
end
if tag_preprocess(3)==1
    recover_bitplane3 = recover_onebitplane(typeI3,block_size,...
        tag_NUB3,case_id3,decrypt_bitplane3);
end
if tag_preprocess(4)==1
    recover_bitplane4 = recover_onebitplane(typeI4,block_size,...
        tag_NUB4,case_id4,decrypt_bitplane4);
end
if tag_preprocess(5)==1
    recover_bitplane5 = recover_onebitplane(typeI5,block_size,...
        tag_NUB5,case_id5,decrypt_bitplane5);
end
if tag_preprocess(6)==1
    recover_bitplane6 = recover_onebitplane(typeI6,block_size,...
        tag_NUB6,case_id6,decrypt_bitplane6);
end
if tag_preprocess(7)==1
    recover_bitplane7 = recover_onebitplane(typeI7,block_size,...
        tag_NUB7,case_id7,decrypt_bitplane7);
end
if tag_preprocess(8)==1
    recover_bitplane8 = recover_onebitplane(typeI8,block_size,...
        tag_NUB8,case_id8,decrypt_bitplane8);
end
end


function PE_bitplane = recover_onebitplane(typeI, block_size, tag_NUB, case_id, decrypt_bitplane)

[row, col] = size(decrypt_bitplane);
block_m = floor(row / block_size);
block_n  = floor(col / block_size);
half     = block_size / 2;
fnub     = length(tag_NUB);

%% Step 1: Clean up zero-subblocks in rearranged NUB area (first fnub blocks)
nub_clean = decrypt_bitplane;
startx = 1; starty = 1;
for i = 1:fnub
    if tag_NUB(i) == 0
        cid = case_id(i);
        zero_subs = get_zero_subblocks(cid);
        for k = 1:length(zero_subs)
            [ox, oy] = get_subblock_offset(zero_subs(k), half);
            nub_clean(startx+ox : startx+ox+half-1, ...
                      starty+oy : starty+oy+half-1) = 0;
        end
    end
    if starty + block_size > block_n * block_size
        startx = startx + block_size;
        starty  = 1;
    else
        starty  = starty + block_size;
    end
end

%% Step 2: Inverse rearrangement
% Original UB blocks → all zeros (no need to copy)
% Original NUB blocks → read sequentially from nub_clean (first fnub blocks)
PE_bitplane = zeros(row, col);
start_nubx = 1;
start_nuby = 1;

for i = 1:block_m
    for j = 1:block_n
        orig_x = (i-1)*block_size + 1;
        orig_y = (j-1)*block_size + 1;

        if typeI(i,j) == 1
            PE_bitplane(orig_x : orig_x+block_size-1, ...
                        orig_y : orig_y+block_size-1) = ...
                nub_clean(start_nubx : start_nubx+block_size-1, ...
                          start_nuby : start_nuby+block_size-1);

            if start_nuby + block_size > block_n * block_size
                start_nubx = start_nubx + block_size;
                start_nuby  = 1;
            else
                start_nuby  = start_nuby + block_size;
            end
        end
        % typeI==0: already zero, no action needed
    end
end
end

function zero_subs = get_zero_subblocks(cid)
pattern = {[2,3,4],[1,3,4],[1,2,4],[1,2,3],[1,2],[3,4],[1,3],[2,4],[1,4],[2,3]};
zero_subs = pattern{cid};
end

function [ox, oy] = get_subblock_offset(sub_idx, half)
switch sub_idx
    case 1, ox=0;    oy=0;
    case 2, ox=0;    oy=half;
    case 3, ox=half; oy=0;
    case 4, ox=half; oy=half;
end
end

