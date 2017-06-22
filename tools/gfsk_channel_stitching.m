function [ stitched ] = gfsk_channel_stitching(channels)

load gfsk_Parameters.mat




stitched = squeeze(channels(1,:,:));

for i=1:length(frequencies)
    for j=1:num_antennas
        coeffs = polyfit([1:length(squeeze(channels(i,j,:)))].',unwrap(angle(squeeze(channels(i,j,:)))),1);
        slp(i,j) = coeffs(1);
        yint(i,j) = coeffs(2);
    end
    
    if i>1
        for j = 1:num_antennas
            %rotate_frequency = slp*;
            %channels(i,j,:) = channels(i,j,:).*exp((-1i*2*pi*rotate_frequency/Fs).*[1:length(channels(i,j,:))-1]);
            
            phase_offset = yint(i,j) + slp(i,j)*(length(squeeze(channels(i,j,:)))+1);
            a(j,:) = squeeze(channels(i,j,:)).*exp(1i*phase_offset);
        end

        stitched = [stitched a];
    end
end


end