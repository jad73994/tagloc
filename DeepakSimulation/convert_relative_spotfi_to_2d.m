function P_out=convert_relative_spotfi_to_2d(P1,P2,ap_pos1,ap_pos2,theta_vals,d_vals,d1,d2)
% Treat d1 and d2 as x,y positions.
% ap_pos: n_ant by 2 arrays for all the antennas on an AP
% Supply the antenna positions in the same order as the channels used for
% spotfi code
if(size(P1,1)~=length(theta_vals) && size(P1,2)~=length(d_vals))
    fprintf('Size does not match. Size(P,1) should be length(theta_vals) \n');
end
if(size(P2,1)~=length(theta_vals) && size(P2,2)~=length(d_vals))
    fprintf('Size does not match. Size(P,1) should be length(theta_vals) \n');
end
if(isrow(d1))
    d1=d1';
end
if(isrow(d2))
    d2=d2';
end
if(isrow(theta_vals))
    theta_vals=theta_vals';
end
if(isrow(d_vals))
    d_vals=d_vals';
end
P_out=zeros(length(d2),length(d1));
[T_IDX_1,D_IDX_1]=compute_idx(ap_pos1,ap_pos2(1,:),d1,d2,d_vals,theta_vals);
[T_IDX_2,D_IDX_2]=compute_idx(ap_pos2,ap_pos1(1,:),d1,d2,d_vals,theta_vals);

IDX1=sub2ind(size(P1),T_IDX_1,D_IDX_1);
IDX2=sub2ind(size(P2),T_IDX_2,D_IDX_2);
P_out(:)=(P1(IDX1)+P2(IDX2))/2;
end

function [T_IDX,D_IDX]=compute_idx(ap_pos,ant_pos, d1,d2,d_vals,theta_vals)
    ap_center = mean(ap_pos);
    X=repmat(d1',length(d2),1);
    Y=repmat(d2,1,length(d1));
    D=sqrt((X-ap_center(1)).^2+(Y-ap_center(2)).^2)-sqrt((X-ant_pos(1)).^2+(Y-ant_pos(2)).^2);
    ap_vec = ap_pos(1,:)-ap_pos(end,:);
    X=X-ap_center(1);
    Y=Y-ap_center(2);
    T=zeros(size(X));
    for i=1:length(X(:))
        T(i) = sign(sum([X(i),Y(i)].*ap_vec))*(pi/2-acos(abs(sum([X(i),Y(i)].*ap_vec))/norm([X(i),Y(i)])/norm(ap_vec)));
    end
    [~,T_IDX]=min(abs(repmat(T(:),1,length(theta_vals))-repmat(theta_vals',length(T(:)),1)),[],2);
    [~,D_IDX]=min(abs(repmat(D(:),1,length(d_vals))-repmat(d_vals',length(D(:)),1)),[],2);
end