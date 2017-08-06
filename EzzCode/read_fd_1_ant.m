%% read_fd_1_ant.m
% Reads frequency domain signal
% Need to change file in fopen
length_sec=60;
f=fopen('mmdata/tag.bin','rb');
%f=fopen('samples_tbviv7_low_snr.bin','rb');
t=fread(f,length_sec*180*14*1000,'uint32');
fclose(f);

imag_data=bitshift(bitand(t,hex2dec('FFFF0000')),-16);
real_data=bitshift(bitand(t,hex2dec('0000FFFF')),0);
%real_data=bitshift(bitand(t,hex2dec('FFFF0000')),-16);
%imag_data=bitshift(bitand(t,hex2dec('0000FFFF')),0);
real_data(real_data>=(2^15))=real_data(real_data>=(2^15))-(2^16);
imag_data(imag_data>=(2^15))=imag_data(imag_data>=(2^15))-(2^16);


Ant_0=real_data+1j*imag_data;

f=fopen('tx_ezz_freq.bin','rb');
n_used_subcarriers=fread(f,1,'uint32');
n_sym_per_slot=fread(f,1,'uint32');
t=fread(f,'float');
fclose(f);
t_complex=t(1:2:end)+1j*t(2:2:end);
clear('imag_data');
clear('real_data');
clear('t');
ch_reshaped=reshape(Ant_0.*conj(repmat(t_complex(1:180*140),length(Ant_0)/(180*140),1)),180*140,[]);
%ch_reshaped=reshape(Ant_0,180*140,[]);

clear('Ant_0');

a=reshape(ch_reshaped,180,140,[]); % Returns  N_subcarrier X N_symbol X N_frame 3-D vector
figure; plot(angle(squeeze(a(10,10,:)))); % Plot symbol 10, subcarrier 10 across frames