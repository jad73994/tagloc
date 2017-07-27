function DP=compute_multipath_profile(h,lambda,p_factor,d_vals)
    DP=zeros(size(d_vals));
    if(iscolumn(lambda))
        lambda=lambda';
    end
    if(iscolumn(h));
        h=h.';
    end
    for i=1:length(d_vals)
        DP(i)=sum(h.*exp(1j*p_factor*pi*d_vals(i)./lambda));
    end
end