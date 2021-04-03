close all
clear

% constants - read directly from the PDG 2018 Physics Particle Booklet
c = 299792458;
h = 6.62607015e-34;
k_b = 1.380649e-23;
T_cal = 1700;
targRatio = .5;
T = 1367;

% https://www.engineeringtoolbox.com/emissivity-coefficients-d_447.html
% says that silicon carbide has an emissivity of .83 - .96. We assume it's
% constant over the entire range of wavelengths (can be modified)
epsilon = .88;
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
lambdaRef = freqResp(:, 1);
rResp = freqResp(:, 2);
gResp = freqResp(:, 3);
bResp = freqResp(:, 4);

% we impose the arbitrary assumption that the sensor has a filter that
% blocks all photons with wavelengths below 370nm and above 700nm, but this
% can be changed
lambda_min = 370;
lambda_max = 700;
% set delta
d_lambda = 1;
% create an array of all lambdas for which values need to be calculated
lambda = (lambda_min:d_lambda:lambda_max)';
% create upper and lower bound arrays
lambdaUpper = lambda + d_lambda/2;
lambdaLower = lambda - d_lambda/2;
% make an array of lambdas to query in the lookup
lambdaQuery = [lambda_min - d_lambda; lambda; lambda_max + d_lambda];
% convert to m
lambda = lambda/10^9;
lambdaQuery = lambdaQuery/10^9;
lambdaUpper = lambdaUpper/10^9;
lambdaLower = lambdaLower/10^9;
% update the lambdaRef array with the boundary conditions
lambdaRef = [lambda_min - d_lambda;lambda_min;lambdaRef;lambda_max;lambda_max + d_lambda]/10^9;

% based on the previous implementation of this code, it is assumed that the
% response data is white balanced, so this must be corrected for proper 
% analysis (division factor)
rResp = [0; 0; rResp; 0; 0] / 1.41;
gResp = [0; 0; gResp; 0; 0]; % for 2000 K uncalibrated = 1.2198881
bResp = [0; 0; bResp; 0; 0] / 1.68;

% we assume the data provided is proportional to the number of photons, and
% normalize it so the numbers aren't massive in the later integral.
propMax = max([rResp; gResp; bResp]);
rResp = rResp/propMax;
gResp = gResp/propMax;
bResp = bResp/propMax;

% we now interpolate the responses such that there's a signal value for
% every lambda of interest
S_r_cal = interp1(lambdaRef, rResp, lambdaQuery);
S_g_cal = interp1(lambdaRef, gResp, lambdaQuery);
S_b_cal = interp1(lambdaRef, bResp, lambdaQuery);

% we can now create the integrands used in the expression to create gamma
% (turns out it's the same regarless of the color channel)
int_cal = @(y) epsilon .* y .* getB(y, T_cal);
% no lambda
% int_cal = @(y) epsilon .* getB(y, T_cal);

% we now calculate gamma (technically gamma/(t*omega), but that divies out)
% for each color channel. I tried to do it without a for loop but it didn't
% work so we have to for loop it
gamma_r = zeros(length(lambda), 1);
gamma_g = zeros(length(lambda), 1);
gamma_b = zeros(length(lambda), 1);
for i = 1:length(lambda)
    gamma_r(i) = interp1(lambdaQuery, S_r_cal, lambda(i))/integral(int_cal, lambdaLower(i), lambdaUpper(i));
    gamma_g(i) = interp1(lambdaQuery, S_g_cal, lambda(i))/integral(int_cal, lambdaLower(i), lambdaUpper(i));
    gamma_b(i) = interp1(lambdaQuery, S_b_cal, lambda(i))/integral(int_cal, lambdaLower(i), lambdaUpper(i));
end

% normalize the gammas
maxGamma = max([gamma_r; gamma_g; gamma_b]);
gamma_r = gamma_r/maxGamma;
gamma_g = gamma_g/maxGamma;
gamma_b = gamma_b/maxGamma;

% now, we plot this gamma against the wavelength to see the spectral
% response of the color sensor
plot(lambda, gamma_r, 'r', lambda, gamma_g, 'g', lambda, gamma_b, 'b')
title('\gamma vs. Wavelength')
xlabel('Wavelength')
ylabel('\gamma')

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
gamma_R_int = @(lamb) interp1(lambda, gamma_r, lamb);
gamma_G_int = @(lamb) interp1(lambda, gamma_g, lamb);
gamma_B_int = @(lamb) interp1(lambda, gamma_b, lamb);
G_lookup = @(lamb) interp1(lambda, G, lamb);

% define integrands in accordance with the formula
int_R = @(y) gamma_R_int(y) .* G_lookup(y) .* y;
int_G = @(y) gamma_G_int(y) .* G_lookup(y) .* y;
int_B = @(y) gamma_B_int(y) .* G_lookup(y) .* y;
% int_R = @(y) gamma_R_int(y) .* G_lookup(y);
% int_G = @(y) gamma_G_int(y) .* G_lookup(y);
% int_B = @(y) gamma_B_int(y) .* G_lookup(y);

% make integrals
S_R = integral(int_R, lambda(1), lambda(end));
S_G = integral(int_G, lambda(1), lambda(end));
S_B = integral(int_B, lambda(1), lambda(end));

ratioPho = S_G/S_R;

disp(ratioPho)