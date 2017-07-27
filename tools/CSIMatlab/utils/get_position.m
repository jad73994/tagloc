function pos=get_position(d,ant_pos,z,dim,origin)
if(isrow(d))
    d=d';
end
if(dim==2)
    pos=zeros(length(d)*(length(d)-1)/2,2);
    r=sqrt(d.^2-(ant_pos(:,3)-z).^2);
    idx=0;
    idx_valid=true(size(pos,1),1);
    for i=1:length(d)
        for j=i+1:length(d)
            [x,y]=circcirc(ant_pos(i,1),ant_pos(i,2),r(i),ant_pos(j,1),ant_pos(j,2),r(j));
            if(isnan(x(1)))
                [x,y]=mycirccirc(ant_pos(i,1),ant_pos(i,2),r(i),ant_pos(j,1),ant_pos(j,2),r(j));
               
            end
            idx=idx+1;
            
            %id=find(x<0);
            if(sum(isnan(x))>0)
                idx_valid(idx)=false;
            else
                [pos(idx,1),pos(idx,2)]=get_origin(x,y,ant_pos([i,j],:),origin(idx));%[x(id),y(id)];
            end
        end
    end
    pos=pos(idx_valid,:);
else
    fprintf('3-D not implemented yet\n');
end
end

function [x1,y1]=get_origin(x,y,ant_pos,origin)
so=sign((ant_pos(2,1)-ant_pos(1,1))*(-ant_pos(1,2))-(ant_pos(2,2)-ant_pos(1,2))*(-ant_pos(1,1)));
for i=1:2
    s(i)=sign((ant_pos(2,1)-ant_pos(1,1))*(y(i)-ant_pos(1,2))-(ant_pos(2,2)-ant_pos(1,2))*(x(i)-ant_pos(1,1)));
end
id=find(s==so,1);
if(isempty(id))
    id=1;
end
if(origin)
    x1=x(id); y1=y(id);
else
    x1=x(id-(-1)^id); y1=y(id-(-1)^id);
end
end

function [x,y]=mycirccirc(x1,y1,r1,x2,y2,r2)
    points=-7.5:0.02:7.5;
    
    A1=repmat((points.'-x1).^2,1,length(points));
    A1=A1+repmat((points-y1).^2,length(points),1);
    A1=(A1-r1^2).^2;
    A2=repmat((points.'-x2).^2,1,length(points));
    A2=A2+repmat((points-y2).^2,length(points),1);
    A2=(A2-r2^2).^2;
    A=A1+A2;
    [~,id]=min(A(:));
    [a,b]=ind2sub(size(A),id);
    x=points(a);
    y=points(b);
    
    
    [x1n,y1n]=linecirc((y2-y1)/(x2-x1),y1-x1*(y2-y1)/(x2-x1),x1,y1,r1);
    [x2n,y2n]=linecirc((y2-y1)/(x2-x1),y1-x1*(y2-y1)/(x2-x1),x2,y2,r2);
    x1=x1n;
    x2=x2n;
    y1=y1n;
    y2=y2n;
    a1=norm([x1(1),y1(1)]-[x2(1),y2(1)]);
    b1=norm([x1(2),y1(2)]-[x2(1),y2(1)]);
    if(a1<b1)
        x(1)=(x1(1)+x2(1))/2;
        y(1)=(y1(1)+y2(1))/2;
        x(2)=(x1(2)+x2(2))/2;
        y(2)=(y1(2)+y2(2))/2;
        
    else
        x(1)=(x1(2)+x2(1))/2;
        y(1)=(y1(2)+y2(1))/2;
        x(2)=(x1(1)+x2(2))/2;
        y(2)=(y1(1)+y2(2))/2;
    end
    
end