clear;
close all;


%QAM Size: 1 for BPSK, 2 for 4QAM, 4 for 16QAM, 6 for 64 QAM, 8 for 256 QAM
QAMsize =2;

load Parameters.mat

fl = '_2.dat';
offset = 16e6;
%offset = offset + 64e6;

knowncfo=-1;
%knowncfo = 31.715;
%knowncfo = 36.56045;
knowncfo = 41.4059;

rx_signal=read_complex_binary2(strcat(dir,'rxdata/',fl),50e6, offset); %length, start
%rx_signal=read_complex_binary2(strcat(dir,'OFDM_fakecfo_0.dat'),50e6,4e6);

% rx_ts = fopen(strcat(fdir,'_md.dat'));
% wholeseconds = fgetl(rx_ts);
% fracseconds = fgetl(rx_ts);1
% fclose(rx_ts);
% secs = str2num(wholeseconds) + str2num(fracseconds)

rx_samples=rx_signal.';

%    cont_point = 1;
figure(4)
plot(abs(rx_signal));

%% Draw constellations and bit error rate


%     figure(2)_
%     plot(abs(rx_signal));
%   return



rngInput = 1;

[h, bits_data_dec, avg_SNR,xx,yy, SNR_in_dB, return_SNR] = rx_ofdm_chain4QAM(rx_samples,QAMsize,rngInput,offset,knowncfo);


% bits_data = getBitsData(rngInput);
% bit_error = calcBitError(bits_data_dec, bits_data)




%% Plot the shift of the angles
% data_start = 0.5e7;
% for m = 1:4000000
%     if mod(m,5000) == 0
%         m
%     endmean_cfos_test
%    rx_samples1=(rx_signal((m-1)*num_bins+data_start+(1:num_bins))).';
%    [bits_data_dec,shift,power] = rx_ofdm_chain4QAMrepeatedPreambles(rx_samples1,QAMsize);
%    finalshift(m) = shift;
%    finalpower(m) = power;
% 
% %    rx_samples2=(rx_signal2((m-1)*num_bins+data_start+(1:num_bins))).';
% %    [bits_data_dec2,shift2,power2] = rx_ofdm_chain4QAMrepeatedPreambles(rx_samples2,QAMsize);
% %    finalshift2(m) = shift2;
% %    finalpower2(m) = power2;
% arxs
%    %rx_samples3=(rx_signal3((m-1)*num_bins+data_start+(1:num_bins))).';
%    %[bits_data_dec3,shift3] = rx_ofdm_chain4QAM(rx_samples3,QAMsize,1);
%    %finalshift3(m) = shift3;
%  end
%  figure(5)
%  plot(finalshift);
%  return





%% Test the angles of the antenna
% data_start = 1;
% load('vertical_patchsilver_to_horn.mat','rms_data','rms_data_2','channel_mag','channel_mag_2','rms_data_3','channel_mag_3');
%
%     rms_data_2 = [rms(rx_signal),rms_data_2];
%     [x y] = size(rms_data_2);
%     for m = 1:5000
%         rx_samples1=(rx_signal((m-1)*num_bins+data_start+(1:num_bins))).';
%         [bits_data_dec,shift,power] = rx_ofdm_chain4QAMrepeatedPreambles(rx_samples1,QAMsize);
%         finalpower(m) = power;
%     end
%     channel_mag_2 = [median(finalpower),channel_mag_2];
% save('vertical_patchsilver_to_horn.mat','rms_data','rms_data_2','channel_mag','channel_mag_2','rms_data_3','channel_mag_3');
% (y-1)*10*-1+90
% return



%% Analyze Data
% data_start = 1;
%
%
%     rx_samples=(rx_signal(1:end)).';
%   figure(4)
%   plot(abs(rx_signal));
%     [bits_data_dec,shift,power] = rx_ofdm_chain4QAM(rx_samples,QAMsize);

