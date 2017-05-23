function M = compute_multipath_profile(h,ant_pos,lambda,theta_vals)
    M = zeros(size(theta_vals));
    for i=1:length(theta_vals)
        M(i) = sum(h.*exp(1j*2*(pi/lambda)*ant_pos*cos(theta_vals(i))))^2;
    end
end