function [] = control_relays(whattodo)

%% Wire or wireless
if strcmp(whattodo,'cal')
    urlread('http://192.168.1.4/30000/01'); %set to wire
    pause(0.1);
end

if strcmp(whattodo,'test')
    urlread('http://192.168.1.4/30000/00'); %set to wireless
    pause(0.1);
end

%% LNAs on/off
if strcmp(whattodo,'lnaon')
    urlread('http://192.168.1.4/30000/15'); %turn on lna
    pause(0.1);
end

if strcmp(whattodo,'lnaoff')
    urlread('http://192.168.1.4/30000/14'); %turn off lna (it gets hot)
    pause(0.1);
end

%% Which AP
if strcmp(whattodo,'ap1')
    urlread('http://192.168.1.4/30000/03'); %switch to ap1
    pause(0.1);
end

if strcmp(whattodo,'ap2')
    urlread('http://192.168.1.4/30000/02'); %switch to ap2
    pause(0.1);
end


%% Which receive antenna AP1

if strcmp(whattodo,'ap1rcvnone')
    urlread('http://192.168.1.4/30000/24'); %turn off rcv1
    urlread('http://192.168.1.4/30000/26'); %turn off rcv2
    urlread('http://192.168.1.4/30000/28'); %turn off rcv3
    urlread('http://192.168.1.4/30000/30'); %turn off rcv4
    pause(0.1);
end

if strcmp(whattodo,'ap1rcv1')
    urlread('http://192.168.1.4/30000/26'); %turn off rcv2
    urlread('http://192.168.1.4/30000/28'); %turn off rcv3
    urlread('http://192.168.1.4/30000/30'); %turn off rcv4
    pause(0.1);
    urlread('http://192.168.1.4/30000/25'); %turn on rcv1
    pause(0.1);
end

if strcmp(whattodo,'ap1rcv2')
    urlread('http://192.168.1.4/30000/24'); %turn off rcv1
    urlread('http://192.168.1.4/30000/28'); %turn off rcv3
    urlread('http://192.168.1.4/30000/30'); %turn off rcv4
    pause(0.1);
    urlread('http://192.168.1.4/30000/27'); %turn on rcv2
    pause(0.1);
end

if strcmp(whattodo,'ap1rcv3')
    urlread('http://192.168.1.4/30000/24'); %turn off rcv1
    urlread('http://192.168.1.4/30000/26'); %turn off rcv2
    urlread('http://192.168.1.4/30000/30'); %turn off rcv4
    pause(0.1);
    urlread('http://192.168.1.4/30000/29'); %turn on rcv3
    pause(0.1);
end

if strcmp(whattodo,'ap1rcv4')
    urlread('http://192.168.1.4/30000/24'); %turn off rcv1
    urlread('http://192.168.1.4/30000/26'); %turn off rcv2
    urlread('http://192.168.1.4/30000/28'); %turn off rcv3
    pause(0.1);
    urlread('http://192.168.1.4/30000/31'); %turn on rcv4
    pause(0.1);
end


%% Which receive antenna AP2

if strcmp(whattodo,'ap2rcvnone')
    urlread('http://192.168.1.4/30000/16'); %turn off rcv1
    urlread('http://192.168.1.4/30000/18'); %turn off rcv2
    urlread('http://192.168.1.4/30000/20'); %turn off rcv3
    urlread('http://192.168.1.4/30000/22'); %turn off rcv4
    pause(0.1);
end

if strcmp(whattodo,'ap2rcv1')
    urlread('http://192.168.1.4/30000/18'); %turn off rcv2
    urlread('http://192.168.1.4/30000/20'); %turn off rcv3
    urlread('http://192.168.1.4/30000/22'); %turn off rcv4
    pause(0.1);
    urlread('http://192.168.1.4/30000/17'); %turn on rcv1
    pause(0.1);
end

if strcmp(whattodo,'ap2rcv2')
    urlread('http://192.168.1.4/30000/16'); %turn off rcv1
    urlread('http://192.168.1.4/30000/20'); %turn off rcv3
    urlread('http://192.168.1.4/30000/22'); %turn off rcv4
    pause(0.1);
    urlread('http://192.168.1.4/30000/19'); %turn on rcv2
    pause(0.1);
end

if strcmp(whattodo,'ap2rcv3')
    urlread('http://192.168.1.4/30000/16'); %turn off rcv1
    urlread('http://192.168.1.4/30000/18'); %turn off rcv2
    urlread('http://192.168.1.4/30000/22'); %turn off rcv4
    pause(0.1);
    urlread('http://192.168.1.4/30000/21'); %turn on rcv3
    pause(0.1);
end

if strcmp(whattodo,'ap2rcv4')
    urlread('http://192.168.1.4/30000/16'); %turn off rcv1
    urlread('http://192.168.1.4/30000/18'); %turn off rcv2
    urlread('http://192.168.1.4/30000/20'); %turn off rcv3
    pause(0.1);
    urlread('http://192.168.1.4/30000/23'); %turn on rcv4
    pause(0.1);
end

%% Turn everything off

if strcmp(whattodo,'alloff')
    control_relays('ap1rcvnone');
    control_relays('ap2rcvnone');
    control_relays('lnaoff');
    control_relays('test');
    control_relays('ap2');
end

end