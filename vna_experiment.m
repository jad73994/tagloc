clear
close all


%% Script Parameters

vnapoints = 31;
f_start = 2400;
f_end = 2560;
freq = (f_start:100/(vnapoints-1):f_end)*1e6;
num_avg=2;
instrreset
vna = Vna('model', Vna.MODEL_AGILENT_E5071C, 'iface', Instr.INSTR_IFACE_TCPIP, 'tcpipAddress', '192.168.128.1', 'tcpipPort', 5025 );
vna.SetTriggerContinuous;

%set to f_start to f_end
%set to 1601 points
%turn off beep


%% Capture


caltemp = zeros(num_avg,vnapoints);
ap1rcv1temp = zeros(num_avg,vnapoints);
ap1rcv2temp = zeros(num_avg,vnapoints);
ap1rcv3temp = zeros(num_avg,vnapoints);
ap1rcv4temp = zeros(num_avg,vnapoints);
ap2rcv1temp = zeros(num_avg,vnapoints);
ap2rcv2temp = zeros(num_avg,vnapoints);
ap2rcv3temp = zeros(num_avg,vnapoints);
ap2rcv4temp = zeros(num_avg,vnapoints);

control_relays('cal');
control_relays('lnaon');
control_relays('ap1');
control_relays('ap1rcv1');
pause(0.2);
for vnai = 1:num_avg
    [vnax, ~, ~, caltemp(vnai,:)]=vna.GetTraceData('Tr1');
    pause(0.1);
end
control_relays('test');
pause(0.1);
for vnai = 1:num_avg
    [vnax, ~, ~, ap1rcv1temp(vnai,:)]=vna.GetTraceData('Tr1');
    pause(0.1);
end
control_relays('ap1rcv2');
pause(0.1);
for vnai = 1:num_avg
    [vnax, ~, ~, ap1rcv2temp(vnai,:)]=vna.GetTraceData('Tr1');
    pause(0.1);
end
control_relays('ap1rcv3');
pause(0.1);
for vnai = 1:num_avg
    [vnax, ~, ~, ap1rcv3temp(vnai,:)]=vna.GetTraceData('Tr1');
    pause(0.1);
end
control_relays('ap1rcv4');
pause(0.1);
for vnai = 1:num_avg
    [vnax, ~, ~, ap1rcv4temp(vnai,:)]=vna.GetTraceData('Tr1');
    pause(0.1);
end


control_relays('ap2');
control_relays('ap2rcv1');
pause(0.1);
for vnai = 1:num_avg
    [vnax, ~, ~, ap2rcv1temp(vnai,:)]=vna.GetTraceData('Tr1');
    pause(0.1);
end
control_relays('ap2rcv2');
pause(0.1);
for vnai = 1:num_avg
    [vnax, ~, ~, ap2rcv2temp(vnai,:)]=vna.GetTraceData('Tr1');
    pause(0.1);
end
control_relays('ap2rcv3');
pause(0.1);
for vnai = 1:num_avg
    [vnax, ~, ~, ap2rcv3temp(vnai,:)]=vna.GetTraceData('Tr1');
    pause(0.1);
end
control_relays('ap2rcv4');
pause(0.1);
for vnai = 1:num_avg
    [vnax, ~, ~, ap2rcv4temp(vnai,:)]=vna.GetTraceData('Tr1');
    pause(0.1);
end
control_relays('alloff');

cal = mean(caltemp(:,[1:end-1]));
% cal(1,:)= mean(caltemp(:,[1:end-1]));
% cal(2,:)= mean(caltemp(:,[1:end-1]));
% cal(3,:)= mean(caltemp(:,[1:end-1]));
% cal(4,:)= mean(caltemp(:,[1:end-1]));

ap1(1,:) = mean(ap1rcv1temp(:,[1:end-1]));
ap1(2,:) = mean(ap1rcv2temp(:,[1:end-1]));
ap1(3,:) = mean(ap1rcv3temp(:,[1:end-1]));
ap1(4,:) = mean(ap1rcv4temp(:,[1:end-1]));
ap2(1,:) = mean(ap2rcv1temp(:,[1:end-1]));
ap2(2,:) = mean(ap2rcv2temp(:,[1:end-1]));
ap2(3,:) = mean(ap2rcv3temp(:,[1:end-1]));
ap2(4,:) = mean(ap2rcv4temp(:,[1:end-1]));


for i=1:4
    ap1_cald(i,:) = ap1(i,:).*conj(cal);
    ap2_cald(i,:) = ap2(i,:).*conj(cal);
    ap2_ant(i,:) = ap2(i,:).*conj(ap1(1,:));
    
    ap1_noamp(i,:) = exp(1i*angle(ap1(i,:))).*conj(exp(1i*angle(cal)));
    ap2_noamp(i,:) = exp(1i*angle(ap2(i,:))).*conj(exp(1i*angle(cal)));
end


spacing = 0.0625;
theta_vals = (-90:1:90)*pi/180;
d_vals = -20:0.2:100;
opt.threshold = 0.01; opt.freq = freq; opt.ant_sep = spacing;


save ex_-28_95


% 
% % AP1
% P = compute_spotfi_profile(ap1_cald, theta_vals, d_vals, opt);
% figure(1)
% subplot(2,1,1)
% imagesc(d_vals, theta_vals*180/pi, abs(P));
% subplot(2,1,2)
% meshc(d_vals, theta_vals*180/pi, db(abs(P)));
% 
% 
% % AP2 
% P = compute_spotfi_profile(ap2_cald, theta_vals, d_vals, opt);
% figure(2)
% subplot(2,1,1)
% imagesc(d_vals, theta_vals*180/pi, abs(P));
% subplot(2,1,2)
% meshc(d_vals, theta_vals*180/pi, db(abs(P)));

% 
% % AP2 compared to AP1ant1
% P = compute_spotfi_profile(ap2_ant, theta_vals, d_vals, opt);
% figure(3)
% subplot(2,1,1)
% imagesc(d_vals, theta_vals*180/pi, abs(P));
% subplot(2,1,2)
% meshc(d_vals, theta_vals*180/pi, db(abs(P)));
% 
% 
% 
% 
% 
% 
% 
% % AP1 no amp
% P = compute_spotfi_profile(ap1_noamp, theta_vals, d_vals, opt);
% figure(4)
% subplot(2,1,1)
% imagesc(d_vals, theta_vals*180/pi, abs(P));
% subplot(2,1,2)
% meshc(d_vals, theta_vals*180/pi, db(abs(P)));
% 
% 
% % AP2 no amp
% P = compute_spotfi_profile(ap2_noamp, theta_vals, d_vals, opt);
% figure(5)
% subplot(2,1,1)
% imagesc(d_vals, theta_vals*180/pi, abs(P));
% subplot(2,1,2)
% meshc(d_vals, theta_vals*180/pi, db(abs(P)));



% [maxvals,indices] = max(P);
% [maxval,index] = max(maxvals);
% 
% max_angle = indices(index);
% max_delay = index;
% max_val = P(max_angle, max_delay)
% max_delay = d_vals(max_delay)
% max_angle = theta_vals_s(max_angle)/pi*180
% 
% 
% figure(125)
% hold all
% for i=1:3
%     pro = compute_distance_profile(h_cald_zeros(i,[1:10]), 3e8./(frequencies(1:10)*1e6), 2, [0:0.1:50]);
%     plot(abs(pro))
% end
% 
% 
% figure(124)
% hold all
% for i=1:num_ants
%     pro = compute_distance_profile_music(h_cald_firstant_zeros(i,:), 3e8./(frequencies*1e6), 2, [0:0.1:50]);
%     plot(abs(pro))
% end





