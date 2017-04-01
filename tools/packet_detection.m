function [ packet_start_index ] = packet_detection(rx_signal)
% 6.888 Wireless Communications Systems
%
% Dina Katabi / Haitham Hassnaieh 
% CSAIL, MIT 
% September 11, 2013
%

load Parameters.mat

% Dc removal filter
alpha = 0.975; 
rx_signal = filter([1 -1], [1 -alpha], rx_signal);
%plot(abs(rx_signal));
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