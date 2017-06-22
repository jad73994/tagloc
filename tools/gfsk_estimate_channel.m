function [ xx yy ] = gfsk_estimate_channel(rx_signal)

load gfsk_Parameters.mat

rep_preamble = zeros(1, num_syms);
for i=1:length(preamble)
    rep_preamble(i:length(preamble):end) = preamble(i);
end

tx_sig = gfsk_modulate(rep_preamble).';
tx_sig = [zeros(1,nsamp*100) tx_sig zeros(1,nsamp*100)];
tx_sig = (0.5*tx_sig).';

tx_sym = fft(tx_sig);
rx_sym = fft(rx_signal);
H = rx_sym./tx_sym;
H = fftshift(H.');

hmf = abs(fftshift(tx_sym.'));
[pts, xx] = findpeaks(hmf, 'MinPeakHeight', max(hmf)/1000);
yy = H(xx);


fftplot(tx_sig, Fs, 11, 'r',1);
fftplot(rx_signal, Fs, 11, 'g',1);

end