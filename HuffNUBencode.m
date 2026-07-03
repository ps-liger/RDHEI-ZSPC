function huffman_stream = HuffNUBencode(case_ids)
% HuffNUBencode - Encode embeddable NUB case sequence using fixed Huffman coding
%
% Fixed code table (ordered by case ID, following the principle of shorter codes for higher frequency):
%   Case  1 → 00      (2 bits)
%   Case  2 → 01      (2 bits)
%   Case  3 → 100     (3 bits)
%   Case  4 → 101     (3 bits)
%   Case  5 → 1100    (4 bits)
%   Case  6 → 1101    (4 bits)
%   Case  7 → 11100   (5 bits)
%   Case  8 → 11101   (5 bits)
%   Case  9 → 11110   (5 bits)
%   Case 10 → 11111   (5 bits)
%
% Input:
%   case_ids - case ID sequence of embeddable NUBs in a single bit-plane (range 1~10)
%
% Output:
%   huffman_stream - Huffman encoded bitstream (0/1 row vector)

% ---- Fixed Huffman Code Table ----
FIXED_CODES = {
    [0,0],          ...  % Case  1 : 00
    [0,1],          ...  % Case  2 : 01
    [1,0,0],        ...  % Case  3 : 100
    [1,0,1],        ...  % Case  4 : 101
    [1,1,0,0],      ...  % Case  5 : 1100
    [1,1,0,1],      ...  % Case  6 : 1101
    [1,1,1,0,0],    ...  % Case  7 : 11100
    [1,1,1,0,1],    ...  % Case  8 : 11101
    [1,1,1,1,0],    ...  % Case  9 : 11110
    [1,1,1,1,1]     ...  % Case 10 : 11111
};

if isempty(case_ids)
    huffman_stream = [];
    return;
end

stream_cell = cell(1, length(case_ids));
for i = 1 : length(case_ids)
    cid = case_ids(i);
    if cid < 1 || cid > 10
        error('Case ID %d is out of range 1~10. Please check input.', cid);
    end
    stream_cell{i} = FIXED_CODES{cid};
end

huffman_stream = cell2mat(stream_cell);
end

