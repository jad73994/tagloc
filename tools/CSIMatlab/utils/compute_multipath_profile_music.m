function P=compute_multipath_profile_music(h,lambda,p_factor,d_vals)    
    if(isrow(lambda))
        lambda=lambda';
    end
    if(iscolumn(h));
        h=h.';
    end
    
    H = h'*h;
    [V, D] = eig(H);
    d = d_vals;
    thresh=3;
    nelem = sum(diag(D) > max(diag(D))/thresh);
    P=zeros(size(d));
    for ii=1:length(d)
        e = exp(1i*p_factor*pi*d(ii)./lambda); 
        P(ii) = 1./abs(e'*V(:, 1:end-nelem)*V(:, 1:end-nelem)'*e);
    end    
end