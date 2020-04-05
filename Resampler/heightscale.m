function datastruct = heightscale(datastruct,demfilename)

if(demfilename)
    disp('scaling by hgt');
    ox = datastruct.nx-datastruct.extrax;
    oy = datastruct.ny-datastruct.extray;
    
    fid  = fopen(demfilename,'r','native');
    temp = fread(fid,[ox*2,oy],'real*4');
    fclose(fid);

    hgt  = temp((ox+1):(ox*2),:);
    hgt  = blkdiag(flipud(hgt'),zeros(datastruct.extray,datastruct.extrax));
    datastruct.hgt = hgt;

else
    datastruct.hgt = [];
    disp('No DEM specified')
end
