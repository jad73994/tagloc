clear
close all

%% Parameters
Fs = 10e6;   % Sample rate (Hz)
channel_width = 2e6;
freqsep = channel_width/4;
nsamp = Fs/1e6;    % Number of samples per symbol
num_syms = 1000;
num_bins = 500;
preamble = [1,0,1,1,0,1,1,1,0];
save gfsk_Parameters.mat
save tools/gfsk_parameters.mat


%% Data
x = zeros(1, num_syms);
for i=1:length(preamble)
    x(i:length(preamble):end) = preamble(i);
end

%% Modulation
y_gfsk = gfsk_modulate(x).';
y_gfsk = [zeros(1,nsamp*100) y_gfsk zeros(1,nsamp*100)];
y_gfsk = y_gfsk.';


% Channel
y_gfsk = awgn(y_gfsk, 100);


%% Packet Detection

pd = gfsk_packet_detection(y_gfsk);


%% Channel Estimation

num_preambles = 10;
i=1;
[h_xx h_yy] = gfsk_estimate_channel(y_gfsk(pd+i*num_preambles*length(preamble)*nsamp:pd-1+(i+1)*num_preambles*length(preamble)*nsamp));

j=1;
for i=1:length(h_xx)
    if h_xx(i) > num_bins*(2/5)
        if h_xx(i) < num_bins*(3/5)
            h_xx2(j) = h_xx(i);
            h_yy2(j) = h_yy(i);
            j = j + 1;
        end
    end
end

figure
plot(h_xx2, abs(h_yy2))

figure
plot(h_xx2, unwrap(angle(h_yy2)))

% 
% afs = fftshift(h);
% 
% figure
% plot(abs(afs(10,ceil(num_bins*(2/5)):ceil(num_bins*(3/5)))))
% 
% figure
% plot(angle(afs(10,ceil(num_bins*(2/5)):ceil(num_bins*(3/5)))))
% 
