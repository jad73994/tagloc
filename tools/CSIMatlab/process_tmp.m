clear
c=read_bf_file_channel('csi_test.dat');
h=zeros(length(c),1);
for i=1:length(h)
    h(i) = (c{i}.csi(1,1,1)./c{i}.csi(1,2,1));
end
figure; plot(angle(h),'.');