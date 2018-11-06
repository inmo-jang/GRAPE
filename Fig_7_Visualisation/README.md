This is the algorithm to generate results like Figure 7 in the paper "Anonymous Hedonic Game for Task Allocation in a Large-Scale Multiple Agent System" (DOI: 10.1109/TRO.2018.2858292)


The included files are as follows:

- Main_visual.m: 
  the main executable file. Firstly, it executes "GRAPE_instance.m". After an output comes out, it visualises the result and saves as a gif file. 

- GRAPE_instance.m: 
This generates a GRAPE instance, and solves it in a (simulated) decentralised manner. 
In there, at first, you should set the instance (e.g., the size of the area where tasks and agents are going to be randomly located). According to your setting, the first part of this m-file generates a random instance. All this information is saved as the variable "environment". 

  Then, the task allocation algorithm ("Task_Allocation_SC_visual.m") solves the instance. Note that where "SC" indicates a strongly-connected network of the agents is considered. The result is saved as the variable "output".  

  Then, "Minimum_Guaranteed_Optimality.m" runs, which calculates the minimum guaranteed global utility, as proposed in Theorem 3 in the paper. 


- Task_Allocation_SC_visual.m:
  This is the actual algorithm (Algorithm 1) proposed in the paper. This is used in "GRAPE_instance.m"
  Here, it is pretended that, at each iteration, every agent runs Algorithm 1. Here "Get_Util.m" is used to get an individual utility. As described in the paper, agents can have any type of individual utility functions as long as the functions hold SPAO. In this visualisation example, 'Logarithm_reward' type is used, meaning that an increase in the number of participants induces higher "team utility" but reduces individual utilities. 
  The utility function used in this visualisation example considers the distance from an agent to a task as "Cost", and the demand of the task as "Reward". Then, "Utility" can be computed as "Reward"/(number of participants) - "Cost", as shown in Eqn (32) in the paper. 


- Get_Util.m:
For each agent to compute its individual utility. This is used in "Task_Allocation_SC_visual.m"


- Minimum_Guaranteed_Optimality.m:
This calculates the minimum guaranteed global utility, as proposed in Theorem 3 in the paper. This is used in "GRAPE_instance.m"
