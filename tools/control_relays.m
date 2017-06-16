function [] = control_relays(whattodo)

%% Where the receive goes
if strcmp(whattodo,'usrp')
    urlread('http://192.168.1.4/30000/01'); %set to USRP
    pause(0.2);
end

if strcmp(whattodo,'vna')
    urlread('http://192.168.1.4/30000/00'); %set to VNA
    pause(0.2);
end


%% Where the transmit goes
if strcmp(whattodo,'cal')
    urlread('http://192.168.1.4/30000/02'); %set to calibration channel
    pause(0.2);
end

if strcmp(whattodo,'test')
    urlread('http://192.168.1.4/30000/03'); %set to test channel
    pause(0.2);
end


%% LNAs on/off
if strcmp(whattodo,'lnaon')
    urlread('http://192.168.1.4/30000/15'); %turn on lna
    pause(0.2);
end

if strcmp(whattodo,'lnaoff')
    urlread('http://192.168.1.4/30000/14'); %turn off lna (it gets hot)
    pause(0.2);
end
        

%% Which receive antenna

if strcmp(whattodo,'rcvnone')
    urlread('http://192.168.1.4/30000/22'); %turn off rcv1
    urlread('http://192.168.1.4/30000/24'); %turn off rcv2
    urlread('http://192.168.1.4/30000/26'); %turn off rcv3
    urlread('http://192.168.1.4/30000/28'); %turn off rcv4
    pause(0.05);
end

if strcmp(whattodo,'rcv1')
    urlread('http://192.168.1.4/30000/24'); %turn off rcv2
    urlread('http://192.168.1.4/30000/26'); %turn off rcv3
    urlread('http://192.168.1.4/30000/28'); %turn off rcv4
    pause(0.05);
    urlread('http://192.168.1.4/30000/23'); %turn on rcv1
    pause(0.05);
end

if strcmp(whattodo,'rcv2')
    urlread('http://192.168.1.4/30000/22'); %turn off rcv1
    urlread('http://192.168.1.4/30000/26'); %turn off rcv3
    urlread('http://192.168.1.4/30000/28'); %turn off rcv4
    pause(0.05);
    urlread('http://192.168.1.4/30000/25'); %turn on rcv2
    pause(0.05);
end

if strcmp(whattodo,'rcv3')
    urlread('http://192.168.1.4/30000/22'); %turn off rcv1
    urlread('http://192.168.1.4/30000/24'); %turn off rcv2
    urlread('http://192.168.1.4/30000/28'); %turn off rcv4
    pause(0.05);
    urlread('http://192.168.1.4/30000/27'); %turn on rcv3
    pause(0.05);
end

if strcmp(whattodo,'rcv4')
    urlread('http://192.168.1.4/30000/22'); %turn off rcv1
    urlread('http://192.168.1.4/30000/24'); %turn off rcv2
    urlread('http://192.168.1.4/30000/26'); %turn off rcv3
    pause(0.05);
    urlread('http://192.168.1.4/30000/29'); %turn on rcv4
    pause(0.05);
end

end