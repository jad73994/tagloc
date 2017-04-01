function [ rx_signal_no_cfo ] = correct_cfo(rx_signal,cfo,fs,offset)

rx_signal_no_cfo = rx_signal.*exp((-1i*2*pi*cfo/fs).*[offset:offset+length(rx_signal)-1]);

end