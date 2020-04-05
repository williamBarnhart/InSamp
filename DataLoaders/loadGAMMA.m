function datastruct = loadGAMMA(datafilename, losfilename, parfile, zone, limitny, azo);

pathname =[];
datastruct=struct([]);
if(nargin<7)
    scaleval=0;
end
if(nargin<6)
    azo=0;
end
if(nargin<5)
    limitny=0;
end
if(nargin<4)
    zone=0;
end

if(nargin<3)
    error('not enough input files to load GAMMA interferogram');
end

phi     = losfilename{1};
theta   = losfilename{2};


% Get info from parfile
[a,b]   = textread(parfile,'%s%s');

nx      = str2num(b{find(contains(a,'width'))});
ny      = str2num(b{find(contains(a,'nlines'))});
x1      = str2num(b{find(contains(a,'corner_lon'))});
y2      = str2num(b{find(contains(a,'corner_lat'))});
dx      = str2num(b{find(contains(a,'post_lon'))});
dy      = str2num(b{find(contains(a,'post_lat'))});
extrax  = 0;
extray  = 0;

% Load interferogram and generate geographic coordinates in UTM
fid     = fopen(datafilename, 'r','native');
rmg     = fread(fid,[nx ny], 'real*4');
data    = flipud(rmg');
data(data==0) = NaN;
fclose(fid);

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

% Load look files and create ENU unit vectors

fid     = fopen(phi,'r','native');
phiR    = fread(fid,[nx ny], 'real*4');
heading    = flipud(phiR')-(pi/2); % Same as second channel LOS image in ISCE
fclose(fid);

fid     = fopen(theta,'r','native');
thetaR  = fread(fid,[nx ny], 'real*4');
look  = (pi/2)-flipud(thetaR');   % Same as first channel LOS image in ISCE
fclose(fid);

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


% Generic things InSamp expects, mostly filler...
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



pixelsize=mean([sqrt((X(1)-X(2))^2+(Y(1)-Y(2))^2) sqrt((X(nx*ny-1)-X(nx*ny))^2+(Y(nx*ny-1)-Y(nx*ny))^2)]);

baddata         = mode(data(:));
badid           = find(data==baddata);
data(badid)     = NaN;
disp(['setting ' num2str(length(badid)) ' pts with phs=' num2str(baddata) ' to NaN']);

lambda  = [];
mag     = [];
phs     = [];

datastruct=struct('data',data,'mag',mag,'phs',phs,'X',X,'Y',Y,'pixelsize',pixelsize, ...
    'zone',zone,'lambda',lambda,'nx',nx,'ny',ny,'filename',datafilename, ...
    'scale',scale','extrax',extrax,'extray',extray, 'S', S);