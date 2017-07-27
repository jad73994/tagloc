function z_s=perm_matrix(n)
    i_s=0:1:2^n-1;
    p_s=dec2bin(i_s,n);
    z_s=(int32(p_s)*2-97)';
    z_s=(z_s>0)*2-1;
end