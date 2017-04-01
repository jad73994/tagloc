function [SNR_per_symbol,SNRs_this_symbol] = calcSNR_NP(subcarrier_config, symf, bits_data,currentIndex, QAMsize, scale)
%CALCSNRPERBIN Summary of this function goes here
%   Detailed explanation goes here

    load Parameters.mat

    
    SNRs_this_symbol = zeros(1,num_bins_data);
    
    
    [bits_data_qam, QAMscale] = QAM(bits_data,QAMsize);
    
    received_values = symf(subcarrier_config==1)*scale*QAMscale;
    
    current_data = bits_data_qam(num_bins_data*(currentIndex-1) + (1:num_bins_data));

    for m = 1:num_bins_data
       NP_this_bin = (abs(received_values(m) - current_data(m)))^2;
       SNR_this_bin = 1/ NP_this_bin;   
       SNRs_this_symbol(m) = SNR_this_bin; 
    end
       SNR_per_symbol = median(SNRs_this_symbol);

end

