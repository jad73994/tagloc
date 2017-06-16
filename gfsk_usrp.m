clear
close all

%% Parameters
Fs = 5e6;   % Sample rate (Hz)
channel_width = 2e6;
freqsep = channel_width/4;
nsamp = Fs/1e6;    % Number of samples per symbol
num_syms = 1000;
num_bins = 500;
preamble = [1,0,1,1,0,1,1,1,0];
save gfsk_Parameters.mat
save tools/gfsk_parameters.mat

txtty = '4';
rxtty = '3';
dir = '/home/abari/Desktop/tagloc/';
gtrdir = '/home/abari/Projects/RFIT/uhd/host/build/mmimo/general_tx_rx';

txips = 'addr0=192.168.30.2,addr1=192.168.40.2,addr2=192.168.50.2';
rxips = 'addr0=192.168.60.2,addr1=192.168.70.2,addr2=192.168.80.2';
frequency = '915e6,915e6';




%% Data
x = zeros(1, num_syms);
for i=1:length(preamble)
    x(i:length(preamble):end) = preamble(i);
end

%% Modulation
y_gfsk = gfsk_modulate(x).';
y_gfsk = [zeros(1,nsamp*100) y_gfsk zeros(1,nsamp*100)];
y_gfsk = y_gfsk.';


%% Channel

write_complex_binary(y_gfsk, strcat([dir,'/gfsksig_0.dat']));
write_complex_binary(y_gfsk, strcat([dir,'/gfsksig_1.dat']));
write_complex_binary(y_gfsk, strcat([dir,'/gfsksig_2.dat']));

unix(strcat(['sudo python ',dir,'ttyexec.py pts/',txtty,' "sudo ', gtrdir,' --arg ',txips,' --rate 5e6 --multifreq ', frequency,' --ant TX/RX --ref EXTERNAL --tx_gain 20 --rx_gain 20"']));
unix(strcat(['sudo python ',dir,'ttyexec.py pts/',rxtty,' "sudo ', gtrdir,' --arg ',rxips,' --rate 5e6 --multifreq ', frequency,' --ant TX/RX --ref EXTERNAL --tx_gain 20 --rx_gain 20"']));

control_relays('usrp');
control_relays('cal');
control_relays('lnaon');
control_relays('rcv1');

pause(10);%wait for usrps to start and lock
    
unix(strcat(['sudo python ',dir,'ttyexec.py pts/',rxtty,' "rx ',dir,'rxdata/ 20000000"']));
pause(0.1);
unix(strcat(['sudo python ',dir,'ttyexec.py pts/',txtty,' "tx ',dir,'gfsksig 40 1e2"']));

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
    h_xx_sum = zeros(1,num_bins);
    h_yy_sum = zeros(1,num_bins);
    num_preambles = 10;
    for i=1:50
        [h_xx h_yy] = gfsk_estimate_channel(y_gfsk(pd+pdspace*(ant-1)+i*num_preambles*length(preamble)*nsamp:pd+pdspace*(ant-1)-1+(i+1)*num_preambles*length(preamble)*nsamp));

        for k=1:length(h_xx)
            if h_xx(k) > num_bins*(1/5)
                if h_xx(k) < num_bins*(4/5)
                    h_xx_sum(h_xx(k)) = h_xx_sum(h_xx(k)) + 1;
                    h_yy_sum(h_xx(k)) = h_yy_sum(h_xx(k)) + h_yy(k);
                end
            end
        end
    end

    j = 1;
    for i=1:length(h_xx_sum)
        if h_xx_sum(i) > 3
            h_final_x(ant,j) = i;
            h_final_y(ant,j) = h_yy_sum(i)/h_xx_sum(i);
            j = j + 1;
        end
    end
    
    h_final_r(ant,:) = interp1(h_final_x(ant,:), real(h_final_y(ant,:)), num_bins*(1/5):num_bins*(4/5));
    h_final_i(ant,:) = interp1(h_final_x(ant,:), imag(h_final_y(ant,:)), num_bins*(1/5):num_bins*(4/5));
    h_final(ant,:) = h_final_r(ant,:) + 1i*h_final_i(ant,:);
end

figure
plot(num_bins*(1/5):num_bins*(4/5), abs(h_final(1,:)))

figure
plot(num_bins*(1/5):num_bins*(4/5), unwrap(angle(h_final(1,:))))
