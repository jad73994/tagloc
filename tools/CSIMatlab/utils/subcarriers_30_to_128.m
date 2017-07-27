function ch_f = subcarriers_30_to_128(ch)
    sub=[-58,-54,-50,-46,-42,-38,-34,-30,-26,-22,-18,-14,-10,-6, -2, 2,6,10,14,18,22,26,30,34,38,42,46,50,54,58];
    subn = convert_bin_index_normal_to_fft(sub,128);
    missing_s = setdiff(1:1:128,subn);
    %missing_s = setdiff(missing_s, 
    n = size(ch,2);
    
    ch = reshape(ch,[],n);
    ch_f = NaN*ones(128,n);
    ch_f_phase = zeros(128,n);
    ch_f(subn,:) = ch;
    ch_f_phase(subn,:) = unwrap(angle(ch));
    cat1 = sort(subn)+1; cat1=cat1(1:end-1);
    cat2 = sort(subn)-1; cat2=cat2(2:end);
    cat3 = sort(subn)-2; cat3=cat3(2:end);
    ch_f(cat3,:) = 1/2*(abs(ch_f(cat3-2,:))+abs(ch_f(cat3+2,:))).*exp(1i*1/2*(ch_f_phase(cat3-2,:)+ch_f_phase(cat3+2,:)));
    ch_f(cat1,:) = (3/4*abs(ch_f(cat1-1,:))+1/4*abs(ch_f(cat1+3,:))).*exp(1i*(3/4*ch_f_phase(cat1-1,:)+1/4*ch_f_phase(cat1+3,:)));
    ch_f(cat2,:) = (1/4*abs(ch_f(cat2-3,:))+3/4*abs(ch_f(cat2+1,:))).*exp(1i*(1/4*ch_f_phase(cat2-3,:)+3/4*ch_f_phase(cat2+1,:)));
end