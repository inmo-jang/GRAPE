%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% For Fig 7. Visualisation Result in GRAPE Paper 
% Written & Revised By Inmo Jang, 15.Jul.2016
% Refined, 21. Jun. 2017 / 26. Sep. 2017
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Global Variable
% - m: # tasks
% - n: # agents
% - variables for generating utility functions

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all;close all;clc;tic
clock
%% Initialisation (1) - Mode Setting
Flag_display = 1; % 1: Show every iteration result, 0: No show. 
%% Initialisation (2) - TA Problem Setting
% The number of Tasks
m = [5];
% % The number of Agents
n = [2^6*m];

Deployment = 1; % 1: Circle, 2: Skewed Circle, 3: Square

%% Below is not needed to change
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ===============

toc
disp(['Algorithm begins @ #Agent = ',num2str(m), ' #Task = ',num2str(n)])
tic

flag_problem = 0; % Just in case that Bound value does not bound

% Modified 26.Jan.2016 for excluding the trivial case as followings:
% 1) some agents do not participate in any task;
% 2) some tasks do not have any agents assigned for that tasks
% Otherwise, the fewer number of rounds may be yielded.
all_participated_flag = 0;
while((all_participated_flag ~= n)||(min(Participants)==0))
    GRAPE_instance;
    all_participated_flag = sum(Participants);
    if (all_participated_flag ~= n)||(min(Participants)==0)
        disp('Again');
    end
end


dummy = 1;

%% Output Result (1): Final status
close all
fig = figure('position', [650, 10, 400, 350]);hold on;
grid on;daspect([1 1 1]);axis square
axis([-t_location_limit(1) t_location_limit(1) -t_location_limit(2) t_location_limit(2)]*1.1)
axis square
grid on;
UAV_ID = cellstr(num2str([1:n]'));
[UAV_1,UAV_2] = find(triu(MST)>0);
n_Edge = length(UAV_1);

dx = 4; dy = 1;
text(a_location(:,1)+dx,a_location(:,2)+dy,UAV_ID);
xlabel('X-axis (m)')
ylabel('Y-axis (m)')


cc_task = jet(m);
cc_task = [[0.4 0.4 0.4 ];cc_task];
final_time = size(output.visual.Satisfied_history,2);
Marker_size = 4.5;

k = final_time;

Alloc_ = output.visual.Alloc_history(:,k);
Satisfied_ = output.visual.Satisfied_history(:,k);
cla;

for kk=1:n_Edge
    i = UAV_1(kk);
    j = UAV_2(kk);
    
    plot([a_location(i,1) a_location(j,1)],[a_location(i,2) a_location(j,2)],'-','Color',cc_task(1,:));
    
end

% Agent position + Allocation
for j=1:n
    if Satisfied_(j)==0
        plot(a_location(j,1),a_location(j,2),'o','MarkerSize',Marker_size,'MarkerEdgeColor',cc_task(1,:),'MarkerFaceColor',cc_task(1,:))
    else
        plot(a_location(j,1),a_location(j,2),'o','MarkerSize',Marker_size,'MarkerEdgeColor',cc_task(1,:), 'MarkerFaceColor',cc_task(Alloc_(j)+1,:))
    end
    %plot(agent(j).x_result(1,k),agent(j).x_result(2,k),'o','Color',cc(j,:),'linewidth',1.5,'MarkerFaceColor',cc(j,:),'MarkerSize',Marker_size);
end


% Task
Adjust_factor = 0.5*0.15;
for jj=1:m
    plot(t_location(jj,1),t_location(jj,2),'s','MarkerEdgeColor',cc_task(1,:),'MarkerSize',Marker_size*t_demand(jj)/1000*Adjust_factor, 'MarkerFaceColor',cc_task(jj+1,:))
    
    txt = ['t',num2str(jj)];
    text(t_location(jj,1),t_location(jj,2),txt,'HorizontalAlignment','center','FontWeight','bold','Fontsize',20)
    
end

if k ==final_time
    filename = 'result_vis_';
    print(fig,filename,'-depsc','-r500');
end


%% Output Result (2): Animation from time 0 to final converged time
close all
figure('position', [650, 10, 400, 350]);hold on;
grid on;daspect([1 1 1]);axis square
axis([-t_location_limit(1) t_location_limit(1) -t_location_limit(2) t_location_limit(2)]*1.1)
axis square
grid on;
UAV_ID = cellstr(num2str([1:n]'));
[UAV_1,UAV_2] = find(triu(MST)>0);
n_Edge = length(UAV_1);
dx = 4; dy = 1;
text(a_location(:,1)+dx,a_location(:,2)+dy,UAV_ID);
xlabel('X-axis (m)')
ylabel('Y-axis (m)')


cc_task = jet(m);
cc_task = [[0.4 0.4 0.4 ];cc_task];
final_time = size(output.visual.Satisfied_history,2);
Marker_size = 4.5;

time = 1:10:final_time;
for k_=1:length(time)
    k = time(k_);
    Alloc_ = output.visual.Alloc_history(:,k);
    Satisfied_ = output.visual.Satisfied_history(:,k);
    cla;
    
    
    % Communication network
    for kk=1:n_Edge
        i = UAV_1(kk);
        j = UAV_2(kk);
        
        plot([a_location(i,1) a_location(j,1)],[a_location(i,2) a_location(j,2)],'-','Color',cc_task(1,:));
        
    end
    
    
    % Agent position + Allocation
    for j=1:n
        plot(a_location(j,1),a_location(j,2),'o','MarkerSize',Marker_size,'MarkerEdgeColor',cc_task(1,:), 'MarkerFaceColor',cc_task(Alloc_(j)+1,:))
    end
    
    
    % Task
    Adjust_factor = 0.5*0.15;
    for jj=1:m
        plot(t_location(jj,1),t_location(jj,2),'s','MarkerEdgeColor',cc_task(1,:),'MarkerSize',Marker_size*t_demand(jj)/1000*Adjust_factor, 'MarkerFaceColor',cc_task(jj+1,:))
        
        txt = ['t',num2str(jj)];
        text(t_location(jj,1),t_location(jj,2),txt,'HorizontalAlignment','center','FontWeight','bold','Fontsize',20)
        
    end
    
    
    % Iterations
    txt = ['# Iterations = ',num2str(output.visual.iteration_history(k))];
    text(500,500,txt,'HorizontalAlignment','right','Fontsize',13)
    
    % For GIF
    if k_==1
        f = getframe;
        [im,map] = rgb2ind(f.cdata,256,'nodither');
        im(1,1,1,20) = 0;
    else
        f = getframe;
        im(:,:,1,k_) = rgb2ind(f.cdata,map,'nodither');
    end
    
end
imwrite(im,map,'Result_TA.gif','DelayTime',0,'LoopCount',inf) %g443800

