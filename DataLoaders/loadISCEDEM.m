function dem = loadISCEDEM(filename,zone);

pathname=[];
dem=struct([]);
if(nargin<2)
    zone = 0;
end
if(nargin<1)
    [infilename, pathname]=uigetfile({'*.dem','DEMs (*.dem)'; ...
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


mag=[];
elev=[];


[nx,ny,x1,y2,dx,dy] = loadGeoXml([filename '.xml']);
nx = str2num(nx); ny = str2num(ny); x1 = str2num(x1); y2 = str2num(y2); dx = str2num(dx); dy = str2num(dy);


fid             = fopen(filename,'r','native');
elev            = fread(fid,[nx,ny],'integer*2');
elev            = flipud(elev');

% [nx,ny]         = size(rmg);
% ny              = ny/2;
status          = fclose(fid);


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

dem=struct('elev',elev,'mag',mag,'X',X,'Y',Y,'pixelsize',pixelsize,'zone',zone,'nx',nx,'ny',ny,'filename',filename);
