function E = findCost(G_U, Belief, lambda, width, height)
    e_data = 0;
    for i=1:height
        for j=1:width            
            e_data = e_data + G_U(i,j, Belief(i,j));
        end
    end
    
    e_smooth = 0;
    %Doing the left/right node.
    for i=1:height
        for j=1:width-1
            i_index = ((i-1)*4)+1;
            j_index = ((j-1)*4)+3;
            if Belief((i_index+3)/4, (j_index+1)/4) ~= Belief((i_index+3)/4, (j_index+5)/4)
                e_smooth = e_smooth + lambda;
            end
        end
    end
    
    %Doing the top/down node.
    for i=1:height-1
        for j=1:width            
            i_index = ((i-1)*4)+3;
            j_index = ((j-1)*4)+1;
            if Belief((i_index+1)/4, (j_index+3)/4) ~= Belief((i_index+5)/4, (j_index+3)/4)
                e_smooth = e_smooth + lambda;
            end
        end
    end
    E = e_data + e_smooth;
end