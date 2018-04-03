function BP_Stereo()
    ImL = imread('Inputs/left1.png');
    ImR = imread('Inputs/right1.png');
    imNo = 1;
    
    ImL = rgb2gray(ImL);
    ImR = rgb2gray(ImR);
    ImL = double(ImL);
    ImR = double(ImR);
    
    height = size(ImL, 1);
    width = size(ImL, 2);
    d_value = 50; 
    
    %Populating the unary cost table.
    G_U = zeros(height, width, d_value);    
    for i=1:height
        for j=1:width
            for d = 1:d_value
                if j-d >= 1
                    G_U(i, j, d) = abs(ImL(i,j) - ImR(i,j-d));
                else
                    G_U(i, j, d) = 255;
                end
            end
        end
    end
    
    G_VF = zeros(height+height-1+(height-1)*2, width+width-1+(width-1)*2, d_value);
    G_FV = zeros(height+height-1+(height-1)*2, width+width-1+(width-1)*2, d_value);
    BeliefG = zeros(height*width, d_value);
    BeliefG_Val = zeros(height, width);
    
    lambda = [1,10,50,100];    
    lamda = 100;
        iter = 20;
        for i_iter=1:iter        
            BeliefL_Val = zeros(height, width);
            % Doing horizaontal/vertical foctor nodes first.
            for i=1:height
                for j=1:width-1                
                    %Doing the left/right node.
                    i_index = ((i-1)*4)+1;
                    j_index = ((j-1)*4)+3;
                    A = findMinimumHL(d_value, i_index, j_index-1, j_index+1, G_VF, lamda);
                    B = findMinimumHR(d_value, i_index, j_index-1, j_index+1, G_VF, lamda);
                    for k=1:d_value
                        G_FV(i_index, j_index-1, k) = A(k,1);
                        G_FV(i_index, j_index+1, k) = B(k,1);
                    end
                end
            end        
            for i=1:height-1
                for j=1:width
                    %Doing the top/down node.
                    i_index = ((i-1)*4)+3;
                    j_index = ((j-1)*4)+1;
                    A = findMinimumVT(d_value, i_index-1, i_index+1, j_index, G_VF, lamda);
                    B = findMinimumVB(d_value, i_index-1, i_index+1, j_index, G_VF, lamda);
                    for k=1:d_value
                        G_FV(i_index-1, j_index, k) = A(k,1);
                        G_FV(i_index+1, j_index, k) = B(k,1);
                    end
                end
            end

            %Updating beliefs.
            for i=1:height
                for j=1:width
                    i_index = ((i-1)*4)+1;
                    j_index = ((j-1)*4)+1;

                    %Top/Bottom.
                    dummy = zeros(d_value,1);                                
                    if i_index == 1
                        val1 = G_FV(i_index+1, j_index, :);
                        val1 = val1(:);
                        dummy = dummy + val1;
                    elseif i_index == size(G_FV, 1)           
                        val2 = G_FV(i_index-1, j_index, :);
                        val2 = val2(:);
                        dummy = dummy + val2;
                    else
                        val1 = G_FV(i_index+1, j_index, :);
                        val1 = val1(:);
                        val2 = G_FV(i_index-1, j_index, :);
                        val2 = val2(:);
                        dummy = dummy + val1;
                        dummy = dummy + val2;
                    end

                    %Left/Right.                                
                    if j_index == 1
                        val1 = G_FV(i_index, j_index+1, :);
                        val1 = val1(:);
                        dummy = dummy + val1;
                    elseif j_index == size(G_FV, 2)                    
                        val2 = G_FV(i_index, j_index-1, :);
                        val2 = val2(:);
                        dummy = dummy + val2;
                    else
                        val1 = G_FV(i_index, j_index+1, :);
                        val1 = val1(:);
                        val2 = G_FV(i_index, j_index-1, :);
                        val2 = val2(:);
                        dummy = dummy + val1;
                        dummy = dummy + val2;
                    end

                    %Adding unary offset.
                    val3 = G_U(i,j,:);
                    val3 = val3(:);
                    dummy = dummy + val3;
                    BeliefG(i*width+j,1:d_value) = dummy';
                end
            end

            %Taking Prediction.
            for i=1:height
                for j=1:width
                    dummy = BeliefG(i*width+j,1:d_value);
                    dummy = dummy(:);
                    [val, idx] = min(dummy);                
                    BeliefL_Val(i,j) = idx;
                end
            end                       

            %Updating the messages.
            %Doing top and bottom.
            for i=1:height-1
                for j=1:width
                    i_index = ((i-1)*4)+1;
                    j_index = ((j-1)*4)+1;

                    if i_index == 1
                        for k=1:d_value
                            G_VF(i_index+1, j_index, k) = BeliefG(i*width+j,k)-G_FV(i_index+1, j_index,k);
                        end
                    elseif i_index == size(G_VF, 1)
                        for k=1:d_value
                            G_VF(i_index-1, j_index, k) = BeliefG(i*width+j,k)-G_FV(i_index-1, j_index,k);
                        end
                    else
                        for k=1:d_value                        
                            G_VF(i_index+1, j_index, k) = BeliefG(i*width+j,k)-G_FV(i_index+1, j_index,k);
                            G_VF(i_index-1, j_index, k) = BeliefG(i*width+j,k)-G_FV(i_index-1, j_index,k);
                        end
                    end
                end
            end

            %Doing left and right.
            for i=1:height
                for j=1:width-1
                    i_index = ((i-1)*4)+1;
                    j_index = ((j-1)*4)+1;

                    if j_index == 1
                        for k=1:d_value
                            G_VF(i_index, j_index+1, k) = BeliefG(i*width+j,k)-G_FV(i_index, j_index+1,k);
                        end
                    elseif j_index == size(G_VF, 1)
                        for k=1:d_value
                            G_VF(i_index, j_index-1, k) = BeliefG(i*width+j,k)-G_FV(i_index, j_index-1,k);
                        end
                    else
                        for k=1:d_value
                            G_VF(i_index, j_index+1, k) = BeliefG(i*width+j,k)-G_FV(i_index, j_index+1,k);
                            G_VF(i_index, j_index-1, k) = BeliefG(i*width+j,k)-G_FV(i_index, j_index-1,k);
                        end                    
                    end

                end
            end
            
            test = BeliefL_Val/50*255;
            test = uint8(test);
            filename = strcat('Outputs/', int2str(imNo), '/Stereo_lambda_');
            filename = strcat(filename, int2str(lamda), '_',int2str(i_iter), '.png');        
            imwrite(test, filename);

            dump1 = uint8(BeliefG_Val);
            dump2 = uint8(BeliefL_Val);
            BeliefG_Val = BeliefL_Val; 
            
            final_cost = findCost(G_U, BeliefG_Val, lamda, width, height);
            if isequal(dump1, dump2) || i_iter == iter
                final_cost
                break;
            end
        end    
end

%Doing horizontal left.
function A =  findMinimumHL(d_value, idx, idxL, idxR, G_VF, lamda)
    finalV = zeros(50,1);
    for i=1:d_value
        
        %Initiallizing minimum value
        costM = lamda;
        if i == 1
            costM = 0;
        end
        minV = costM + G_VF(idx, idxR, 1);
        
        for j=1:d_value
            costV = lamda;
            if i == j
                costV = 0;
            end
            costV = costV + G_VF(idx, idxR, j);
            if minV > costV
                minV = costV;
            end
        end
        finalV(i,1) = minV;
    end
    A = finalV;
end

%Doing horizontal right.
function A =  findMinimumHR(d_value, idx, idxL, idxR, G_VF, lamda)
    finalV = zeros(50,1);
    for i=1:d_value
        
        %Initiallizing minimum value
        costM = lamda;
        if i == 1
            costM = 0;
        end
        minV = costM + G_VF(idx, idxL, 1);
        
        %minV = 1000000;
        for j=1:d_value
            costV = lamda;
            if i == j
                costV = 0;
            end
            costV = costV + G_VF(idx, idxL, j);
            if minV > costV
                minV = costV;
            end
        end
        finalV(i,1) = minV;
    end
    A = finalV;
end

%Doing vertical top.
function A =  findMinimumVT(d_value, idxT, idxB, idx, G_VF, lamda)
    finalV = zeros(50,1);
    for i=1:d_value
        
        %Initiallizing minimum value
        costM = lamda;
        if i == 1
            costM = 0;
        end
        minV = costM + G_VF(idxB, idx, 1);
        
        for j=1:d_value
            costV = lamda;
            if i == j
                costV = 0;
            end
            costV = costV + G_VF(idxB, idx, j);
            if minV > costV
                minV = costV;
            end
        end
        finalV(i,1) = minV;
    end
    A = finalV;
end

%Doing vertical bot.
function A =  findMinimumVB(d_value, idxT, idxB, idx, G_VF, lamda)
    finalV = zeros(50,1);
    for i=1:d_value
        
        %Initiallizing minimum value
        costM = lamda;
        if i == 1
            costM = 0;
        end
        minV = costM + G_VF(idxT, idx, 1);
        
        for j=1:d_value
            costV = lamda;
            if i == j
                costV = 0;
            end
            costV = costV + G_VF(idxT, idx, j);
            if minV > costV
                minV = costV;
            end
        end
        finalV(i,1) = minV;
    end
    A = finalV;
end
