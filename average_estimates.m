h_avg = zeros(length(frequencies), num_ants + 1, length(squeeze(h_save(1,1,1,:))));
for i = 1:length(frequencies)
    for j = 1:num_ants
        for run = 1:10
            s=robustfit(1:length(squeeze(h_save(run,i,j,:))),phase(h_save(run,i,j,:)));
            h_avg(j,i,:) = h_avg(j,i,:) + s(2);
        end
        h_avg(j,i,:) = exp(1i*(h_avg(j,i,:)/10).*[1:length(h_avg(j,j,:))]);
    end
end