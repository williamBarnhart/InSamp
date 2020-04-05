Npatch  = length(patchstruct);

Cd      = diag(Var*ones(1,np)./[resampstruct.count]);
ch      = chol(Cd);
Cdinv   = inv(ch');

x       = ([resampstruct.X]-min([resampstruct.X]))/max([resampstruct.X]-min([resampstruct.X]));
y       = ([resampstruct.Y]-min([resampstruct.Y]))/max([resampstruct.Y]-min([resampstruct.Y]));

Gramp   = [ones(np,1) x' y' x'.*y'];
nramp   = 4;
G       = Cdinv*[green Gramp];
di      = Cdinv*[resampstruct.data]';

smoothW = [smoo*smooth zeros(Npatch*2,nramp)];
Gsmoo   = [G;smoothW];
Gg      = inv(Gsmoo'*Gsmoo)*G';
N       = G*Gg;
mil     = Gg*di;
