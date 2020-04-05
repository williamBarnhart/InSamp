function datastruct = loadGMTSAR(filename, losfilename,nx, ny, zone, limitny, azo);

datastruct=struct([]);
S = [];
if(nargin<7)
    azo=0;
end
if(nargin<6)
    limitny=0;
end
if(nargin<5)
    zone=0;
end

if nargin<2
    losfilename=[];
end

if(nargin<1)
    [infilename, pathname]=uigetfile({'*.xy*','Unwrapped files (*.xy)'; ...
        '*','All files'}, ...
        'Pick an input file');
    
    filename=[pathname infilename];
    
    nx  = input([' \n'...
        '\n'...
        'Enter width of the interferogram from grdinfo output \n','s']);
    ny  = input([' \n'...
        '\n'...
        'Enter length of the interferogram from grdinfo output \n','s']);
    
end



unwrapfile          = load(filename);
[X,Y]               = my_utm2ll(unwrapfile(:,1),unwrapfile(:,2),2,zone);
pixelsize           = mean([sqrt((X(1)-X(2))^2+(Y(1)-Y(2))^2) sqrt((X(nx*ny-1)-X(nx*ny))^2+(Y(nx*ny-1)-Y(nx*ny))^2)]);

X                   = reshape(X,nx,ny);
Y                   = reshape(Y,nx,ny);
data                = reshape(unwrapfile(:,3),nx,ny);
if exist(losfilename)
    for k=1:length(losfilename);
        look        = load(losfilename{k});
        S(:,:,k)    = reshape(look(:,3),ny,nx);
    end
end

datastruct=struct('data',data,'mag',[],'phs',data,'X',X,'Y',Y,'pixelsize',pixelsize, ...
    'zone',zone,'lambda',[],'nx',nx,'ny',ny,'filename',filename, ...
    'scale',0,'extrax',0,'extray',0, 'S',S);

