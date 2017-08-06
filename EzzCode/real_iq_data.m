f=fopen('mmdata/ap2.bin','rb');
t=fread(f,'uint32');
fclose(f);

seq   =bitshift(bitand(t(2:2:end),hex2dec('FFFF0000')),-16);
delta_seq=diff(seq);
unique(diff(seq))
u_delta_seq=sort(unique(delta_seq));
t=circshift(t,-2*find(delta_seq==u_delta_seq((u_delta_seq~=1)&(u_delta_seq~=-65535)&(u_delta_seq~=-45055))));
seq   =bitshift(bitand(t(2:2:end),hex2dec('FFFF0000')),-16);

%%
fn_rotated = sprintf('samples_rotated.bin');
f_fn_rotated = fopen(fn_rotated, 'wb');
fwrite(f_fn_rotated, t, 'uint32');
fclose(f_fn_rotated);
%%

unique(diff(seq))
real_0=bitshift(bitand(t(1:2:end),hex2dec('00000FFF')),0);
imag_0=bitshift(bitand(t(1:2:end),hex2dec('00FFF000')),-12);
real_1=bitshift(bitand(t(2:2:end),hex2dec('0000000F')),8)+bitshift(bitand(t(1:2:end),hex2dec('FF000000')),-24);
imag_1=bitshift(bitand(t(2:2:end),hex2dec('0000FFF0')),-4);

real_0(real_0>=(2^11))=real_0(real_0>=(2^11))-(2^12);
imag_0(imag_0>=(2^11))=imag_0(imag_0>=(2^11))-(2^12);
real_1(real_1>=(2^11))=real_1(real_1>=(2^11))-(2^12);
imag_1(imag_1>=(2^11))=imag_1(imag_1>=(2^11))-(2^12);

Ant_0_td=real_0+1j*imag_0;
Ant_1_td=real_1+1j*imag_1;
figure;plot(real(Ant_0_td))