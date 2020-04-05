function [datastruct]=load_any_data(filename,zone,limitny,azo,scaleval)
if(exist([matlabroot '/toolbox/map/mapproj'])==7)
    goodmap=1;
else
    disp('No mapping toolbox found, using clugy utm2ll for lat/lon conversion')
    goodmap=0;
end

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
        '*.int','Interferograms (*.int)'; ...
        '*.slc','Single Look Complex (*.slc)'; ...
        '*.amp','Amplitude files (*.amp)'; ...
        '*.cor','Correlation files (*.cor)'; ...
        '*.hgt','Height files (*.hgt)'; ....
        '*.msk','Mask files (*.msk)'; ...
        '*.dem','DEMs (*.dem)'; ...
        '*.byt','Byte files (*.byt)'; ...
        '*.flg','Flag files (*.flg)'; ...
        '*.slp','Slope files (*.slp)'; ...
        '*.off','Offset files (*.off)'; ...
        '*','All files'}, ...
        'Pick an input file');

    filename=[pathname infilename];
end

mag=[];
phs=[];
pixelsize=[];


[nx,ny,lambda,x1,y2,dx,dy,xunit]=load_rscs(filename,'WIDTH','FILE_LENGTH','WAVELENGTH','X_FIRST','Y_FIRST','X_STEP','Y_STEP','X_UNIT');

n        = length(filename);
patterns = {'.int','.slc','.amp','.cor','.unw','.hgt','.msk','.dem','.byt','.flg','.slp','.off'};
type     = strmatch(filename(n-3:end),patterns);
im       = sqrt(-1);

if(limitny)
    ny=limitny;
end

if(sum(type==[1:3])) %cpx file
  disp('Loading cpx file')
  fid         = fopen(filename,'r','native');
  [rmg,count] = fread(fid,[nx*2,ny],'real*4');
  status      = fclose(fid);
  real        = flipud((rmg(1:2:nx*2,1:ny))');
  imag        = flipud((rmg(2:2:nx*2,1:ny))');
  mag         = abs(real+im*imag);
  phs         = angle(real+im*imag);
  data        = phs;
  
elseif(sum(type==[4:7])) %rmg
  disp('Loading rmg file')
  fid         = fopen(filename,'r','native');
  [rmg,count] = fread(fid,[nx,ny*2],'real*4');
  status      = fclose(fid);
  mag         = flipud((rmg(1:nx,1:2:ny*2))');
  phs         = flipud((rmg(1:nx,2:2:ny*2))');
  data        = phs;
  
  if(azo)
      %azimuth offset type
      disp('just using offsets, no scale')
  else
      if(type==5) %unw file
          if(lambda==0)
              disp('not scaling by lambda')
          else
              data  = -phs*lambda/(4*pi); 
              data  = data;
%             data = data;
          end
      end
  end

elseif(sum(type==[8:9])) %i2
  disp('Loading i2 file')
  fid          = fopen(filename,'r','native');
  [data,count] = fread(fid,[nx,ny],'integer*2');
  status       = fclose(fid);
  data         = flipud(data');
  
elseif(type==10) %i1
  disp('Loading i1 file')
  fid          = fopen(filename,'r','native');
  [data,count] = fread(fid,[nx,ny],'integer*1');
  status       = fclose(fid);
  data         = flipud(data');
  
elseif(type==11) %slope
  disp('Loading slope file')
  
  fid          = fopen(filename,'r','native');
  [rmg,count]  = fread(fid,[nx*2,ny],'real*4');
  status       = fclose(fid);
  slope        = flipud((rmg(1:2:nx*2,1:ny))')*180/pi;
  azimuth      = flipud((rmg(2:2:nx*2,1:ny))')*180/pi;
  data         = slope;
  
elseif(type==12)%off
  disp('Loading offset file')
  fid          = fopen(filename,'r','native');
  [data,count] = fread(fid,[nx,ny],'real*4');
  status       = fclose(fid);

else
  disp('filename has bad format, must end with .int, .slc, .amp, .cor, .unw, .hgt, .msk, .dem, .byt,.flg, .slp or .off');
  return
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


pixelsize=[];
if (isnumeric(x1))
    disp('File is geocoded')
   
    y1=y2+dy*(ny-1);
    x2=x1+dx*(nx-1);

    x=x1:dx:x2;
    y=y1:-dy:y2;

    [X,Y]=meshgrid(x,y);
    if(strcmp(xunit,'meters'))
        pixelsize=mean([sqrt((X(1)-X(2))^2+(Y(1)-Y(2))^2) sqrt((X(nx*ny-1)-X(nx*ny))^2+(Y(nx*ny-1)-Y(nx*ny))^2)]);
        X=X+pixelsize/2;
        Y=Y-pixelsize/2;
        zone=[];
    else
        if(zone)
        else
            if(goodmap)
                [jnk1,jnk2,zone]=my_utm2ll(mean(x),mean(y),2);
            else
                [jnk1,jnk2,zone]=utm2ll(mean(x),mean(y),0,2);
            end
            zone=char(inputdlg(['which zone (-1=nogeo), ' num2str(zone) '?']));

        end
        if(str2num(zone)<=-1)
            disp('not setting zone')
        else
            if(goodmap)
                [X,Y]=my_utm2ll(X,Y,2,zone);
            else
                [X,Y]=utm2ll(X,Y,2,zone);
            end
            pixelsize=mean([sqrt((X(1)-X(2))^2+(Y(1)-Y(2))^2) sqrt((X(nx*ny-1)-X(nx*ny))^2+(Y(nx*ny-1)-Y(nx*ny))^2)]);
            X=X+pixelsize/2;
            Y=Y-pixelsize/2;

        end
    end
else
    disp('File is not geocoded')
    [X,Y]=meshgrid(1:nx,1:ny);
    zone=[];
end

%look for bad points
baddata         = mode(data(:));
badid           = find(data==baddata);
data(badid)     = NaN;
disp(['setting ' num2str(length(badid)) ' pts with phs=' num2str(baddata) ' to NaN']);


datastruct=struct('data',data,'mag',mag,'phs',phs,'X',X,'Y',Y,'pixelsize',pixelsize, ...
    'zone',zone,'lambda',lambda,'nx',nx,'ny',ny,'filename',filename, ...
    'scale',scale','extrax',extrax,'extray',extray);
