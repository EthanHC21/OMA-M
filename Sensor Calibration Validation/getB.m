function B = getB(temp, lambda)

% these were read directly from the PDG 2018 Physics Particle Booklet
c = 299792458;
h = 6.62607015e-34;
k_b = 1.380649e-23;

% this function has been verified with Maple and a Ti-Nspire CX II CAS
B = 2*h*c^2./lambda.^5 .* 1./(exp(h*c./(lambda*k_b*temp)) - 1);