clear
close all


%% Script Parameters
txtty = '4';
rxtty = '3';

dir = '/home/abari/Desktop/tagloc/';
gtrdir = '/home/abari/Projects/RFIT/uhd/host/build/mmimo/general_tx_rx';

txips = 'addr0=192.168.30.2,addr1=192.168.40.2,addr2=192.168.50.2';
rxips = 'addr0=192.168.60.2,addr1=192.168.70.2,addr2=192.168.80.2';

frequencies = [907,919,923];
%frequencies_measured = [719.9725,829.6375,939.8875];
frequencies_measured = frequencies;
load Parameters.mat

packet_detection_bump = 4;
max_zp_std = 0.5;
cfo_syms = 36;
QAMsize = 2;
num_packets = 1000;
packet_size = num_syms_preamble*num_bins + cp;
packet_size = packet_size + (num_syms_data/QAMsize)*(num_bins+cp);

usevna = 0;
vnapoints = 1601;
vnastart = 700;
vnaend = 1000;
instrreset
vna = Vna('model', Vna.MODEL_AGILENT_E5071C, 'iface', Instr.INSTR_IFACE_TCPIP, 'tcpipAddress', '192.168.128.1', 'tcpipPort', 5025 );
vna.SetTriggerContinuous;
%set to 600MHz - 1000MHz


%% Capture
flag = 0;
offset1 = 0;
punt = 0;
freqs = strcat([int2str(frequencies(1)),'e6,',int2str(frequencies(2)),'e6,',int2str(frequencies(3)),'e6']);


while flag == 0
    disp('capturing...');
        
    unix(strcat(['sudo python ',dir,'ttyexec.py pts/',txtty,' "sudo ', gtrdir,' --arg ',txips,' --rate 5e6 --multifreq ', freqs,' --ant TX/RX --ref EXTERNAL --tx_gain 20 --rx_gain 20"']));
    unix(strcat(['sudo python ',dir,'ttyexec.py pts/',rxtty,' "sudo ', gtrdir,' --arg ',rxips,' --rate 5e6 --multifreq ', freqs,' --ant TX/RX --ref EXTERNAL --tx_gain 20 --rx_gain 20"']));
    pause(10);%wait for usrps to start and lock
    
    control_relays('usrp');
    control_relays('cal');
    control_relays('lnaon');
    control_relays('rcv1');
    
    unix(strcat(['sudo python ',dir,'ttyexec.py pts/',txtty,' "tx ',dir,'OFDM_fakecfo 2 13e3"']));
    unix(strcat(['sudo python ',dir,'ttyexec.py pts/',rxtty,' "rx ',dir,'rxdata/ 150000000"']));
    
    pause(0.5);
    pause(3.5);
    control_relays('rcv2');
    pause(3.5);
    control_relays('rcv3');
    pause(3.5);
    control_relays('rcv4');
    pause(3.5);
    pause(0.5);
    
    control_relays('test');
    control_relays('rcv1');
    
    pause(0.5);
    pause(3.5);
    control_relays('rcv2');
    pause(3.5);
    control_relays('rcv3');
    pause(3.5);
    control_relays('rcv4');
    pause(3.5);
    pause(0.5);
    
    pause(10);
    unix(strcat(['sudo python ',dir,'ttyexec.py pts/',txtty,' "quit"']));
    unix(strcat(['sudo python ',dir,'ttyexec.py pts/',rxtty,' "quit"']));
    
    
    control_relays('vna');
    control_relays('rcvnone');
    
    if usevna == 1
        control_relays('cal');
        pause(0.2);

        calvna = zeros(1,vnapoints);
        testvna = zeros(1,vnapoints);

        for i = 1:10
            [vnax, ~, ~, vnay]=vna.GetTraceData('Tr1');
            calvna = calvna + angle(vnay);
            pause(0.2);
        end

        control_relays('test');
        pause(0.2);

        for vnai = 11:20
            [vnax, ~, ~, vnay]=vna.GetTraceData('Tr1');
            testvna = testvna + angle(vnay);
            pause(0.2);
        end

        calvna = calvna ./ 10;
        testvna = testvna ./ 10;
    end
    
    control_relays('cal');
    control_relays('lnaoff');

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

rx_signal(1,:) = rx_signal0(offset1:(offset1+50e6));
rx_signal(4,:) = rx_signal0(offset2:(offset2+50e6));
clear rx_signal0;
rx_signal(2,:) = rx_signal1(offset1:(offset1+50e6));
rx_signal(5,:) = rx_signal1(offset2:(offset2+50e6));
clear rx_signal1;
rx_signal(3,:) = rx_signal2(offset1:(offset1+50e6));
rx_signal(6,:) = rx_signal2(offset2:(offset2+50e6));
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
    lr_p(1,packeti) = zero_subchannel_phase(estimate_channel(temp_signal(1,start_index1:end_index1),temp_signal(1,start_index2:end_index2)));
    lr_p(2,packeti) = zero_subchannel_phase(estimate_channel(temp_signal(2,start_index1:end_index1),temp_signal(2,start_index2:end_index2)));
    lr_p(3,packeti) = zero_subchannel_phase(estimate_channel(temp_signal(3,start_index1:end_index1),temp_signal(3,start_index2:end_index2)));
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
    lr_p(4,packeti) = zero_subchannel_phase(estimate_channel(temp_signal(1,start_index1:end_index1),temp_signal(1,start_index2:end_index2)));
    lr_p(5,packeti) = zero_subchannel_phase(estimate_channel(temp_signal(2,start_index1:end_index1),temp_signal(2,start_index2:end_index2)));
    lr_p(6,packeti) = zero_subchannel_phase(estimate_channel(temp_signal(3,start_index1:end_index1),temp_signal(3,start_index2:end_index2)));
end

clear temp_signal;

disp('doing fine cfo estimate/correction...');

%fine cfo estimate
for si = 1:6
    coeffs = polyfit(1:1000,unwrap(lr_p(si,:)),1);
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

for si = 1:6
    zp(si) = mod(mean(unwrap(lr(si,:))),2*pi);
    sp(si) = std(unwrap(lr(si,:)));
    
    if sp(si) > max_zp_std
        disp('Channel Estimation Error')
        punt = 1;
    end
end

sp

if punt == 0
    phases(1) = zp(1)-zp(4);
    phases(2) = zp(2)-zp(5);
    phases(3) = zp(3)-zp(6);

    phases
    
    chinese_remainder(phases, frequencies_measured)
end




%% Debugging
resp = 'y';
while ~strcmp(resp, 'n')
    resp = input('Debug? (pd, cfo, rss, zp, vna)', 's');
    
    if strcmp(resp,'rss')
        figure(3)
        subplot(3,2,1)
        plot(abs(rx_signal(1,1:1e2:end)))
        subplot(3,2,2)
        plot(abs(rx_signal(4,1:1e2:end)))
        subplot(3,2,3)
        plot(abs(rx_signal(2,1:1e2:end)))
        subplot(3,2,4)
        plot(abs(rx_signal(5,1:1e2:end)))
        subplot(3,2,5)
        plot(abs(rx_signal(3,1:1e2:end)))
        subplot(3,2,6)
        plot(abs(rx_signal(6,1:1e2:end)))
    end

    if strcmp(resp,'pd')
        pd0s
        pd1s
        
        figure(4)
        subplot(3,2,1)
        plot(abs(rx_signal(1,[(packet_start0-100):(packet_start0+100)])))
        subplot(3,2,2)
        plot(abs(rx_signal(4,[(packet_start1-100):(packet_start1+100)])))
        subplot(3,2,3)
        plot(abs(rx_signal(2,[(packet_start0-100):(packet_start0+100)])))
        subplot(3,2,4)
        plot(abs(rx_signal(5,[(packet_start1-100):(packet_start1+100)])))
        subplot(3,2,5)
        plot(abs(rx_signal(3,[(packet_start0-100):(packet_start0+100)])))
        subplot(3,2,6)
        plot(abs(rx_signal(6,[(packet_start1-100):(packet_start1+100)])))
    end

    if strcmp(resp,'cfo')
        resp = input('Which file? (0, 1, 2)', 's');
        disp('reading files...');
        rx_sample = read_complex_binary2(strcat([dir,'rxdata/_', resp, '.dat']),15e7,0);

        rx_signal_temp = rx_sample.';
        clear rx_sample;

        rx_signal1 = rx_signal_temp(offset1:(offset1+50e6));
        rx_signal2 = rx_signal_temp(offset2:(offset2+50e6));
        
        for cfo_syms = 2:2:96
            cfoi1 = zeros(1,num_packets);
            cfoi2 = zeros(1,num_packets);

            %rough cfo estimate
            for packeti = 1:num_packets
                start_index1 = cfo_start0 + (packeti-1)*packet_size;
                end_index1 = start_index1+((cfo_syms/2)*num_bins)-1;
                start_index2 = start_index1+((cfo_syms/2)*num_bins);
                end_index2 = start_index1+(cfo_syms*num_bins)-1;
                cfoi1(packeti) = estimate_cfo(rx_signal1(start_index1:end_index1),rx_signal1(start_index2:end_index2),fs);

                start_index1 = cfo_start1 + (packeti-1)*packet_size;
                end_index1 = start_index1+((cfo_syms/2)*num_bins)-1;
                start_index2 = start_index1+((cfo_syms/2)*num_bins);
                end_index2 = start_index1+(cfo_syms*num_bins)-1;
                cfoi2(packeti) = estimate_cfo(rx_signal2(start_index1:end_index1),rx_signal2(start_index2:end_index2),fs);
            end

            cfot1(cfo_syms) = mean(cfoi1);
            cfot2(cfo_syms) = mean(cfoi2);
        end
        
        figure(5)
        subplot(1,2,1)
        plot(2:2:96,cfot1(2:2:96))
        subplot(1,2,2)
        plot(2:2:96,cfot2(2:2:96))
    end
    
    if strcmp(resp,'zp')
        resp = input('Final or preliminary? (f, p)', 's');
        
        if strcmp(resp,'f')
            lrn = lr;
        end
        if strcmp(resp,'p')
            lrn = lr_p;
        end
        
        figure(6)
        subplot(3,2,1)
        plot(unwrap(lrn(1,:)))
        subplot(3,2,2)
        plot(unwrap(lrn(4,:)))
        subplot(3,2,3)
        plot(unwrap(lrn(2,:)))
        subplot(3,2,4)
        plot(unwrap(lrn(5,:)))
        subplot(3,2,5)
        plot(unwrap(lrn(3,:)))
        subplot(3,2,6)
        plot(unwrap(lrn(6,:)))
    end
    
    if strcmp(resp,'vna')
        ftovna = round(((frequencies_measured - vnastart) ./ (vnaend-vnastart)) * vnapoints);
        phases(1) = calvna(ftovna(1))-testvna(ftovna(1));
        phases(2) = calvna(ftovna(2))-testvna(ftovna(2));
        phases(3) = calvna(ftovna(3))-testvna(ftovna(3));
    
        ftovna
        phases
    
        close all
        chinese_remainder(phases, frequencies_measured)        
    end
end








