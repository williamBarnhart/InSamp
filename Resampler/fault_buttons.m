switch func
    case 1
        numver   = numver+1;
        ver      = get(gca,'CurrentPoint');
        vertices = [vertices ver(1,1:2)'];
        n        = numver;

        set(fh(1),'String',(1:numver)','Value',n);
        for i=2:3
            set(fh(i),'String',vertices((i-1),n));
        end

        if(numver>=2)
            numfaults                     = numfaults+1;
            onfault                       = onfault+1;
            dx                            = diff(vertices(1,[n-1 n]));
            dy                            = diff(vertices(2,[n-1 n]));
            faultstruct(onfault).vertices = vertices(:,[n-1 n]);;
            faultstruct(onfault).zt       = zt;
            faultstruct(onfault).W        = W;
            faultstruct(onfault).dip      = dip;
            faultstruct(onfault).L        = norm([dx dy]);
            faultstruct(onfault).strike   = atan2(dx,dy)*180/pi;
            faultstruct(onfault).zone     = zone;
        end

    case 2 %load mskfile
        datatype   = 1;
        name       = '*.msk';
        datastruct = load_any_data;
        zone       = datastruct.zone;
        data       = datastruct.data;
        nx         = datastruct.nx;
        ny         = datastruct.ny;
        X          = datastruct.X;
        Y          = datastruct.Y;
        docrop     = str2num(char(inputdlg(['Crop interferogram? 1=yes 0=np'])));
        if(docrop)
            plot_func=1;
            crop_faultdata
            func=18;
        end
        set(fh(7),'string',num2str(zone));

    case 3 %load phsfile
        datatype   = 1;
        name       = '*.unw';
        datastruct = load_any_data;
        zone       = datastruct.zone;
        data       = datastruct.data;
        nx         = datastruct.nx;
        ny         = datastruct.ny;
        X          = datastruct.X;
        Y          = datastruct.Y;       docrop     = str2num(char(inputdlg(['Crop interferogram? 1=yes 0=np'])));
        if(docrop)
            plot_func=1;
            crop_faultdata
            func=18;
        end
        set(fh(7),'string',num2str(zone));

    case 4 % load data structure
        datatype             = 2;
        [filename, pathname] = uigetfile({'*.mat','Data structure (*.mat)'},'Load resampled data');
        filename             = [pathname filename];
        load(filename);
        resampstruct         = datastruct.data;
        boxx                 = [boxx; [resampstruct.boxx]'];
        boxy                 = [boxy; [resampstruct.boxy]'];
        data                 = [data resampstruct.data];
        zone                 = datastruct.zone;
        set(fh(7),'string',num2str(zone));
        numdatas             = numdatas+1;

    case 5 %load fault set
        [faultfile,faultdir] = uigetfile({'*.mat','Fault structure (*.mat)'},'Choose pre-existing fault file');
        faultfile            = [faultdir faultfile];
        load(faultfile)
        [junk,numfaults]     = size(faultstruct);

        n                    = 1;
        numver               = numfaults+1;
        onfault              = 1;

        for i=1:numfaults
            vertices(1,i)=faultstruct(i).vertices(1,1);
            vertices(2,i)=faultstruct(i).vertices(2,1);
        end
        vertices(1,numver)=faultstruct(i).vertices(1,2);
        vertices(2,numver)=faultstruct(i).vertices(2,2);

        set(fh(1),'String',(1:numver));
        set(fh(1),'Value',n);
        for i=2:3
            set(fh(i),'String',vertices((i-1),n));
        end
        set(fh(4),'String',num2str(faultstruct(onfault).zt));
        set(fh(5),'String',num2str(faultstruct(onfault).W));
        set(fh(6),'String',num2str(faultstruct(onfault).dip));

    case 6 %save fault set
        [faultfile, faultdir] = uiputfile('*.mat','Save As');
        faultfile             = [faultdir faultfile];
        save(faultfile,'faultstruct');

    case 7 %done
        close(figh(1))
        close(figh(2))

    case 8 % change ver
        n       = get(fh(1),'Value');
        onfault = n-1;
        set(fh(2),'string',num2str(vertices(1,n)));
        set(fh(3),'string',num2str(vertices(2,n)));

    case 9 %update
        vertices(1:2,n)=str2num(char(get(fh(2:3),'String')));
        if(n==numver)
            disp(['adjusting segment ' num2str(onfault)])
            dx                            = diff(vertices(1,[n-1 n]));
            dy                            = diff(vertices(2,[n-1 n]));
            faultstruct(onfault).vertices = vertices(:,[n-1 n]);
            faultstruct(onfault).L        = norm([dx dy]);
            faultstruct(onfault).strike   = atan2(dx,dy)*180/pi;
        elseif(n>1)
            disp(['adjusting segment ' num2str(onfault)])
            dx                            = diff(vertices(1,[n-1 n]));
            dy                            = diff(vertices(2,[n-1 n]));
            faultstruct(onfault).vertices = vertices(:,[n-1 n]);
            faultstruct(onfault).L        = norm([dx dy]);
            faultstruct(onfault).strike   = atan2(dx,dy)*180/pi;

            disp(['adjusting segment ' num2str(onfault+1)])
            dx                              = diff(vertices(1,[n n+1]));
            dy                              = diff(vertices(2,[n n+1]));
            faultstruct(onfault+1).vertices = vertices(:,[n n+1]);
            faultstruct(onfault+1).L        = norm([dx dy]);
            faultstruct(onfault+1).strike   = atan2(dx,dy)*180/pi;
        else
            disp(['adjusting segment ' num2str(onfault+1)])
            dx                              = diff(vertices(1,[n n+1]));
            dy                              = diff(vertices(2,[n n+1]));
            faultstruct(onfault+1).vertices = vertices(:,[n n+1]);
            faultstruct(onfault+1).L        = norm([dx dy]);
            faultstruct(onfault+1).strike   = atan2(dx,dy)*180/pi;
        end

    case 10 %delete ver

        vertices = [vertices(:,1:(n-1)) vertices(:,(n+1):numver)];
        numver   = numver-1;
        n        = 1;

        set(fh(1),'String',(1:numver)');
        set(fh(1),'Value',n);
        for i=2:3
            set(fh(i),'String',vertices((i-1),n));
        end
        clear faultstruct
        if (numver>=2)
            numfaults=numver-1;
            for i=1:numfaults
                dx                      = diff(vertices(1,[i i+1]));
                dy                      = diff(vertices(2,[i i+1]));
                faultstruct(i).vertices = vertices(:,[i i+1]);
                faultstruct(i).zt       = zt;
                faultstruct(i).W        = W;
                faultstruct(i).dip      = dip;
                faultstruct(i).L        = norm([dx dy]);
                faultstruct(i).strike   = atan2(dx,dy)*180/pi;
                faultstruct(i).zone     = zone;
            end

            onfault   = 1;
        else
            faultstruct = [];
            numfaults   = 0;
            onfault     = 0;
        end

    case 11 % get zt
        zt  = str2num(get(fh(4),'string'));

    case 12 % get W
        W   = str2num(get(fh(5),'string'));

    case 13 % get dip
        dip = str2num(get(fh(6),'string'));

    case 14 % get zone
        zone = str2num(get(fh(7),'string'));

    case 15 % get zone
        avg = str2num(get(fh(8),'string'));




    case 16 % plot other
        [faultfile,faultdir] = uigetfile({'*.mat','Fault file (*.mat)'},'Choose pre-existing fault file');
        faultfile            = [faultdir faultfile];
        temp                 = load(faultfile);
        otherstruct          = [otherstruct temp.faultstruct];

        [jnk,otherflt]=size(otherstruct);

    case 17 %replot
        func = 18; % go to null to get out of loop

        figure(figh(1))
        if(datatype==1)
            a=1:avg:ny;
            b=1:avg:nx;
            hold off
            pcolor(X(a,b),Y(a,b),data(a,b));
            hold on
        elseif(datatype==2)
            hold off
            cla
            patch(boxx',boxy',data)
            hold on
        else
            disp('no data yet')
        end

        if(numver>0)
            plot(vertices(1,:),vertices(2,:),'-','color',[.8 .8 .8],'linewidth',2);
            plot(vertices(1,:),vertices(2,:),'kv','markersize',10);
            plot(vertices(1,n),vertices(2,n),'k^','markersize',10);
        end
        for i=1:otherflt
            plot(otherstruct(i).vertices(1,:),otherstruct(i).vertices(2,:),'y.-','linewidth',2)
        end
        a=axis;
        set(gca,'dataaspectratio',[a(1) a(1) 1])
        colorbar,shading flat


    case 18 % null

end

if (onfault>0)
    faultstruct(onfault).zt  = zt;
    faultstruct(onfault).W   = W;
    faultstruct(onfault).dip = dip;
end


if(isempty(intersect(func,[7 18]))) %done null
    func=17;
    fault_buttons;
end
