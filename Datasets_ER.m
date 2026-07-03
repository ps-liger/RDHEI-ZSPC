clear;
clc;
rng(0,'twister');

root_dir = '\Testimages';

dataset_names = {'Bossbase', 'Bows-2', 'UCID'};
dataset_exts  = {'*.pgm', '*.bmp', '*.tif'};
dataset_nums  = [10000, 10000, 1338];

block_size = 4;
num = 4000000;
Data = randi([0 1], 1, num);

avg_ER = nan(3,1);
max_ER = nan(3,1);
min_ER = nan(3,1);

for d = 1:3
    dataset_path = fullfile(root_dir, dataset_names{d});
    files = dir(fullfile(dataset_path, dataset_exts{d}));
    [~, idx] = sort({files.name});
    files = files(idx);

    sample_num = 1000;
    cur_num = min(sample_num, length(files));
    
    rand_idx = randperm(length(files), cur_num);
    files = files(rand_idx);
    
    ER_list = nan(cur_num,1);


    fprintf('\n========== %s ==========\n', dataset_names{d});

tic;
for i = 1:cur_num
    img_path = fullfile(dataset_path, files(i).name);

    try
        ER_list(i) = calc_ER_only(img_path, block_size, Data, num);

        fprintf('%s: %d/%d, %s, ER = %.6f bpp\n', ...
            dataset_names{d}, i, cur_num, files(i).name, ER_list(i));

    catch ME
        ER_list(i) = NaN;

        fprintf('%s: %d/%d, %s failed: %s\n', ...
            dataset_names{d}, i, cur_num, files(i).name, ME.message);
    end
end

t = toc;

    valid_ER = ER_list(~isnan(ER_list));

    avg_ER(d) = mean(valid_ER);
    max_ER(d) = max(valid_ER);
    min_ER(d) = min(valid_ER);

    fprintf('%s Valid images: %d / %d\n', dataset_names{d}, length(valid_ER), cur_num);
    fprintf('Average embedding rate: %.6f bpp\n', avg_ER(d));
    fprintf('Max embedding rate: %.6f bpp\n', max_ER(d));
    fprintf('Min embedding rate: %.6f bpp\n', min_ER(d));
    fprintf('Runtime: %.2f s\n', t);
end

ResultTable = table(dataset_names(:), avg_ER, max_ER, min_ER, ...
    'VariableNames', {'Dataset','Average_ER','Max_ER','Min_ER'});

disp(ResultTable);
save('average_er_results.mat', 'ResultTable', 'avg_ER', 'max_ER', 'min_ER');


%% ==========================================================
function ER = calc_ER_only(img_path, block_size, Data, num)

    I = imread(img_path);

    % UCID dataset contains color images, convert to grayscale; grayscale images remain unchanged
    if ndims(I) == 3
        I = rgb2gray(I);
    end

    Origin_I = double(I);
    [row, col] = size(Origin_I);

    [~,~,~,~,~,~,~,~, ...
     compress_type_len,~,~,~, ...
     compress_predict,tag_preprocess,finalem,f, ...
     Process_bitplane1,Process_bitplane2,Process_bitplane3,Process_bitplane4, ...
     Process_bitplane5,Process_bitplane6,Process_bitplane7,Process_bitplane8] = ...
        Preprocess1(Origin_I, block_size);

    [bin_NUB_len,~, ...
     tag_NUB1,tag_NUB2,tag_NUB3,tag_NUB4,tag_NUB5,tag_NUB6,tag_NUB7,tag_NUB8, ...
     Second_pro_bitplane1,Second_pro_bitplane2,Second_pro_bitplane3,Second_pro_bitplane4, ...
     Second_pro_bitplane5,Second_pro_bitplane6,Second_pro_bitplane7,Second_pro_bitplane8, ...
     case_id1,case_id2,case_id3,case_id4,case_id5,case_id6,case_id7,case_id8, ...
     data_start] = ...
        Preprocess2(compress_type_len, tag_preprocess, finalem, f, block_size, ...
        Process_bitplane1, Process_bitplane2, Process_bitplane3, Process_bitplane4, ...
        Process_bitplane5, Process_bitplane6, Process_bitplane7, Process_bitplane8);

    tag_NUB_all = {tag_NUB1,tag_NUB2,tag_NUB3,tag_NUB4,...
                   tag_NUB5,tag_NUB6,tag_NUB7,tag_NUB8};

    case_id_all = {case_id1,case_id2,case_id3,case_id4,...
                   case_id5,case_id6,case_id7,case_id8};

    %% Calculate compressed length of tag_NUB
    compress_tagNUB_len = zeros(1,8);

    for bp = 1:8
        if tag_preprocess(bp) == 1 && ~isempty(tag_NUB_all{bp})
            cPos_x = cell(1,1);
            cPos_x{1} = tag_NUB_all{bp}(:);
            loc_Com = arith07(cPos_x);
            [~, compress_tagNUB_len(bp)] = dec_transform_bin(loc_Com, 8);
        end
    end

    %% Generate processed image
    Process_I = eight_to_one( ...
        Second_pro_bitplane1,Second_pro_bitplane2,Second_pro_bitplane3,Second_pro_bitplane4, ...
        Second_pro_bitplane5,Second_pro_bitplane6,Second_pro_bitplane7,Second_pro_bitplane8);

    %% Encryption
    Encrypt_I = Encrypt_image(Process_I, 1, data_start, f, tag_preprocess, block_size);

    %% Calculate embeddable data in UB regions only
    [~, num_emubD, ~, ...
     Stego_bitplane1,Stego_bitplane2,Stego_bitplane3,Stego_bitplane4, ...
     Stego_bitplane5,Stego_bitplane6,Stego_bitplane7,Stego_bitplane8] = ...
        Embed_data(Encrypt_I, block_size, Data, num, tag_preprocess, data_start, f);

    %% Calculate embeddable data in NUB regions only
    Stego_all = {Stego_bitplane1,Stego_bitplane2,Stego_bitplane3,Stego_bitplane4,...
                 Stego_bitplane5,Stego_bitplane6,Stego_bitplane7,Stego_bitplane8};

    emnub_t = num_emubD;

    for bp = 1:8
        if tag_preprocess(bp) == 1 && ~isempty(tag_NUB_all{bp})
            [~, emnub_t] = Embed_NUBdata( ...
                tag_NUB_all{bp}, case_id_all{bp}, Stego_all{bp}, Data, emnub_t, block_size);
        end
    end

    num_NUBD = emnub_t - num_emubD;

    %% Embedding rate
    ER = (num_emubD + num_NUBD ...
        - length(compress_predict) ...
        - 8 ...
        - 16*8 ...
        - sum(bin_NUB_len)) / (row * col);
    end
