clc;
clear;
close all

load Parameters.mat

%QAM Size: 1 for BPSK, 2 for 4QAM, 4 for 16QAM, 6 for 64 QAM, 8 for 256 QAM
QAMsize =2;

fake_cfo = 0;

%%Generate TX signal time domain%%
numBits=num_syms_data*num_bins_data;
rng(1);
bits_data=randi(2,1,numBits)-1;

%%Generate TX signal frequency domain Ofdm%%
s = tx_ofdm_chain4QAM(bits_data,QAMsize);
% adjust the amp of the signal and add zero at the end and begin
factor=0.1;
s=factor*s/max(abs(s));

tx_signal=[1.*s];
tx_signal = repmat(tx_signal,1, 1000);
tx_signal = [tx_signal];
tx_signal = [zeros(1,5e6) tx_signal];
tx_signal = tx_signal .* exp((-1i*2*pi*fake_cfo/fs) .* [0:length(tx_signal)-1]);

figure(4)
hold on
plot(abs(tx_signal),'b');
write_complex_binary(tx_signal, strcat(dir,'OFDM_fakecfo_0.dat'));
write_complex_binary(tx_signal, strcat(dir,'OFDM_fakecfo_1.dat'));
write_complex_binary(tx_signal, strcat(dir,'OFDM_fakecfo_2.dat'));


% rx_signal=read_complex_binary2('/home/sparsefft/Projects/mmWave/data/OFDM_repeatedPreamble2_0.dat');
%  figure(5)
%  plot(abs(rx_signal));

