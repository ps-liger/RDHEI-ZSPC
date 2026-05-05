function [Encrypt_I] = Encrypt_image(Process_I, Image_key, data_start, f, tag_preprocess, block_size)

[row, col] = size(Process_I);

rand('seed', Image_key);
E = round(rand(row, col) * 255);

E_bitplane = cell(1, 8);
Process_bitplane = cell(1, 8);
bin1 = zeros(1, 8);
bin2 = zeros(1, 8);
for i = 1:row
    for j = 1:col
        bin1 = Decimalism_Binary(E(i,j));
        for bp = 1:8
            E_bitplane{bp}(i,j) = bin1(bp);
        end
        bin2 = Decimalism_Binary(Process_I(i,j));
        for bp = 1:8
            Process_bitplane{bp}(i,j) = bin2(bp);
        end
    end
end

final_enbitplane = cell(1, 8);
for bp = 1:8
    if tag_preprocess(bp) == 1
        enc_bp = encrypt_NUB(f(bp), Process_bitplane{bp}, block_size, E_bitplane{bp});
        final_enbitplane{bp} = encrypt_UB(enc_bp, E_bitplane{bp}, data_start(bp,1), data_start(bp,2), block_size);
    else
        final_enbitplane{bp} = encrypt_All(Process_bitplane{bp}, E_bitplane{bp}, block_size);
    end
end

[Encrypt_I] = eight_to_one(final_enbitplane{1}, final_enbitplane{2}, final_enbitplane{3}, final_enbitplane{4}, ...
    final_enbitplane{5}, final_enbitplane{6}, final_enbitplane{7}, final_enbitplane{8});
end


function encrypt_bp = encrypt_NUB(fnub, bitplane, block_size, E_bitplane)
[row, col] = size(bitplane);
block_n = floor(col / block_size);
block_m = floor(row / block_size);
encrypt_bp = bitplane;

startx = 1;
starty = 1;
for k = 1:fnub
    for p = 0:block_size-1
        for q = 0:block_size-1
            vx = startx + p;
            vy = starty + q;
            encrypt_bp(vx, vy) = bitxor(bitplane(vx, vy), E_bitplane(vx, vy));
        end
    end
    if starty + block_size > block_n * block_size
        startx = startx + block_size;
        starty = 1;
    else
        starty = starty + block_size;
    end
    if startx > block_m * block_size
        break;
    end
end
end


function final_bp = encrypt_UB(bitplane, E_bitplane, start_x, start_y, block_size)
[row, col] = size(bitplane);
block_m = floor(row / block_size);
block_n = floor(col / block_size);
final_bp = bitplane;

cur_x = start_x;
cur_y = start_y;

while cur_x <= block_m * block_size
    for p = 0:block_size-1
        for q = 0:block_size-1
            vx = cur_x + p;
            vy = cur_y + q;
            final_bp(vx, vy) = bitxor(bitplane(vx, vy), E_bitplane(vx, vy));
        end
    end
    if cur_y + block_size > block_n * block_size
        cur_x = cur_x + block_size;
        cur_y = 1;
    else
        cur_y = cur_y + block_size;
    end
end
end


function final_bp = encrypt_All(bitplane, E_bitplane, block_size)
[row, col] = size(bitplane);
block_m = floor(row / block_size);
block_n = floor(col / block_size);
final_bp = bitplane;

startx = 1;
starty = 1;
while startx <= block_m * block_size
    for p = 0:block_size-1
        for q = 0:block_size-1
            vx = startx + p;
            vy = starty + q;
            final_bp(vx, vy) = bitxor(bitplane(vx, vy), E_bitplane(vx, vy));
        end
    end
    if starty + block_size > block_n * block_size
        startx = startx + block_size;
        starty = 1;
    else
        starty = starty + block_size;
    end
end
end
