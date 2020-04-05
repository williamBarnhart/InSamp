function res=getpowlaw(in,Var,x,c,n)


scale=max(c);
c=c/scale;
Var=Var/scale;
%Var=in(1);
l=in(1);
n=n/max(n);


%res=norm(a*exp(-((x2-b)/c).^2)-y2);
%res=a*exp(-((x2-b)/c).^2)-y2;

powfit        = Var*10.^(-x/l);

%whos powfitx c

res=powfit-c;
res=res.*n;
%disp(norm(res))

