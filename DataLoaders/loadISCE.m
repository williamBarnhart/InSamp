function datastruct = loadISCE(filename,zone,limitny,azo,scaleval)
pathname =[];
datastruct=struct([]);
if(nargin<5)
    scaleval=0;
end
if(nargin<4)
    azo=0;
end
if(nargin<3)
    limitny=0;
end
if(nargin<2)
    zone=0;
end
if(nargin<1)
    [infilename, pathname]=uigetfile({'*.unw','Unwrapped files (*.unw)'; ...
        '*.flat','Interferograms (*.flat)'; ...
        '*.slc','Single Look Complex (*.slc)'; ...
        %         '*.amp','Amplitude files (*.amp)'; ...
        '*.cor','Correlation files (*.cor)'; ...
        '*.hgt','Height files (*.hgt)'; ....
        %         '*.msk','Mask files (*.msk)'; ...
        '*.dem','DEMs (*.dem)'; ...
        %         '*.byt','Byte files (*.byt)'; ...
        %         '*.flg','Flag files (*.flg)'; ...
        %         '*.slp','Slope files (*.slp)'; ...
        %         '*.off','Offset files (*.off)'; ...
        '*','All files'}, ...
        'Pick an input file');
    
    filename=[pathname infilename];
elseif length(strsplit(filename,'/'))>1
    pathname = [];
    parts=strsplit(filename,'/');
    if isempty(parts{1})
        for k=2:length(parts)-1
            pathname = [pathname  '/' parts{k}];
        end
        %         pathname = ['/' pathname];
    else
        for k=1:length(parts)-2
            pathname =[pathname parts{k} '/'];
        end
        pathname = [pathname parts{end-1}];
    end
else
    pathname = '.';
end
% if isempty(pathname)
%     pathname='.';
% end
mag=[];
phs=[];

n        = length(filename);
patterns = {'phsig','cor','unw','rdr','flat','hgt','dem','slc'};
figtype  = {'phsig','rmg','rmg','rmg','cpx','rmg','rmg','cpx'};



for k = 1:length(patterns)
    if(regexp(filename,patterns{k}))
        type=figtype{k};
        break
    end
end
im       = sqrt(-1);

if(regexp(filename,'geo'))
    %     [nx,ny,lambda,x1,y2,dx,dy] = load_xml([pathname '/insarProc.xml'],'GEO_WIDTH','GEO_LENGTH','radar_wavelength','maximum_longitude','maximum_latitude','LONGITUDE_SPACING','LATITUDE_SPACING');
    %     [nx,ny,x1,y2,dx,dy] = load_xml([pathname '/' filename '.xml'],
    [nx,ny,x1,y2,dx,dy] = loadGeoXml([filename '.xml']);
    if regexp(filename,'merged')
        lambda= '0.055465763';
    else
        lambda  = loadGenericXml([pathname '/insarProc.xml'],'radar_wavelength');
        % lambda='0.055';
    end
    
    nx = str2num(nx); ny = str2num(ny); x1 = str2num(x1); y2 = str2num(y2); dx = str2num(dx); dy = str2num(dy);lambda=str2num(lambda);
else
    if regexp(filename,'merged')
        
        lambda = '0.05465763';
        [nx, ny] = loadISCEinfo([pathname(1:end-7) '/isce.log'],'isce.mroipac.filter - DEBUG - width','isce.mroipac.filter - DEBUG - length');
        
    else
        
        %     [nx,ny,lambda] = loadGenericXml([pathname '/insarProc.xml'],'WIDTH','LENGTH','RADAR_WAVELENGTH');
        [nx, ny,lambda] = loadISCEinfo([pathname '/isce.log'],'runCorrect.inputs.width','runCorrect.inputs.length','runCorrect.inputs.radar_wavelength');
    end
    nx = str2num(nx); ny = str2num(ny); lambda =str2num(lambda);
end

% lambda  = getWavelength(sensor);

if(limitny)
    ny = limitny;
end

switch type
    case 'rmg'
        disp('Loading rmg file')
        fid             = fopen(filename,'r','native');
        [rmg,count]     = fread(fid,[nx,ny*2],'real*4');
        [nx,ny]         = size(rmg);
        ny              = ny/2;
        status          = fclose(fid);
        mag             = flipud((rmg(1:nx,1:2:ny*2))');
        phs             = flipud((rmg(1:nx,2:2:ny*2))');
        data            = phs;
        if(regexp(filename,'unw'));
            data            = -phs*lambda/(4*pi);
        end
    case 'cpx'
        
        disp('Loading cpx file')
        fid         = fopen(filename,'r','native');
        [rmg,count] = fread(fid,[nx*2,ny],'real*4');
        status      = fclose(fid);
        real        = flipud((rmg(1:2:nx*2,1:ny))');
        imag        = flipud((rmg(2:2:nx*2,1:ny))');
        mag         = abs(real+im*imag);
        phs         = angle(real+im*imag);
        data        = phs;
    case 'phsig'
        disp('Loading PHSIG file')
        fid=fopen(filename,'r','native');
        [cor,count]=fread(fid,[nx, ny],'real*4');
        data = flipud(cor');
end



if(scaleval)
    olddata = data;
    scale   = 2^ceil(log2(min([ny nx])/scaleval));
    extrax  = scale-mod(nx,scale);
    extray  = scale-mod(ny,scale);
    data    = blkdiag(olddata,zeros(extray,extrax));
    [ny,nx] = size(data);
    y2      = y2-extray*dy;
    disp(['padding X,Y,data,S with ' num2str(extrax) '/' num2str(extray) ' zeros']);
else
    extrax = 0;
    extray = 0;
    scale  = 0;
end


if(regexp(filename,'geo'))
    disp('File is geocoded')
    y1      =y2+dy*(ny-1);
    x2      =x1+dx*(nx-1);
    
    x       =x1:dx:x2;
    y       =y1:-dy:y2;
    
    [X,Y]    =meshgrid(x,y);
    if zone==0
        [jnk1,jnk2,zone] = my_utm2ll(mean(x),mean(y),2);
    end
    if(str2num(zone)<=-1)
        disp('not setting zone');
    else
        [leng,width]        =size(X);
        [X,Y]               = my_utm2ll(X,Y,2,zone);
        X                   = reshape(X,leng,width);
        Y                   = reshape(Y,leng,width);
        pixelsize           = mean([sqrt((X(1)-X(2))^2+(Y(1)-Y(2))^2) sqrt((X(nx*ny-1)-X(nx*ny))^2+(Y(nx*ny-1)-Y(nx*ny))^2)]);
        X                   = X+pixelsize/2;
        Y                   = Y-pixelsize/2;
    end
else
    disp('File is not geocoded')
    [X,Y]   = meshgrid(1:nx,1:ny);
    zone    = [];
end

pixelsize=mean([sqrt((X(1)-X(2))^2+(Y(1)-Y(2))^2) sqrt((X(nx*ny-1)-X(nx*ny))^2+(Y(nx*ny-1)-Y(nx*ny))^2)]);

baddata         = mode(data(:));
badid           = find(data==baddata);
data(badid)     = NaN;
disp(['setting ' num2str(length(badid)) ' pts with phs=' num2str(baddata) ' to NaN']);


datastruct=struct('data',data,'mag',mag,'phs',phs,'X',X,'Y',Y,'pixelsize',pixelsize, ...
    'zone',zone,'lambda',lambda,'nx',nx,'ny',ny,'filename',filename, ...
    'scale',scale','extrax',extrax,'extray',extray);

