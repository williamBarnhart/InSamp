function datastruct = loadLOS_ISCE(datastruct,losfilename, azo);


if(isempty(losfilename));
    filename   = datastruct.filename;
    c          = strsplit(filename,'/');
    pathname   = [];
    for k = 2:length(c)-1
        pathname=[pathname '/' c{k}];
    end
    
    losfilename=[pathname '/los.rdr.geo'];
end
clear c k
squint = 0.1;
if(azo==1)
    heading = datastruct.heading+squint;
    S       = zeros(datastruct.ny, datastruct.nx,3);
    S(:,:,1)= sind(heading);
    S(:,:,2)= cosd(heading);
    S(:,:,3)= 0;
else
    
    nx     = datastruct.nx;
    ny     = datastruct.ny;
    extrax = datastruct.extrax;
    extray = datastruct.extray;
    ox     = nx-extrax;
    oy     = ny-extray;
    
    fid         = fopen(losfilename,'r','native');
    [tmp,count] = fread(fid,[ox*2,oy],'real*4');
    status      = fclose(fid);
    
    look        = tmp(1:ox,:);
    heading     = tmp((ox+1):(ox*2),:);
    heading     = 180-flipud(heading'); %Puts heading into same convention as ROI_PAC geo_incidence.unw
    
    look        = flipud(look');
    
    heading     = heading.*pi/180;
    look        = look.*pi/180;
    
    id          = find(heading==0);
    jd          = find(heading~=0);
    heading(id) = mean(heading(jd));
    look(id)    = mean(look(jd));
    
    S1          = [sin(heading).*sin(look)];
    S2          = [cos(heading).*sin(look)];
    S3          = [-cos(look)];
    
    S1          = blkdiag(S1,zeros(extray,extrax));
    S2          = blkdiag(S2,zeros(extray,extrax));
    S3          = blkdiag(S3,zeros(extray,extrax));
    badid       = find(S1(:)==0);
    S1(badid)   = S1(1); % set to average in load_los
    S2(badid)   = S2(1);
    S3(badid)   = S2(1);

    S(:,:,1)    = S1;
    S(:,:,2)    = S2;
    S(:,:,3)    = S3;
    
end

datastruct.S=S;
    
    
