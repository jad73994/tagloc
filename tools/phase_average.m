function [ pa ] = phase_average(phases)

xs = cos(phases);
ys = sin(phases);

avgx = mean(xs);
avgy = mean(ys);

pa = atan2(avgy,avgx);

end