function [ h, bits_data_rcv, avg_SNR,xx,yy, SNR_in_dB,return_SNR] = rx_ofdm_chain4QAM(rx_signal,QAMsize,rngInput,offset, knowncfo)
%function [ bits_data_rcv,shift ] = rx_ofdm_chain4QAM(rx_signal,QAMsize)

avg_SNR= 0;
ldfrmfile = 1;
cfo_syms = 6;

load Parameters.mat

if(ldfrmfile==0)
   num_bins = 64;
   gaurd_bins =[-32,-31,-30,-29,-28,-27,0,27,28,29,30,31];
   pilots = [-21,-7,7,21];
   cp = 16;
end


num_packets = 1000;
packet_size = num_syms_preamble*num_bins + cp;
packet_size = packet_size + (num_syms_data/QAMsize)*(num_bins+cp);


bits_data_rcv = [];
subcarrier_config = ones(1,num_bins);
subcarrier_config(convert_bin_index_normal_to_fft(gaurd_bins,num_bins)) = 0;
subcarrier_config(convert_bin_index_normal_to_fft(pilots,num_bins)) = 3; 


%% PACKET DETECTION


avg_SNR= 0;
ldfrmfile = 1;

if(ldfrmfile==0)
   num_bins = 64;
   gaurd_bins =[-32,-31,-30,-29,-28,-27,0,27,28,29,30,31];
   pilots = [-21,-7,7,21];
   cp = 16;
end


bits_data_rcv = [];
subcarrier_config = ones(1,num_bins);
subcarrier_config(convert_bin_index_normal_to_fft(gaurd_bins,num_bins)) = 0;
subcarrier_config(convert_bin_index_normal_to_fft(pilots,num_bins)) = 3; 

current_index = 1;

packet_start = packet_detection(rx_signal(current_index:end)) + 6
%packet_start = 2920328;


%peakIndices = all_Packet_Detection(rx_signal(current_index:end));

figure(4)
hold on
plot(packet_start,0.0003,'-r*')
hold off

current_index = packet_start+ceil(cp/4);
current_index = current_index + 4;

%% CFO ESTIMATION AND CORRECTION

%TESTING CFO ESTIMATE
arxs = angle(rx_signal);
figure(1413432)
hold all
for test_num_cfo = 1:96
    phases(test_num_cfo) = arxs(current_index + 6 + test_num_cfo*num_bins);
    amplitudes(test_num_cfo) = abs(rx_signal(current_index + 6 + test_num_cfo*num_bins));
    plot(db(abs(rx_signal(current_index+test_num_cfo*num_bins:current_index+test_num_cfo*num_bins+num_bins))))
    
    for packeti = 1:num_packets
        cfo_test(packeti) = estimate_cfo(rx_signal(current_index:current_index+((test_num_cfo/2)*num_bins)-1),rx_signal(current_index+((test_num_cfo/2)*num_bins):current_index+(test_num_cfo*num_bins)-1),fs);
        current_index = current_index + packet_size;
    end
    current_index = current_index - packet_size*num_packets;
    mean_cfos_test(test_num_cfo) = mean(cfo_test);
    std_cfos_test(test_num_cfo) = std(cfo_test);
end

figure(242341251)
plot(unwrap(phases))

figure(234234233)
plot(amplitudes)

figure(13415151)
plot(mean_cfos_test(2:2:end))


figure(9769876)
plot(std_cfos_test(2:2:end))
%TESTING CFO ESTIMATE


%%do cfo estimation
for packeti = 1:num_packets
    cfoi(packeti) = estimate_cfo(rx_signal(current_index:current_index+((cfo_syms/2)*num_bins)-1),rx_signal(current_index+((cfo_syms/2)*num_bins):current_index+(cfo_syms*num_bins)-1),fs);
    current_index = current_index + packet_size;
end
mean_cfo = mean(cfoi)
%mean_cfo = 0;

figure(23423)
plot(cfoi)



%correct cfo
rx_signal2 = correct_cfo(rx_signal, mean_cfo, fs, offset);
current_index = current_index - packet_size*num_packets + 94*num_bins;



%%channel estimation
for packeti = 1:num_packets
    [h,shift,absVal] = estimate_channel(rx_signal2(current_index:current_index+num_bins-1),rx_signal2(current_index+num_bins:current_index+2*num_bins-1));

    uafs = unwrap(angle(fftshift(h)));

    xr_left = [ones(26,1) ([7:32]).'];
    xr_right = [ones(26,1) ([34:59]).'];
    
    rr_left = xr_left\(uafs([7:32])).';
    rr_right = xr_right\(uafs([34:59])).';
    
    rr_left(1) = mod(rr_left(1)+pi,2*pi)-pi;
    rr_right(1) = mod(rr_right(1)+pi,2*pi)-pi;

    lr(1,packeti) = rr_left(1);
    lr(2,packeti) = (rr_left(2)+rr_right(2))/2;
 
    current_index = current_index + packet_size; 
end



%correct residual cfo
coeffs = polyfit(1:1000,unwrap(lr(1,:) + 33*lr(2,:)),1);
slp = coeffs(1);
rcf = (slp*1000) / (2*pi*9.28314);
cfo = mean_cfo + rcf;

if knowncfo ~= -1
    cfo = knowncfo;
end

cfo

rx_signal = correct_cfo(rx_signal, cfo, fs, offset);
current_index = current_index - packet_size*num_packets;


%%channel estimation again
for packeti = 1:num_packets
    [h,shift,absVal] = estimate_channel(rx_signal(current_index:current_index+num_bins-1),rx_signal(current_index+num_bins:current_index+2*num_bins-1));

    uafs = unwrap(angle(fftshift(h)));

    xr_left = [ones(26,1) ([7:32]).'];
    xr_right = [ones(26,1) ([34:59]).'];
    
    rr_left = xr_left\(uafs([7:32])).';
    rr_right = xr_right\(uafs([34:59])).';
    
    rr_left(1) = mod(rr_left(1)+pi,2*pi)-pi;
    rr_right(1) = mod(rr_right(1)+pi,2*pi)-pi;

    lr(1,packeti) = rr_left(1);
    lr(2,packeti) = (rr_left(2)+rr_right(2))/2;
 
    current_index = current_index + packet_size; %go to next CFO preambles
end



figure(34352)
hold all
plot(unwrap(lr(1,:) + 33*lr(2,:)))




%Calculate zero subchannel phase

slope = 0;
yint = 0;
numinc = 0;

for i=1:length(lr(1,:))
    if abs(lr(1,i)) < (abs(median(lr(1,:)))+0.4)
        if abs(lr(1,i)) > (abs(median(lr(1,:)))-0.4)
            if abs(lr(2,i)) < (abs(median(lr(2,:)))+0.4)
                if abs(lr(2,i)) > (abs(median(lr(2,:)))-0.4)
                    numinc = numinc + 1;
                    yint = yint + lr(1,i);
                    slope = slope + lr(2,i);

                    zp_store(numinc,1) = mod(lr(1,i) + lr(2,i)*33 + pi, 2*pi) - pi;
                    zp_store1(numinc,1) = mod(lr(1,i) + lr(2,i)*33, 2*pi);
                end
            end
        end
    end
end

%slope = slope/numinc
%yint = yint/numinc
numinc
%zp = mod(yint + slope*33 + pi, 2*pi) - pi
zp = mean(zp_store)
std_dev = std(zp_store)

zp1 = mod(mean(zp_store1) + pi, 2*pi) - pi
std_dev1 = std(zp_store1)


figure(78); plot(abs(fftshift(h)));
figure(79); hold all; plot(angle(fftshift(h)));




%set the pointer back so we decode the last packet.
current_index = current_index - packet_size + 2*num_bins + cp;


%% DECODING
noise_power=0;
     if QAMsize == 1
         scale = 1;
        limits = -scale:0.1:scale;
        figure(3)
        hold on
        plot(0,limits,'red');
        hold off
     end
     if QAMsize == 2
         scale = sqrt(2);
%         limits = -scale:0.1:scale;
%         figure(3)
%         hold on
%         plot(limits,0,'red');
%         plot(0,limits,'red');
%         hold off
     end
     if QAMsize == 4
        scale = sqrt(10); 
       limits = -scale:0.1:scale;
       figure(3)
       hold on
          plot(limits,0,'red');plot(limits,2,'red'); plot(limits,-2,'red');
          plot(0,limits,'red');plot(2,limits,'red');plot(-2,limits,'red'); 
        hold off
     end
    if QAMsize == 6
        scale = sqrt(42); 
%        limits = -scale:0.1:scale;
%        figure(3)
%        hold on
%        plot(limits,0,'red');plot(limits,2,'red');plot(limits,4,'red');plot(limits,6,'red');plot(limits,-2,'red');plot(limits,-4,'red');plot(limits,-6,'red');
%        plot(0,limits,'red');plot(2,limits,'red');plot(4,limits,'red');plot(6,limits,'red');plot(-2,limits,'red');plot(-4,limits,'red');plot(-6,limits,'red');
%         hold off
     end
     if QAMsize == 8
        scale = sqrt(170);
       limits = -scale*1.2:0.1:scale*1.2;
      figure(3)
        hold on
        plot(limits,0,'red');plot(limits,2,'red');plot(limits,4,'red');plot(limits,6,'red');plot(limits,8,'red');plot(limits,10,'red');plot(limits,12,'red');plot(limits,14,'red');plot(limits,-2,'red');plot(limits,-4,'red');plot(limits,-6,'red');plot(limits,-8,'red');plot(limits,-10,'red');plot(limits,-12,'red');plot(limits,-14,'red');
        plot(0,limits,'red');plot(-2,limits,'red');plot(-4,limits,'red');plot(-6,limits,'red');plot(-8,limits,'red');plot(-10,limits,'red');plot(-12,limits,'red');plot(-14,limits,'red');plot(2,limits,'red');plot(4,limits,'red');plot(6,limits,'red');plot(8,limits,'red');plot(10,limits,'red');plot(12,limits,'red');plot(14,limits,'red');
        hold off
     end
    
bits_data = getBitsData(rngInput);

SNR_per_symbol = zeros(1,floor(num_syms_data/QAMsize));

    for m = 1:1:100%(floor(num_syms_data/QAMsize)) %%%%%%%%%%%%%%%%remove 10
        symt = rx_signal(current_index:current_index+num_bins-1);
        symf = (1/sqrt(num_bins))*fft(symt);
        [r_cfo r_sfo] = estimate_residual_cfo_sfo(symf, h);
        r_cfo;
        h = correct_residual_cfo_sfo(h, r_cfo , r_sfo);
        symf = correct_channel(symf,h); 
        bits = decodeQAM(subcarrier_config, symf, QAMsize,scale);
        %bits = symf(subcarrier_config==1) < 0;
        bits_data_rcv = [bits_data_rcv, bits];
        current_index = current_index + num_bins+cp;
    
    
        noise_power=noise_power+ (real(symf)-round(real(symf))).^2+ imag(symf).^2;

         figure(3)
         hold on
         xx(m,:)=real(symf(subcarrier_config==1))*scale;
         yy(m,:)=imag(symf(subcarrier_config==1))*scale;
         plot(xx(m,:),yy(m,:),'*')
         xlim([-scale*sqrt(2),+scale*sqrt(2)])
         ylim([-scale*sqrt(2),+scale*sqrt(2)])
         title(sprintf('symbol %d',m));
         pause(0.002);
         hold off
         [SNR_per_symbol(m),SNR_per_bin(m,:)] = calcSNR_NP(subcarrier_config,symf,bits_data,m, QAMsize, scale);
    end
  
    avg_SNR = median(10*log10(SNR_per_symbol));

    return_SNR = median(10*log10(SNR_per_bin));
    

SNR=10*log10(1./(noise_power/num_syms_data));
useful_SNR = [SNR(2:27),SNR(39:64)];
avg_SNR = mean(useful_SNR);


median_SNR = median(useful_SNR);
 figure(10)
 hold on
  rng('shuffle')
 % plot(return_SNR,'Color',rand(3,1));
 plot(10*log10(SNR_per_symbol),'Color',rand(3,1));
 med_SNR = median(10*log10(SNR_per_symbol(1:100)))
 SNR_in_dB = 10*log10(SNR_per_symbol(1:100));
 ylim([-10 50]) 
 %figure(11)
 %plot(abs(fft(10*log10(SNR_per_symbol))),'Color',rand(3,1));
 %end
end