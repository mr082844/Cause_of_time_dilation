%% constants
c =  299792458; % [m/s] speed of light
h = 6.62607015e-34;% [m^2 kg / s] Planck's Constant
kB = 5.670374419184429453970e-8; % [J?m?2?s?1?K?4] stefan-boltzmann constant
b = 2.897771955e-3; % [m?K] Wien's displacement constant
G = 6.6744e-11; % [m^3/(kg s)] gravitational constant
re = 6371000; % [m] earth's mean radius
rSunE = 152.03e9; % [m] distance from sun to earth
Me = 5.97219e24; % [kg] earth's mass
Ms = 333000*Me; % [kg] sun's mass
eMax = c^2/2;
vGalaxy = 0.581152e6; %[m/s] how fast our galaxy is moving
planckl = @(lambda,T) 2*h*c^2./(lambda.^5.*(exp(h*c./(kB*lambda.*T))-1));
planckl_odd = @(lambda,T) 2*h*c^2./(lambda.^2.*(exp(h*c./(kB*lambda.*T))-1));
planckf = @(v,T) 2*h*v.^3./(c^2*(exp(h*v/(T))-1));
ly_per_parsec = 26/8;
ls_per_ly = 365*24*60*60;
m_per_ls = c;
m_per_parsec =  (m_per_ls * ls_per_ly * ly_per_parsec);
c_parsec = c / m_per_parsec;
G_parsec = G / (m_per_ls * ls_per_ly * ly_per_parsec)^3;
workP = @(M,r1,r2) integral(@(r) -G*M./r.^2,r1,r2);
gamma = @(M,r1,r2) 1/sqrt(1-workP(M,r1,r2)/eMax);
v_green = .55e-6;
m_green = v_green * h;
m_electron = 1e-31;
photon_per_electron = m_electron / m_green;

%% earth time derivative gradient
delta_E_r = 1000; % [m] Additional distance
rE_far = re + delta_E_r; % [m] earth distance from center of Sun
gamma_gr = gamma(Me,rE_far,re);
tau_SQ = 1 - 1/gamma_gr^2;
g_est = (eMax/delta_E_r) * tau_SQ;
gE_far = G*Me/rE_far^2;
gE = G*Me/re^2;
g_mean = sqrt(gE_far*gE);%(gGPS^dtGPS*ge^dte)^(1/(dtGPS + dte)); % matches a_est line 25
d_error = g_mean - g_est;
p_error = 100*d_error/g_mean;

%% solar time derivative gradient
dtSunE_far = 1;
delta_SunE_r = c/2; % [m] Additional distance
rSunE_far = rSunE + delta_SunE_r; % [m] earth distance from center of Sun
drSunE = delta_SunE_r/c;
r = rSunE:drSunE:rSunE_far;
g = Ms*G./r.^2;
dSE = g.*drSunE;
deltaSE = cumsum(dSE);
dSEend = deltaSE(end);
dt1_dt2 = dtSunE_far*sqrt(1-dSEend/eMax); % agrees with deltaGPS_t in line 13
grad_t = (dt1_dt2-dtSunE_far)/delta_SunE_r;
dv = delta_SunE_r/dtSunE_far;
a_est = (eMax/delta_SunE_r)*(1-(dv*grad_t+1)^2);
gSunE_far = G*Ms/rSunE_far^2;
gSunE = G*Ms/rSunE^2;
g_mean = sqrt(gSunE_far*gSunE);%(gGPS^dtGPS*ge^dte)^(1/(dtGPS + dte)); % matches a_est line 25
d_error = g_mean - a_est;
p_error = 100*d_error/g_mean;