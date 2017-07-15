function [ stitched ] = channel_stitching(channels)

%channels is (frequency, antenna, bins)

load Parameters.mat

if length(frequencies) < 2
    stitched = squeeze(channels(1,:,:));
    return
end

offset_bins = length(gaurd_bins)*(frequencies(2) - frequencies(1) - 4);
stitched = zeros(size(squeeze(channels(1,:,:))));

for i=1:length(frequencies)
    for j=1:num_ants
        coeffs = polyfit([1:length(squeeze(channels(i,j,:)))].',unwrap(angle(squeeze(channels(i,j,:)))),1);
        slp(i,j) = coeffs(1);
        yint(i,j) = coeffs(2);
    end
    
    if i>1
        for j = 1:num_ants
            
            rotate_frequency = slp(1,j)-slp(i,j);
            channels(i,j,:) = (squeeze(channels(i,j,:)).').*exp((1i*rotate_frequency).*[1:length(channels(i,j,:))]);
            
            if offset_bins > 0
                filler(j,:) = exp(1i*slp(1,j).*[1:offset_bins]);
                filler_phase_offset = angle(channels(i-1,j,end)) + slp(1,j) - angle(filler(j,1));
                filler(j,:) = filler(j,:).*exp(1i*filler_phase_offset);
                filler(j,:) = mean(abs(channels(i-1,j,:))).*filler(j,:);
                phase_offset = angle(filler(j,end)) + slp(1,j) - angle(channels(i,j,1));
            else
                phase_offset = angle(channels(i-1,j,end)) + slp(1,j) - angle(channels(i,j,1));
            end
            
            channels(i,j,:) = (squeeze(channels(i,j,:)).*exp(1i*phase_offset)).';
            
            if offset_bins > 0
                b(j,:) = [filler(j,:) squeeze(channels(i,j,:)).'];
            else
                b(j,:) = squeeze(channels(i,j,:));
            end
        end

        stitched = [stitched b];
    else
        stitched = squeeze(channels(i,:,:));
    end
end


end