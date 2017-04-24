clear
close all


%% Script Parameters
txtty = '4';
rxtty = '3';

dir = '/home/abari/Desktop/tagloc/';
gtrdir = '/home/abari/Projects/RFIT/uhd/host/build/mmimo/general_tx_rx';

txips = 'addr0=192.168.30.2,addr1=192.168.40.2,addr2=192.168.50.2';
rxips = 'addr0=192.168.60.2,addr1=192.168.70.2,addr2=192.168.80.2';

frequencies = [740,850,960];
%frequencies_measured = [719.9725,829.6375,939.8875];
frequencies_measured = frequencies;
load Parameters.mat

packet_detection_bump = 4;
max_zp_std = 0.5;
cfo_syms = 30;
QAMsize = 2;
num_packets = 1000;
packet_size = num_syms_preamble*num_bins + cp;
packet_size = packet_size + (num_syms_data/QAMsize)*(num_bins+cp);



%% Capture (flip switch ~15sec after "SSSSSSS" shows in tx terminal)
flag = 0;
offset1 = 0;
freqs = strcat([int2str(frequencies(1)),'e6,',int2str(frequencies(2)),'e6,',int2str(frequencies(3)),'e6']);


while flag == 0
    disp('capturing...');
        
    unix(strcat(['sudo python ',dir,'ttyexec.py pts/',txtty,' "sudo ', gtrdir,' --arg ',txips,' --rate 5e6 --multifreq ', freqs,' --ant TX/RX --ref EXTERNAL --tx_gain 20 --rx_gain 20"']));
    unix(strcat(['sudo python ',dir,'ttyexec.py pts/',rxtty,' "sudo ', gtrdir,' --arg ',rxips,' --rate 5e6 --multifreq ', freqs,' --ant TX/RX --ref EXTERNAL --tx_gain 20 --rx_gain 20"']));
    pause(10);%wait for usrps to start and lock
    
    urlread('http://192.168.1.4/30000/00'); %set to wire
    urlread('http://192.168.1.4/30000/15'); %turn on lna
    
    unix(strcat(['sudo python ',dir,'ttyexec.py pts/',txtty,' "tx ',dir,'OFDM_fakecfo 2 13e3"']));
    pause(1.3);
    unix(strcat(['sudo python ',dir,'ttyexec.py pts/',rxtty,' "rx ',dir,'rxdata/ 150000000"']));
    pause(14.4);
    
    urlread('http://192.168.1.4/30000/01'); %set to wireless
    pause(25);
    
    urlread('http://192.168.1.4/30000/14'); %turn off lna (it gets hot)
    urlread('http://192.168.1.4/30000/00'); %set to wire
    unix(strcat(['sudo python ',dir,'ttyexec.py pts/',txtty,' "quit"']));
    unix(strcat(['sudo python ',dir,'ttyexec.py pts/',rxtty,' "quit"']));

    % verify flip was correct

    rx_samples0 = read_complex_binary2(strcat([dir,'rxdata/_0.dat']),15e7,0);
    hfig = figure(1);
    set(hfig, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
    plot(real(rx_samples0(1:1e3:end)))

    resp = input('looks good?', 's');
    if strcmp(resp,'y') || strcmp(resp,'yes')
        figure(2)
        plot(real(rx_samples0(1:30e6)))
        resp = input('where to start?');
        if resp > 0.1 && resp < 3.0
            offset1 = resp*1e7;
            flag = 1;
            disp('okay, reading USRP files...');
        end
    end
    
end

rx_samples1 = read_complex_binary2(strcat([dir,'rxdata/_1.dat']),15e7,0);
rx_samples2 = read_complex_binary2(strcat([dir,'rxdata/_2.dat']),15e7,0);

rx_signal0 = rx_samples0.';
clear rx_samples0;
rx_signal1 = rx_samples1.';
clear rx_samples1;
rx_signal2 = rx_samples2.';
clear rx_samples2;

offset2 = offset1 + 64e6;

rx_signal(1,:) = rx_signal0(offset1:offset1+50e6);
rx_signal(4,:) = rx_signal0(offset2:offset2+50e6);
clear rx_signal0;
rx_signal(2,:) = rx_signal1(offset1:offset1+50e6);
rx_signal(5,:) = rx_signal1(offset2:offset2+50e6);
clear rx_signal1;
rx_signal(3,:) = rx_signal2(offset1:offset1+50e6);
rx_signal(6,:) = rx_signal2(offset2:offset2+50e6);
clear rx_signal2;


%% Packet Detection

disp('doing packet detection...')

pd0s = [packet_detection(rx_signal(1,:)),packet_detection(rx_signal(2,:)),packet_detection(rx_signal(3,:))];
pd1s = [packet_detection(rx_signal(4,:)),packet_detection(rx_signal(5,:)),packet_detection(rx_signal(5,:))];

% temp_packet_start0 = pd0s - median(pd0s);
% temp_packet_start1 = pd1s - median(pd1s);
% 
% for i = 1:length(pd0s)
%     if abs(temp_packet_start0(i)) > 100
%         disp('corrected packet start')
%         pd0s
%         pd0s(i) = ceil(mean(pd0s([1:i-1,i+1:end])));
%         pd0s
%     end
% end
% for i = 1:length(pd1s)
%     if abs(temp_packet_start1(i)) > 100
%         disp('corrected packet start')
%         pd1s
%         pd1s(i) = ceil(mean(pd1s([1:i-1,i+1:end])));
%         pd1s
%     end
% end
packet_start0 = ceil(mean(pd0s)) + packet_detection_bump;
packet_start1 = ceil(mean(pd1s)) + packet_detection_bump;

cfo_start0 = packet_start0 + ceil(cp/4) + 4;
cfo_start1 = packet_start1 + ceil(cp/4) + 4;

h_start0 = cfo_start0 + 94*num_bins;
h_start1 = cfo_start1 + 94*num_bins;


%% CFO

disp('doing rough cfo estimate...')

cfoi0 = zeros(1,2*num_packets);
cfoi1 = zeros(1,2*num_packets);
cfoi2 = zeros(1,2*num_packets);

%rough cfo estimate
for packeti = 1:num_packets
    start_index1 = cfo_start0 + (packeti-1)*packet_size;
    end_index1 = start_index1+((cfo_syms/2)*num_bins)-1;
    start_index2 = start_index1+((cfo_syms/2)*num_bins);
    end_index2 = start_index1+(cfo_syms*num_bins)-1;
    cfoi(1,packeti) = estimate_cfo(rx_signal(1,start_index1:end_index1),rx_signal(1,start_index2:end_index2),fs);
    cfoi(2,packeti) = estimate_cfo(rx_signal(2,start_index1:end_index1),rx_signal(2,start_index2:end_index2),fs);
    cfoi(3,packeti) = estimate_cfo(rx_signal(3,start_index1:end_index1),rx_signal(3,start_index2:end_index2),fs);
    
    start_index1 = cfo_start1 + (packeti-1)*packet_size;
    end_index1 = start_index1+((cfo_syms/2)*num_bins)-1;
    start_index2 = start_index1+((cfo_syms/2)*num_bins);
    end_index2 = start_index1+(cfo_syms*num_bins)-1;
    cfoi(4,packeti) = estimate_cfo(rx_signal(4,start_index1:end_index1),rx_signal(4,start_index2:end_index2),fs);
    cfoi(5,packeti) = estimate_cfo(rx_signal(5,start_index1:end_index1),rx_signal(5,start_index2:end_index2),fs);
    cfoi(6,packeti) = estimate_cfo(rx_signal(6,start_index1:end_index1),rx_signal(6,start_index2:end_index2),fs);
end

for i = 1:6
    rough_cfo(i) = mean(cfoi(i,:));
end
rough_cfo

disp('doing rough cfo correction...')

%rough cfo correction (1/2 because laptop runs out of memory...)
temp_signal(1,:) = correct_cfo(rx_signal(1,:), rough_cfo(1), fs, offset1);
temp_signal(2,:) = correct_cfo(rx_signal(2,:), rough_cfo(2), fs, offset1);
temp_signal(3,:) = correct_cfo(rx_signal(3,:), rough_cfo(3), fs, offset1);

%preliminary channel estimation (1/2 because laptop runs out of memory...)
for packeti = 1:num_packets
    start_index1 = h_start0 + (packeti-1)*packet_size;
    end_index1 = start_index1+num_bins-1;
    start_index2 = start_index1+num_bins;
    end_index2 = start_index1+2*num_bins-1;
    lr(1,packeti) = zero_subchannel_phase(estimate_channel(temp_signal(1,start_index1:end_index1),temp_signal(1,start_index2:end_index2)));
    lr(2,packeti) = zero_subchannel_phase(estimate_channel(temp_signal(2,start_index1:end_index1),temp_signal(2,start_index2:end_index2)));
    lr(3,packeti) = zero_subchannel_phase(estimate_channel(temp_signal(3,start_index1:end_index1),temp_signal(3,start_index2:end_index2)));
end

%rough cfo correction (2/2 because laptop runs out of memory...)
temp_signal(1,:) = correct_cfo(rx_signal(4,:), rough_cfo(4), fs, offset2);
temp_signal(2,:) = correct_cfo(rx_signal(5,:), rough_cfo(5), fs, offset2);
temp_signal(3,:) = correct_cfo(rx_signal(6,:), rough_cfo(6), fs, offset2);

%preliminary channel estimation (2/2 because laptop runs out of memory...)
for packeti = 1:num_packets
    start_index1 = h_start1 + (packeti-1)*packet_size;
    end_index1 = start_index1+num_bins-1;
    start_index2 = start_index1+num_bins;
    end_index2 = start_index1+2*num_bins-1;
    lr(4,packeti) = zero_subchannel_phase(estimate_channel(temp_signal(1,start_index1:end_index1),temp_signal(1,start_index2:end_index2)));
    lr(5,packeti) = zero_subchannel_phase(estimate_channel(temp_signal(2,start_index1:end_index1),temp_signal(2,start_index2:end_index2)));
    lr(6,packeti) = zero_subchannel_phase(estimate_channel(temp_signal(3,start_index1:end_index1),temp_signal(3,start_index2:end_index2)));
end

clear temp_signal;

disp('doing fine cfo estimate/correction...');

%fine cfo estimate
for si = 1:6
    coeffs = polyfit(1:1000,unwrap(lr(si,:)),1);
    slp = coeffs(1);
    fine_cfo(si) = (slp*1000) / (2*pi*9.28314);
end
fine_cfo

cfo(1) = mean([rough_cfo(1) + fine_cfo(1),rough_cfo(4) + fine_cfo(4)]);
cfo(2) = mean([rough_cfo(2) + fine_cfo(2),rough_cfo(5) + fine_cfo(5)]);
cfo(3) = mean([rough_cfo(3) + fine_cfo(3),rough_cfo(6) + fine_cfo(6)]);
cfo


%fine cfo correction
rx_signal(1,:) = correct_cfo(rx_signal(1,:), cfo(1), fs, offset1);
rx_signal(2,:) = correct_cfo(rx_signal(2,:), cfo(2), fs, offset1);
rx_signal(3,:) = correct_cfo(rx_signal(3,:), cfo(3), fs, offset1);
rx_signal(4,:) = correct_cfo(rx_signal(4,:), cfo(1), fs, offset2);
rx_signal(5,:) = correct_cfo(rx_signal(5,:), cfo(2), fs, offset2);
rx_signal(6,:) = correct_cfo(rx_signal(6,:), cfo(3), fs, offset2);



%% Channel

disp('doing channel estimation...');

for packeti = 1:num_packets
    start_index1 = h_start0 + (packeti-1)*packet_size;
    end_index1 = start_index1+num_bins-1;
    start_index2 = start_index1+num_bins;
    end_index2 = start_index1+2*num_bins-1;
    lr(1,packeti) = zero_subchannel_phase(estimate_channel(rx_signal(1,start_index1:end_index1),rx_signal(1,start_index2:end_index2)));
    lr(2,packeti) = zero_subchannel_phase(estimate_channel(rx_signal(2,start_index1:end_index1),rx_signal(2,start_index2:end_index2)));
    lr(3,packeti) = zero_subchannel_phase(estimate_channel(rx_signal(3,start_index1:end_index1),rx_signal(3,start_index2:end_index2)));
    
    start_index1 = h_start1 + (packeti-1)*packet_size;
    end_index1 = start_index1+num_bins-1;
    start_index2 = start_index1+num_bins;
    end_index2 = start_index1+2*num_bins-1;
    lr(4,packeti) = zero_subchannel_phase(estimate_channel(rx_signal(4,start_index1:end_index1),rx_signal(4,start_index2:end_index2)));
    lr(5,packeti) = zero_subchannel_phase(estimate_channel(rx_signal(5,start_index1:end_index1),rx_signal(5,start_index2:end_index2)));
    lr(6,packeti) = zero_subchannel_phase(estimate_channel(rx_signal(6,start_index1:end_index1),rx_signal(6,start_index2:end_index2)));
end

% lrm1 = mod(lr,2*pi);%should we do mod of mean or mean of mod??
% lrm2 = mod(lr+pi,2*pi)-pi;
% 
% for si = 1:6
%     zp1(si) = mod(mean(lrm1(si,:)),2*pi);
%     sd1(si) = std(lrm1(si,:));
%     zp2(si) = mod(mean(lrm2(si,:))+pi,2*pi)-pi;
%     sd2(si) = std(lrm2(si,:));
%     
%     if sd1(si) > max_zp_std && sd2(si) > max_zp_std
%         disp('Channel Estimation Error')
%         return
%     end
%     
%     if sd1 < sd2
%         zp(si) = zp1(si);
%     else
%         zp(si) = zp2(si);
%     end
% end

for si = 1:6
    zp(si) = mod(mean(lr(si,:)),2*pi);
    sp(si) = std(lr(si,:));
    
    if sp(si) > max_zp_std
        disp('Channel Estimation Error')
        return
    end
end

sp
zp

phases(1) = zp(1)-zp(4);
phases(2) = zp(2)-zp(5);
phases(3) = zp(3)-zp(6);

chinese_remainder(phases, frequencies_measured)













