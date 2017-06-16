function [ xx yy ] = gfsk_estimate_channel(rx_signal)

load gfsk_Parameters.mat

rep_preamble = zeros(1,length(rx_signal)/nsamp);
for i=1:length(preamble)
    rep_preamble(i:length(preamble):end) = preamble(i);
end
tx_sig = gfsk_modulate(rep_preamble);

tx_sym = fft(tx_sig,num_bins);
rx_sym = fft(rx_signal,num_bins);
H = rx_sym./tx_sym;
H = fftshift(H.');

hmf = abs(fftshift(tx_sym.'));
[pts, xx] = findpeaks(hmf, 'MinPeakHeight', max(hmf)/10);
yy = H(xx);


fftplot(tx_sig, Fs, 11, 'r',1);
fftplot(rx_signal, Fs, 11, 'g',1);

figure(12); 
subplot(2,1,1)
hold all
plot(abs(fftshift(tx_sym)))
plot(abs(fftshift(rx_sym)))
plot(abs(fftshift(H)))
subplot(2,1,2)
hold all
plot(unwrap(angle(fftshift(tx_sym)))/pi)
plot(unwrap(angle(fftshift(rx_sym)))/pi)
plot(unwrap(angle(fftshift(H)))/pi)

end