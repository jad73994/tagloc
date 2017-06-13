Ts = 1/5e6;
t = 0:1:10e7;

f=1e5;
x =exp(1i*2*pi*f*Ts*t);

plot(t, abs(x))

write_complex_binary(x, '/home/abari/Desktop/austinmatlab/test_sine_0.dat');
write_complex_binary(x, '/home/abari/Desktop/austinmatlab/test_sine_1.dat');
write_complex_binary(x, '/home/abari/Desktop/austinmatlab/test_sine_2.dat');
