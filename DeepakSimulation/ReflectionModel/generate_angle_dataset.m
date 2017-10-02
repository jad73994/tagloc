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
model.lambda = 3e8./(2.4:0.01:2.7)./1e9;
model.amps = ones(length(model.lambda),1)*100; % Lambda and amps can be arrays
%% Define the setup
ant_sep = min(model.lambda)/2;
ap{1}=[10,0;
    10+ant_sep,0;
    10+2*ant_sep,0];


n_total = 100000;
n_ant_per_ap = 3;
%% Generate the points. Ap 1 antenna 1 serves as the reference
features=zeros(n_total,length(model.lambda)*length(ap)*n_ant_per_ap*2);
labels = zeros(n_total,1);
channels = zeros(length(model.lambda),length(ap),n_ant_per_ap);
rng;
max_x = max(model.walls(:,1));
max_y = max(model.walls(:,2));
start_time = now;
%parpool(4);
for i=1:n_total
    pos = [rand()*max(model.walls(:,1)),rand()*max(model.walls(:,2))];
    for j=1:length(ap)
        for k=1:n_ant_per_ap
            channels(:,j,k)=get_channels_from_model(model,pos,ap{j}(k,:),false);
        end
    end
    %channels = channels./repmat(channels(:,1,1),1,length(ap),n_ant_per_ap);
    channels(:) = awgn(channels(:),30);
    features(i,:) =[real(channels(:));imag(channels(:))].';  
    labels(i) = cart2pol(pos(1)-ap{1}(2,1),pos(2)-ap{1}(2,2));
    if(mod(i,100)==0)
        disp([i,(now -start_time)*24*60]);
    end
end

%delete(gcp('nocreate'));