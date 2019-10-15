clear
clc

% Script to calculate thrust to weight T/W and wing loading W/S
% Typical value for W/S, jet transport = 0.25-0.4 (higher value, fewer
% engines), Raymer 5ed p117

%% PARAMETERS
Mcruise= 0.75; % cruise Mach number
Mmax = 0.8; % max Mach number
% parameters from Reymar statistical estimation of T/W for jet transport
a = 0.267;
C = 0.363;

Vvert = 1; % m/s, vertical velocity required in climb, FAR25
Vclimb = 1; % m/s, velocity during climb, CHANGE THIS WITH FORMULA

%% ESTIMATION OF L/D
Sratio = 7; % ratio of wetted surface over Sref, Swet/Sref
AR = 8; % aspect ratio
Awet = AR/Sratio; % wetted aspect ratio
LDmax = (Awet-0.8)*125/16 + 14; % linear approximation from graph, Raymer 5ed p39, civil jets (acceptable range of Awet is 0.6-1.8)

% for jet
LDcruise = LDmax*sqrt(3)/2;
LDloiter = LDmax;


%% T/W0 FROM TABLE, Raymer 5ed p
TWstat = a*Mmax^C;


%% THRUST MATCHING
% here TW refers to takeoff weight, for other conditions: subscript
TWcruise = 1/LDcruise;
TWclimb = 1/LDclimb + Vvert/Vclimb;















