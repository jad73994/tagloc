clear
close all

load Parameters.mat

%% Script Parameters
txtty = '4';
rxtty = '3';
dir = '/home/abari/Desktop/tagloc/';
gtrdir = '/home/abari/Projects/RFIT/uhd/host/build/mmimo/general_tx_rx';
txips = 'addr0=192.168.30.2,addr1=192.168.40.2,addr2=192.168.50.2';
rxips = 'addr0=192.168.60.2,addr1=192.168.70.2,addr2=192.168.80.2';

frequencies = 2400:5:2425;
max_zp_std = 0.5;
cfo_syms = 36;
QAMsize = 2;
num_ants = 4;

packet_size = num_syms_preamble*num_bins + cp;
packet_size = packet_size + (num_syms_data/QAMsize)*(num_bins+cp);
packet_offset_ms = 300;
packet_offset = (packet_offset_ms/1e3) * fs;
ant_offset = packet_offset * 5;

save Parameters.mat
save tools/Parameters.mat





%% Capture

for f = 1:length(frequencies)
    flag = 0;
    while flag == 0
        disp('capturing...');
        freq = strcat([int2str(frequencies(f)),'e6,',int2str(frequencies(f)),'e6,',int2str(frequencies(f)),'e6']);

        unix(strcat(['sudo python ',dir,'ttyexec.py pts/',txtty,' "sudo ', gtrdir,' --arg ',txips,' --rate 5e6 --multifreq ', freq,' --ant TX/RX --ref EXTERNAL --tx_gain 20 --rx_gain 20"']));
        unix(strcat(['sudo python ',dir,'ttyexec.py pts/',rxtty,' "sudo ', gtrdir,' --arg ',rxips,' --rate 5e6 --multifreq ', freq,' --ant TX/RX --ref EXTERNAL --tx_gain 20 --rx_gain 20"']));

        control_relays('cal');
        control_relays('lnaon');
        control_relays('rcv1');
        
        pause(8);%wait for usrps to start and lock
        
        unix(strcat(['sudo python ',dir,'ttyexec.py pts/',txtty,' "tx ',dir,'OFDM_fakecfo 80 "',int2str(packet_offset_ms)]));
        pause(2.5);
        unix(strcat(['sudo python ',dir,'ttyexec.py pts/',rxtty,' "rx ',dir,'rxdata/ 50000000"']));

        pause(2);
        control_relays('test');
        pause(1);
        control_relays('rcv2');
        pause(1);
        control_relays('rcv3');
        pause(1);
        control_relays('rcv4');
        
        pause(10);
        
        control_relays('rcvnone');
        control_relays('lnaoff');
        
        unix(strcat(['sudo python ',dir,'ttyexec.py pts/',txtty,' "quit"']));
        unix(strcat(['sudo python ',dir,'ttyexec.py pts/',rxtty,' "quit"']));

        rx_signal = read_complex_binary2(strcat([dir,'rxdata/_0.dat']),5e7,0);
        rx_signal = rx_signal.';
        
        figure(1)
        plot(real(rx_signal(1:1e3:end)))


        %% Packet Detection

        disp('doing packet detection...')

        tx_signal = read_complex_binary2(strcat(dir,'OFDM_fakecfo_0.dat'));
        packet_start = gfsk_packet_detection(rx_signal(1:6e6),tx_signal(1e6:end));
        cfo_start = packet_start + ceil(cp/4) + 4; 
        h_start = cfo_start + 94*num_bins;



        %% Channel

        disp('doing channel estimation...');

        for ant = 1:num_ants
            ht = zeros(1,num_bins);
            for symboli = 2:5
                firstpreamble = rx_signal((h_start + ((symboli-2)*num_bins)):(h_start + ((symboli-1)*num_bins) - 1));
                secondpreamble = rx_signal((h_start + ((symboli-1)*num_bins)):(h_start + (symboli*num_bins) - 1));
                ht = ht + estimate_channel(firstpreamble, secondpreamble);
            end
            h_each(ant,:) = fftshift(ht./4);
            h_start = h_start + ant_offset;
        end
        
        for ant = 1:num_ants
            h_each(ant,33) = mean([h_each(ant,32) h_each(ant,34)]);
        end
        h_cut(f,:,:) = h_each(:,[7:59]);

        figure(2)
        subplot(2,1,1)
        hold all
        for ant = 1:num_ants
            plot(abs(squeeze(h_cut(f,ant,:))))
        end
        subplot(2,1,2)
        hold all
        for ant = 1:num_ants
            plot(unwrap(angle(squeeze(h_cut(f,ant,:)))))
        end
    
        resp = input('looks good?', 's');
        if strcmp(resp,'y') || strcmp(resp,'yes')
            flag=1;
        end
        close all
    end
end

h = channel_stitching(h_cut);

figure(3)
ax1=subplot(3,1,1)
hold all
for ant = 1:num_ants
    plot(abs(h(ant,:)))
end
ax2=subplot(3,1,2)
hold all
for ant = 1:num_ants
    plot(unwrap(angle(h(ant,:))))
end
ax3=subplot(3,1,3)
hold all
for ant = 1:num_ants
    plot(angle(h(ant,:)))
end
linkaxes([ax1,ax2,ax3],'x')


freq =  [frequencies(1)-2:(frequencies(end)-frequencies(1))/length(h):frequencies(end)+2]*1e6;
spacing = 0.0625;
theta_vals_m = (1:1:180)*pi/180;
theta_vals_s = (-90:1:90)*pi/180;
d_vals = 1:0.1:30;

opt.threshold = 0.01; opt.freq = freq; opt.ant_sep = spacing;
P = compute_spotfi_profile(h.', theta_vals_s, d_vals, opt);
figure; imagesc(d_vals, theta_vals_s*180/pi, abs(P));

[maxvals,indices] = max(P);
[maxval,index] = max(maxvals);

max_angle = indices(index);
max_delay = index;
max_val = P(max_angle, max_delay)
max_delay = d_vals(max_delay)
max_angle = theta_vals_s(max_angle)/pi*180

% 
% figure(123)
% hold all
% for i=1:num_ants
%     pro = compute_distance_profile_music(h(i,:), 3e8./freq, 2, [0:0.1:50]);
%     plot(abs(pro))
% end


