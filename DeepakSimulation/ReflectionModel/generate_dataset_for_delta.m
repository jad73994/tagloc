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
obstacles{1} = get_rectangle([7,5],2,3); %Obstacles are bounded and opaque to wireless signals
%obstacles{2} = get_rectangle([16,5],2,3); %get rectangle([x,y],w,h) returns a rectangle at x,y with width w and height h
reflectors{1} = [20,8;20,13]; % Reflectors are linear for ease 
model.walls = walls;
model.reflectors =  reflectors;
model.obstacles = obstacles;
%model.obstacles={};
%model.reflectors={};
model.lambda = 3e8./(2.4e9:3e6:2.487e9);
model.amps = ones(length(model.lambda),1)*100; % Lambda and amps can be arrays
%% Define the setup
ant_sep = min(model.lambda)/2;
ap{1}=[0,0;
    ant_sep,0;
    2*ant_sep,0];

ap{2} = [20,0;
    20,ant_sep;
    20,ant_sep*2];

ap{3} = [20,15;
        20-ant_sep,15;
        20-2*ant_sep,15];
    
ap{4} = [0,15;
        0,15-ant_sep;
        0,15-2*ant_sep];

n_total = 1000;
n_ant_per_ap = 3;
%% Generate the points. Ap 1 antenna 1 serves as the reference
features=cell(n_total,1);
for i=1:n_total
    features{i} = zeros(length(model.lambda),length(ap),n_ant_per_ap);
    
end
labels = zeros(n_total,2);
rng;
max_x = max(model.walls(:,1));
max_y = max(model.walls(:,2));
start_time = now;
%parpool(4);
for i=1:n_total
    labels(i,:) = [rand()*max(model.walls(:,1)),rand()*max(model.walls(:,2))];
    for j=1:length(ap)
        for k=1:n_ant_per_ap
            features{i}(:,j,k)=get_channels_from_model(model,labels(i,:),ap{j}(k,:),false);
        end
    end
    %channels = channels./repmat(channels(:,1,1),1,length(ap),n_ant_per_ap);
    features{i}(:) = awgn(features{i}(:),30);
    %features(i,:) =[real(channels(:));imag(channels(:))].';    
    if(mod(i,100)==0)
        disp([i,(now -start_time)*24*60]);
    end
end

%delete(gcp('nocreate'));