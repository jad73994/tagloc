function [ H ] = estimate_channel(rx_sym1,rx_sym2)

load gfsk_Parameters.mat

tx_sym = zeros(size(rx_sym1));
subcarrier_config = ones(size(rx_sym1));
subcarrier_config(convert_bin_index_normal_to_fft(gaurd_bins,num_bins)) = 0;
subcarrier_config(convert_bin_index_normal_to_fft(pilots,num_bins)) = 3; 
tx_sym(subcarrier_config~=0) = 1-2*bits_preamble;
rx_sym = (1/sqrt(num_bins))*fft((rx_sym1+rx_sym2)/2);
H = rx_sym./tx_sym;


H(convert_bin_index_normal_to_fft(gaurd_bins,num_bins)) = 0;

end