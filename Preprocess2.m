function [bin_NUB_len, final_emUBdata, ...
    tag_NUB1, tag_NUB2, tag_NUB3, tag_NUB4, tag_NUB5, tag_NUB6, tag_NUB7, tag_NUB8, ...
    Second_pro_bitplane1, Second_pro_bitplane2, Second_pro_bitplane3, Second_pro_bitplane4, ...
    Second_pro_bitplane5, Second_pro_bitplane6, Second_pro_bitplane7, Second_pro_bitplane8, ...
    case_id1, case_id2, case_id3, case_id4, case_id5, case_id6, case_id7, case_id8, ...
    data_start] = ...
    Preprocess2(compress_type_len, tag_preprocess, finalem, f, block_size, ...
    Process_bitplane1, Process_bitplane2, Process_bitplane3, Process_bitplane4, ...
    Process_bitplane5, Process_bitplane6, Process_bitplane7, Process_bitplane8)
% Preprocess2
% Main fix:
% use the same explicit block-cursor rule as Preprocess1 when writing
% [codebook_bits | huffman_stream] into UB area starting from finalem.

num_planes = 8;

Process_bitplane = {Process_bitplane1, Process_bitplane2, Process_bitplane3, Process_bitplane4, ...
                    Process_bitplane5, Process_bitplane6, Process_bitplane7, Process_bitplane8};

bin_NUB_len    = zeros(1, num_planes);
final_emUBdata = cell(1, num_planes);
tag_NUB_all    = cell(1, num_planes);
case_id_all    = cell(1, num_planes);
Second_all     = cell(1, num_planes);
bin_NUB_all    = cell(1, num_planes);
data_start     = zeros(8, 2);

all_embeddable_case_ids = [];

for bp = 1 : num_planes
    if tag_preprocess(bp) == 1
        fnub_bp = f(bp);
        [tag_NUB_bp, case_id_bp] = NUBjudge(Process_bitplane{bp}, block_size, fnub_bp);

        tag_NUB_all{bp} = tag_NUB_bp;
        case_id_all{bp} = case_id_bp;

        embeddable_ids_bp       = case_id_bp(tag_NUB_bp == 0);
        all_embeddable_case_ids = [all_embeddable_case_ids, embeddable_ids_bp]; %#ok<AGROW>
    else
        tag_NUB_all{bp}  = [];
        case_id_all{bp}  = [];
        Second_all{bp}   = Process_bitplane{bp};
        bin_NUB_all{bp}  = [];
        bin_NUB_len(bp)  = 0;
        data_start(bp,1) = finalem(bp,1);
        data_start(bp,2) = finalem(bp,2);
    end
end

if isempty(all_embeddable_case_ids)
    for bp = 1 : num_planes
        if isempty(Second_all{bp})
            Second_all{bp} = Process_bitplane{bp};
        end
    end
    [tag_NUB1,tag_NUB2,tag_NUB3,tag_NUB4,tag_NUB5,tag_NUB6,tag_NUB7,tag_NUB8] = unpack_cell(tag_NUB_all);
    [case_id1,case_id2,case_id3,case_id4,case_id5,case_id6,case_id7,case_id8]   = unpack_cell(case_id_all);
    [Second_pro_bitplane1,Second_pro_bitplane2,Second_pro_bitplane3,Second_pro_bitplane4,...
     Second_pro_bitplane5,Second_pro_bitplane6,Second_pro_bitplane7,Second_pro_bitplane8] = unpack_cell(Second_all);
    final_emUBdata = Second_all;
    data_start = finalem;
    return;
end

freq = zeros(1, 10);
for k = 1 : 10
    freq(k) = sum(all_embeddable_case_ids == k);
end

[~, rank_order] = sort(freq, 'descend');

case_to_rank = zeros(1, 10);
for r = 1 : 10
    case_to_rank(rank_order(r)) = r;
end

FIXED_CODES = {
    [0,0], [0,1], [1,0,0], [1,0,1], [1,1,0,0], ...
    [1,1,0,1], [1,1,1,0,0], [1,1,1,0,1], [1,1,1,1,0], [1,1,1,1,1]
};

codebook_bits = zeros(1, 38);
codebook_bits(1:2)  = [0, 0];
codebook_bits(3:6)  = dec2bin(9, 4) - '0';
codebook_bits(7:10) = dec2bin(5, 4) - '0';
for i = 1 : 7
    codebook_bits(10 + (i-1)*4 + 1 : 10 + i*4) = dec2bin(rank_order(i), 4) - '0';
end

for bp = 1 : num_planes
    if tag_preprocess(bp) == 1
        tag_NUB_bp = tag_NUB_all{bp};
        case_id_bp = case_id_all{bp};

        embeddable_ids_bp = case_id_bp(tag_NUB_bp == 0);

        stream_cell = cell(1, length(embeddable_ids_bp));
        for i = 1 : length(embeddable_ids_bp)
            cid = embeddable_ids_bp(i);
            stream_cell{i} = FIXED_CODES{case_to_rank(cid)};
        end

        if isempty(stream_cell)
            huffman_stream_bp = [];
        else
            huffman_stream_bp = cell2mat(stream_cell);
        end

        bin_NUB_bp      = [codebook_bits, huffman_stream_bp];
        bin_NUB_all{bp} = bin_NUB_bp;
        bin_NUB_len(bp) = length(bin_NUB_bp);

        bitplane_bp = Process_bitplane{bp};
        [~, col_bp] = size(bitplane_bp);
        block_n_bp  = floor(col_bp / block_size);

        [bitplane_bp, next_x_bp, next_y_bp] = write_bits_by_blocks( ...
            bitplane_bp, bin_NUB_bp, finalem(bp,1), finalem(bp,2), block_n_bp, block_size);

        Second_all{bp} = bitplane_bp;
        data_start(bp, 1) = next_x_bp;
        data_start(bp, 2) = next_y_bp;
    end
end

[tag_NUB1,tag_NUB2,tag_NUB3,tag_NUB4,tag_NUB5,tag_NUB6,tag_NUB7,tag_NUB8] = unpack_cell(tag_NUB_all);
[case_id1,case_id2,case_id3,case_id4,case_id5,case_id6,case_id7,case_id8]   = unpack_cell(case_id_all);
[Second_pro_bitplane1,Second_pro_bitplane2,Second_pro_bitplane3,Second_pro_bitplane4,...
 Second_pro_bitplane5,Second_pro_bitplane6,Second_pro_bitplane7,Second_pro_bitplane8] = unpack_cell(Second_all);

final_emUBdata = Second_all;
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

function [a,b,c,d,e,f_,g,h] = unpack_cell(C)
a = C{1}; b = C{2}; c = C{3}; d = C{4};
e = C{5}; f_ = C{6}; g = C{7}; h = C{8};
end
