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

frequencies = 2402:4:2478;
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
for run = 1:10
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
            h_start = cfo_start + 4*num_bins;



            %% Channel

            disp('doing channel estimation...');

            for ant = 1:num_ants+1
                ht = zeros(1,num_bins);
                for symboli = 2:5
                    firstpreamble = rx_signal((h_start + ((symboli-2)*num_bins)):(h_start + ((symboli-1)*num_bins) - 1));
                    secondpreamble = rx_signal((h_start + ((symboli-1)*num_bins)):(h_start + (symboli*num_bins) - 1));
                    ht = ht + estimate_channel(firstpreamble, secondpreamble);
                end
                h_each(ant,:) = fftshift(ht./4);
                h_start = h_start + ant_offset;
            end

            for ant = 1:num_ants+1
                h_each(ant,33) = mean([h_each(ant,32) h_each(ant,34)]);
            end
            h_cut(f,:,:) = h_each(:,[7:59]);
            h_save(run,f,:,:) = h_each(:,[7:59]);

%             figure(2)
%             subplot(2,1,1)
%             hold all
%             for ant = 2:num_ants+1
%                 plot(abs(squeeze(h_cut(f,ant,:))))
%             end
%             subplot(2,1,2)
%             hold all
%             for ant = 2:num_ants+1
%                 plot(unwrap(angle(squeeze(h_cut(f,ant,:)))))
%             end

%             resp = input('looks good?', 's');
%             if strcmp(resp,'y') || strcmp(resp,'yes')
%                 flag=1;
%             end
            flag = 1;
            
            close all
        end
    end
end

h_cald = h_cut(:,[2:num_ants+1],:);
for i = 1:num_ants
    h_cald(:,i,:) = exp(1i*(angle(h_cald(:,i,:))-angle(h_cut(:,1,:))));
end
h_cald_zeros = squeeze(h_cald(:,:,33)).';



h = channel_stitching(h_cut(:,[2:num_ants+1],:));

for i = 1:num_ants
    for j = 1:length(h)
        h(i,j) = exp(1i*angle(h(i,j)));
    end
end

s=robustfit(1:size(h,2),phase(h(4,:)));
s(2)=s(2)+0.01;
for i=1:num_ants
    h(i,:)=h(i,:).*exp(-1j*s(2)*[1:length(h(i,:))]);
end






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


freq =  [(frequencies(1)-2):((frequencies(end)-frequencies(1)+4)/(length(h)-1)):(frequencies(end)+2)]*1e6;
spacing = 0.0625;
theta_vals_m = (1:1:180)*pi/180;
theta_vals_s = (-90:1:90)*pi/180;
d_vals = -10:0.2:100;

%zero subchannels before stitching
% freq2 = freq([33:num_bins:length(freq)]);
% h2 = h_cut(:,:,33).';

%first sample before stitching
% freq2 = freq([1:num_bins:length(freq)]);
% h2 = h_cut(:,:,1).';

% zero subchannels
% freq2 = freq([5:(length(freq)/length(frequencies)):length(freq)]);
% h2 = h(:,[5:(length(freq)/length(frequencies)):length(freq)]);

%first sample
% freq2 = freq([3:num_bins:length(freq)]);
% h2 = h(:,[3:num_bins:length(freq)]);

%first channel
% freq2 = freq([1:52]);
% h2 = h(:,[1:52]);

%all
% freq2 = freq;
% h2 = h;

%subsample
freq2 = freq(1:8:end-4);
h2 = h(:,1:8:end-4);


opt.threshold = 0.01; opt.freq = freq2; opt.ant_sep = spacing;
P = compute_spotfi_profile(h2, theta_vals_s, d_vals, opt);
%figure; meshc(d_vals, theta_vals_s*180/pi, abs(P));
figure; imagesc(d_vals, theta_vals_s*180/pi, abs(P));

[maxvals,indices] = max(P);
[maxval,index] = max(maxvals);

max_angle = indices(index);
max_delay = index;
max_val = P(max_angle, max_delay)
max_delay = d_vals(max_delay)
max_angle = theta_vals_s(max_angle)/pi*180



opt.threshold = 0.01; opt.freq = frequencies*1e6; opt.ant_sep = spacing;
P = compute_spotfi_profile(h_cald_zeros, theta_vals_s, d_vals, opt);
figure; imagesc(d_vals, theta_vals_s*180/pi, abs(P));




figure(123)
hold all
for i=1
    pro = compute_distance_profile_music(h(i,:), 3e8./freq, 2, [0:0.1:50]);
    plot(abs(pro))
end


figure(124)
hold all
for i=1:num_ants
    pro = compute_distance_profile_music(h_cald_zeros(i,:), 3e8./(frequencies*1e6), 2, [0:0.1:50]);
    plot(abs(pro))
end
