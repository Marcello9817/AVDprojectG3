%% AVD - Gross Max Takeoff Weight W0

clear 
clc
close all

% This script aims at estimating the max takeoff weight of the aircraft at a
%conceptual stage

%% Inputs
disp("Please input all values as COLUMN arrays!!!!")
Mc=input('Crew mass (kg): ');
Mp=input('Payload mass (kg): ');
A=input('Aspect ratio (-): ');
Powerplant=input('Powerplant? Turbojet=1, LBR Turbofan=2, HBR Turbofan=3: ');
Composite=input('Is the aircraft made mostly in composite material? yes=1, no=0: ');
Var_sweep=input('Variable sweep wings? yes=1, no=0: '); 

% Turn into weight 
Wc=Mc.*9.81; % N
Wp=Mp.*9.81; % N

%% Fuel weight fraction calculation

% from Raymer's book p.16 and 18

% (1) Warm up + takeoff
f1=0.97;

% (2) Climb
f2=0.985;

% (3) Cruise 1
R1=2*10^6; % 2000km (m)
M1=0.75; % mission Mach number for cruise 1
a1=sqrt(1.4*287*218.808); % speed of sound at h=35000 ft (ISA model)
C_cruise=[0.9,0.8,0.5]/3600; % SFC in cruise (1/s)

%Constructing array of SFC for cruise
for i = 1: length(Mp)
    switch Powerplant(i)
        case 1 % turbojet
            C(i,1)=C_cruise(1);
        case 2 % LBR turbofan
            C(i,1)=C_cruise(2);
        case 3 % HBR turbofan
            C(i,1)=C_cruise(3);
    end
end

k_LD=15.5; % from Raymer's book p.22
Wet_area_ratio=5.5; % wetted area ratio from Raymer's book p.21
A_wet=A./Wet_area_ratio; % wetted aspect ratio from Raymer's book p.21
LD_max=k_LD*sqrt(A_wet); % L/D max 
V1=M1*a1; % TAS (m/s)
f3=exp(-(R1*C)./(LD_max*V1)); 

% (4) Descent 1
f4=0.995;

% (5) Climb due to missed approach
f5=f2;

% (6) Cruise 2
R2=370*10^3; % 370km (m)
M2=0.45; % mission Mach number for cruise 2
a2=sqrt(1.4*287*282.206); % speed of sound at h=3000 ft (ISA model)
V2=M2*a2;
f6=exp(-(R2*C)./(V2*LD_max)); 

% (7) Loiter 
E=45*60; % endurance of the loiter required (s)
a_l=sqrt(1.4*287*278.4); % speed of sound at h=1500m (m/s)
C_loiter=[0.8,0.7,0.4]/3600; % SFC in cruise (1/s)

%Constructing array of SFC for loiter
for i = 1:length(Mp)
    switch Powerplant(i)
        case 1 % turbojet
            C(i,1)=C_loiter(1);
        case 2 % LBR turbofan
            C(i,1)=C_loiter(2);
        case 3 % HBR turbofan
            C(i,1)=C_loiter(3);
    end
end
f7=exp(-(E*C)./LD_max); 

% (8) Descent 2
f8=f4;

% (9) Landing + taxi
f9=0.995;

% Combination of all mission segments fuel weight fractions
f=f1.*f2.*f3.*f4.*f5.*f6.*f7.*f8.*f9;

% Fuel weight fraction accounting for trapped fuel + safety margin
F_weight_fract=1.06*(1-f); 

%% Extra design considerations

Variation=[Composite, Var_sweep]; % array of design combinations

if Variation(1)==1 && Variation(2)==0
    Extra_des_coeff=0.95; % reduction in empty weight fraction due to composites
elseif Variation(1)==0 && Variation(2)==1
    Extra_des_coeff=1.05; % increase in empty weight fraction due to variable sweep wings
elseif Variation(1)==1 && Variation(2)==1
    Extra_des_coeff=1.05*0.95; % combined effect
else 
    Extra_des_coeff=1; % no changes
end 

%% Gross takeoff weight numerical scheme

% Empty weight fraction empirical model: (We/W0)=A*W0^C
A_const=0.97; % from Raymer's book p.13
C_const=-0.06; % from Raymer's book p.13

W01=20000*ones(length(Mp),1); % initialising W01
W02=30000*ones(length(Mp),1); % initialising W02
tol=0.1; % tolerance value (N)
% iterating until right W0 is found. 
while any(abs(W02-W01))>=tol 
    if W02(1)==30000
        W02=(Wc+Wp)./(1-F_weight_fract-(Extra_des_coeff*A_const*W01.^C_const));
    else 
        W01=W02;
        W02=(Wc+Wp)./(1-F_weight_fract-(Extra_des_coeff*A_const*W01.^C_const));
    end    
end 
W_overall=W02; % display gross takeoff weight (N)
M_overall=W_overall/9.81 % takeoff mass (kg)
M_empty=(Extra_des_coeff*A_const*W_overall.^C_const).*W_overall/9.81 % empty mass (kg)
M_fuel=F_weight_fract.*W_overall/9.81 % fuel mass at takeoff (kg)


