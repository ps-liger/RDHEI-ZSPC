function [emubD,num_emubD,num_em_ub,...
    Stego_bitplane1,Stego_bitplane2,Stego_bitplane3,Stego_bitplane4,...
    Stego_bitplane5,Stego_bitplane6,Stego_bitplane7,Stego_bitplane8] = ...
    Embed_data(Encrypt_I, block_size, Data, num, tag_preprocess, data_start, f)

start_d = 0;
start_d2 = 0;

[row, col] = size(Encrypt_I);
Process_bitplane = cell(1, 8);
bin = zeros(1, 8);
for i = 1:row
    for j = 1:col
        bin = Decimalism_Binary(Encrypt_I(i,j));
        for bp = 1:8
            Process_bitplane{bp}(i,j) = bin(bp);
        end
    end
end

Stego_bitplane = cell(1, 8);
for bp = 1:8
    Stego_bitplane{bp} = Process_bitplane{bp};
end

num_em_ub = zeros(1, 8);

for bp = 1:8
    if tag_preprocess(bp) == 1
        start_d = start_d2;
        [Stego_bitplane{bp}, start_d2] = embed(Process_bitplane{bp}, Data, num, start_d, ...
            data_start(bp,1), data_start(bp,2), block_size);
        num_em_ub(bp) = start_d2 - start_d;
    end
end

num_emubD = start_d2;
emubD = Data(1:num_emubD);

Stego_bitplane1=Stego_bitplane{1}; Stego_bitplane2=Stego_bitplane{2};
Stego_bitplane3=Stego_bitplane{3}; Stego_bitplane4=Stego_bitplane{4};
Stego_bitplane5=Stego_bitplane{5}; Stego_bitplane6=Stego_bitplane{6};
Stego_bitplane7=Stego_bitplane{7}; Stego_bitplane8=Stego_bitplane{8};
end


function [Stego_bitplane1, start_d2] = embed(Process_bitplane1, Data, num, start_d, start_x, start_y, block_size)
start_d2 = start_d;
[row, col] = size(Process_bitplane1);

block_m = floor(row / block_size);
block_n = floor(col / block_size);

Stego_bitplane1 = Process_bitplane1;
startx_emdata = start_x;
starty_emdata = start_y;

while start_d2 < num
    for p = 0:block_size-1
        for q = 0:block_size-1
            if start_d2 >= num
                break;
            end
            start_d2 = start_d2 + 1;
            vx = startx_emdata + p;
            vy = starty_emdata + q;
            Stego_bitplane1(vx, vy) = Data(start_d2);
        end
        if start_d2 >= num
            break;
        end
    end

    if start_d2 >= num
        break;
    end

    if starty_emdata + block_size > block_n * block_size
        startx_emdata = startx_emdata + block_size;
        starty_emdata = 1;
    else
        starty_emdata = starty_emdata + block_size;
    end

    if startx_emdata > block_m * block_size
        break;
    end
end
end
