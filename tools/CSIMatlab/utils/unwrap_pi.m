function h=unwrap_pi(h)
% for i=2:length(h)
%     if(angle(h(i)/h(i-1))>pi/2)
%         h(i:end)=-h(i:end);
%     end
% end
for i=3:length(h)
    %if((dop(h(i)-h(i-1),h(i-1)-h(i-2)))<(dop(-h(i)-h(i-1),h(i-1)-h(i-2))))
    %    h(i:end)=-h(i:end);
    %end
    v=h(i-1)+(h(i-1)-h(i-2));
    %if(abs(h(i)-v)>abs(-h(i)-v))
    d1=dop(v-h(i-1),-h(i)-h(i-1));
    d2=dop(v-h(i-1),h(i)-h(i-1));
    a1=abs(-h(i)-v);
    a2=abs(h(i)-v);
    %if(dop(v-h(i-1),-h(i)-h(i-1))/abs(-h(i)-v)>dop(v-h(i-1),h(i)-h(i-1))/abs(h(i)-v))
    %if(d1/(abs(d1)+abs(d2))-a1/(a1+a2)>d2/(abs(d1)+abs(d2))-a2/(a1+a2))
    if((d1>d2 && abs(-h(i)-v)<abs(h(i)-v)*2)||abs(-h(i)-v)*2<abs(h(i)-v))
        h(i:end)=-h(i:end);
    end
end
for i=length(h)-2:-1:1
    %if((dop(h(i)-h(i+1),h(i+1)-h(i+2)))<(dop(-h(i)-h(i+1),h(i+1)-h(i+2))))
    %    h(1:i)=-h(1:i);
    %end
    v=h(i+1)+(h(i+1)-h(i+2));
    d1=dop(v-h(i+1),-h(i)-h(i+1));
    d2=dop(v-h(i+1),h(i)-h(i+1));
    a1=abs(-h(i)-v);
    a2=abs(h(i)-v);
    %if(dop(v-h(i+1),-h(i)-h(i+1))/abs(-h(i)-v)>dop(v-h(i+1),h(i)-h(i+1))/abs(h(i)-v))
    %if(d1/(abs(d1)+abs(d2))-a1/(a1+a2)>d2/(abs(d1)+abs(d2))-a2/(a1+a2))
    %if(abs(h(i)-v)>abs(-h(i)-v))
    if((d1>d2 && abs(-h(i)-v)<abs(h(i)-v)*2)||abs(-h(i)-v)*2<abs(h(i)-v))
        h(1:i)=-h(1:i);
    end
    
end
end

function dp=dop(c1,c2)
    dp=(real(c1).*real(c2)+imag(c1).*imag(c2))./abs(c1)./abs(c2);
end