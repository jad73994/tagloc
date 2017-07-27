function DP=compute_distance_profile(h,lambda,p_factor,d_vals)
    if(iscolumn(lambda))
        lambda=lambda';
    end
    if(iscolumn(h));
        h=h.';
    end
    if(iscolumn(d_vals))
        d_vals=d_vals';
    end
    lambda_vals=1./lambda;
    D=repmat(d_vals',1,length(lambda_vals));
    L=repmat(lambda_vals,length(d_vals),1);    
    M=exp(1j.*p_factor*pi.*L.*D);
    H=repmat(h,length(d_vals),1);
    DP=sum(H.*M,2);
end