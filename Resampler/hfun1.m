function h = hfun1(x,y,args)

newscales = args{1};
yc        = args{2};
zc        = args{3};

h  = griddata(yc,zc,newscales,x,y);
h2 = griddata(yc,zc,newscales,x,y,'nearest');

id=find(isnan(h));
h(id)=h2(id);

end      
