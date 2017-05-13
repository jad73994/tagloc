clear
close all


%% Script Parameters

frequencies = [897,913,927];
vnapoints = 1601;


instrreset
vna = Vna('model', Vna.MODEL_AGILENT_E5071C, 'iface', Instr.INSTR_IFACE_TCPIP, 'tcpipAddress', '192.168.128.1', 'tcpipPort', 5025 );
vna.SetTriggerContinuous;
%set to 600MHz - 1000MHz
%set to 1601 points


%% Capture

urlread('http://192.168.1.4/30000/00'); %set to VNA
urlread('http://192.168.1.4/30000/02'); %set to calibration channel
urlread('http://192.168.1.4/30000/15'); %turn on lna
pause(0.2);
    
calvna = zeros(1,vnapoints);
testvna = zeros(1,vnapoints);
    
for vnai = 1:10
    [vnax, ~, ~, vnay(vnai,:)]=vna.GetTraceData('Tr1');
    calvna = calvna + angle(vnay(vnai,:));
    pause(0.2);
end
    
urlread('http://192.168.1.4/30000/03'); %set to test channel
pause(0.2);
    
for vnai = 11:20
    [vnax, ~, ~, vnay(vnai,:)]=vna.GetTraceData('Tr1');
    testvna = testvna + angle(vnay(vnai,:));
    pause(0.2);
end
    
calvna = calvna ./ 10;
testvna = testvna ./ 10;
    
urlread('http://192.168.1.4/30000/02'); %set to calibration channel
urlread('http://192.168.1.4/30000/14'); %turn off lna (it gets hot)    

ftovna = round(((frequencies - 890) ./ 70) * vnapoints);
phases(1) = calvna(ftovna(1))-testvna(ftovna(1));
phases(2) = calvna(ftovna(2))-testvna(ftovna(2));
phases(3) = calvna(ftovna(3))-testvna(ftovna(3));
 
ftovna
phases
    
close all
chinese_remainder(phases, frequencies)        









