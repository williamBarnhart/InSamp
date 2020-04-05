function [f1,f2,f3] = fBi(sig, eta, parvec, p, q);

%%%%% Pull out parameters form parvec    %%%%%
%%%%% parvec = [d, a, delta, fault_type] %%%%%

d          = parvec(1);
a          = parvec(2);
delta      = parvec(3);
fault_type = parvec(4);

%%%%% Some simplifications %%%%%

epsn  = 1.0e-10;
cosd  = cos(delta);
sind  = sin(delta);
tand  = tan(delta);
cosd2 = cos(delta)^2;
sind2 = sin(delta)^2;
cssnd = cos(delta)*sin(delta);

R     = sqrt(sig.^2 + eta.^2 + q.^2);	
X     = sqrt(sig.^2 + q.^2);		
ytil  = eta*cosd + q*sind;		
dtil  = eta*sind - q*cosd;		

Rdtil = R + dtil;			
Rsig  = R + sig;			
Reta  = R + eta;			
RX    = R + X;

lnRdtil = log(Rdtil);		
lnReta  = log(Reta);

badid   = find((R-eta)==0);
lnReta0 = -log(R-eta);	
lnReta0(badid) = -inf;
%lnReta0 = lnReta0';

badid  = find(or(R==0,Rsig==0));
ORRsig = 1./(R.*Rsig);
ORRsig(badid)=inf;
%ORRsig = ORRsig';

OReta   = 1 ./ Reta;			
ORReta  = 1 ./ (R .* Reta);

indfix  = find(abs(Reta) < epsn);		%check for bad values
if (~isempty(indfix))
  lnReta(indfix) = lnReta0(indfix);		
  OReta(indfix)  = 0 * indfix;
  ORReta(indfix) = 0 * indfix;
end

indfix  = find(abs(Rsig) < epsn);		
if (~isempty(indfix))
  ORsig(indfix)  = 0 * indfix;
  ORRsig(indfix) = 0 * indfix;
end

%%%%% theta term with q = 0 fix
theta  = 0*q;
indfix = find(abs(q) < epsn);
indok  = find(abs(q) > epsn);
theta(indok)  = atan((sig(indok).*eta(indok))./(q(indok).*R(indok)));		
if (~isempty(indfix))
  theta(indfix) = 0 * indfix;
end
%%%%% The I_12345 factors %%%%%

if abs(cosd) < epsn
%%%%% cosd = 0 fix [eqn. (29)]
  I5 = -a   .* sig .* sind ./ Rdtil;
  I4 = -a   .* q ./ Rdtil;
  I3 =  a/2 .* (eta ./ Rdtil + (ytil .* q) ./ (Rdtil.^2) - lnReta );
  I2 = -a   .* lnReta - I3;
  I1 = -a/2 .* (sig .* q) ./ (Rdtil.^2);
else
%%%%% default [eqn. (28)]
%  I5 = a * 2 ./ cosd .* atan2( (eta.*(X+q.*cosd) + X.*RX.*sind),...
%                             (sig.*RX.*cosd) );
  sigtemp = sig;
  indfix = find(abs(sig)<epsn);
  sigtemp(indfix) = epsn;
  I5 = a * 2 ./ cosd .* ...
       atan( (eta.*(X+q.*cosd) + X.*RX.*sind)./(sigtemp.*RX.*cosd) );
  if (~isempty(indfix))
   I5(indfix) = 0 * indfix;
  end
  
  I4 = a ./ cosd .* (lnRdtil - sind .* lnReta);
  I3 = a * (1 ./ cosd .* ytil ./ Rdtil - lnReta) + tand .* I4;
  I2 = -a .* lnReta - I3;
  I1 = -a ./ cosd .* sig ./ Rdtil - tand .* I5;
end

%change shape if necessary
%[ny,nx]=size(p);
%if(and(ny==1,nx>1))
%    theta   = theta';
%    lnReta0 = lnReta0';
%    ORRsig  = ORRsig';
%end

%%%%% The fault specific parameters %%%%%

if fault_type == 1;  		%%%%% Strike Slip [eqn. (25)]

  f1 = (sig .* q)  .* ORReta + theta + I1 .* sind;
  f2 = (ytil .* q) .* ORReta + (q .* cosd) .* OReta + I2 .* sind;
  f3 = (dtil .* q) .* ORReta + (q .* sind) .* OReta + I4 .* sind;
%  f3 = -f3; %fix by rlohman?
elseif fault_type == 2;  	%%%%% Dip Slip  [eqn. (26)]

  f1 = q./R - I3 .* cssnd;
  f2 = (ytil .* q) .* ORRsig + cosd .* theta - I1 .* cssnd;
  f3 = (dtil .* q) .* ORRsig + sind .* theta - I5 .* cssnd;

else fault_type == 3;		%%%%% Tensile [eqn. (27)]

  f1 = q.^2 .* ORReta - I3 .* sind2;
  f2 = (-dtil .* q) .* ORRsig ...
     - sind .* ((sig .* q) .* ORReta - theta) - I1 .* sind2;
  f3 = (ytil .* q) .* ORRsig ...
     + cosd .* ((sig .* q) .* ORReta - theta) - I5 .* sind2;
 % f3=-f3;%fix by rlohman?
end

