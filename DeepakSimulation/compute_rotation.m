function [R,T]=compute_rotation(ap_pos)
% This function compute the rotation matrix for the AP positions
% ap_pos is n_ant times 2 matrix of ap positions
% each row is x,y
% assume uniform antenna separation 
% R*(ap_pos'-repmat(T',1,size(ap_pos,1))) should return an array along the negative x axis
ap_pos = ap_pos';
n_ant=size(ap_pos,2);
ant_sep = norm(ap_pos(:,1)-ap_pos(:,2));
T=mean(ap_pos');
ap_vec=ap_pos(:,end)-ap_pos(:,1);
theta=-pi-cart2pol(ap_vec(1),ap_vec(2));
R=[cos(theta),-sin(theta);sin(theta),cos(theta)];
end