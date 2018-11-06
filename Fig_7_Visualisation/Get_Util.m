%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% Given situation, this function is used to obtain an agent's utility 
% [Input]
% - agent_id
% - task_id
% - participants (number_of_members)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [util_value] = Get_Util(agent_id, task_id, n_participants, environment)

a_location = environment.a_location;
t_location = environment.t_location;
t_demand = environment.t_demand;
%global a_location t_location t_demand table_rand_util

%% Setting Utility Type
% Util_type = 'Peaked_reward';
Util_type = 'Logarithm_reward';
%Util_type = 'Constant_reward';
%Util_type = 'Random';

%%
switch Util_type
    
    case 'Peaked_reward'
        % Cost
        cost = 1*norm(t_location(task_id,:)-a_location(agent_id,:));
        
        % Relative Task Demand
        Desired_num_agent_adjust_factor = 1;
        n = size(a_location,1);
        t_desired_num_agent = round(t_demand(task_id,1)./sum(t_demand(:,1))*n*Desired_num_agent_adjust_factor);
        if t_desired_num_agent <= 1
            t_desired_num_agent = 1;
        end
        
%         util_value = t_demand(task_id)*exp(-(n_participants-1)/t_desired_num_agent) - cost;
        util_value = t_demand(task_id)*exp(-n_participants/t_desired_num_agent + (1-log(t_desired_num_agent))) - cost;
       
        
    case 'Logarithm_reward'
%         cost = 2*norm(t_location(task_id,:)-a_location(agent_id,:));
%         util_value = t_demand(task_id)*log2(n_participants+1)/n_participants - cost;
        n = size(a_location,1);
        m = size(t_location,1);
        cost = norm(t_location(task_id,:)-a_location(agent_id,:));
        util_value = t_demand(task_id)/(log2(n/m+1))*log2(n_participants+1)/n_participants - cost;        
        
    case 'Constant_reward'
        cost = norm(t_location(task_id,:)-a_location(agent_id,:));
        util_value = t_demand(task_id)/n_participants - cost;
        
        
    case 'Random'        
        % table_rand_util(#Participants, Task ID, Agent ID)
        util_value = t_demand(task_id)*prod(table_rand_util(1:n_participants,task_id,agent_id));
        
    case 'Else'
        
        % Setting : threshold for deciding to go void task
        Void_task_threshold = 0;
        
        %% Utility Function for Testing GAP
        
        
        bin_size_ = bin_size(bin_id);
        %bin_size_ = bin_size(bin_id,item_id);
        item_size_ = item_size(bin_id,:);
        item_value_ = item_value(bin_id,:);
        
        % profit ratio
        profit_ratio_ = item_value_./item_size_;
        
        if bin_size_ >= item_size_(item_id)
            weight_ = profit_ratio_(item_id)/sum(profit_ratio_(current_members));
            util_value = profit_ratio_(item_id)*(bin_size_*1.1 - item_size_(item_id))*weight_;    % Problem: if item size is just fit, then becomes 0
            %util_value = profit_ratio_(item_id)*weight_;
            
        else
            util_value = 0;
        end
        
end

if util_value < 0
    util_value = 0;
end
end
