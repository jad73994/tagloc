clear
%% Description: 
% The goal of this code is to get channels given a physical space. 
% The definition of physical space can include finite reflectors and 
% bounded obstacles.
% Reflectors are obstacles by default
% Color code: Red is for walls, blue is for obstacles and green is for
% reflectors
% For paths, red path is a non-blocked path and black path is a blocked
% path
%% Define the space
walls = get_rectangle([0,0],20,15);  % Walls are defined just for plotting. They are non-reflecting, non-blocking                              
obstacles{1} = get_rectangle([7,5],2,2); %Obstacles are bounded and opaque to wireless signals
obstacles{2} = get_rectangle([16,5],2,3); %get rectangle([x,y],w,h) returns a rectangle at x,y with width w and height h
reflectors{1} = [20,2;20,13]; % Reflectors are linear for ease 
model.walls = walls;
model.reflectors =  reflectors;
model.obstacles = obstacles;
src = [17,3];
dst = [17,13];
lambda = 3e8/2.4e9;
amps = 1; % Lambda and amps can be arrays
%% Display the space
figure; 
display_model(model);
%% Check if there are reflections
rays{1} = [src;dst]; %Direct path
ray_status=[0,0];
for i=1:length(model.reflectors)
    [p,t]=is_reflect(src,dst, model.reflectors{i});    
    if(t)
        rays{end+1} =[src;p;dst]; % Add a reflected path
        ray_status(end+1,:)=[1,i];
    end    
end

%% Check if a ray is blocked

% Collect all blocking line segments into one array
all_blocking_rays ={};
blocking_ray_status=[];
for j=1:length(model.reflectors)
    all_blocking_rays{end+1}=model.reflectors{j};
    blocking_ray_status(end+1,:)=[1,j];
end
for j=1:length(model.obstacles)
    for k=1:size(model.obstacles{j},1)
        start_point = model.obstacles{j}(k,:);
        if(k==size(model.obstacles{j},1))
            end_point = model.obstacles{j}(1,:);
        else
            end_point = model.obstacles{j}(k+1,:);
        end
        all_blocking_rays{end+1}=[start_point;end_point];
        blocking_ray_status(end+1,:)=[0,j];
    end
end 

is_ray_blocked = false(length(rays),1);
for i=1:length(rays)
    % Check if these line segments are blocking the signal
    
    for j=1:length(all_blocking_rays)
        if(sum(abs(ray_status(i,:)-blocking_ray_status(j,:)))==0)
            fprintf('Skipping\n');
        else
            for k=1:size(rays{i},1)-1
                t=is_blocked(rays{i}(k:k+1,:),all_blocking_rays{j}); % Main function
                if(t)
                    is_ray_blocked(i)=true;
                end
                if(is_ray_blocked(i))
                    break;
                end
            end
            if(is_ray_blocked(i))
                break;
            end
        end
    end
    
    
end


for i=1:length(rays)
    if(is_ray_blocked(i))
        clr = 'k';
    else
        clr = 'r';
    end
    for j=1:size(rays{i},1)-1
        plot(rays{i}(j:j+1,1),rays{i}(j:j+1,2),'-','color',clr);
    end
end

model.rays = rays;
model.is_ray_blocked = is_ray_blocked;

%% Define the channels
channels = zeros(length(lambda));
for i=1:length(rays)
    cur_d = 0;
    for j=1:size(rays{i},1)-1
        cur_d = cur_d + norm(rays{i}(j+1,:)-rays{i}(j,:));
    end
    for j=1:length(lambda)
        channels(j) = channels(j) + amps(j)*exp(1j*2*pi/lambda(j)*cur_d);
    end
end