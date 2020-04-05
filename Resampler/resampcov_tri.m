function [covstruct] = resampcov_tri(resampstruct,datastruct,covstruct)

maxcovp     = 1e3;
np          = length(resampstruct);
pixelsize   = datastruct.pixelsize;
data        = datastruct.data;
X           = datastruct.X;
Y           = datastruct.Y;
tmpid1      = randperm(maxcovp)';
tmpid2      = randperm(maxcovp)';
Var         = covstruct.Var;
els         = covstruct.els;
a           = els(1)*pixelsize;
b           = els(2)*pixelsize;
alpha       = els(3);
Q           = [cos(alpha), -sin(alpha); sin(alpha) cos(alpha)];
sampledcov  = zeros(np);

tic
h=waitbar(0,'Calculating Cd');
for i=1:np
    %calc new variance of average
    id       = [resampstruct(i).trid];
    tmpdata  = data(id);
    goodid   = id(isfinite(tmpdata));
    n        = length(goodid);
    if(n^2>maxcovp)
        tmp1   = mod(tmpid1,n)+1;
        tmp2   = mod(tmpid2,n)+1;
        distsx = X(goodid(tmp1))-X(goodid(tmp2));
        distsy = Y(goodid(tmp1))-Y(goodid(tmp2));
    else
        bx       = meshgrid(X(goodid),X(goodid));
        by       = meshgrid(Y(goodid),Y(goodid));
        distsx   = bx-bx';
        distsy   = by-by';
    end
    newd  = sqrt(distsx.^2+distsy.^2);
    %calculate oriented covariance for all points
    angs  = atan2(distsy(:),distsx(:))';
    angs2 = atan(a/b*tan(angs-alpha));
    X2    = Q*[a*cos(angs2);b*sin(angs2)];
    sc    = sqrt(X2(1,:).^2+X2(2,:).^2);
    covs  = Var(1)*10.^(-newd(:)./sc');
   if(~isfinite(mean(covs(:))))
        disp(i)
        return
    end
    sampledcov(i,i) = mean(covs(:));

    %now do vs. other patches
    for l=(i+1):np
        jd          = [resampstruct(l).trid];
        tmpdata     = data(jd);
        goodid2     = jd(isfinite(tmpdata));
        n2          = length(goodid2);
        if(n*n2>maxcovp)
            tmp1   = mod(tmpid1,n)+1;
            tmp2   = mod(tmpid2,n2)+1;
            distsx = X(goodid(tmp1))-X(goodid2(tmp2));
            distsy = Y(goodid(tmp1))-Y(goodid2(tmp2));
        else
            [bx,bx2]  = meshgrid(X(goodid),X(goodid2));
            [by,by2]  = meshgrid(Y(goodid),Y(goodid2));
            distsx    = bx-bx2;
            distsy    = by-by2;
        end
        newd  = sqrt(distsx.^2+distsy.^2);
        angs  = atan2(distsy(:),distsx(:))';
        angs2 = atan(a/b*tan(angs-alpha));
        X2    = Q*[a*cos(angs2);b*sin(angs2)];
        sc    = sqrt(X2(1,:).^2+X2(2,:).^2);
        covs  = Var(1)*10.^(-newd(:)./sc');
        
        sampledcov(i,l) = mean(covs(:));
        sampledcov(l,i) = sampledcov(i,l);
    end

    waitbar(i/np,h);
end
close(h)


%manipulate matrix a bit to make it REALLY positive definite.
[U,E,V]       = svd(sampledcov);
sampledcov    = U*E*U';
covstruct.cov = sampledcov;

%Generate some noise
%If you want to check covariance, n should be diag.
noise = corr_noise(sampledcov,1);

[ch,junk] = chol(sampledcov);
if(junk==0)
    Cdinv = inv(ch');
    n     = Cdinv*noise;
    figure
    patch([resampstruct.trix]/1e3,[resampstruct.triy]/1e3,n')
    axis image,shading flat
    colorbar('h')
    title('Weighted noise, should be random if Chol worked');
    
else
    disp('Cholesky fact. failed')
    disp('You should never get to this point...something is wrong!')
    n     = noise;
end

figure,orient landscape,wysiwyg
subplot(2,3,1)
imagesc(sampledcov)
axis square
title('Sampled covariance matrix, Cd')

subplot(2,3,2)
patch([resampstruct.trix]/1e3,[resampstruct.triy]/1e3,noise')
axis image,shading flat
colorbar('h')
title('synthetic noise, generated with Cd')

subplot(2,3,3)
patch([resampstruct.trix]/1e3,[resampstruct.triy]/1e3,diag(sampledcov)')
axis image,shading flat
colorbar('h')
title('Resampled Variance (cm^2)');

pointid=10;
subplot(2,3,4)
patch([resampstruct.trix]/1e3,[resampstruct.triy]/1e3,sampledcov(pointid,:))
hold on
plot(resampstruct(pointid).trix/1e3,resampstruct(pointid).triy/1e3,'k','linewidth',4)
axis image,shading flat
colorbar('h')
title('Resampled Covariance at 10th point (cm)^2');

pointid=np-10;
subplot(2,3,5)
patch([resampstruct.trix]/1e3,[resampstruct.triy]/1e3,sampledcov(pointid,:))
hold on
plot(resampstruct(pointid).trix/1e3,resampstruct(pointid).triy/1e3,'k','linewidth',4)
axis image,shading flat
colorbar('h')
title('Resampled Covariance at 10th to last point (cm)^2');

dists=sqrt(([resampstruct.X]-resampstruct(pointid).X).^2+([resampstruct.Y]-resampstruct(pointid).Y).^2);
subplot(2,3,6)
plot(dists(:)/1e3,sampledcov(pointid,:),'b.')
hold on
a=axis;
xlabel('Distance (km)')
ylabel('Covariance (cm^2)')




