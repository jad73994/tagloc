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
%obstacles{2} = get_rectangle([16,5],2,3); %get rectangle([x,y],w,h) returns a rectangle at x,y with width w and height h
reflectors{1} = [20,2;20,13]; % Reflectors are linear for ease 
model.walls = walls;
model.reflectors =  reflectors;
model.obstacles = obstacles;
src = [1,10];
dst = [17,13];
model.lambda = 3e8./(2.4:0.01:3.7)./1e9;
model.amps = ones(length(model.lambda),1)*100; % Lambda and amps can be arrays
%% Display the space
channels = get_channels_from_model(model,src,dst);
channels = awgn(channels, 20);
d_vals = 0.1:0.1:30;
P=compute_distance_profile_music(channels,model.lambda,2,d_vals);
figure; plot(d_vals,(P));