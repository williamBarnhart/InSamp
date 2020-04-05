
switch plot_func
 case 1
  disp('Click lower left and upper right of region to be saved')
  a=1:avg:ny;
  b=1:avg:nx;
  
  figh(3)=figure('Position',[800 660 500 500], ...
         'Name','File cropping', ...
         'NumberTitle','off', ...
	 'MenuBar','none', ...
	 'WindowButtonDownFcn','plot_func=2;crop_faultdata');
  
  pcolor(data(a,b))
  shading flat,axis image
  allver = [];
  
 case 2 
  figure(figh(3));
  ver    = get(gca,'CurrentPoint');
  allver = [allver ver(1,1:2)'];
  
  hold off
  pcolor(data(a,b))
  hold on
  shading flat,axis image
  plot(allver(1,:),allver(2,:),'ko','markerfacecolor','w','markersize',10)
  
  if(length(allver(1,:))==2)
    close
    tmp     = ceil(allver)*avg;
    a       = tmp(1,1):tmp(1,2);
    b       = tmp(2,1):tmp(2,2);
    X       = X(b,a);
    Y       = Y(b,a);
    data    = data(b,a);
    
    [ny,nx] = size(X);
    
    clear allver ver a b tmp jnk1 jnk2

    func=17;
    fault_buttons
  end
end
