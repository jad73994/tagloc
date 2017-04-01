clear
close all

dir = '/home/abari/Desktop/tagloc/';
txtty = '4';
rxtty = '3';

unix(strcat(['sudo python ',dir,'ttyexec.py pts/',txtty,' "tx ',dir,'OFDM_fakecfo 2 13e3"']))
pause(1.5);
unix(strcat(['sudo python ',dir,'ttyexec.py pts/',rxtty,' "rx ',dir,'rxdata/ 150000000"']))
pause(40);

file0 = strcat(dir,'rxdata/_0.dat');
file1 = strcat(dir,'rxdata/_1.dat');
file2 = strcat(dir,'rxdata/_2.dat');

a=read_complex_binary2(file0,1e7,1e6);
b=read_complex_binary2(file1,1e7,1e6);
c=read_complex_binary2(file2,1e7,1e6);


%x= x(1:1e5);

% a = a(5800000:5810000);
% b = b(5779250:5779350);
% c = c(5779250:5779350);
% d = d(5779250:5779350);
% % eo = eo(40500:40600);
% 
% a_log = abs(a)>((max(abs(a))-min(abs(a)))/2);
% b_log = abs(b)>((max(abs(b))-min(abs(b)))/2);
% c_log = abs(c)>((max(abs(c))-min(abs(c)))/2);
% d_log = abs(d)>((max(abs(d))-min(abs(d)))/2);

% 
% ar = real(a);
% ai = imag(a);
% br = real(b);
% bi = imag(b);
% cr = real(c);
% ci = imag(c);
% dr = real(d);
% di = imag(d);
% eor = real(eo);
% eoi = imag(eo);
% 
% a = ((ar-mean(ar)) + 1j.*(ai-mean(ai)));
% b = ((br-mean(br)) + 1j.*(bi-mean(bi)));
% c = ((cr-mean(cr)) + 1j.*(ci-mean(ci)));
% d = ((dr-mean(dr)) + 1j.*(di-mean(di)));
% eo = ((eor-mean(eor)) + 1j.*(eoi-mean(eoi)));

% a_f = fftshift(fft(a));
% b_f = fftshift(fft(b));
% c_f = fftshift(fft(c));
% d_f = fftshift(fft(d));
% 
% [~,peaks_loc_a] = findpeaks(abs(a_f),'MinPeakHeight',max(abs(a_f))*(9/10),'MinPeakDistance',100);
% [~,peaks_loc_b] = findpeaks(abs(b_f),'MinPeakHeight',max(abs(b_f))*(9/10),'MinPeakDistance',100);
% [~,peaks_loc_c] = findpeaks(abs(c_f),'MinPeakHeight',max(abs(c_f))*(9/10),'MinPeakDistance',100);
% [~,peaks_loc_d] = findpeaks(abs(d_f),'MinPeakHeight',max(abs(d_f))*(9/10),'MinPeakDistance',100);

% ant_pos(1) = 0;
% ant_pos(2) = 0.1638;
% ant_pos(3) = 0.3276;
% ant_pos(4) = 0.4915;
% 
% theta_vals = (1:1:180)*pi/180;
% 
% M = zeros(size(theta_vals));
% 
% j = 533000
% t = 0;
% 
% for i=1:1000
%     if j > size(a_log)
%         break;
%     end
%     
%     if a_log(j) == 1
%         t = t + 1;
%         
%         h(1) = a(j);
%         h(2) = b(j);
%         h(3) = c(j);
%         h(4) = d(j);
% 
%         M = M + compute_multipath_profile(h, ant_pos, 0.3276, theta_vals);
%     end
%        
%     j = j + 100;
% end


%da = [zeros(1e3)' a]
%phasediff = a .* conj(b);

figure(1)
subplot(221);
plot(imag(a));

subplot(222);
plot(imag(b));

subplot(223);
plot(imag(c));

subplot(224);
%plot(real(d));

% 
% 
% ppd = angle(phasediff);
% ppds = size(ppd);
% lregx = [ones(ppds(1),1) (1:ppds(1))'];
% lregb = lregx\ppd;
% lreg = lregx*lregb;
% 
% figure(2)
% subplot(211);
% plot(ppd)
% hold on
% plot(lreg, 'r')
% subplot(212);
% plot(abs(phasediff));
% 
% fftplot(a,5e6,11,'r',1);
% fftplot(b,5e6,11,'k',1);
% %fftplot(x,5e5,11,'g',1);
% 
% 
% load('ofdm_tx_signal.mat','tx_vec_air', 'tx_syms_mat', 'tx_data', 'tx_syms' ,'N_DATA_SYMS');
% 
% [al, bl] = xcorr(a,tx_vec_air);
% alabs = abs(al);
% [~, peaks] = findpeaks(alabs, 'MinPeakHeight', max(alabs) - (max(alabs)/10), 'MinPeakDistance', floor(max(bl)/10));
% 
% figure(3)
% plot(alabs)
% hold on
% plot(peaks, alabs(peaks), 'rv', 'MarkerFaceColor', 'r')
% 
% usepeak = 1;
% if (peaks(1) < length(bl)/2)
%     usepeak = 2;
% end
% 
% rx_chop = a(peaks(usepeak) - (length(bl)/2) - 10 : peaks(usepeak) + length(tx_vec_air) - (length(bl)/2) + 20)
% 
% figure(4)
% plot(abs(rx_chop))
% 
% 
% %figure(2)
% %plot(theta_vals, abs(M))

% %figure(3)
%quiver(0,0,cos((pi/2)-peakangle),sin((pi/2)-peakangle))
%set(gca, 'XLim', [-1,1], 'YLim', [-1,1]);
