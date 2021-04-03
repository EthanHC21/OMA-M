% t0 is the reference temperature
% values around this temperature will be used as a reference
% to generate a greybody lookup table
t0 = 1650;

path = 'D:\Documents\School Documents\2020-2021 Senior Year College\Research\MATLAB Scripts\out\';

name = '861';
% get temperature
T = temps;
GREEN = g;
% this is the camera response we use for the flight ACME camera
file = load('RGB_gige_resp.txt');
wavelength = file(:,1);

startWave=370;
dL=1; %wavelength increment in nm
l=[startWave:dL:700];
dLambda=dL*1e-9;


norm=max(file(:,3));
% values from the text file for the camera
fred = file(:,2) /1.41/norm ;
fgreen = file(:,3)  * 1.1/norm;
fblue = file(:,4)  / 1.68/norm ;
% this is the only part that doesn't make sense to me

% extrapolate camera values
wavelength = [startWave;wavelength;700];
fred = [0; fred; 0];
fgreen = [0; fgreen; 0];
fblue = [0; fblue; 0];

fblue = interp1(wavelength,fblue,l);
fgreen = interp1(wavelength,fgreen,l);
fred = interp1(wavelength,fred,l);


figure
% the r g b filter profiles
axes('FontSize',14);
plot(l, fblue, 'b', l, fgreen, 'g', l, fred, 'r', 'LineWidth',2);
xlabel('Wavelength (nm)','FontSize',14);
ylabel('Transmission','FontSize',14);
xlim([350 750]);

lambda = l*1e-9;
i = 1;
dT = 1;
emis = .88;

n = length(lambda);

for Temp = 1100:dT:1900
    inten = emis*Cal_BB(lambda,Temp)'; % the greybody spectrum at a given temperature
    
    Ir(i) = fred*inten*dLambda;
    Ig(i) = fgreen*inten*dLambda;
    Ib(i) = fblue*inten*dLambda;
    i=i+1;
end
Lookup_T = 1100:1900;
dt = 10;
%
tg=[T(:),GREEN(:)];
sortrows(tg);
greenvals=tg(tg(:,1)>=t0-dt & tg(:,1)<=t0+dt,:);
greentarg=mean(greenvals(:,2));

convertG=greentarg/interp1(Lookup_T,Ig,t0);

Lookup_g = Ig*convertG ;

% two figures

sz=size(T);
t=reshape(T,sz(1)*sz(2),1);
x=[min(t),max(t)];
load oma_pal
fsize = 14;

figure
r=reshape(GREEN,sz(1)*sz(2),1);
scatterData = [r,t];
result = hist3(scatterData,[200 200]);
result(:,1)=0;
y=[min(r),max(r)];
imagesc(x,y,result);
xlabel('Temperature','FontSize',fsize);
ylabel('Counts','FontSize',fsize);
axis xy
colormap(oma_palette);
colorbar('FontSize',fsize);
hold on
title(strcat(name,'-green'),'FontSize',fsize);
plot(Lookup_T,Lookup_g,'r.');
set(gca,'FontSize',fsize);
saveas(gcf,strcat(path,'/',name,'GrnLookup.png'));
hold off

fid = fopen(strcat(path,'GreenFiberIntenLookup',name,'.o2d'),'w');
fprintf(fid,'%d\n',length(Lookup_T));
for i = 1:length(Lookup_T);
    fprintf(fid,'%d\t%d\n',Lookup_g(i),Lookup_T(i));
end
fclose(fid);

figure
intenRatioT=interp1(Lookup_g,Lookup_T,GREEN(1,:));
hold on
plot([1:length(intenRatioT)],intenRatioT);
plot([1:length(intenRatioT)],T(1,:));
ylabel('Temperature','FontSize',fsize);
xlabel('Pixel','FontSize',fsize);
legend('Intensity Ratio','Color Ratio');
set(gca,'FontSize',fsize);
saveas(gcf,strcat(path,'/',name,'RatioComparison.png'));
hold off


