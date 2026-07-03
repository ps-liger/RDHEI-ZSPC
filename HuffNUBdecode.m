function case_ids = HuffNUBdecode(huffman_stream, num_nub_embeddable)
% HuffNUBdecode - Decode case ID sequence from bitstream using fixed Huffman code table
%
% Fixed code table (identical to HuffNUBencode):
%   Case  1 → 00      Case  2 → 01
%   Case  3 → 100     Case  4 → 101
%   Case  5 → 1100    Case  6 → 1101
%   Case  7 → 11100   Case  8 → 11101
%   Case  9 → 11110   Case 10 → 11111
%
% Input:
%   huffman_stream     - Huffman encoded bitstream (0/1 row vector)
%   num_nub_embeddable - number of embeddable NUBs to decode
%
% Output:
%   case_ids - case ID sequence (range 1~10)

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

case_ids = zeros(1, num_nub_embeddable);
ptr = 1;

for i = 1 : num_nub_embeddable
    found = false;
    for cid = 1 : 10
        clen = length(FIXED_CODES{cid});
        if ptr + clen - 1 > length(huffman_stream)
            continue;
        end
        seg = huffman_stream(ptr : ptr + clen - 1);
        if isequal(seg, FIXED_CODES{cid})
            case_ids(i) = cid;
            ptr = ptr + clen;
            found = true;
            break;
        end
    end
    if ~found
        error('Decoding failed for symbol %d. Please check if Huffman stream is complete.', i);
    end
end
end

