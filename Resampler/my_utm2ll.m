function [x,y,zone]=my_utm2ll(X,Y,utmorll,zone)

if(nargin<4)
  zone=0;
end
if(and(zone~=0,isnumeric(zone)))
  zone=[num2str(zone) 'N']; %default zone, near equator
end

r_a    = 6378137.0;            %equatorial radius, WGS84
r_pole = 6356752.3;            %polar radius, WGS84
r_e2   = (1-r_pole^2/r_a^2);   %ellipsoid eccentricity squared
r_e    = sqrt(r_e2);

mstruct       = defaultm('utm');
mstruct.geoid = [r_a r_e];
   
if(utmorll==1) %convert utm to ll
  if(zone==0)
    disp('Need zone for utm to ll conversion')
    return
  else
    
    mstruct.zone = zone;
    mstruct      = defaultm(mstruct);
    [y,x]        = minvtran(mstruct,X,Y);
  end
  
elseif(utmorll==2) %convert ll to utm
  if(zone==0)
    zone=utmzone(mean(Y(:)),mean(X(:)));
  end   
    
  mstruct.zone = zone;
  mstruct      = defaultm(mstruct);
  [x,y]        = mfwdtran(mstruct,Y,X);
    
  else
    disp('utmorll must be 1 (for utm2ll) or 2 (for ll2utm)')
  return
end
