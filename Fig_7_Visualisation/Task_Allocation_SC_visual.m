function [output] = Task_Allocation_SC_visual(input)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAPE Task Allocation_newation Solver Module
% By Inmo Jang, 2.Apr.2016
% Modified, 15.Jul.2016
% Modified, 25.Oct.2017
% Modified for Asynchronous communication environment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The following describes the name of variables; meanings;  and their matrix sizes
% Input :
%   - n;    the number of agents
%   - m;    the number of tasks
%   - environment.t_location;   Task Position(x,y);             m by 2 matrix (m = #tasks)
%   - environment.t_demand;     Task demand or reward;          m by 1 matrix
%   - environment.a_location;   Agent Posision(x,y);             n by 2 matrix (n = #agents)
%   - Alloc_existing;    Current allocation status of agents;        n by 1 matrix
%   - Flag_display; Flag for display the process;   1 by 1 matrix
% Output :
%   - Alloc;        New allocation status of agents;   n by 1 matrix
%   - a_utility;    Resulted individual utility for each agent; n by 1 matrix
%   - iteration;    Resulted number of iteration for convergence;   1 by 1   matrix

%% Interface (Input)
Alloc_existing = input.Alloc_existing;
Flag_display = input.Flag_display;
n = input.n;
m = input.m;
MST = input.MST;
environment = input.environment;


%% For visualisation
Alloc_history = zeros(n,10);
Satisfied_history = zeros(n,10);
iteration_history = [];
Case = 0;
%% Initialisation

a_satisfied = 0; % # Agents who satisfy the current partition

for i=1:n
    agent(i).iteration = 0;
    agent(i).time_stamp = rand;
    agent(i).Alloc = Alloc_existing;
    agent(i).satisfied_flag = 0;
    agent(i).util = 0;
end

%% Neighbour agents identification (Assumming a static situation)
for i=1:n
    agent_info(i).set_neighbour_agent_id = find(MST(i,:)>0);
end
Iteration_agent_current = zeros(n,1);
Timestamp_agent_current = zeros(n,1);

%% GRAPE Algorithm
while a_satisfied~=n
    
    for i=1:n % For Each Agent 
        
        %%%%% Line 5 of Algorithm 1
        Alloc_ = agent(i).Alloc;
        current_task = Alloc_(i); % Currently-selected task
        
        Candidate = ones(m,1)*(-inf);
        for t=1:m
            % Check member agent ID in the selected task
            current_members = (Alloc_ == ones(n,1)*t);
            current_members(i) = 1; % including oneself
            % Cardinality of the coalition
            n_participants = sum(current_members);
            
            % Obtain possible individual utility value
            Candidate(t) = Get_Util(i, t, n_participants,environment);
        end
        
        % Select Best alternative
        [Best_utility,Best_task] = max(Candidate);
        %%%%% End of Line 5 of Algorithm 1
        
        
        %%%%% Line 6-11 of Algorithm 1
        if Best_utility == 0
            Alloc_(i,1) = 0; % Go th the void
        else
            Alloc_(i,1) = Best_task;
        end
        agent(i).util = Best_utility;
        %
        if current_task == Alloc_(i,1) % if this choice is the same as remaining
            agent(i).satisfied_flag = 1;            
        else
            agent(i).satisfied_flag = 1;  
            agent(i).Alloc = Alloc_;
            agent(i).time_stamp = rand;
            agent(i).iteration = agent(i).iteration + 1;           
        end
        %%%%% End of Line 6-11 of Algorithm 1
        
        % For speed up when executing Algorithm 2
        Iteration_agent_current(i) = agent(i).iteration;
        Timestamp_agent_current(i) = agent(i).time_stamp;        
    end
    
    %% Distributed Mutex (Algorithm 2)  

    
    for i=1:n
        set_neighbour_agent_id = find(MST(i,:)>0);
        % Initially
        agent_(i).satisfied_flag = 1;
        agent_(i).Alloc = agent(i).Alloc;
        agent_(i).time_stamp = agent(i).time_stamp;
        agent_(i).iteration = agent(i).iteration;
        agent_(i).util = agent(i).util;
        
%         for j_=1:length(set_neighbour_agent_id)
%             j = set_neighbour_agent_id(j_); % neighbour agent id
%             % Send information from i to j
%             if agent(i).iteration < agent(j).iteration % i's info is more recent
%                 % Update using i's info                
%                 agent_(i).Alloc = agent(j).Alloc;
%                 agent_(i).time_stamp = agent(j).time_stamp;
%                 agent_(i).iteration = agent(j).iteration;
%                 agent_(i).satisfied_flag = 0;
%             elseif agent(i).iteration == agent(j).iteration % when i = j is the same 
%                 if agent(i).time_stamp < agent(j).time_stamp % if i's info is more eariler stamped
%                 agent_(i).Alloc = agent(j).Alloc;
%                 agent_(i).time_stamp = agent(j).time_stamp;
%                 agent_(i).iteration = agent(j).iteration;
%                 agent_(i).satisfied_flag = 0;                
%                 end
%             else % j's info is more recent
%                 % Keep the current info
%             end
%         end

%       (Revision) To find out the local "deciding agent" amongst neighbour agents
        set_neighbour_agent_id_ = [set_neighbour_agent_id i];
        % Iteratation amongst neighbour agent set
        Iteration_agent_neighbour = Iteration_agent_current(set_neighbour_agent_id_);
        % Maximum iteration amongst neighbour agent set
        max_Iteration = max(Iteration_agent_neighbour);
        % Agents who have maximum iteration
        max_Iteration_agent_neighbour = (Iteration_agent_neighbour == max_Iteration);
        
        % Timestamp amongst neighbour agent set
        Timestamp_agent_neighbour = Timestamp_agent_current(set_neighbour_agent_id_);
        % Time stamps amongst neighbour agent who have maximum iteraiton
        Timestamp_agent_maxiteration = Timestamp_agent_neighbour.*max_Iteration_agent_neighbour;
        
        [max_Timestamp,agent_neighbour_index] = max(Timestamp_agent_maxiteration);
        valid_agent_id = set_neighbour_agent_id_(agent_neighbour_index);  % Find out "deciding agent" 
        
        % Update local information from the deciding agent's local information
        agent_(i).Alloc = agent(valid_agent_id).Alloc;
        agent_(i).time_stamp = agent(valid_agent_id).time_stamp;
        agent_(i).iteration = agent(valid_agent_id).iteration;
        
        if min(agent(i).Alloc == agent_(i).Alloc)==1 % If local information is changed
        else
            agent_(i).satisfied_flag = 0;
        end
    end    
    agent = agent_;
    
    %% Check the current status
    a_satisfied = 0;
    iteration = 1;
    for i=1:n
        if agent(i).satisfied_flag == 1
        a_satisfied = a_satisfied + 1;
        end
        % Check the maximum iteration
        iteration = max(agent(i).iteration,iteration);
    end
    
    %%
    
    if Flag_display == 1 
        if mod(iteration,10) == 0
        disp(['Iteration = ',num2str(iteration)])
        end
    end
    
    
    %% Save data for visualisation
    Case = Case + 1;
    Alloc_known_ = zeros(n,1);
    Satisfied = zeros(n,1);
    for i=1:n
        Alloc_known_(i) = agent(i).Alloc(i);
        Satisfied(i) = agent(i).satisfied_flag;
    end
    Alloc_history(:,Case) = Alloc_known_;
    Satisfied_history(:,Case) = Satisfied;
    iteration_history(Case) = iteration;
end

%% Last Check: If Alloc is consensused?
a_utility = zeros(n,1);
output.flag_problem = 0;
for i=1:n
    if i==1
    Alloc_1 = agent(i).Alloc;
    iteration_1 = agent(i).iteration;
    time_stamp_1 = agent(i).time_stamp;
    else
        Alloc = agent(i).Alloc;        
        iteration = agent(i).iteration;
        time_stamp = agent(i).time_stamp;
        
        if (sum(Alloc_1 == Alloc) == n)&&(iteration_1 == iteration)&&(time_stamp_1 == time_stamp)
            % Consensus OK
        else
            disp(['Problem: Non Consensus with Agent#1 and Agent#',num2str(i)]);
            output.flag_problem = 1;
        end        
    end
    a_utility(i) = agent(i).util;
end


%% Interface (Output)

output.Alloc = Alloc;
output.a_utility = a_utility;
output.iteration = iteration;

output.visual.Alloc_history = Alloc_history;
output.visual.Satisfied_history = Satisfied_history;
output.visual.iteration_history = iteration_history;


end
