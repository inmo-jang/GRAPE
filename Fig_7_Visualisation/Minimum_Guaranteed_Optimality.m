
Loss = 0; %Loss defined in Theorem 3

Participants = zeros(m,1);
for t=1:m
    Max_Loss = 0;
    
    % Cardinality of each coalition in the resulted Nash-stable assignment
    compare_sample = ones(n,1)*t;
    Participants(t) = sum(compare_sample==Alloc);
    
    % Find minimum p & applicable agent for each task
    Min_p_for_each_agent = inf*ones(1,n); % Minimum cardinality for making L_ij[p] maximum
    Max_Loss_candidate = zeros(1,n);      % Maximum L_ij[p] candidate btw agents for one task
    for i=1:n
        % Step(1): To Find minimum cardinality (excluding p=n)
        for k=1:n-1
            Term1_k = Get_Util(i,t,k,environment)*k;
            if Term1_k == 0 % In this case, all the utility value with regard k is 0, so skip
                Min_p_for_each_agent(i)=0;
                break;
            else
                Term1_kplus1 =  Get_Util(i,t,k+1,environment)*(k+1);
                Term1 = Term1_kplus1 - Term1_k;
                
                if t ~= Alloc(i);
                    Term2 = Get_Util(i,t,Participants(t)+1,environment);
                else % if the tested task is current task
                    Term2 = Get_Util(i,t,Participants(t),environment);
                end
                
                if Term1 < Term2
                    Min_p_for_each_agent(i)=k;
                    break;
                end
            end
        end
        Min_P = Min_p_for_each_agent(i);
        
        if Min_P > 0
            % Step(2): To find maximum L_ij[p] based on the minimum cardinality for each agent
            Max_Loss_candidate_p = Min_P*(Get_Util(i,t,Min_P,environment)-Term2);
            if Min_P == n-1 % considering the case of p=n
                Max_Loss_candidate_n = n*(Get_Util(i,t,n,environment)-Term2);
                Max_Loss_candidate_p = max(Max_Loss_candidate_p,Max_Loss_candidate_n);
            end
            
            Max_Loss_candidate(i) = Max_Loss_candidate_p;
        end
        
    end
    
    % Find max loss of the agents chosen as having Min P
    [Max_Loss,agent_Max_P] = max(Max_Loss_candidate);
    
    % Sum all Loss
    Loss = Loss + Max_Loss;
end

Global_GRAPE = sum(a_utility);
Bound = Global_GRAPE/(Global_GRAPE +  Loss);
if (Bound >= 0) && (Bound <= 1)
    disp(['Minimum-guaranteed Suboptimality is = ',num2str(Bound)]);
else
    disp(['Problem bound11']);
    flag_problem = 1;
    
end



