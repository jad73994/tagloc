num_entries = length(intel_log);
csi = cell(1,num_entries);
csi_tx1_rx1_ch1 = zeros(1,num_entries);
csi_tx1_rx2_ch1 = zeros(1,num_entries);
num_tx = zeros(1,num_entries);
timestamp = zeros(1,num_entries);
ch = 5;
for i = 1:num_entries
    timestamp(i) = intel_log{i}.timestamp_low;
    csi{i} = intel_log{i}.csi;
    csi_tx1_rx1_ch1(i) = csi{i}(1,1,ch);
    csi_tx1_rx2_ch1(i) = csi{i}(1,2,ch);
    csi_tx1_rx3_ch1(i) = csi{i}(1,3,ch);
    num_tx(i) = intel_log{i}.Ntx;
end
close all
plot((csi_tx1_rx1_ch1),'*')
plot(timestamp,phase(csi_tx1_rx2_ch1./csi_tx1_rx1_ch1),'*');
hold on;
plot(timestamp,phase(csi_tx1_rx3_ch1./csi_tx1_rx2_ch1),'r*');
