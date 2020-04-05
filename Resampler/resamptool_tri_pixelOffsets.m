resamp_in

% Load data and add zeros so that ~ power of 2
% % [datastruct] = load_any_data(datafilename,zone,limitny,azo);
% % [datastruct] = load_los(datastruct,losfilename,azo,const_los);
% % [datastruct] = heightscale(datastruct,demfilename);


% Load data and add zeros so that ~ power of 2
[datastruct] = load_any_data(datafilename,zone,limitny,azo);
 %datastruct.data=[-datastruct.data];
 %[datastruct] = load_los(datastruct,losfilename,azo,const_los);
 S        = zeros(datastruct.ny,datastruct.nx,3);
    S(:,:,1) = 0;
    S(:,:,2) = 1;
    S(:,:,3) = 0;
    datastruct.S=S;
[datastruct] = heightscale(datastruct,demfilename);


%load fault
faultstruct=[];
for i=1:length(faultfilename)
    tmp                      = load(faultfilename{i});
    faultstruct              = [faultstruct tmp.faultstruct];
end
[patchstruct,totLp,Wp]   = ver2patchconnect(faultstruct,Lp,Wp,length(faultstruct));
xfault                   = [[patchstruct.xfault]']';
yfault                   = [[patchstruct.yfault]']';
zfault                   = [[patchstruct.zfault]']';
id                       = find(zfault(1,:)==min(zfault(1,:)));
xfaultsurf               = xfault(:,id);
yfaultsurf               = yfault(:,id);

disp('Beginning resampling')
[resampstruct,res,rhgt] = resampler_tri(datastruct,patchstruct,faultstruct);
Var                = var(res(isfinite(res)));
datastd            = Var./sqrt([resampstruct.count]);

disp('Calculating data covariance')
covstruct=struct('cov',[],'Var',Var,'tx',[],'ty',[],'Vxy',[],'allnxy',[],'els',[]);
covstruct2=covstruct;


if(azo)
    disp('just using Var of non-NaN points - Azimuth offsets should have no spatial correlation');
    getcov=1;
end
switch getcov
    case 1
        covstruct.cov = diag(datastd);
    case 2
        plotflag    = 1;
        covstruct   = get_cov_quick(covstruct,plotflag,res);
        covstruct2  = covstruct;
        els=covstruct.els;
        a=mean(els(1:2));
        els(1:2)=a;
        covstruct2.els = els;
        disp('Calculating covariance averages for resampled patches')
        covstruct   = resampcov_tri(resampstruct,datastruct,covstruct);
        set(gcf,'name','Includes directional anisotropy in noise');
        covstruct2  = resampcov_tri(resampstruct,datastruct,covstruct2);
        set(gcf,'name','Isotropic noise');
end

if(demfilename)
    Varh       = var(rhgt(isfinite(rhgt)));
    datastdh   = Varh./sqrt([resampstruct.count]);
    covstructh = struct('cov',[],'Var',Varh,'tx',[],'ty',[],'Vxy',[],'allnxy',[],'els',[]);
    switch getcov
        case 1
            covstructh.cov = diag(datastdh);
        case 2
            plotflag    = 1;
            covstructh  = get_cov_quick(covstructh,plotflag,rhgt);
            
            disp('Calculating covariance averages for resampled patches')
            covstructh  = resampcov_tri(resampstruct,datastruct,covstructh);
            set(gcf,'name','Anisotropic noise minus elevation fit');
    end
end



if(savestructname)
    savestruct = struct('name',[],'data',[],'np',[],'covstruct',[],'zone',[]);
    savestruct.name       = datafilename;
    savestruct.data       = resampstruct;
    savestruct.np         = length(resampstruct);
    savestruct.covstruct  = covstruct;
    savestruct.covstruct2 = covstruct2;
    savestruct.zone       = zone;
   
    if(demfilename)
        savestruct.covstructh = covstructh;
    end
    save(savestructname,'savestruct');
    disp('Saved data structure')

end
if(savexyname)
    xy=[[resampstruct.X]' [resampstruct.Y]' [resampstruct.S]' [resampstruct.data]' datastd'];
    save(savexyname,'xy','-ascii','-double')
    disp('saved xyfile')
    clear xy
end
