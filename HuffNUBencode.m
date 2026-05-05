function huffman_stream = HuffNUBencode(case_ids)
% HuffNUBencode - 使用固定哈夫曼编码对可嵌入NUB情形序列进行编码
%
% 固定编码表（按情形编号顺序，遵循高频分短码原则排列）：
%   情形  1 → 00      (2位)
%   情形  2 → 01      (2位)
%   情形  3 → 100     (3位)
%   情形  4 → 101     (3位)
%   情形  5 → 1100    (4位)
%   情形  6 → 1101    (4位)
%   情形  7 → 11100   (5位)
%   情形  8 → 11101   (5位)
%   情形  9 → 11110   (5位)
%   情形 10 → 11111   (5位)
%
% 输入：
%   case_ids — 单个位平面中可嵌入NUB的情形编号序列（值域1~10）
%
% 输出：
%   huffman_stream — 哈夫曼编码比特流（0/1行向量）

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

if isempty(case_ids)
    huffman_stream = [];
    return;
end

stream_cell = cell(1, length(case_ids));
for i = 1 : length(case_ids)
    cid = case_ids(i);
    if cid < 1 || cid > 10
        error('情形编号 %d 超出范围1~10，请检查输入。', cid);
    end
    stream_cell{i} = FIXED_CODES{cid};
end

huffman_stream = cell2mat(stream_cell);
end

