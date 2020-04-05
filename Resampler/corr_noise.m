function [noise,orig]=corr_noise(covd,numdatas)

np=length(covd);
[v,d]=eig(covd);


%d(d<0)=0; %quick fix for poorly-conditioned covd
orig=randn(np,numdatas);
noise=v*sqrt(d)*orig;
noise=real(noise);