function datastruct = load_los(datastruct,losfilename,azo,const_los)

if(azo==1)
    % changed to use heading from input .rsc file EJF 2010/4/29
    heading  = load_rscs(losfilename,'HEADING_DEG')
    S        = zeros(datastruct.ny,datastruct.nx,3);
    S(:,:,1) = sind(heading);
    S(:,:,2) = cosd(heading);
    S(:,:,3) = 0;
else
    
    nx     = datastruct.nx;
    ny     = datastruct.ny;
    extrax = datastruct.extrax;
    extray = datastruct.extray;
    ox     = nx-extrax;
    oy     = ny-extray;
    
    if const_los
        disp('check directions, here look=23, heading=170');
        const_look    = 23;
        const_heading = 170;
        look          = ones(ny,nx)*const_look;    % this needs to be set manually right now
        heading       = ones(ny,nx)*const_heading;
    else
        fid          = fopen(losfilename,'r','native');
        [temp,count] = fread(fid,[ox*2,oy],'real*4');
        status       = fclose(fid);

        look    = temp(1:ox,:);
        heading = temp((ox+1):(ox*2),:);
        heading = flipud(heading');
        look    = flipud(look');
    end

    squint  = 0.1;
    heading = (heading-squint).*pi/180;
    look    = look.*pi/180;

    id          = find(heading==0);
    jd          = find(heading~=0);
    heading(id) = mean(heading(jd));
    look(id)    = mean(look(jd));

    S1 = [sin(heading).*sin(look)];
    S2 = [cos(heading).*sin(look)];
    S3 = [ -cos(look)];

    S1      = blkdiag(S1,zeros(extray,extrax));
    S2      = blkdiag(S2,zeros(extray,extrax));
    S3      = blkdiag(S3,zeros(extray,extrax));
    badid   = find(S1(:)==0);
    S1(badid) = S1(1); % set to average in load_los
    S2(badid) = S2(1);
    S3(badid) = S2(1);

    S(:,:,1)  = S1;
    S(:,:,2)  = S2;
    S(:,:,3)  = S3;
    
end

datastruct.S=S;