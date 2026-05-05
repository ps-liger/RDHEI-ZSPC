clear
clc
dbstop if error

I = imread('D:\code\Forth\Testimages\Tiffany.tiff');
Origin_I = double(I);

num = 4000000;
rand('seed',0);
Data = round(rand(1,num)*1);

[row,col] = size(Origin_I);
block_size = 4;
Image_key  = 1;
Data_key   = 2;

%% Preprocessing 1: Bit-plane decomposition & rearrangement
[typeI1,typeI2,typeI3,typeI4,typeI5,typeI6,typeI7,typeI8,...
 compress_type_len,recover_start_ub,Predict_error_I,judge_predict,...
 compress_predict,tag_preprocess,finalem,f,...
 Process_bitplane1,Process_bitplane2,Process_bitplane3,Process_bitplane4,...
 Process_bitplane5,Process_bitplane6,Process_bitplane7,Process_bitplane8] = ...
    Preprocess1(Origin_I, block_size);


%% Preprocessing 2: Judge embeddable regions & embed bin_NUB into UB area
[bin_NUB_len, ~,...
 tag_NUB1,tag_NUB2,tag_NUB3,tag_NUB4,tag_NUB5,tag_NUB6,tag_NUB7,tag_NUB8,...
 Second_pro_bitplane1,Second_pro_bitplane2,Second_pro_bitplane3,Second_pro_bitplane4,...
 Second_pro_bitplane5,Second_pro_bitplane6,Second_pro_bitplane7,Second_pro_bitplane8,...
 case_id1,case_id2,case_id3,case_id4,case_id5,case_id6,case_id7,case_id8,...
 data_start] = ...
    Preprocess2(compress_type_len,tag_preprocess,finalem,f,block_size,...
    Process_bitplane1,Process_bitplane2,Process_bitplane3,Process_bitplane4,...
    Process_bitplane5,Process_bitplane6,Process_bitplane7,Process_bitplane8);

tag_NUB_all  = {tag_NUB1,tag_NUB2,tag_NUB3,tag_NUB4,...
                tag_NUB5,tag_NUB6,tag_NUB7,tag_NUB8};
case_id_all  = {case_id1,case_id2,case_id3,case_id4,...
                case_id5,case_id6,case_id7,case_id8};
%% Calculate arithmetic-coded length of tag_NUB (embeddable / non-embeddable flags)
compress_tagNUB = cell(1,8);
compress_tagNUB_len = zeros(1,8);

for bp = 1:8
    if tag_preprocess(bp) == 1
        flow_map = tag_NUB_all{bp};   % 0 = embeddable, 1 = non-embeddable
        cPos_x = cell(1,1);
        cPos_x{1} = flow_map(:);
        loc_Com = arith07(cPos_x);
        bin_index = 8;
        [compress_tagNUB{bp}, compress_tagNUB_len(bp)] = dec_transform_bin(loc_Com, bin_index);
    else
        compress_tagNUB{bp} = [];
        compress_tagNUB_len(bp) = 0;
    end
end


%% Image encryption (UB encryption starts from data_start, covering bin_NUB)
[Process_I] = eight_to_one(...
    Second_pro_bitplane1,Second_pro_bitplane2,Second_pro_bitplane3,Second_pro_bitplane4,...
    Second_pro_bitplane5,Second_pro_bitplane6,Second_pro_bitplane7,Second_pro_bitplane8);
[Encrypt_I] = Encrypt_image(Process_I, Image_key, data_start, f, tag_preprocess, block_size);

%% Embed data into UB regions (starting from data_start, after bin_NUB)
[emubD,num_emubD,num_em_everyub,...
 Stego_bitplane1,Stego_bitplane2,Stego_bitplane3,Stego_bitplane4,...
 Stego_bitplane5,Stego_bitplane6,Stego_bitplane7,Stego_bitplane8] = ...
    Embed_data(Encrypt_I, block_size, Data, num, tag_preprocess, data_start, f);

%% Embed data into NUB regions
Stego_all = {Stego_bitplane1,Stego_bitplane2,Stego_bitplane3,Stego_bitplane4,...
             Stego_bitplane5,Stego_bitplane6,Stego_bitplane7,Stego_bitplane8};

emnub_t        = num_emubD;
num_NUBD_every = zeros(1,8);

for bp = 1:8
    if tag_preprocess(bp) == 1 && ~isempty(tag_NUB_all{bp})
        t_before = emnub_t;
        [Stego_all{bp}, emnub_t] = Embed_NUBdata(...
            tag_NUB_all{bp}, case_id_all{bp}, Stego_all{bp}, Data, emnub_t, block_size);
        num_NUBD_every(bp) = emnub_t - t_before;
    end
end
num_NUBD = emnub_t - num_emubD;
emNUBD   = Data(num_emubD+1 : num_emubD+num_NUBD);

final_Stego1=Stego_all{1}; final_Stego2=Stego_all{2};
final_Stego3=Stego_all{3}; final_Stego4=Stego_all{4};
final_Stego5=Stego_all{5}; final_Stego6=Stego_all{6};
final_Stego7=Stego_all{7}; final_Stego8=Stego_all{8};

[Stego_I] = eight_to_one(final_Stego1,final_Stego2,final_Stego3,final_Stego4,...
    final_Stego5,final_Stego6,final_Stego7,final_Stego8);

%% Extract UB data (starting from data_start)
[exUB_Data, exUB_numData] = Extract_UBdata(tag_preprocess, num_emubD, data_start, block_size,...
    final_Stego1,final_Stego2,final_Stego3,final_Stego4,...
    final_Stego5,final_Stego6,final_Stego7,final_Stego8);

%% Extract NUB data
Final_Stego_all = {final_Stego1,final_Stego2,final_Stego3,final_Stego4,...
                   final_Stego5,final_Stego6,final_Stego7,final_Stego8};
exNUB_Data = [];

for bp = 1:8
    bp_quota = num_NUBD_every(bp);
    if bp_quota == 0, continue; end
    [bp_data, ~] = Extract_NUBdata(...
        tag_NUB_all{bp}, case_id_all{bp}, Final_Stego_all{bp}, ...
        0, block_size, bp_quota);
    exNUB_Data = [exNUB_Data, bp_data];
end
exNUB_numData = length(exNUB_Data);

%% Calculate embedding rate
compress_predict_len = length(compress_predict);
ER = ((num_emubD + num_NUBD - compress_predict_len - 8 - 16*8 - sum(bin_NUB_len)) / (row*col));
fprintf('Embedding rate = %.4f bpp\n', ER);

%% Image decryption (UB decryption starts from data_start)
[Decrypt_I] = decrypt_image(Stego_I, Image_key, data_start, f, tag_preprocess, block_size);

%% Recover bit-planes
[recover_bitplane1,recover_bitplane2,recover_bitplane3,recover_bitplane4,...
 recover_bitplane5,recover_bitplane6,recover_bitplane7,recover_bitplane8] = ...
    Recover_image1(Decrypt_I,compress_type_len,tag_preprocess,recover_start_ub,block_size,...
    typeI1,typeI2,typeI3,typeI4,typeI5,typeI6,typeI7,typeI8,...
    tag_NUB1,tag_NUB2,tag_NUB3,tag_NUB4,tag_NUB5,tag_NUB6,tag_NUB7,tag_NUB8,...
    case_id1,case_id2,case_id3,case_id4,case_id5,case_id6,case_id7,case_id8,...
    final_Stego1,final_Stego2,final_Stego3,final_Stego4,...
    final_Stego5,final_Stego6,final_Stego7,final_Stego8);

%% Final image recovery
[Recover_I, Prediction_I] = Recover_image2(judge_predict,...
    recover_bitplane1,recover_bitplane2,recover_bitplane3,recover_bitplane4,...
    recover_bitplane5,recover_bitplane6,recover_bitplane7,recover_bitplane8);


figure('Position',[100,100,1600,400]);

subplot(1,4,1);
imshow(Origin_I,[]);
title('Original Image');

subplot(1,4,2);
imshow(Encrypt_I,[]);
title('Encrypted Image');

subplot(1,4,3);
imshow(Stego_I,[]);
title('Encrypted Image with Data');

subplot(1,4,4);
imshow(Recover_I,[]);
title('Recovered Image');

   