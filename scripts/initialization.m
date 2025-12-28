% Copyright (C) 2024 Fondazione Istitito Italiano di Tecnologia (IIT)
% All Rights Reserved.

%% Parameters
wheel_diamenter = 18;                                   % wheel diameter [inch]
R = wheel_diamenter * 2.54 / 100 / 2;                   % radius [m]
g = 9.81;                                               % gravity [m/s^2]

m_b = smiData.Solid(1).mass;                            % body mass [kg]
m_pl = smiData.Solid(3).mass;                           % payload mass [kg]
m_w = smiData.Solid(2).mass;                            % wheel mass [kg]
m_tot = m_b + m_pl + 2 * m_w;                           % total mass [kg]

%% Estimated paramenters of the nonlinear model
k1 = 1.51348556280119;
k2 = 1.11964815684147;
k3 = 0.245609453747589;

%% Initial states
p0 = 2;                                                 % pitch [deg]

%% Contacts
transition_width = 1e-4;                                % [m]
k_c = m_tot * g / transition_width;                     % [N/m]
b_c = 2 * sqrt(k_c * m_tot);                            % [N/(m/s)]

static_friction_c = 0.6;
dynamic_friction_c = 0.4;

%% Controllers
K = lqr(linsys1, diag([10 1 500]), 1);
Kf = 1 / dcgain(feedback(linsys1, K));
Kf = Kf(3);

A = [linsys1.A, zeros(3, 1); 0 0 -1 0];
B = [linsys1.B; 0];
K_int = lqr(A, B, diag([10 1 500 1]), 1);
Kf_int = 1 / dcgain(feedback(ss(A, B, blkdiag(linsys1.C, 0), 0), K_int));
Kf_int = Kf_int(3);