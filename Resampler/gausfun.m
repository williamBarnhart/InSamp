function res=gausfun(in)
global x2 b y2

a=in(1);
c=in(2);
%res=norm(a*exp(-((x2-b)/c).^2)-y2);
res=a*exp(-((x2-b)/c).^2)-y2;
