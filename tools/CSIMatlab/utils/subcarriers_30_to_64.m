function ch_f = subcarriers_30_to_64(ch)
n = size(ch,2);
subn = [37:2:63 64 2:2:28 29];
missing_s = [3:2:27 38:2:62];
ch = reshape(ch,[],n);
ch_f = NaN*ones(64,n);
ch_f_phase = zeros(64,n);
ch_f(subn,:) = ch;
ch_f_phase(subn,:) = unwrap(angle(ch));
ch_f(missing_s,:) = 1/2*(abs(ch_f(missing_s-1,:))+abs(ch_f(missing_s+1,:))).*exp(1i*1/2*(ch_f_phase(missing_s-1,:)+ch_f_phase(missing_s+1,:)));
end