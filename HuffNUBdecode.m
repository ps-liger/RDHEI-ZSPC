function case_ids = HuffNUBdecode(huffman_stream, num_nub_embeddable)
% HuffNUBdecode - 使用固定哈夫曼码表从比特流中解码情形编号序列
%
% 固定编码表（与 HuffNUBencode 完全一致）：
%   情形  1 → 00      情形  2 → 01
%   情形  3 → 100     情形  4 → 101
%   情形  5 → 1100    情形  6 → 1101
%   情形  7 → 11100   情形  8 → 11101
%   情形  9 → 11110   情形 10 → 11111
%
% 输入：
%   huffman_stream     — 哈夫曼编码比特流（0/1行向量）
%   num_nub_embeddable — 待解码的可嵌入NUB数量
%
% 输出：
%   case_ids — 情形编号序列（值域1~10）

% ---- 固定哈夫曼码表 ----
FIXED_CODES = {
    [0,0],          ...  % 情形 1 : 00
    [0,1],          ...  % 情形 2 : 01
    [1,0,0],        ...  % 情形 3 : 100
    [1,0,1],        ...  % 情形 4 : 101
    [1,1,0,0],      ...  % 情形 5 : 1100
    [1,1,0,1],      ...  % 情形 6 : 1101
    [1,1,1,0,0],    ...  % 情形 7 : 11100
    [1,1,1,0,1],    ...  % 情形 8 : 11101
    [1,1,1,1,0],    ...  % 情形 9 : 11110
    [1,1,1,1,1]     ...  % 情形10 : 11111
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
        error('第%d个符号解码失败，请检查哈夫曼流是否完整。', i);
    end
end
end

