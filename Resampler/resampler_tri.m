function [resampstruct,res,rhgt,smoothwidths] = resampler_tri(datastruct,patchstruct,faultstruct)
resamp_in

splitid = 0;
iter    = 0;
rp      = 0:0.01:pi*2;
rx      = cos(rp);
ry      = sin(rp);
px      = datastruct.pixelsize;
nx      = datastruct.nx;
ny      = datastruct.ny;
S       = datastruct.S;
data    = datastruct.data;
X       = datastruct.X;
Y       = datastruct.Y;
hgt     = datastruct.hgt;
Var     = var(data(isfinite(data)));
plotf   = 1; %outputs more plots
if(~isempty(hgt))
    dohgt=1;
else
    dohgt=0;
end

Scolumns = reshape(S,nx*ny,3);
% Scolumns = S;
smooth  = smoother(2,patchstruct);
id=0;

[x,y] = meshgrid(linspace(min(X(:)),max(X(:)),10),linspace(min(Y(:)),max(Y(:)),10));
x     = x(:);
y     = y(:);
x     = x+randn(size(x));
y     = y+randn(size(y));
np    = 0;
done  = 0;
iter  = 0;

while(done~=1)
    iter  = iter+1;
    DT    = DelaunayTri(x,y);
    tri   = DT.Triangulation;
    
    SI   = pointLocation(DT,X(:),Y(:));
    SI(isnan(data))=NaN;
    good = unique(SI(isfinite(data)));
    good = good(isfinite(good));
    tri   = tri(good,:);
    tcx   = mean(x(tri),2);
    tcy   = mean(y(tri),2);
    clear resampstruct
    disp('ordering data into new triangles')
    
    for i=1:length(tcx)
        goodids               = SI==good(i);
        n                     = sum(goodids(:));
        resampstruct(i).X     = tcx(i);
        resampstruct(i).Y     = tcy(i);
        resampstruct(i).data  = mean(data(goodids));
        resampstruct(i).S     = mean(Scolumns(goodids,:),1)';
        resampstruct(i).count = n;
        resampstruct(i).trix  = x(tri(i,:));
        resampstruct(i).triy  = y(tri(i,:));
        resampstruct(i).scale = sqrt(polyarea([resampstruct(i).trix],[resampstruct(i).triy]));
        if(dohgt)
            resampstruct(i).hgt = mean(hgt(goodids));
        end
    end
    id               = find([resampstruct.count]);
    resampstruct     = resampstruct(id);
    oldnp            = np;
    np               = length(id);
    percnew          = abs(oldnp-np)/np*100;
    if(plotf)
        figure
        pcolor(X,Y,data)
        axis image,shading flat,hold on
        plot(x,y,'r.')
        patch([resampstruct.trix],[resampstruct.triy],nan,'edgecolor','m')
        title([num2str(np) ' out of ' num2str(size(DT,1)) ' tris contain data']);
    end
    disp(['num triangles = ' num2str(np) ' minres = ' num2str(min([resampstruct.scale]))])
    disp([num2str(abs(np-oldnp)) ' new triangles, ' num2str((abs(oldnp-np)/np)*100) '% change'])
    if(or(np>maxnp,percnew<5))
        done=1;
    else
        plotflag         = zeros(1,np);
        green            = make_green(patchstruct,resampstruct);
        quickinvert
        disp('calculating new widths')
        smoothwidths     = getsmoothwidths_tri(N,resampstruct,plotflag);
        
        node            = [min(X(:)) min(Y(:));max(X(:)) min(Y(:)); max(X(:)) max(Y(:)); min(X(:)) max(Y(:))];
        hdata.fun       = @hfun1;
        hdata.args      = {smoothwidths, [resampstruct.X], [resampstruct.Y]};
        
        clear triCoords triId
        disp('remeshing');
        [triCoords, triId, stats] = mesh2d(node, [], hdata);
        close
        x=triCoords(:,1);
        y=triCoords(:,2);
        
        if(plotf)
            clear tx ty
            for i=1:stats.Triangles
                tx(i,:)=triCoords(triId(i,:),1);
                ty(i,:)=triCoords(triId(i,:),2);
            end
            b=polyarea(tx',ty');
            
            figure
            subplot(2,2,1)
            patch([resampstruct.trix],[resampstruct.triy],smoothwidths)
            colorbar, axis image
            title(['inferred smoothing width, ' num2str(np) ' triangles'])
            subplot(2,2,2)
            patch([resampstruct.trix],[resampstruct.triy],[resampstruct.scale])
            colorbar, axis image
            title('actual length scale')
            subplot(2,2,3)
            patch([resampstruct.trix],[resampstruct.triy],[resampstruct.data])
            colorbar, axis image
            title('resampled data')
            subplot(2,2,4)
            patch(tx',ty',sqrt(b))
            colorbar, axis image
            title(['length scale for ' num2str(length(b)) ' new triangles'])
            
        end
        
    end
end

for i=1:np
    id=find(SI==good(i));
    resampstruct(i).trid=id;
end
green            = make_green(patchstruct,resampstruct);
quickinvert
   
disp('Calculating residual')
synth   = [green Gramp]*mil;
ramp    = [Gramp]*mil(Npatch*2+[1:nramp]);
zi      = griddata([resampstruct.X],[resampstruct.Y],synth,X,Y);
res     = data-zi;

ver        = [faultstruct.vertices];
dists      = dist_point_lines(X(:),Y(:),ver(1,:),ver(2,:));
res(find(dists<maskdist))=NaN;

if(dohgt)
    cols=3;
else
    cols=2;
end

figure
subplot(2,cols,1)
patch([resampstruct.trix]/1e3,[resampstruct.triy]/1e3,[resampstruct.data])
axis image,colorbar('h'),shading flat
title(['resampled data, np=' num2str(np)])

subplot(2,cols,2)
%if(nx>500);
%  a=1:10:ny;
%  b=1:10:nx;
%  pcolor(X(a,b)/1e3,Y(a,b)/1e3,res(a,b))
%else
pcolor(X/1e3,Y/1e3,res)
%end
hold on
axis image,colorbar('h'),shading flat
title('res used in covariance estimation')
cax=caxis;

subplot(2,cols,cols+1)
patch([resampstruct.trix]/1e3,[resampstruct.triy]/1e3,[resampstruct.scale])
axis image,colorbar('h')
title(['minimum scale=' num2str(min([resampstruct.scale]))])

subplot(2,cols,cols+2)
patch([resampstruct.trix]/1e3,[resampstruct.triy]/1e3,[resampstruct.count])
hold on
plot([resampstruct.X]/1e3,[resampstruct.Y]/1e3,'k.','markersize',1)
axis image,colorbar('h');
title('count per box');


if(dohgt)
    disp('Scaling by height')
    hgtid  = and(isfinite(res),hgt>minhgt);
    p      = polyfit(hgt(hgtid),res(hgtid),1);
    modhgt = p(1)*hgt+p(2);
    rhgt   = res-modhgt;
    subplot(2,cols,3)
    %if(nx>500);
    %    a=1:10:ny;
    %    b=1:10:nx;
    %    pcolor(X(a,b)/1e3,Y(a,b)/1e3,rhgt(a,b))
    %else
pcolor(X/1e3,Y/1e3,rhgt)
    %end
    axis image,colorbar('h'),shading flat
    title('res scaled by hgt')
    caxis(cax);
    
    subplot(2,cols,cols+3)
    plot(hgt(hgtid),res(hgtid),'r.')
    hold on
    plot(hgt(hgtid),modhgt(hgtid),'k.')
    axis tight
    legend('data','fit')
    xlabel('height')
    ylabel('signal')
else
    rhgt=[];
end



