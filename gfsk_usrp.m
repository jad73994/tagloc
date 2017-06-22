clear
close all

%% Parameters
num_antennas = 4;
Fs = 5e6;   % Sample rate (Hz)
channel_width = 2e6;
freqsep = channel_width;
nsamp = Fs/1e6;    % Number of samples per symbol
num_syms = 1000;
num_bins = 500;
preamble = [1,0,1,1,0,1,1,1,0];

txtty = '4';
rxtty = '3';
dir = '/home/abari/Desktop/tagloc/';
gtrdir = '/home/abari/Projects/RFIT/uhd/host/build/mmimo/general_tx_rx';

txips = 'addr0=192.168.30.2,addr1=192.168.40.2,addr2=192.168.50.2';
rxips = 'addr0=192.168.60.2,addr1=192.168.70.2,addr2=192.168.80.2';
frequencies = [916, 918, 920];


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
    
    
    while flag == 0
        
        freqstr = strcat([int2str(frequencies(channel)),'e6,',int2str(frequencies(channel)),'e6,',int2str(frequencies(channel)),'e6']);
        unix(strcat(['sudo python ',dir,'ttyexec.py pts/',txtty,' "sudo ', gtrdir,' --arg ',txips,' --rate ',int2str(Fs/1e6),'e6 --multifreq ',freqstr,' --ant TX/RX --ref EXTERNAL --tx_gain 20 --rx_gain 20"']));
        unix(strcat(['sudo python ',dir,'ttyexec.py pts/',rxtty,' "sudo ', gtrdir,' --arg ',rxips,' --rate ',int2str(Fs/1e6),'e6 --multifreq ',freqstr,' --ant TX/RX --ref EXTERNAL --tx_gain 20 --rx_gain 20"']));

        control_relays('usrp');
        control_relays('cal');
        control_relays('lnaon');
        control_relays('rcv1');

        pause(8);%wait for usrps to start and lock

        unix(strcat(['sudo python ',dir,'ttyexec.py pts/',rxtty,' "rx ',dir,'rxdata/ 20000000"']));
        pause(0.1);
        unix(strcat(['sudo python ',dir,'ttyexec.py pts/',txtty,' "tx ',dir,'gfsksig 30 1e2"']));

        pause(0.5);
        control_relays('rcv2');
        pause(0.5);
        control_relays('rcv3');
        pause(0.5);
        control_relays('rcv4');

        pause(10);
        unix(strcat(['sudo python ',dir,'ttyexec.py pts/',txtty,' "quit"']));
        unix(strcat(['sudo python ',dir,'ttyexec.py pts/',rxtty,' "quit"']));
        control_relays('vna');
        control_relays('rcvnone');
        control_relays('cal');
        control_relays('lnaoff');


        y_gfsk = read_complex_binary2(strcat([dir,'rxdata/_0.dat']),2e7,0);

        figure
        plot(real(y_gfsk))

        %% Packet Detection

        pd = gfsk_packet_detection(y_gfsk(1:1e6));
        pdspace = 35e5;

        %% Channel Estimation

        for ant = 1:4
            [h_xx(ant,:) h_yy(ant,:)] = gfsk_estimate_channel(y_gfsk(pd+(ant-1)*pdspace:pd+num_syms*nsamp+1e3+(ant-1)*pdspace-1));
        end

        lval = max([h_xx(1,1),h_xx(2,1),h_xx(3,1),h_xx(4,1),(1.5/5)*6000]);
        hval = min([h_xx(1,length(h_xx(1,:))),h_xx(2,length(h_xx(2,:))),h_xx(3,length(h_xx(3,:))),h_xx(4,length(h_xx(4,:))),(3.5/5)*6000]);

        for ant=1:4
            jc(ant,:) = dsearchn(h_xx(ant,:).',[lval:(hval-lval)/29:hval].');
            freqs(ant,:) = h_xx(ant,jc(1,:));
            h_cut(ant,:) = h_yy(ant,jc(ant,:));
        end

        figure
        subplot(2,1,1)
        hold all
        for i=1:4
            plot(abs(h_cut(i,:)))
        end
        subplot(2,1,2)
        hold all
        for i=1:4
            plot(unwrap(angle(h_cut(i,:))))
        end
        
        resp = input('looks good?', 's');
        if strcmp(resp,'y') || strcmp(resp,'yes')
            flag = 1;
        end
    end

    h_final(channel,:,:) = h_cut;
end

h_final = gfsk_channel_stitching(h_final);
h_final_subsampled = h_final(:,1:(length(h_final)-1)/29:length(h_final));

figure
subplot(4,1,1)
plot(unwrap(angle(h_final(1,:))))
subplot(4,1,2)
plot(unwrap(angle(h_final(2,:))))
subplot(4,1,3)
plot(unwrap(angle(h_final(3,:))))
subplot(4,1,4)
plot(unwrap(angle(h_final(4,:))))


freq =  [915:6/29:921]*1e6;
spacing = 0.5 * 0.1224;
ant_pos = spacing * [0:num_antennas-1];
theta_vals_m = (1:1:180)*pi/180;
theta_vals_s = (-90:1:90)*pi/180;
d_vals = -50:1:50;

opt.threshold = 0.01; opt.freq = freq; opt.ant_sep = spacing;
P = compute_spotfi_profile(h_final_subsampled, theta_vals_s, d_vals, opt);
figure; imagesc(d_vals, theta_vals_s*180/pi, abs(P));

[maxvals,indices] = max(P);
[maxval,index] = max(maxvals);

max_angle = indices(index);
max_delay = index;
max_val = P(max_angle, max_delay)
max_delay = d_vals(max_delay)
max_angle = theta_vals_s(max_angle)/pi*180
