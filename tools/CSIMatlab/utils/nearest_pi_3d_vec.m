function t=nearest_pi_3d_vec(X,Y,Z,ant_x,ant_y,ant_z,p,lambda)
    t=round((2*pi/lambda*(sqrt((X-ant_x(1)).^2+(Y-ant_y(1)).^2+(Z-ant_z(1)).^2)-sqrt((X-ant_x(2)).^2+(Y-ant_y(2)).^2+(Z-ant_z(2)).^2))+p(1))/2/pi);
end