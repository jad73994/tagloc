function DP=compute_distance_profile_sparse(h,lambda,p_factor,d_vals,opt)
tic
    if(~exist('opt','var'))
        opt.lambda=20;
        opt.max_iter=100000;
    end
    
    if(isrow(lambda))
        lambda=lambda';
    end
    if(isrow(h));
        h=h.';
    end
    if(iscolumn(d_vals))
        d_vals=d_vals';
    end        
    A=exp(-1j*p_factor*pi.*repmat(1./lambda,1,length(d_vals)).*repmat(d_vals,length(lambda),1));
    DP1=compute_distance_profile(h,lambda,p_factor,d_vals);
    DP=min_L1_norm(A,DP1,h,opt.lambda,opt.max_iter);

toc
end