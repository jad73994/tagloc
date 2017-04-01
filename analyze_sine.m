clear
close all

fdir = '/home/abari/Desktop/austinmatlab/rxdata/';
%f = 1/49.978712;
f = 1/50;
fs = 5000000;

a1=read_complex_binary2(strcat(fdir,'_0.dat'),4e7,1e7);
b1=read_complex_binary2(strcat(fdir,'_1.dat'),4e7,1e7);
c1=read_complex_binary2(strcat(fdir,'_2.dat'),4e7,1e7);
% a2=read_complex_binary2(strcat(fdir,'2/_0.dat'),9e7,0);
% b2=read_complex_binary2(strcat(fdir,'2/_1.dat'),9e7,0);
% c2=read_complex_binary2(strcat(fdir,'2/_2.dat'),9e7,0);
a2=a1;
b2=b1;
c2=c1;

tsfile = fopen(strcat(fdir,'_md.dat'));
wholeseconds = fgetl(tsfile);
fracseconds = fgetl(tsfile);
fclose(tsfile);
ts1 = str2num(wholeseconds) + str2num(fracseconds);
tsfile = fopen(strcat(fdir,'_md.dat'));
wholeseconds = fgetl(tsfile);
fracseconds = fgetl(tsfile);
fclose(tsfile);
ts2 = str2num(wholeseconds) + str2num(fracseconds);

t1 = (exp((i*2*pi*f).*[0:length(a1)-1]).*exp(i*2*pi*f*ts1*fs)).';
t2 = (exp((i*2*pi*f).*[0:length(a1)-1]).*exp(i*2*pi*f*ts2*fs)).';

figure(1)
subplot(221);
plot(real(b1(9.9e4:10.1e4)));
subplot(222);
plot(real(t1(9.9e4:10.1e4)));
subplot(223);
plot(angle(b1(9.9e4:10.1e4)));
subplot(224);
plot(angle(t1(9.9e4:10.1e4)));


d1 = mod(angle(a1)-angle(t1)+pi,2*pi)-pi;
d2 = mod(angle(a2)-angle(t2)+pi,2*pi)-pi;

d3 = mod(angle(b1)-angle(t1)+pi,2*pi)-pi;
d4 = mod(angle(b2)-angle(t2)+pi,2*pi)-pi;

d5 = mod(angle(c1)-angle(t1)+pi,2*pi)-pi;
d6 = mod(angle(c2)-angle(t2)+pi,2*pi)-pi;

figure(2)
subplot(321);
plot(unwrap(d1));
subplot(322);
plot(unwrap(d2));
subplot(323);
plot(unwrap(d3));
subplot(324);
plot(unwrap(d4));
subplot(325);
plot(unwrap(d5));
subplot(326);
plot(unwrap(d6));

figure(3)
subplot(321);
plot(d1);
subplot(322);
plot(d2);
subplot(323);
plot(d3);
subplot(324);
plot(d4);
subplot(325);
plot(d5);
subplot(326);
plot(d6);
