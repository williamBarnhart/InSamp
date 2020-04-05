if(nargin<11)
    smoo=0.25;
end
if(nargin<10);
    Wp=10;
end
if(nargin<9)
    Lp=10;
end
if(nargin<8)
    throwout=10;
end
if(nargin<7)
    maskdist=0;
end
if(nargin<6)
    minhgt=200;
end
if(nargin<5)
    limitny=0;
end
if(nargin<4)
    scaleval=0;
end
if(nargin<3)
    azo=0;
end
if(nargin<2)
    maxnp=1000;
end
if(nargin<1)
    getcov=2;
end


[unwfilename, unwpathname]  = uigetfile({'*','All Files'}, 'Pick unwrapped interferogram');
datafilename                 = [unwpathname unwfilename];
if sum(datafilename)==0
    error('Thou shall select an unwrapped interferogram')
end


[losfilename, lospathname]  = uigetfile({'*','All Files'}, 'Pick LOS file');
losfilename                 = [lospathname losfilename];

if sum(losfilename)==0
    error('Thou shall select an LOS file')
end


[faultfilename, faultpathname]= uigetfile({'*.mat','Matlab File'}, 'Pick Fault File');
ftemp                       = [faultpathname faultfilename];
faultfilename               = {ftemp};
if sum(ftemp)==0
    error('Thou shall select a fault file')
end


zone = input(['\n'...
    '\n'...
    'Input UTM zone (e.g., ''41R'' or [])   ']);


savestructname = input(['\n'...
    '\n'...
    'Input .mat file name to be saved   ']);
