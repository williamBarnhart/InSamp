function mytest()
node = [
    -5e3   0
    5e3   0
    5e3   8e3
    -5e3   8e3
        ];

hdata.fun = @hfun1;

[p,t] = mesh2d(node,[],hdata);



end

function h = hfun1(x,y)

% User defined size function for square

%h = 0.01 + 0.1*sqrt( (x-0.25).^2+(y-0.75).^2 );
h  = peaks(x/2e3,(y-4e3)/1e3);
h=1./(h.^4+10)*30e3;
end      % hfun1()
