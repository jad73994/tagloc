function [a_n1,a_n2]=remove_slope(a1,a2,x)
slope1=regress(a1',[x', ones(length(x),1)]);
slope2=regress(a2',[x', ones(length(x),1)]);
slope(1)=(slope1(1)+slope2(1))/2;
a_n1=a1-slope(1)*x;
a_n2=a2-slope(1)*x;
end