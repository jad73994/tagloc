function P = compute_multipath_profile_music(h,ant_pos,lambda,theta_vals)   
    if(isrow(ant_pos))
        ant_pos = ant_pos';       
    end
%     if(iscolumn(h));
%         h=h.';
%     end
   
    
    %H = h'*h;
    H = h*h';
    [V, D] = eig(H);   
    thresh=3;
    nelem = sum(diag(D) > max(diag(D))/thresh);
    P=zeros(size(theta_vals));
    for ii=1:length(theta_vals)
        e = exp(1j*2*pi*ant_pos*cos(theta_vals(ii))./lambda);
        P(ii) = 1./abs(e'*V(:, 1:end-nelem)*V(:, 1:end-nelem)'*e);
    end   
end