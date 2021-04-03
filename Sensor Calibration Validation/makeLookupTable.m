close all
clear

% constants - read directly from the PDG 2018 Physics Particle Booklet
c = 299792458;
h = 6.62607015e-34;
k_b = 1.380649e-23;

% define temperature vector
temp = (1000:1:3500)';

% define output table
grRatio = zeros(length(temp), 1);

% https://www.engineeringtoolbox.com/emissivity-coefficients-d_447.html
% says that silicon carbide has an emissivity of .83 - .96. We assume it's
% constant over the entire range of wavelengths (can be modified)
epsilon = .88; % DIRECTLY FROM JESSE
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
rResp = [0; rResp; 0] / 1.41;
gResp = [0; gResp; 0] * 1.1; % for 2000 K uncalibrated = 1.2198881
bResp = [0; bResp; 0] / 1.68;

% obtain the maximum response
propMax = max([rResp; gResp; bResp]);

% we divide the responses by this number to generate a relative
% relationship.
rResp = rResp / propMax;
gResp = gResp / propMax;
bResp = bResp / propMax;

% now, we plot this response against the wavelength to see the spectral
% response of the color sensor
plot(lambda, rResp, 'r', lambda, gResp, 'g', lambda, bResp, 'b')
title('Camera Response')
xlabel('Wavelength')
ylabel('Relative Sensitivity')

for i = 1:length(temp)
    
    % obtain the value of G (defined in my formula) for the integrand
    G = epsilon * getB(temp(i), lambda);
    % this function has been verified with Maple and a Ti-Nspire CX II CAS
    
    % we can define the signal S for a color channel as the number of photons
    % that are registered. Since this is an integral, we must define an
    % integrand, which relies on a gamma function (defined in my formula). To
    % obtain this, we create a lookup function (curve fitting doesn't work)
    % gamma_R = fit(lambda, rRespPho, 'cubicinterp');
    % gamma_G = fit(lambda, gRespPho, 'cubicinterp');
    % gamma_B = fit(lambda, bRespPho, 'cubicinterp');
    % G_fit = fit(lambda, G, 'cubicinterp');
    gamma_R = @(lamb) interp1(lambda, rResp, lamb);
    gamma_G = @(lamb) interp1(lambda, gResp, lamb);
    gamma_B = @(lamb) interp1(lambda, bResp, lamb);
    G_lookup = @(lamb) interp1(lambda, G, lamb);
    
    % define integrands in accordance with the formula. This is assumed to
    % simply be a constant scaling factor
    int_R = @(y) gamma_R(y) .* G_lookup(y);
    int_G = @(y) gamma_G(y) .* G_lookup(y);
    int_B = @(y) gamma_B(y) .* G_lookup(y);
    
    % make integrals
    S_R = integral(int_R, lambda(1), lambda(end));
    S_G = integral(int_G, lambda(1), lambda(end));
    S_B = integral(int_B, lambda(1), lambda(end));
    
    grRatio(i) = S_G/S_R;
    
end