function [final_Stego, next_emnub_t] = Embed_NUBdata( ...
    tag_NUB, case_id, Stego_bitplane, Data, emnub_t, block_size)
% Embed_NUBdata - 将秘密数据嵌入可嵌入NUB块的全零子块（单个位平面版本）
%
% 嵌入规则：
%   根据每个可嵌入NUB的情形编号，确定其全零子块位置，
%   将秘密数据顺序写入这些全零子块的像素位置。
%   情形1~4（3个全零子块）：每块可嵌入 3×4 = 12 比特
%   情形5~10（2个全零子块）：每块可嵌入 2×4 =  8 比特
%
% 输入：
%   tag_NUB        — 1×fnub，0=可嵌入，1=不可嵌入
%   case_id        — 1×fnub，情形编号（不可嵌入时为0）
%   Stego_bitplane — 当前位平面（二值矩阵）
%   Data           — 待嵌入的秘密数据比特流（0/1行向量）
%   emnub_t        — 当前数据嵌入指针（已嵌入的比特数，从0开始）
%   block_size     — 块大小（4）
%
% 输出：
%   final_Stego  — 嵌入后的位平面
%   next_emnub_t — 更新后的嵌入指针

[~, col]    = size(Stego_bitplane);
block_n     = floor(col / block_size);
final_Stego = Stego_bitplane;
half        = block_size / 2;   % = 2
num_NUB     = length(tag_NUB);
total_data  = length(Data);

startx = 1;
starty = 1;

for i = 1 : num_NUB
    if emnub_t >= total_data, break; end

    if tag_NUB(i) == 0   % 可嵌入NUB
        cid       = case_id(i);
        zero_subs = get_zero_subblocks(cid);

        for k = 1 : length(zero_subs)
            [ox, oy] = get_subblock_offset(zero_subs(k), half);

            for p = 0 : half - 1
                for q = 0 : half - 1
                    if emnub_t >= total_data, break; end
                    emnub_t = emnub_t + 1;
                    final_Stego(startx + ox + p, starty + oy + q) = Data(emnub_t);
                end
                if emnub_t >= total_data, break; end
            end
            if emnub_t >= total_data, break; end
        end
    end

    % ---------- 更新块位置（按行扫描）----------
    if starty + block_size > block_n * block_size
        startx = startx + block_size;
        starty  = 1;
    else
        starty = starty + block_size;
    end
end

next_emnub_t = emnub_t;
end


% ================================================================
% 辅助函数：根据情形编号获取全零子块编号列表
% 子块编号：1=TL, 2=TR, 3=BL, 4=BR
% ================================================================
function zero_subs = get_zero_subblocks(cid)
pattern = {
    [2,3,4], ...   % case 1
    [1,3,4], ...   % case 2
    [1,2,4], ...   % case 3
    [1,2,3], ...   % case 4
    [1,2],   ...   % case 5
    [3,4],   ...   % case 6
    [1,3],   ...   % case 7
    [2,4],   ...   % case 8
    [1,4],   ...   % case 9
    [2,3]    ...   % case 10
};
zero_subs = pattern{cid};
end


% ================================================================
% 辅助函数：子块编号 → 块内行列偏移量
% ================================================================
function [ox, oy] = get_subblock_offset(sub_idx, half)
switch sub_idx
    case 1,  ox = 0;    oy = 0;
    case 2,  ox = 0;    oy = half;
    case 3,  ox = half; oy = 0;
    case 4,  ox = half; oy = half;
end
end

