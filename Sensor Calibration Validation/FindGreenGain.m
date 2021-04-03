close all
clear

% constants - read directly from the PDG 2018 Physics Particle Booklet
c = 299792458;
h = 6.62607004e-34;
k_b = 1.38064852e-23;
T = 2000;
targRatio = .5;

% https://www.engineeringtoolbox.com/emissivity-coefficients-d_447.html
% says that silicon carbide has an emissivity of .83 - .96. We assume it's
% constant over the entire range of wavelengths (can be modified)
epsilon = .96;
% as I currently understand this, it shouldn't matter what the emissivity
% is if it's constant across the entire wavelength range, but I've been
% wrong before and so this is a test.

% path where calibration file is located (must have trailing \)
path = 'D:\Documents\School Documents\2020-2021 Senior Year College\Research\MATLAB Scripts\mblong\';
freqRespName = 'RGB_gige_resp.txt';

% read calibration file in
freqResp = load(strcat(path, freqRespName));
% extract data
% it is unknown whether the number of photons or amount of energy that hit
% the sensor per given wavelength were kept constant, so we will do two
% calculations
lambda = freqResp(:, 1);
rResp = freqResp(:, 2);
gResp = freqResp(:, 3);
bResp = freqResp(:, 4);

% we impose the arbitrary assumption that the sensor has a filter that
% blocks all photons with wavelengths below 370nm and above 700nm
lambda = [370; lambda; 700];
lambda = lambda/10^9;
% based on the previous implementation of this code, it is assumed that the
% response data is white balanced, so this must be corrected for proper 
% analysis (division factor)
rRespPho = [0; rResp; 0] / 1.41;
gRespPho = [0; gResp; 0] * 1.1;
bRespPho = [0; bResp; 0] / 1.68;

% because I don't know what's going on, we're going to start with assuming
% that the data provided is directly proportional to the number of photons.
% As such, we need to normalize all of the channels to the max number of
% photons detected.
propMaxPhotons = max([rRespPho; gRespPho; bRespPho]);

% we divide the responses by this number to generate a relative
% relationship.
rRespPho = rRespPho / propMaxPhotons;
gRespPho = gRespPho / propMaxPhotons;
bRespPho = bRespPho / propMaxPhotons;

% now, we plot this response against the wavelength to see the spectral
% response of the color sensor
plot(lambda, rRespPho, 'r', lambda, gRespPho, 'g', lambda, bRespPho, 'b')
title('Data is Photons')
xlabel('Wavelength')
ylabel('Relative Sensitivity')

% obtain the value of G (defined in my formula) for the integrand
G = epsilon * getB(T, lambda);
% this function has been verified with Maple and a Ti-Nspire CX II CAS

% we can define the signal S for a color channel as the number of photons
% that are registered. Since this is an integral, we must define an
% integrand, which relies on a gamma function (defined in my formula). To
% obtain this, we create a lookup function (curve fitting doesn't work)
% gamma_R = fit(lambda, rRespPho, 'cubicinterp');
% gamma_G = fit(lambda, gRespPho, 'cubicinterp');
% gamma_B = fit(lambda, bRespPho, 'cubicinterp');
% G_fit = fit(lambda, G, 'cubicinterp');
gamma_R_pho = @(lamb) interp1(lambda, rRespPho, lamb);
gamma_G_pho = @(lamb) interp1(lambda, gRespPho, lamb);
gamma_B_pho = @(lamb) interp1(lambda, bRespPho, lamb);
G_lookup = @(lamb) interp1(lambda, G, lamb);

% define integrands in accordance with the formula
int_R_pho = @(y) gamma_R_pho(y) .* G_lookup(y) .* y;
int_G_pho = @(y) gamma_G_pho(y) .* G_lookup(y) .* y;
int_B_pho = @(y) gamma_B_pho(y) .* G_lookup(y) .* y;

% make integrals
S_R_pho = integral(int_R_pho, lambda(1), lambda(end));
S_G_pho = integral(int_G_pho, lambda(1), lambda(end));
S_B_pho = integral(int_B_pho, lambda(1), lambda(end));

disp(S_G_pho/S_R_pho)
