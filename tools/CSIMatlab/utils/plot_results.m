ant_num=2;
for i=1:length(DP_M{ant_num})
    figure(1); clf; plot(d_vals,abs(DP_M{ant_num}{i}));
    hold on; plot(mod([ground(i,13+ant_num),ground(i,13+ant_num)]+offset(ant_num),7.5),[min(abs(DP_M{ant_num}{i})),max(abs(DP_M{ant_num}{i}))],'m');
    hold on; plot(mod([dist(i,ant_num),dist(i,ant_num)]+offset(ant_num),7.5),[min(abs(DP_M{ant_num}{i})),max(abs(DP_M{ant_num}{i}))],'r');
    title(i);
    pause(1);
end