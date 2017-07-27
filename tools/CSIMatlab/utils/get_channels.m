function out=get_channels(filename,isdrone)
if(~exist('isdrone','var'))
    isdrone=false;
end
for i=1:length(filename)
    if(~isdrone)
        [out.channels{i}, out.timestamp{i},out.packet_ids{i},out.MACs{i},out.sec{i},out.usec{i},out.ht40{i}]=process_trace_channel(filename{i},[]);
    else
        [out.channels{i}, out.timestamp{i},out.packet_ids{i},out.MACs{i},out.sec{i},out.usec{i},out.ht40{i},out.ant_tx{i},out.ant_rx{i}]=process_trace_drone(filename{i},[]);
    end
end
end