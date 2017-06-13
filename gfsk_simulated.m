clear
close all
 
Fs = 10e6;   % Sample rate (Hz)
channel_width = 2e6;
nsamp = Fs/1e6;    % Number of samples per symbol
num_syms = 1000;
t = [1:(nsamp*num_syms)]*(1/Fs);
preamble = 11100;

save gfsk_Parameters.mat

x = zeros(1, num_syms);
for i=1:length(preamble)
    x(i:length(preamble):end) = preamble(i);
end
 

gaussFilter = gaussdesign(0.5, 3, nsamp);


gamma_fsk = zeros(1,length(t));
for i=1:length(x)
    gamma_fsk((((i-1)*nsamp)+1):(i*nsamp)) = ((x(i)*2)-1);
end
gamma_gfsk = filter(gaussFilter, 1, gamma_fsk);
 

gfsk_phase = (freqsep/Fs)*pi*cumtrapz(gamma_gfsk);
y_gfsk = exp(1i*gfsk_phase).';


figure
plot(x)

pd = gfsk_packet_detection(y_gfsk);

