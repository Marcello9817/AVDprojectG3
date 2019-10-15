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
e = 1; % Oswald efficiency 
%parameters for empty weight estimation (Raymer 6th ed, p 148)
Ae = 0.32;
Be = 0.66;
C1 = -0.13;
C2 = 0.3;
C3 = 0.06;
C4 = -0.05;
C5 = 0.05;

%% ESTIMATION OF L/D
Sratio = 6; % ratio of wetted surface over Sref, Swet/Sref
AR = 8; % aspect ratio
Awet = AR/Sratio; % wetted aspect ratio
KLD = 15.5;
LDmax = KLD*sqrt(Awet);
% for jet
LDcruise = LDmax*sqrt(3)/2;
LDloiter = LDmax;


%% T/W0 FROM TABLE, Raymer 5ed p
TWstat = a*Mmax^C;

%% WE/W0 AND W0 ESTIMATION, Raymer 6ed p 148
W0 = 18.5*10^3*9.81; % initial W0 guess
W0S = 481.85*9.81;  % W0/S guess       
W02 = 30000*9.81; % second W0 guess
tol = 0.1; % tolerance of convergence
WfW0 = 0.225962906113095; %assumed fuel weight fraction

while abs(W02 - W0)>tol
    % We use Raymer's equation from 6ed, p 148 to estimate We/W0, then we
    % use this to update W0, and we use this updated value to update WeW0.
    % The iteration is repeated until convergence.
    if W02 ~= 30000*9.81
        W0 = W02;
    end
    WeW0 =(Ae + Be*W0^(C1)*AR^(C2)*TWstat^(C3)*W0S^(C4)*Mmax^(C5));
    W02 = (5670*9.81)/(1 - WfW0 -WeW0);
end

W0mass = W0/9.81
Wemass = WeW0*W0mass
fuelmass = W0mass*WfW0


