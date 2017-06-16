function [ packet_start_index ] = gfsk_packet_detection(rx_signal)

load gfsk_Parameters.mat

% Dc removal filter
alpha = 0.975; 
rx_signal = filter([1 -1], [1 -alpha], rx_signal);
threshold=6;

A=zeros(1,length(rx_signal));
B=zeros(1,length(rx_signal));
intsum = cumsum(abs(rx_signal).^2);

A(2*nsamp:end) = intsum(2*nsamp:end) - intsum(nsamp:end-nsamp);
B(1+2*nsamp:end) = intsum(1+nsamp:end-nsamp) - intsum(1:end-2*nsamp);
B(2*nsamp) = intsum(nsamp);

metric=A./B;
if(isempty(metric > threshold))
    packet_start_index = -1;
    return;
end

[value index] = max(metric);
packet_start_index = index - nsamp +1;


end