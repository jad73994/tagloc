function [ packet_start_index ] = gfsk_packet_detection(rx_signal)

load gfsk_Parameters.mat

% Dc removal filter
alpha = 0.975; 
rx_signal = filter([1 -1], [1 -alpha], rx_signal);
threshold=6;

A=zeros(1,length(rx_signal));
B=zeros(1,length(rx_signal));
intsum = cumsum(abs(rx_signal).^2);

A(2*num_bins:end) = intsum(2*num_bins:end) - intsum(num_bins:end-num_bins);
B(1+2*num_bins:end) = intsum(1+num_bins:end-num_bins) - intsum(1:end-2*num_bins);
B(2*num_bins) = intsum(num_bins);

metric=A./B;
if(isempty(metric > threshold))
    packet_start_index = -1;
    return;
end

[value index] = max(metric);
packet_start_index = index - num_bins +1;


end