function [ H,shift,med_absVal ] = estimate_channel(rx_sym1,rx_sym2)

load Parameters.mat

tx_sym = zeros(size(rx_sym1));
subcarrier_config = ones(size(rx_sym1));
subcarrier_config(convert_bin_index_normal_to_fft(gaurd_bins,num_bins)) = 0;
subcarrier_config(convert_bin_index_normal_to_fft(pilots,num_bins)) = 3; 
tx_sym(subcarrier_config~=0) = 1-2*bits_preamble;
rx_sym = (1/sqrt(num_bins))*fft((rx_sym1+rx_sym2)/2);
H = rx_sym./tx_sym;

shift = 0;
med_absVal = 0;
%med_power=0;
%shift = 0;
% 
% figure(200);
% hold on
% plot(unwrap(angle(fftshift(rx_sym))));
% plot(unwrap(angle(fftshift(tx_sym))),'r');
% 
% 
% figure(16);
% plot(rx_sym,'.r'); hold on; plot(tx_sym,'.b');

%% Get Finalshift by Removing guard bins before unwrapping
% power = 0;
% rx_sym = (1/sqrt(num_bins))*fft(rx_sym1);
% H = rx_sym./tx_sym;
% wrapped_ang = fftshift(angle(H));
% wrapped_ang_noguards = [wrapped_ang(8:32),wrapped_ang(34:58)];
% ang = unwrap(wrapped_ang_noguards);
% plot(ang);
% x = [1:25,27:51];
% estimate = regress(ang', [ones(1,length(ang)); x]');
% pointDC = estimate(1)+estimate(2)*26;
% shift = (mod(pointDC,2*pi))/(2*pi)*360;




%% Get power by by Removing guard bins before unwrapping
% shift = 0;
% 
% rx_sym = (1/sqrt(num_bins))*fft(rx_sym1);
% H = rx_sym./tx_sym;
% absVal = fftshift(abs(H));
% absVal_noguards = [absVal(8:32),absVal(34:58)];
% med_absVal = median(absVal_noguards);






%%

%%Linear regression for estimating DC
%ang = unwrap(fftshift(angle(H)));
%needed_ang = [ang(10:32),ang(34:56)];
%x = [10:32,34:56];
%estimate = regress(needed_ang', [ones(1,length(needed_ang)); x]');
%point33 = estimate(1)+estimate(2)*33;
%shift = (mod(point33,2*pi))/(2*pi)*360;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%55

%%
H(convert_bin_index_normal_to_fft(gaurd_bins,num_bins)) = 0;

end