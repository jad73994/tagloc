function [ signal ] = tx_ofdm_chain4QAM(bits_data,QAMsize)


load Parameters.mat


%Added data rate division here
num_samples=(num_bins*num_syms_preamble)+cp  +  (num_bins+cp)*num_syms_data/QAMsize;
%num_samples=(num_bins*num_syms_preamble); 
signal = zeros(1,num_samples);

% Use this variable to create each symbol in the frequency domain before
% taking the fft
symbol_freq = zeros(1,num_bins);

% Use this variable to help you set the data subcarriers from pilot
% subcarriers from unused subcarriers
subcarrier_config = ones(1,num_bins);
subcarrier_config(convert_bin_index_normal_to_fft(gaurd_bins,num_bins)) = 0;
subcarrier_config(convert_bin_index_normal_to_fft(pilots,num_bins)) = 3; 


%% ADD PREAMBLE SYMBOLS
for m = 1:1:num_syms_preamble
%for m = 1:1:200
    %  ... add Preamble %
    symbol_freq(subcarrier_config~=0)= -2*bits_preamble+1;
    signal((m-1)*num_bins+(1:num_bins))=sqrt(num_bins)*ifft(symbol_freq);
    
end
   %  ... add one CP %
   signal(num_syms_preamble*num_bins+(1:cp))=signal((num_syms_preamble-1)*num_bins+(1:cp));
   

% %% ADD DATA SYMBOLS
% 
 encoded_signal = QAM(bits_data,QAMsize);
 figure(20);plot(encoded_signal,'.');

 for m = 1:1:(num_syms_data/QAMsize)
 
 %  ... add your code here ... %
 
     symbol_freq(convert_bin_index_normal_to_fft(pilots,num_bins))=-2*bits_pilots+1;
     symbol_freq(subcarrier_config==0)=0;
     %symbol_freq(subcarrier_config==1)=-2*bits_data((m-1)*num_bins_data+(1:num_bins_data))+1;
     symbol_freq(subcarrier_config==1)=encoded_signal((m-1)*num_bins_data+(1:num_bins_data));
         
     signal((num_syms_preamble*num_bins+cp)+((m-1)*(num_bins+cp))+(1:num_bins))=sqrt(num_bins)*ifft(symbol_freq);
     signal((num_syms_preamble*num_bins+cp)+((m-1)*(num_bins+cp))+num_bins+(1:cp))=signal((num_syms_preamble*num_bins+cp)+((m-1)*(num_bins+cp))+(1:cp));
 
 end
 
end