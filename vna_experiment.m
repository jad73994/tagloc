clear
close all


%% Script Parameters

f_center = 2450;
f_start = 2400;
f_end = 2500;
frequencies = [2431,2451,2471];
vnapoints = 1601;

instrreset
vna = Vna('model', Vna.MODEL_AGILENT_E5071C, 'iface', Instr.INSTR_IFACE_TCPIP, 'tcpipAddress', '192.168.128.1', 'tcpipPort', 5025 );
vna.SetTriggerContinuous;
%set to f_start to f_end
%set to 1601 points
%turn off beep

num_antennas = 4;
spacing = 0.5 * 0.1224;
ant_pos = spacing * [0:num_antennas-1];
theta_vals = (1:1:180)*pi/180;


%% Capture

control_relays('vna');
control_relays('cal');
control_relays('lnaon');
pause(0.2);

calvna1temp = zeros(10,vnapoints);
calvna2temp = zeros(10,vnapoints);
calvna3temp = zeros(10,vnapoints);
calvna4temp = zeros(10,vnapoints);
testvna1temp = zeros(10,vnapoints);
testvna2temp = zeros(10,vnapoints);
testvna3temp = zeros(10,vnapoints);
testvna4temp = zeros(10,vnapoints);

control_relays('rcv1');
for vnai = 1:10
    [vnax, ~, ~, calvna1temp(vnai,:)]=vna.GetTraceData('Tr1');
    pause(0.2);
end
control_relays('rcv2');
for vnai = 1:10
    [vnax, ~, ~, calvna2temp(vnai,:)]=vna.GetTraceData('Tr1');
    pause(0.2);
end
control_relays('rcv3');
for vnai = 1:10
    [vnax, ~, ~, calvna3temp(vnai,:)]=vna.GetTraceData('Tr1');
    pause(0.2);
end
control_relays('rcv4');
for vnai = 1:10
    [vnax, ~, ~, calvna4temp(vnai,:)]=vna.GetTraceData('Tr1');
    pause(0.2);
end


control_relays('test');

    
control_relays('rcv1');
for vnai = 1:10
    [vnax, ~, ~, testvna1temp(vnai,:)]=vna.GetTraceData('Tr1');
    pause(0.2);
end
control_relays('rcv2');
for vnai = 1:10
    [vnax, ~, ~, testvna2temp(vnai,:)]=vna.GetTraceData('Tr1');
    pause(0.2);
end
control_relays('rcv3');
for vnai = 1:10
    [vnax, ~, ~, testvna3temp(vnai,:)]=vna.GetTraceData('Tr1');
    pause(0.2);
end
control_relays('rcv4');
for vnai = 1:10
    [vnax, ~, ~, testvna4temp(vnai,:)]=vna.GetTraceData('Tr1');
    pause(0.2);
end


control_relays('rcvnone');
control_relays('cal');
control_relays('lnaoff');

calvna(1,:) = mean(calvna1temp);
calvna(2,:) = mean(calvna2temp);
calvna(3,:) = mean(calvna3temp);
calvna(4,:) = mean(calvna4temp);
testvna(1,:) = mean(testvna1temp);
testvna(2,:) = mean(testvna2temp);
testvna(3,:) = mean(testvna3temp);
testvna(4,:) = mean(testvna4temp);

ftovna = round(((frequencies - f_start) ./ (f_end-f_start)) * vnapoints);
vnah = calvna(:,ftovna)-testvna(:,ftovna);

figure;
subplot(2,2,1);
plot(unwrap(angle(testvna(1,:) ./ calvna(1,:))));
subplot(2,2,2);
plot(unwrap(angle(testvna(2,:) ./ calvna(2,:))));
subplot(2,2,3);
plot(unwrap(angle(testvna(3,:) ./ calvna(3,:))));
subplot(2,2,4);
plot(unwrap(angle(testvna(4,:) ./ calvna(4,:))));


coeffs1 = polyfit(1:1601,unwrap(angle(testvna(1,:) ./ calvna(1,:))),1);
coeffs2 = polyfit(1:1601,unwrap(angle(testvna(2,:) ./ calvna(2,:))),1);
coeffs3 = polyfit(1:1601,unwrap(angle(testvna(3,:) ./ calvna(3,:))),1);
coeffs4 = polyfit(1:1601,unwrap(angle(testvna(4,:) ./ calvna(4,:))),1);
slp1 = coeffs1(1)
slp2 = coeffs2(1)
slp3 = coeffs3(1)
slp4 = coeffs4(1)

% close all
% chinese_remainder(phases, frequencies)


M = compute_multipath_profile_music(vnah(:,1), ant_pos, spacing*2, theta_vals);
figure
plot(M)













