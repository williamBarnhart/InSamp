function [covstruct,a,b,z,alpha] = get_cov_quick(covstruct,plotflag,res)

[ny,nx] = size(res);
Var     = var(res(isfinite(res)));
      
tot = 1000;
tx  = fix(abs(randn(tot,1))*nx/8);
ty  = fix(randn(tot,1)*ny/8);
id  = find(and(tx<nx,abs(ty/2)<ny/2));
tx  = tx(id);
ty  = ty(id);

atx = abs(tx)+1;
aty = abs(ty)+1;

alli = length(tx);
s    = 0;
h    = waitbar(s,'Calculating covariance from residual');

for i=1:alli
    tic
    if((tx(i)*ty(i))>0)
        A   = res(1:(ny-aty(i)+1),1:(nx-atx(i)+1));
        B   = res(aty(i):ny,atx(i):nx);
    else
        A   = res(1:(ny-aty(i)+1),atx(i):nx);
        B   = res(aty(i):ny,1:(nx-atx(i)+1));
    end
    
    mA  = mean(A(isfinite(A)));
    mB  = mean(B(isfinite(B)));
    C   = (A-mA).*(B-mB);
    g   = isfinite(C);
    n   = sum(g(:));

    Vxy(i)    = sum(C(g))/(n-1);
    allnxy(i) = n;
    update_time
    
end

close(h)

dists      = sqrt(tx.^2+ty.^2);
angs       = atan2(ty,tx);
startdists = mean(dists); %pixels
dpi        = pi/8;
angtest    = [-pi/2:dpi:pi/2];


options = optimset('Display','off');
for i=1:length(angtest)
    id=find(and(angs>=(angtest(i)-dpi/2),angs<(angtest(i)+dpi/2)));
    moddist(i)=lsqnonlin('getpowlaw',[startdists],[],[],options,Var,dists(id),Vxy(id)',allnxy(id)');
end

x = moddist.*cos(angtest);
y = moddist.*sin(angtest);
x = [x -x];
y = [y -y];

[z,a,b,alpha] = fitellipse([x;y]);
els           = [a b alpha];

npts = length(angs);

Q     = [cos(alpha), -sin(alpha); sin(alpha) cos(alpha)];
angs2 = atan(a/b*tan(angs-alpha));
X     = Q*[a*cos(angs2');b*sin(angs2')];
x2    = X(1,:);
y2    = X(2,:);


eldist  = sqrt(X(1,:).^2+X(2,:).^2);
modcovs = Var*10.^(-dists./eldist');


if(plotflag)
figure
subplot(2,2,1)
scatter(tx,ty,18,Vxy,'filled')
caxis([-Var/2 Var])
colorbar,axis image
hold on
plot(x,y,'k.')
plotellipse(z,a,b,alpha);
title('calculated')

subplot(2,2,2)
scatter(tx,ty,18,modcovs,'filled')
caxis([-Var/2 Var])
colorbar,axis image
hold on
plotellipse(z,a,b,alpha);
title('Used, with ellipsoidal powerlaw')

subplot(2,2,3)
scatter(tx,ty,18,Vxy-modcovs','filled')
caxis([-Var/2 Var])
colorbar,axis image
title('residual: calc-used')

subplot(2,2,4)
scatter(tx,ty,18,allnxy,'filled')
colorbar,axis image
title('count: number valide pairs at each distance/angle')
end


covstruct.Vxy    = Vxy;
covstruct.allnxy = allnxy;
covstruct.tx     = tx;
covstruct.ty     = ty;
covstruct.els    = els;
covstruct.mx     = x;
covstruct.my     = y;
covstruct.modcov = modcovs;




%old
%tx=fix(nx/2*ls(:).*cos(as(:)));
%ty=fix(ny/2*ls(:).*sin(as(:)));
%x=-nx/2:20:nx/2;
%y=-ny/2:20:ny/2;
%[tx,ty]=meshgrid(x,y);
%tx=tx(:);
%ty=ty(:);
%nang=50;
%nd=50;
%d_ang=pi/(nang-1);
%a=-pi/2:d_ang:pi/2;
%l1=log(1/(max(nx,ny)/2));
%dl=(0-l1)/(nd-1);
%l=10.^(l1:dl:0);
%[as,ls]=meshgrid(a,l);
%t=[fix(nx/2*ls(:).*cos(as(:))) fix(ny/2*ls(:).*sin(as(:)))];

