function [ux,uy,uz]=calc_okada(U,x,y,nu,delta,d,len,W,fault_type,strike);
%fault_type=1 strikeslip
%fault_type=2 dipslip

if(0)
  if (strike==90)
  strike=89.9;
elseif (strike==45)
  strike=44.9;
elseif (strike==0)
  strike=0.1;
  end
if (delta==0)
  delta=0.1;
elseif (delta==90)
  delta=90;
end
end

%initialize arrays
ux=zeros(size(x));
uy=zeros(size(x));
uz=zeros(size(x));

strike = -strike * pi/180 + pi/2;
coss   = cos(strike);
sins   = sin(strike);
rot    = [coss -sins ; sins coss];
rotx   =  x*coss+y*sins;
roty   = -x*sins+y*coss;

%%%%% Okada fault model for dislocation in an elastic half-space.
%%%%% based on BSSA Vol. 95 p.1135-45, 1985

L     = len/2;
delta = delta * pi/180;	%fault dip, radians 

for i=1:length(U)
  Const = -U(i)/(2*pi);
  
  cosd  = cos(delta);
  sind  = sin(delta);
  
  p = roty*cosd + d*sind;	%a matrix eqn. (30)
  q = roty*sind - d*cosd;	%a matrix eqn. (30)
  a = 1-2*nu;		% mu/(lambda+mu) = 1-2*poisson's ratio
  
  parvec = [d, a, delta, fault_type(i)];
  
  [f1a,f2a,f3a] = fBi(rotx+L, p  , parvec, p, q);
  [f1b,f2b,f3b] = fBi(rotx+L, p-W, parvec, p, q);
  [f1c,f2c,f3c] = fBi(rotx-L, p  , parvec, p, q);
  [f1d,f2d,f3d] = fBi(rotx-L, p-W, parvec, p, q);
  
  %%%%% Displacement eqns. (25-27)
  
  uxj =      Const * (f1a - f1b - f1c + f1d);
  uyj =      Const * (f2a - f2b - f2c + f2d);
  uz  = uz + Const * (f3a - f3b - f3c + f3d);
  
  % rotate horizontals back to the orig. coordinate system
  ux= ux-uyj*sins+uxj*coss;  
  uy= uy+uxj*sins+uyj*coss;
end
