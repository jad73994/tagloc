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
reflectors{1} = [20,2;20,13]; % Reflectors are linear for ease 
model.walls = walls;
model.reflectors =  reflectors;
model.obstacles = obstacles;
model.obstacles={};
model.reflectors={};
model.lambda = 3e8./(2.4)./1e9;
model.amps = ones(length(model.lambda),1)*100; % Lambda and amps can be arrays
%% Define the setup
max_x = max(model.walls(:,1));
max_y = max(model.walls(:,2));
ant_sep = min(model.lambda)/2;
ap{1}=[10,0;
    10+ant_sep,0;
    10+2*ant_sep,0];

ap{2}=[10,15;
    10+ant_sep,15;
    10+2*ant_sep,15];

ap{3}=[0,7.5-ant_sep;
        0, 7.5;
        0,7.5+ant_sep;];

ap{4}=[20,7.5-ant_sep;
        20, 7.5;
        20,7.5+ant_sep;];
ap_orient=[1,1,2,2];
n_total = 100000;
n_ant_per_ap = 3;
theta_vals = [-pi/2:0.01:pi/2];
d1 = 0:0.5:max_x;
d2=0:0.5:max_y;
%% Generate the points. Ap 1 antenna 1 serves as the reference
%features=zeros(n_total,length(model.lambda)*length(ap)*n_ant_per_ap*2);
features = zeros(n_total,length(ap),length(d2),length(d1));
labels = zeros(n_total,2);
channels = zeros(length(model.lambda),length(ap),n_ant_per_ap);
rng;

start_time = now;
%parpool(4);
for i=1:n_total
    pos = [rand()*max(model.walls(:,1)),rand()*max(model.walls(:,2))];
    for j=1:length(ap)
        for k=1:n_ant_per_ap
            channels(:,j,k)=get_channels_from_model(model,pos,ap{j}(k,:),false);
        end
        channels(:,j,:) = awgn(squeeze(channels(:,j,:)),30);
        P = compute_multipath_profile(squeeze(channels(:,j,:)),ap{j}(:,ap_orient(j)),model.lambda,theta_vals);
        P_out = convert_multipath_to_2d(P,theta_vals,d1,d2,ap{j});
        %channels = channels./repmat(channels(:,1,1),1,length(ap),n_ant_per_ap);
        
        features(i,j,:,:) = abs(P_out);
    end
    labels(i,:) = pos;
    if(mod(i,100)==0)
        disp([i,(now -start_time)*24*60]);
    end
end

%delete(gcp('nocreate'));