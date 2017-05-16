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
%turn off beep


%% Capture

control_relays('vna');
control_relays('cal');
control_relays('lnaon');
pause(0.2);

calvna1temp = zeros(10,vnapoints);
calvna2temp = zeros(10,vnapoints);
calvna3temp = zeros(10,vnapoints);
calvna4temp = zeros(10,vnapoints);
testvna1temp = zeros(10,vnapoints);
testvna2temp = zeros(10,vnapoints);
testvna3temp = zeros(10,vnapoints);
testvna4temp = zeros(10,vnapoints);

control_relays('rcv1');
for vnai = 1:10
    [vnax, ~, ~, calvna1temp(vnai,:)]=vna.GetTraceData('Tr1');
    pause(0.2);
end
control_relays('rcv2');
for vnai = 1:10
    [vnax, ~, ~, calvna2temp(vnai,:)]=vna.GetTraceData('Tr1');
    pause(0.2);
end
control_relays('rcv3');
for vnai = 1:10
    [vnax, ~, ~, calvna3temp(vnai,:)]=vna.GetTraceData('Tr1');
    pause(0.2);
end
control_relays('rcv4');
for vnai = 1:10
    [vnax, ~, ~, calvna4temp(vnai,:)]=vna.GetTraceData('Tr1');
    pause(0.2);
end


control_relays('test');

    
control_relays('rcv1');
for vnai = 1:10
    [vnax, ~, ~, testvna1temp(vnai,:)]=vna.GetTraceData('Tr1');
    pause(0.2);
end
control_relays('rcv2');
for vnai = 1:10
    [vnax, ~, ~, testvna2temp(vnai,:)]=vna.GetTraceData('Tr1');
    pause(0.2);
end
control_relays('rcv3');
for vnai = 1:10
    [vnax, ~, ~, testvna3temp(vnai,:)]=vna.GetTraceData('Tr1');
    pause(0.2);
end
control_relays('rcv4');
for vnai = 1:10
    [vnax, ~, ~, testvna4temp(vnai,:)]=vna.GetTraceData('Tr1');
    pause(0.2);
end


control_relays('cal');
control_relays('lnaoff');

calvna1 = zeros(1,vnapoints);
testvna1 = zeros(1,vnapoints);
calvna2 = zeros(1,vnapoints);
testvna2 = zeros(1,vnapoints);
calvna3 = zeros(1,vnapoints);
testvna3 = zeros(1,vnapoints);
calvna4 = zeros(1,vnapoints);
testvna4 = zeros(1,vnapoints);

for i = 1:vnapoints
    calvna1(i) = phase_average(angle(calvna1temp(:,i)));
    calvna2(i) = phase_average(angle(calvna2temp(:,i)));
    calvna3(i) = phase_average(angle(calvna3temp(:,i)));
    calvna4(i) = phase_average(angle(calvna4temp(:,i)));
    testvna1(i) = phase_average(angle(testvna1temp(:,i)));
    testvna2(i) = phase_average(angle(testvna2temp(:,i)));
    testvna3(i) = phase_average(angle(testvna3temp(:,i)));
    testvna4(i) = phase_average(angle(testvna4temp(:,i)));
end

ftovna = round(((frequencies - 890) ./ 70) * vnapoints);
phases1 = calvna1(ftovna)-testvna1(ftovna);
phases2 = calvna2(ftovna)-testvna2(ftovna);
phases3 = calvna3(ftovna)-testvna3(ftovna);
phases4 = calvna4(ftovna)-testvna4(ftovna);
%     
% close all
% chinese_remainder(phases, frequencies)        









