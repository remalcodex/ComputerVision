function BeliefPropogation_Hamming()
    %8,9,10 are parity checks
    tableV = createTable();
    cost_matrix = [0.0,3.0;
        0.0,2.0;
        0.0,2.5;
        0.0,5.4;
        0.0,4.0;
        0.2,0.0;
        0.7,0.0];    

    G = graph([1 2 3 4 5 6 7 11 12 13 14 15 16 17], [8 8 8 9 8 9 10 1 2 3 4 5 6 7]);
    G = G.addedge(1,9);
    G = G.addedge(1,10);
    G = G.addedge(2,9);
    G = G.addedge(3,10);
    G = G.addedge(4,10);        
    
    M_V = zeros(17,17,2);    
    M_F = zeros(17,17,2);
    BeliefG = zeros(7,3);
    %variables 1-7
    %factors 8-10
    iter = 10;
    for iIter = 1:iter
        BeliefL = zeros(7,3);
        %Sending messages from factors to variables.
        for f = 8:17
            nbrs = neighbors(G, f);            
            inbr = 1;
            for nbr = nbrs'
                if f < 11
                    C0 = findMinimum(inbr, 0, tableV);
                    minSum0 = 100000000;
                    minIndex0 = -1;
                    for i = 1:size(C0,1)
                        row = C0(i,:);
                        sum = 0;
                        for j = 1:numel(row)
                            if j ~= inbr
                                x = nbrs(j);
                                sum  = sum + M_V(x, f, row(j)+1);                                
                            end                            
                        end
                        if minSum0 > sum
                            minSum0 = sum;
                            minIndex0 = row;
                        end
                    end                    
                    
                    C1 = findMinimum(inbr, 1, tableV);
                    minSum1 = 100000000;
                    minIndex1 = -1;
                    for i = 1:size(C1,1)
                        row = C1(i,:);
                        sum = 0;
                        for j = 1:numel(row)
                            if j ~= inbr
                                x = nbrs(j);
                                sum  = sum + M_V(x, f, row(j)+1);                                
                            end                            
                        end
                        if minSum1 > sum
                            minSum1 = sum;
                            minInde1x = row;
                        end
                    end                    
                    
                    M_F(f, nbr, 1) = minSum0;
                    M_F(f, nbr, 2) = minSum1;
                else
                    M_F(f, nbr, 1) = cost_matrix(f-10,1); %Can probably add val0 here but that wont effect anything.
                    M_F(f, nbr, 2) = cost_matrix(f-10,2);
                end
                inbr = inbr + 1;
            end
        end
        
        %Calculating belief.
        for b = 1:7
            nbrs = neighbors(G, b);
            sum0 = 0;
            sum1 = 0;
            for nbr = nbrs'
                sum0 = sum0 + M_F(nbr, b, 1);
                sum1 = sum1 + M_F(nbr, b, 2);
            end
            BeliefL(b, 1) = sum0;
            BeliefL(b, 2) = sum1;
            [val, idx] = min(BeliefL(b,1:2));
            BeliefL(b, 3) = idx-1;
        end
        
        final_cost = calculateCost(cost_matrix, BeliefL, G);       
        
        if isequal(BeliefG(:,3), BeliefL(:,3))            
            disp(strcat('Iteration no:', int2str(iIter)));
            BeliefL
            final_cost
            break;
        else
            BeliefG = BeliefL;
        end
        
        %Calculating the message from value node to factor node.
        for b = 1:7
            nbrs = neighbors(G, b);
            for nbr = nbrs'
                belief = BeliefL(b,1:2);
                belief(1) = belief(1) - M_F(nbr, b, 1);
                belief(2) = belief(2) - M_F(nbr, b, 2);
                M_V(b, nbr, 1) = belief(1);
                M_V(b, nbr, 2) = belief(2);
            end
        end        
    end
end

function E = calculateCost(cost_matrix, Belief, G)
    e_data = 0;
    for b=1:7
        e_data = e_data + cost_matrix( b, Belief(b,3)+1);        
    end
    
    e_smooth = 0;    
    for f = 8:17
        nbrs = neighbors(G, f);                        
        sum = 0;
        for nbr = nbrs'
            sum = sum + Belief(nbr,3);
        end
        if mod(sum,2) ~= 0
            e_smooth = e_smooth + 100000000;
        end
    end
    
    E = e_data + e_smooth;   
end

function A = findMinimum(xP, xV, tableV)
    minimum = [];
    idx = tableV(:,xP) == xV;
    rows = tableV(idx, :);
    
    idx = rows(:, 5) == 0;
    rows = rows(idx, :);
    A = rows(:,1:4);
end

function A = createTable()
    tableV = [];
    for x1 = [0,1]
        for x2 = [0,1]
            for x3 = [0,1]
                for x4 = [0,1]
                    if mod(x1+x2+x3+x4, 2) == 0
                        tableV = [tableV; [x1, x2, x3, x4, 0]];
                    else
                        tableV = [tableV; [x1, x2, x3, x4, 10000000]];
                    end
                end
            end
        end
    end
    A = tableV;
end