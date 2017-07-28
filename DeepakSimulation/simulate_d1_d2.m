clear
freq=2.4e9:3e6:2.487e9;
ant_sep=3e8/max(freq)/2;
opt.threshold=0.1;
opt.freq=freq;
opt.ant_sep=ant_sep;
theta_vals= (-90:1:90)*pi/180;
d_vals = -60:60;
ap{1}.ant_pos=[3,0;
                3-ant_sep,0;
                3-2*ant_sep,0];
ap{2}.ant_pos=ap{1}.ant_pos(:,[2,1]);
tag_pos=[10,20;
    -20,30];
for i=1:length(ap)
    for j=1:size(ap{i}.ant_pos,1)
        for k=1:length(freq)
            h{i}(j,k)=get_channel(ap{i}.ant_pos(j,:), tag_pos,freq(k));
        end
        
    end
end
for i=1:2
    p{i}=compute_spotfi_profile(h{i},theta_vals, d_vals, opt);
    figure; imagesc(d_vals,theta_vals*180/pi,db(p{i}));
end
p_f_1=compute_spotfi_profile(h{1}.*conj(repmat(h{2}(1,:),3,1)),theta_vals, d_vals, opt);
p_f_2=compute_spotfi_profile(h{2}.*conj(repmat(h{1}(1,:),3,1)),theta_vals, d_vals, opt);
figure; imagesc(d_vals,theta_vals*180/pi,db(p_f_1));
figure; imagesc(d_vals,theta_vals*180/pi,db(p_f_2));
% Plot d1 d2
d1=-50:1:50;
d2=-40:1:40;
for ap_idx=1:2
   P_out{ap_idx}=convert_spotfi_to_2d(p{ap_idx},theta_vals,d_vals, d1,d2,ap{ap_idx}.ant_pos);    
   
   figure; imagesc(d1,d2,db(P_out{ap_idx}));
end
figure; imagesc(d1,d2,db(P_out{1}.*P_out{2}));
P_out=convert_relative_spotfi_to_2d(p_f_1,p_f_2,ap{1}.ant_pos,ap{2}.ant_pos,theta_vals,d_vals,d1,d2);
figure; imagesc(d1,d2,db(P_out));

function h=get_channel(src,dst,freq)
    h=0;
    for i=1:size(dst,1)
        h=h+exp(-1j*2*pi*freq/3e8*norm(src-dst(i,:)));
    end
end

function [d,theta]=get_ground_truth(ap,src)
    d=norm(mean(ap.ant_pos)-src);
    v1=ap.ant_pos(end,:)-ap.ant_pos(1,:);
    v2=src-mean(ap.ant_pos);
    theta=acos(sum(v1.*v2)/norm(v1)/norm(v2));
    
end