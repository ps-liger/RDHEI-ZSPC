function [Recover_I,Prediction_I] = Recover_image2(judge_predict,recover_bitplane1,recover_bitplane2,recover_bitplane3,recover_bitplane4,recover_bitplane5,recover_bitplane6,recover_bitplane7,recover_bitplane8)

[row,col] = size(recover_bitplane1); 

Prediction_I = zeros(row,col);
Recover_I = zeros(row,col);

%% (1,1) 参考像素：直接读取原像素
bin2 = get8bits(recover_bitplane1,recover_bitplane2,recover_bitplane3,recover_bitplane4,...
                recover_bitplane5,recover_bitplane6,recover_bitplane7,recover_bitplane8,1,1);
Prediction_I(1,1) = Binary_Decimalism(bin2);
Recover_I(1,1) = Prediction_I(1,1);

%% 第一行：线性恢复
for j = 2:col
    bin2 = get8bits(recover_bitplane1,recover_bitplane2,recover_bitplane3,recover_bitplane4,...
                    recover_bitplane5,recover_bitplane6,recover_bitplane7,recover_bitplane8,1,j);
    if judge_predict(1,j) == 0
        pe = zf_Binary_Decimalism(bin2);
        Prediction_I(1,j) = pe;
        Recover_I(1,j) = Recover_I(1,j-1) + pe;
    else
        Prediction_I(1,j) = Binary_Decimalism(bin2);
        Recover_I(1,j) = Prediction_I(1,j);
    end
end

%% 第一列：线性恢复
for i = 2:row
    bin2 = get8bits(recover_bitplane1,recover_bitplane2,recover_bitplane3,recover_bitplane4,...
                    recover_bitplane5,recover_bitplane6,recover_bitplane7,recover_bitplane8,i,1);
    if judge_predict(i,1) == 0
        pe = zf_Binary_Decimalism(bin2);
        Prediction_I(i,1) = pe;
        Recover_I(i,1) = Recover_I(i-1,1) + pe;
    else
        Prediction_I(i,1) = Binary_Decimalism(bin2);
        Recover_I(i,1) = Prediction_I(i,1);
    end
end

%% 内部像素：最后一列 MED，其余 SGAP
for i = 2:row
    for j = 2:col
        bin2 = get8bits(recover_bitplane1,recover_bitplane2,recover_bitplane3,recover_bitplane4,...
                        recover_bitplane5,recover_bitplane6,recover_bitplane7,recover_bitplane8,i,j);

        if judge_predict(i,j) == 0
            pe = zf_Binary_Decimalism(bin2);
            Prediction_I(i,j) = pe;

            x1 = Recover_I(i-1,j-1);
            x2 = Recover_I(i-1,j);
            x3 = Recover_I(i,j-1);

            if j == col
                pred = MED_pred(x1,x2,x3);
            else
                x4 = Recover_I(i-1,j+1);
                pred = SGAP_pred(x1,x2,x3,x4);
            end

            Recover_I(i,j) = pred + pe;
        else
            Prediction_I(i,j) = Binary_Decimalism(bin2);
            Recover_I(i,j) = Prediction_I(i,j);
        end
    end
end

end

function bin2 = get8bits(b1,b2,b3,b4,b5,b6,b7,b8,i,j)
bin2 = zeros(1,8);
bin2(1)=b1(i,j); bin2(2)=b2(i,j); bin2(3)=b3(i,j); bin2(4)=b4(i,j);
bin2(5)=b5(i,j); bin2(6)=b6(i,j); bin2(7)=b7(i,j); bin2(8)=b8(i,j);
end

function pred = MED_pred(x1,x2,x3)
    if x1 <= min(x2,x3)
        pred = max(x2,x3);
    elseif x1 >= max(x2,x3)
        pred = min(x2,x3);
    else
        pred = x2 + x3 - x1;
    end
end

function pred = SGAP_pred(x1,x2,x3,x4)
    pred = round((x2 + x3)/2 + (x4 - x1)/4);
    pred = min(255, max(0, pred));
end
