function datastruct = loadData(processor,datafilename,zone,limitny,azo,const_los,losfilename,nx,ny,parfile);

switch processor
    case 'ROIPAC'
        if isempty(losfilename)
            error('Designate a geo_incidence.unw file and path');
        end
        
        datastruct = loadROIPAC(datafilename,zone,limitny,azo);
        datastruct = loadLOS_ROIPAC(datastruct,losfilename,azo,const_los);
    
    case 'ISCE'
        datastruct = loadISCE(datafilename, zone, limitny, azo);
        datastruct = loadLOS_ISCE(datastruct,losfilename,azo);
    
    case 'GMT'
        datastruct = loadGMT(datafilename, losfilename,nx, ny, zone, limitny, azo);
    case 'GAMMA'
        datastruct = loadGAMMA(datafilename, losfilename, parfile,zone);
        
end
