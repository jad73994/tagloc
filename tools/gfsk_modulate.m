function [ y ] = gfsk_modulate(x)

load gfsk_Parameters.mat

t = [1:(nsamp*length(x))]*(1/Fs);
%gaussFilter = gaussdesign(0.5, 3, nsamp); not compatible with 2012a.
gaussFilter = [0.0000 0.0000 0.0000 0.0000 0.0000 0.0001 0.0005 0.0016 0.0046 0.0116 0.0254 0.0482 0.0793 0.1132 0.1402 0.1505 0.1402 0.1132 0.0793 0.0482 0.0254 0.0116 0.0046 0.0016 0.0005 0.0001 0.0000 0.0000 0.0000 0.0000 0.0000];

gamma_fsk = zeros(1,length(t));
for i=1:length(x)
    gamma_fsk((((i-1)*nsamp)+1):(i*nsamp)) = ((x(i)*2)-1);
end
gamma_gfsk = filter(gaussFilter, 1, gamma_fsk);
 
gfsk_phase = (freqsep/Fs)*pi*cumtrapz(gamma_gfsk);
y = exp(1i*gfsk_phase);
y = y.';

end