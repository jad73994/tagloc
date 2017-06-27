function [ zero ] = gfsk_channel_zeros(channel)

load gfsk_Parameters.mat

a = size(channel)

for i=1:a(1)
    for j=1:a(2)
        coeffs = polyfit([1:length(channel(i,j,:))].',unwrap(squeeze(angle(channel(i,j,:)))),1);
        slp = coeffs(1);
        yint = coeffs(2);

        zero(i,j) = exp(1i*mod(yint+slp*(length(channel(i,j,:))/2), 2*pi))
    end
end


end