function [ zp ] = zero_subchannel_phase(h)

uafs = unwrap(angle(fftshift(h)));

xr_left = [ones(26,1) ([7:32]).'];
xr_right = [ones(26,1) ([34:59]).'];
    
rr_left = xr_left\(uafs([7:32])).';
rr_right = xr_right\(uafs([34:59])).';
  
rr_left(1) = mod(rr_left(1)+pi,2*pi)-pi;
rr_right(1) = mod(rr_right(1)+pi,2*pi)-pi;

lr(1) = rr_left(1);
lr(2) = (rr_left(2)+rr_right(2))/2;

zp = lr(1) + lr(2)*33;

end