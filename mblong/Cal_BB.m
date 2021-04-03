% Calculate blackbody radiance as a function of temperature and wavelength
% spectral radiance, or energy per unit time per unit surface area of
% emitting surface per unit solid angle per unit wavelength
% SI Unit: J/(s.m2.sr.m)
% * 1e-7 to convert to Commonly used Unit: microW/(cm2.nm.sr)

% Input: lambda (m), t (K)

function [BB] = Cal_BB(lambda,t)
% Universal constants in SI units
h = 6.62606896e-34;
c = 299792458; % I changed this
k = 1.3806504e-23;

C1 = 2*h*c^2;
C2 = h*c/k;
% assume grey body
BB = C1./lambda.^5.*(exp(C2./lambda/t)-1).^-1;
