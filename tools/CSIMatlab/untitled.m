clear
c=read_bf_file('csi.dat');
h=zeros(length(c),1);
for i=1:length(h)
    h(i) = c{i}.csi(1,1,1)./c{i}.csi(1,1,1);
end