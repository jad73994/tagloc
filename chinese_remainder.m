function [ d ] = chinese_remainder(phases, frequencies)
    phase_error_tolerance_radians = 0.2;
    max_nanoseconds = 100;
    peaks_separation = 2000; % (2ns)

    seconds = [0:1e-12:max_nanoseconds * 1e-9];
    gaussians = zeros(length(frequencies), length(seconds));
    gaus_stdev = phase_error_tolerance_radians ./ (2 * pi * frequencies * 1e6);
    gaus_scale = 1 ./ normpdf(0,0,gaus_stdev);

    tau_init = phases ./ (2 * pi * frequencies * 1e6);
    tau_delta = 1 ./ (frequencies * 1e6);

    for i=1:length(frequencies)
        pts = tau_init(i) + ([0:10*max_nanoseconds] * tau_delta(i));
        pts = round(pts/1e-12)*1e-12;

        for j=1:length(pts)
            gaussians(i, :) = gaussians(i, :) + (gaus_scale(i) .* normpdf(seconds, pts(j), gaus_stdev(i)));
        end
    end

    gaussians_multiplied = ones(size(gaussians(1,:)));
    for i=1:length(frequencies)
        gaussians_multiplied = gaussians_multiplied .*gaussians(i, :);
    end
    
    
    %% Find Peaks
    [pks, locs] = findpeaks(gaussians_multiplied,'MinPeakDistance',peaks_separation,'MinPeakHeight',max(gaussians_multiplied)/1.001);
 
    if length(locs) == 0
        d = -1;
    else 
        d = locs(1)/1000;
    end


    %% Figures
    figure(771)
    hold all
    xlabel('nanoseconds')
    for i=1:length(frequencies)
        plot(0:1e-3:max_nanoseconds, i+gaussians(i,:))
    end


    figure(772)
    set(gca, 'Ticklength', [0 0])
    hold all
    xlabel('nanoseconds')
    plot(0:1e-3:max_nanoseconds, gaussians_multiplied)
end