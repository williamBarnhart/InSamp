function [patchstruct,totLp,Wp,Lps]=ver2patchconnect(faultstruct,targetLp,Wp,faultnp);

[junk,numfaults] = size(faultstruct);

if(length(faultnp)>1)
  id=1;
  for i=1:length(faultnp)
    breakno(id:(id+faultnp(i)-1))=i;
    id=id+faultnp(i);
  end
else
  breakno=faultnp;
end
  
totL=0;
totLp=0;
for k=1:numfaults
  totL  = totL+faultstruct(k).L;
end


for k=1:numfaults
  Lp    = fix(faultstruct(k).L/totL*targetLp);
  if (Lp==0) Lp=1; end
  Lps(k)=Lp;
  totLp = totLp+Lp;
end

for k=1:numfaults
  xt     = mean(faultstruct(k).vertices(1,:));
  yt     = mean(faultstruct(k).vertices(2,:));
  strike = faultstruct(k).strike;
  L      = faultstruct(k).L;
  W      = faultstruct(k).W;
  dip    = faultstruct(k).dip;
  zt     = faultstruct(k).zt;
  Lp     = Lps(k);

  if(dip>0)
    x0        = xt+W.*cosd(dip).*cosd(strike);   
    y0        = yt-W.*cosd(dip).*sind(strike);  
  else
    x0        = xt-W.*cosd(dip).*cosd(strike);   
    y0        = yt+W.*cosd(dip).*sind(strike);   
    dip       = -dip;
  end    
  z0        = zt+W.*sind(dip);
  xs        = mean([xt,x0]);
  ys        = mean([yt,y0]);
  zs        = mean([zt,z0]);
  
  dL    = L/Lp;
  dW    = W/Wp;
  dx    = (xt-x0)/Wp;
  dy    = (yt-y0)/Wp;

  for i=1:Wp
    
    xtc = xt-dx*(i-1);
    x0c = xt-dx*(i);
    xsc = mean([x0c xtc]);
    ytc = yt-dy*(i-1);
    y0c = yt-dy*(i);
    ysc = mean([y0c ytc]);
    z0p = z0-dW*(Wp-i).*sind(dip);
    ztp = z0-dW*(Wp-i+1).*sind(dip);
    zsp = mean([z0p,ztp]);
    
    for j=1:Lp
      
      id     = (i-1)*totLp+sum(Lps(1:k-1))+Lp-j+1;
      
      lsina  = (L/2-dL*(j-1)).*sind(strike);
      lsinb  = (L/2-dL*j).*sind(strike);
      lcosa  = (L/2-dL*(j-1)).*cosd(strike);
      lcosb  = (L/2-dL*j).*cosd(strike);
      lsin   = (L/2-dL*(j-.5)).*sind(strike);
      lcos   = (L/2-dL*(j-.5)).*cosd(strike);
      
      xfault = [xtc+lsina, xtc+lsinb, x0c+lsinb, x0c+lsina, xtc+lsina]';
      yfault = [ytc+lcosa, ytc+lcosb, y0c+lcosb, y0c+lcosa, ytc+lcosa]';
      zfault = [ztp ztp z0p z0p ztp]';

      x0p    = x0c+lsin;
      y0p    = y0c+lcos;
      xsp    = xsc+lsin;
      ysp    = ysc+lcos;
      patchstruct(id).x0     = x0p;
      patchstruct(id).y0     = y0p;
      patchstruct(id).z0     = z0p;
      patchstruct(id).xs     = xsp;
      patchstruct(id).ys     = ysp;
      patchstruct(id).zs     = zsp;
      patchstruct(id).strike = strike;
      patchstruct(id).dip    = dip;
      patchstruct(id).L      = dL;
      patchstruct(id).W      = dW;
      patchstruct(id).xfault = xfault;
      patchstruct(id).yfault = yfault;
      patchstruct(id).zfault = zfault;
      patchstruct(id).edgetype=0;
    end
  end
end


    
if(Wp>1)

%Top left
id=1;
patchstruct(id).connect=[NaN id+1 NaN id+totLp NaN];
%Top right
id=totLp;
patchstruct(id).connect=[NaN NaN id+totLp NaN id-1];
%Bottom left
id=totLp*(Wp-1)+1;
patchstruct(id).connect=[id-totLp NaN id+1 NaN NaN];
%Bottom right
id=totLp*Wp;
patchstruct(id).connect=[id-totLp NaN NaN NaN id-1];

%Top
for i=2:totLp-1
   id=i;
   patchstruct(id).connect=[NaN id-1 NaN id+totLp NaN  id+1];
end
    
    
%Bottom
for i=2:totLp-1
   id=i+totLp*(Wp-1);
   patchstruct(id).connect=[id-totLp NaN id+1 NaN NaN id-1];
end
    
%Left
for j=2:Wp-1
  id=totLp*(j-1)+1;
  patchstruct(id).connect=[id-totLp NaN id+1 NaN id+totLp NaN];
end
    
%Right  
for j=2:Wp-1
  id=totLp*j;
  patchstruct(id).connect=[id-totLp NaN NaN id+totLp NaN id-1];
end
    
%Interior
for i=2:totLp-1
  for j=2:Wp-1
     id=totLp*(j-1)+i;
     patchstruct(id).connect=[id-totLp NaN id+1 NaN id+totLp NaN id-1];
  end
end
else

  %left
  id=1;
  patchstruct(id).connect=[NaN id+1 NaN NaN];
  %right
  id=totLp;
  patchstruct(id).connect=[NaN NaN NaN id-1];
  for i=2:totLp-1
    id=i;
    patchstruct(id).connect=[NaN id-1 NaN NaN  id+1];
  end
end