clear
load('ReflectionModel\dataset_delta_simple.mat')
lambda = model.lambda;
ant_sep = min(model.lambda)/2;
opt.threshold=0.1;
opt.freq=3e8./lambda;
opt.ant_sep=ant_sep;
theta_vals= (-90:1:90)*pi/180;
d_vals = -50:50;
start_time=now;
for cur_pt = 1:200%length(features)
    h = cell(length(ap),1);    
    for i=1:length(ap)
        h{i} = squeeze(features{cur_pt}(:,i,:)).';
    end
    
    %for i=1:length(ap)
    %    p{i}=compute_spotfi_profile(h{i},theta_vals, d_vals, opt);
        %figure; imagesc(d_vals,theta_vals*180/pi,db(p{i}));
    %end
    pairs =[1,2;
            2,3;
            3,4;
            1,4;
            1,3;
            2,4];
    
    d1 = [0:0.4:40];
    d2 = [0:0.4:30];
    P_out = zeros(length(d2),length(d1));
    for i=1:length(pairs)
        p_f_1=compute_spotfi_profile(h{pairs(i,1)}.*conj(repmat(h{pairs(i,2)}(1,:),3,1)),theta_vals, d_vals, opt);
        p_f_2=compute_spotfi_profile(h{pairs(i,2)}.*conj(repmat(h{pairs(i,1)}(1,:),3,1)),theta_vals, d_vals, opt);

        %figure; imagesc(d_vals,theta_vals*180/pi,db(p_f_1));
        %figure; imagesc(d_vals,theta_vals*180/pi,db(p_f_2));
        P_out=P_out+convert_relative_spotfi_to_2d(p_f_1,p_f_2,ap{pairs(i,1)},ap{pairs(i,2)},theta_vals,d_vals,d1,d2);
        %figure; imagesc(d1,d2,db(P_out));

    end
    [~,idx]=max(P_out(:));
    [i,j]=ind2sub(size(P_out),idx);
    err(cur_pt) = norm(labels(cur_pt,:)-[d1(j),d2(i)]);
    disp([cur_pt,err(cur_pt),(now-start_time)*24*60]);
end
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