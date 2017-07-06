function [ h ] = gfsk_partial_channel_estimate(rx_signal)

load gfsk_Parameters.mat


rep_preamble = zeros(1, num_syms);
tx_sig_binary_ones = zeros(1, num_syms*nsamp);
tx_sig_binary_zeroes = zeros(1, num_syms*nsamp);

for i=1:length(preamble)
    rep_preamble(i:length(preamble):end) = preamble(i);
end

tx_sig = gfsk_modulate(rep_preamble).';
tx_sig = [zeros(1, filter_delay) tx_sig zeros(1, (abs(length(rx_signal)-length(tx_sig))+2))];
tx_sig = (0.5*tx_sig).';

fftplot(tx_sig, Fs, 11, 'r',1);
fftplot(rx_signal, Fs, 11, 'g',1);

for i=1:length(rep_preamble)
    tx_sig_binary_ones((1+((i-1)*nsamp)):(i*nsamp)) = rep_preamble(i);    
    tx_sig_binary_zeros((1+((i-1)*nsamp)):(i*nsamp)) = (-1*(rep_preamble(i)-1));
end

tx_sig_binary_ones = [zeros(1,filter_delay) tx_sig_binary_ones];
tx_sig_binary_zeros = [zeros(1,filter_delay) tx_sig_binary_zeros];


% 
% for i=1:10
%     lindex = ((i-1)*nsamp*length(preamble)*10)+1;
%     hindex = i*nsamp*length(preamble)*10;
% end
    
div = angle(rx_signal./tx_sig(1:length(rx_signal)));
    
onesdiv = div(find(tx_sig_binary_ones));
zerosdiv = div(find(tx_sig_binary_zeros));

    
figure(112)
ax1 = subplot(3,1,1);
plot(unwrap(angle(rx_signal)))
ax2 = subplot(3,1,2);
plot(unwrap(angle(tx_sig(1:length(rx_signal)))))
ax3 = subplot(3,1,3);
plot(unwrap(div))
linkaxes([ax1,ax2,ax3],'x')

figure(113)
ax4 = subplot(3,1,1);
plot(unwrap(div))
ax5 = subplot(3,1,2);
plot(unwrap(onesdiv))
ax6 = subplot(3,1,3);
plot(unwrap(zerosdiv))
linkaxes([ax4,ax5,ax6],'x')
    
h = mean([exp(1i*(mod(median(unwrap(onesdiv)),2*pi))), exp(1i*(mod(median(unwrap(zerosdiv)),2*pi)))]);

end