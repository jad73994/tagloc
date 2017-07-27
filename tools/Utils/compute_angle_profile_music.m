function P=compute_angle_profile_music(h,lambda,ant_pos,theta_vals)    
    if(isrow(ant_pos))
        ant_pos = ant_pos';        
    end
    if(isrow(h));
        h=h.';
    end
    h = reshape_channel(h);
    
    H = h*h';
    [V, D] = eig(H);    
    thresh=50;
    nelem = sum(diag(D) > max(diag(D))/thresh);
    P=zeros(size(theta_vals));
    for ii=1:length(theta_vals)
        e = exp(-1j*2*pi*ant_pos(1:end-2)*cos(theta_vals(ii))./lambda); 
        P(ii) = 1./abs(e'*V(:, 1:end-nelem)*V(:, 1:end-nelem)'*e);
    end    
end

function h = reshape_channel(h)
    h = [h(1:end-2) h(2:end-1)  h(3:end)];
end