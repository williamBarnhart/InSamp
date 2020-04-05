function dists=dist_point_lines(xp,yp,xl,yl)

nl=length(xl)-1;
np=length(xp);

dists=zeros(np,nl);

for i=1:nl
  d1=sqrt((xp-xl(i)).^2+(yp-yl(i)).^2);
  d2=sqrt((xp-xl(i+1)).^2+(yp-yl(i+1)).^2);

  dx=xl(i+1)-xl(i);
  dy=yl(i+1)-yl(i);

  if(sqrt(dx^2+dy^2)==0)
    dl=d1;
    n1=0;
    n2=0;
  else
    dl=abs((xp-xl(i))*dy-(yp-yl(i))*dx)/sqrt(dx^2+dy^2);
      
    n1=yl(i)-dx/dy*(xp-xl(i));
    n2=yl(i+1)-dx/dy*(xp-xl(i+1));
  
  end  
  da=min([d1 d2 dl],[],2);
  db=min([d1 d2],[],2);
    
  goodid=find(and(yp>=n1,yp<=n2));

  dists(:,i) = db;
  dists(goodid,i)=da(goodid);
  
end

dists=min(dists,[],2);