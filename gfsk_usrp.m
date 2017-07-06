clear
close all

%% Parameters
num_antennas = 4;
Fs = 5e6;   % Sample rate (Hz)
channel_width = 2e5;
freqsep = channel_width;
nsamp = Fs/1e5;    % Number of samples per symbol
num_syms = 2000;
preamble = [ones(1,20) zeros(1,20)];
filter_delay = nsamp*0.2;

txtty = '4';
rxtty = '3';
dir = '/home/abari/Desktop/tagloc/';
gtrdir = '/home/abari/Projects/RFIT/uhd/host/build/mmimo/general_tx_rx';

txips = 'addr0=192.168.30.2,addr1=192.168.40.2,addr2=192.168.50.2';
rxips = 'addr0=192.168.60.2,addr1=192.168.70.2,addr2=192.168.80.2';
frequencies = 2400:4:2444;


save gfsk_Parameters.mat
save tools/gfsk_parameters.mat


%% Data
x = zeros(1, num_syms);
for i=1:length(preamble)
    x(i:length(preamble):end) = preamble(i);
end

%% Modulation
x_gfsk = gfsk_modulate(x).';
x_gfsk = [zeros(1,nsamp*100) x_gfsk zeros(1,nsamp*100)];
x_gfsk = (0.5*x_gfsk).';


%% Channel

write_complex_binary(x_gfsk, strcat([dir,'/gfsksig_0.dat']));
write_complex_binary(x_gfsk, strcat([dir,'/gfsksig_1.dat']));
write_complex_binary(x_gfsk, strcat([dir,'/gfsksig_2.dat']));

for channel=1:length(frequencies)
    flag = 0;
    
    
    %while flag == 0
        close all
        try
            freqstr = strcat([int2str(frequencies(channel)),'e6,',int2str(frequencies(channel)),'e6,',int2str(frequencies(channel)),'e6']);
            unix(strcat(['sudo python ',dir,'ttyexec.py pts/',txtty,' "sudo ', gtrdir,' --arg ',txips,' --rate ',int2str(Fs/1e6),'e6 --multifreq ',freqstr,' --ant TX/RX --ref EXTERNAL --tx_gain 20 --rx_gain 20"']));
            unix(strcat(['sudo python ',dir,'ttyexec.py pts/',rxtty,' "sudo ', gtrdir,' --arg ',rxips,' --rate ',int2str(Fs/1e6),'e6 --multifreq ',freqstr,' --ant TX/RX --ref EXTERNAL --tx_gain 20 --rx_gain 20"']));

            control_relays('cal');
            control_relays('lnaon');
            control_relays('rcv1');

            pause(8);%wait for usrps to start and lock

            unix(strcat(['sudo python ',dir,'ttyexec.py pts/',rxtty,' "rx ',dir,'rxdata/ 20000000"']));
            pause(0.1);
            unix(strcat(['sudo python ',dir,'ttyexec.py pts/',txtty,' "tx ',dir,'gfsksig 80 5e1"']));

            pause(0.5);
            control_relays('test');
            pause(0.5);
            control_relays('rcv2');
            pause(0.5);
            control_relays('rcv3');
            pause(0.5);
            control_relays('rcv4');

            pause(10);
            control_relays('rcvnone');
            control_relays('lnaoff');
            unix(strcat(['sudo python ',dir,'ttyexec.py pts/',txtty,' "quit"']));
            unix(strcat(['sudo python ',dir,'ttyexec.py pts/',rxtty,' "quit"']));


            y_gfsk = read_complex_binary2(strcat([dir,'rxdata/_0.dat']),2e7,0);

            figure(1)
            plot(real(y_gfsk))

            %% Packet Detection

            pd = gfsk_packet_detection(y_gfsk(1:1e6), x_gfsk((100*nsamp):(end-(100*nsamp))));
            pdspace = 35e5;

            %% Channel Estimation
            
            h_cal(channel) = gfsk_partial_channel_estimate(y_gfsk(pd:(pd+(num_syms*nsamp)+1e3-1)));

            for ant = 2:(num_antennas+1)
                h_final(channel,ant-1) = gfsk_partial_channel_estimate(y_gfsk(pd+(ant-1)*pdspace:pd+num_syms*nsamp+1e3+(ant-1)*pdspace-1))./h_cal(channel);
            end
        
%             resp = input('looks good?', 's');
%             if strcmp(resp,'y') || strcmp(resp,'yes')
%                 flag = 1;
%             end
        catch
            warning('something broke')
        end
%     end
end


freq =  frequencies*1e6;
spacing = 0.0625;
theta_vals_m = (1:1:180)*pi/180;
theta_vals_s = (-90:1:90)*pi/180;
d_vals = 1:0.1:30;

opt.threshold = 0.01; opt.freq = freq; opt.ant_sep = spacing;
P = compute_spotfi_profile(h_final.', theta_vals_s, d_vals, opt);
figure; imagesc(d_vals, theta_vals_s*180/pi, abs(P));

[maxvals,indices] = max(P);
[maxval,index] = max(maxvals);

max_angle = indices(index);
max_delay = index;
max_val = P(max_angle, max_delay)
max_delay = d_vals(max_delay)
max_angle = theta_vals_s(max_angle)/pi*180


figure(123)
hold all
for i=1:num_antennas
    pro = compute_distance_profile_music(h_final(:,i), 3e8./freq, 2, [0:0.1:50]);
    plot(abs(pro))
end
