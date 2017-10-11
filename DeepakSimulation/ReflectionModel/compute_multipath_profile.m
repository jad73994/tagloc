function DP=compute_multipath_profile(h,ant_pos,lambda,theta_vals)
    DP=zeros(size(theta_vals));
    if(iscolumn(ant_pos))
        ant_pos=ant_pos';
    end
    if(iscolumn(h))
        h=h.';
    end
    for i=1:length(theta_vals)
        DP(i)=sum(h.*exp(1j*2*pi*ant_pos*sin(theta_vals(i))/lambda));
    end
end