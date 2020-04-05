function [smooth]=smoother(twoD,patchstruct)

areas=[patchstruct.L]'.*[patchstruct.W]';
np  = length(areas);


smooth=eye(np);

for i=1:np
   connect=patchstruct(i).connect;
   connect=connect(isfinite(connect));
   areasum=sum(areas(connect));
   for j=1:length(connect)
     smooth(i,connect(j))=-areas(connect(j))/areasum;
     %smooth(connect(j),i)=smooth(i,connect(j));
  end
end

if (twoD==2)
  smooth=blkdiag(smooth,smooth);
end
