function Pose_Estimation()
    load('Inputs/Q_m_i.mat');
    load('Inputs/q_i.mat');
    load('Inputs/Calib_Results.mat');
    q_i = double(q_i);
    Q_m_i(:,3) = 1;
    
    %KK is the K matrix.
    arr = [1,2,3,4,5,6,7,8,9,10];
    data = [-1,-1,-1];
    global data_g;
    data_g = [];
    %Calculating all the 120 permutations possible for 10C3 points.
    calculate_Permutations(arr, data, 1, 10, 1, 4);    
    
    i = 54;%20;    
    q1 = data_g(i, 1);
    q2 = data_g(i, 2);
    q3 = data_g(i, 3);
    if check_on_line(q1, q2, q3, q_i) ~= 0
    	Q_c_1 = mtimes(inv(KK), [q_i(q1,:) 1]');
        Q_c_2 = mtimes(inv(KK), [q_i(q2,:) 1]');
        Q_c_3 = mtimes(inv(KK), [q_i(q3,:) 1]');
            
        d_12 = norm(Q_m_i(q1,:) - Q_m_i(q2,:));
        d_23 = norm(Q_m_i(q2,:) - Q_m_i(q3,:));
        d_31 = norm(Q_m_i(q1,:) - Q_m_i(q3,:));
            
        Q_m_1 = Q_m_i(q1,:)';
        Q_m_2 = Q_m_i(q2,:)';
        Q_m_3 = Q_m_i(q3,:)';        
            
        X1 = Q_c_1(1);
        Y1 = Q_c_1(2);
        Z1 = Q_c_1(3);
            
       	X2 = Q_c_2(1);
        Y2 = Q_c_2(2);
        Z2 = Q_c_2(3);
            
        X3 = Q_c_3(1);
        Y3 = Q_c_3(2);
        Z3 = Q_c_3(3);
            
        syms l1 l2 l3;
%             sols = solve(((lx_1*Q_m_1(1)) - (lx_2*Q_m_2(1)))^2 + ((lx_1*Q_m_1(2)) - (lx_2*Q_m_2(2)))^2 + ((lx_1*Q_m_1(3)) - (lx_2*Q_m_2(3)))^2 == d_12^2,... 
%             ((lx_2*Q_m_2(1)) - (lx_3*Q_m_3(1)))^2 + ((lx_2*Q_m_2(2)) - (lx_3*Q_m_3(2)))^2 + (lx_2*Q_m_2(3) - (lx_3*Q_m_3(3)))^2 == d_23^2,...
%             ((lx_3*Q_m_3(1)) - (lx_1*Q_m_1(1)))^2 + ((lx_3*Q_m_3(2)) - (lx_1*Q_m_1(2)))^2 + (lx_3*Q_m_3(3) - (lx_1*Q_m_1(3)))^2 == d_31^2);
%         
%             sols = solve(((l1*Q_m_1(1) - l2*Q_m_2(1))^2 + (l1*Q_m_1(2) - l2*Q_m_2(2))^2 + (l1*Q_m_1(3) - l2*Q_m_2(3))^2) == d_12^2,...
%                 ((l2*Q_m_2(1) - l3*Q_m_3(1))^2 + (l2*Q_m_2(2) - l3*Q_m_3(2))^2 + (l2*Q_m_2(3) - l3*Q_m_3(3))^2) == d_23^2,...
%                 ((l3*Q_m_3(1) - l1*Q_m_1(1))^2 + (l3*Q_m_3(2) - l1*Q_m_1(2))^2 + (l3*Q_m_3(3) - l1*Q_m_1(3))^2) == d_31^2);

%         sols = solve((50*(l2)^2 + l1^2 - 2*(l1*l2)) == d_12,...
%         (50*(l2)^2 + 9*(l3)^2 - 30*l2*l3) == d_23,...
%         (9*(l3)^2 + l1^2 - 2*l1*l3) == d_31);
        
        eqn1 = (l1*X1 - l2*X2)^2 + (l1*Y1 - l2*Y2)^2 + (l1*Z1 - l2*Z2)^2 == d_12^2;
        eqn2 = (l2*X2 - l3*X3)^2 + (l2*Y2 - l3*Y3)^2 + (l2*Z2 - l3*Z3)^2 == d_23^2;
        eqn3 = (l3*X3 - l1*X1)^2 + (l3*Y3 - l1*Y1)^2 + (l3*Z3 - l1*Z1)^2 == d_31^2;
        sols = vpasolve(eqn1, eqn2, eqn3);
        l_1 = double(sols.l1);
        l_2 = double(sols.l2);
        l_3 = double(sols.l3);
        
        bestRPE = 100000000;
        bestK = -1;
        for k=1:size(l_1,1)
        	if isreal(l_1(k,:)) ~= 0 && isreal(l_2(k,:)) ~= 0 && isreal(l_3(k,:)) ~= 0
                if l_1(k,:) >= 0 && l_2(k,:) >= 0 && l_3(k,:) >= 0
                    Q_c_1 = Q_c_1 * real(l_1(k));
                    Q_c_2 = Q_c_2 * real(l_2(k));
                    Q_c_3 = Q_c_3 * real(l_3(k));
                    final_calib = Register3DPointsQuaternion([Q_m_1 Q_m_2 Q_m_3], [Q_c_1 Q_c_2 Q_c_3]);
                    rot_m = final_calib(1:3,1:3);
                    trans_m = (-1)*rot_m'*final_calib(1:3,4);

                    RPE = 0;
                    for i=1:size(arr,2)
                        reprojection = KK * ((rot_m * Q_m_i(i,:)') - (rot_m * trans_m));
                        reprojection = reprojection/reprojection(3);
                        real_pt = [q_i(i,:) 1]';
                        rpe = real_pt - reprojection;
                        rpe = rpe.^2;
                        rpe = sum(rpe);
                        rpe = sqrt(rpe);
                        RPE = RPE + rpe;
                        %reprojection = KK * ((rotation_matrix * ))
                    end                
                    RPE = RPE/10;
                    if RPE < bestRPE
                        bestRPE = RPE;
                        bestK = k;
                    end
                end
            end
        end    
        %format short g;
        if bestK ~= -1
            fprintf ('The least reprojection error is: %f \n', bestRPE)
            fprintf ('For the lambdas: %f %f %f \n', l_1(bestK), l_2(bestK), l_3(bestK))
            fprintf ('For the image points:\n');
            disp(q_i(q1, :));
            disp(q_i(q2, :));
            disp(q_i(q3, :));
            fprintf ('For the world coordinate points: \n');
            disp(Q_m_i(q1, :));
            disp(Q_m_i(q2, :));
            disp(Q_m_i(q3, :));
        end
    end    
end

function A = check_on_line(q1, q2, q3, q_i)
    mat = [[q_i(q1,:) 1]; [q_i(q2,:) 1]; [q_i(q3,:) 1]];
    A = det(mat);
end

function calculate_Permutations(arr, data, start_i, end_i, index, r)
    % Current combination is ready to be printed, print it
    if (index == r)
        data;
        global data_g;
        data_g = [data_g; data];        
        return;
    end

    for i=start_i:end_i
        if end_i-i+1 >= r-index
            data(index) = arr(i);
            calculate_Permutations(arr, data, i+1, end_i, index+1, r);
        end
    end    
end