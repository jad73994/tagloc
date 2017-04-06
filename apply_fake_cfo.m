clear
close all

%f = '/home/abari/Desktop/tagloc/OFDM_fakecfo_';
f = '/home/abari/Desktop/tagloc/rxdata/_';
num_files = 3;

num_samps = 15e7;
fakecfo = [-30,-33.984063745,-37.96812749];

load Parameters.mat

for i=1:num_files
    a=read_complex_binary2(strcat(f,int2str(i-1),'.dat'),num_samps,0);
    a = (a.') .* exp((-1i*2*pi*fakecfo(i)/fs).*[0:num_samps-1]);
    write_complex_binary(a, strcat(f,int2str(i-1),'.dat'));
end

figure(1)
plot(abs(a(1e4:1e4:end)))