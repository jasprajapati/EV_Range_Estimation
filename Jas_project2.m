%------------------------ Load Data ---------------------------------------
UDDS = readtable('UDDS.xlsx'); % Load UDDS drive cycle data
t_udds=UDDS.TestTime_sec_;
v_udds=UDDS.TargetSpeed_mph_;

US06 = readtable('US06.xlsx'); % Load US06 drive cycle data
t_us06=US06.TestTime_sec_;%Extract time(sec) from data set
v_us06=US06.TargetSpeed_mph_;%Extract target speed(mph) from data set

%----------------------- Initialize Variables------------------------------
m = 1300; % Vehicle mass excluding battery pack (kg)
g = 9.81; % Gravity acceleration (m/s^2)
theta = 0; % Slope (degrees)
cr = 0.013; % Rolling resistance coefficient
Af = 2.65; % Frontal area (m^2)
rho_air = 1.2; % Air density (kg/m^3)
cd = 0.23; % Drag coefficient
eta = 0.8; % Powertrain efficiency
ca = 0.12; % Auxiliary coefficient

x_1=96; x_2=92;
y_1=46;y_2=9;
Vcell_1=3.65; Vcell_2=3.6;
Qcell_1=4.6; Qcell_2=22;
cell_1_weight=68.6/1000; cell_2_weight=358/1000;  % cell weight in kg

%---------------------- Tesla 2170 Parameters------------------------------
Ecell_1 = Vcell_1 * Qcell_1; % Energy capacity of a single cell (Wh) 
Epack_1= x_1* y_1 * Ecell_1; % Energy capacity of the pack (Wh) 
Vpack_1 = x_1 * Vcell_1; % Pack voltage (V) 
Qpack_1 = y_1 * Qcell_1; % Pack capacity (Ah)
battery_weight_1 = y_1 * cell_1_weight * x_1; %  Total battery weight 
total_mass_1= m + battery_weight_1;% Total Vehicle Weight

%---------------------- Tesla 4680 Parameters------------------------------
Ecell_2 = Vcell_2 * Qcell_2; % Energy capacity of a single cell (Wh)
Epack_2= x_2 * y_2 * Ecell_2; % Energy capacity of the pack (Wh)
Vpack_2= x_2 * Vcell_2; % Pack voltage (V)
Qpack_2 = y_2* Qcell_2; % Pack capacity (Ah)
battery_weight_2 = y_2* cell_2_weight * x_2; % Assume cell weight 
total_mass_2 = m + battery_weight_2; % Total Vehicle Weight

%---------------------------Acceleration ----------------------------------
a_udds = gradient(v_udds/2.237, t_udds);
a_us06= gradient(v_us06/2.237,t_us06);

%-----------------duty cycle for Battery 1(Tesla 2170)---------------------
P_udds_1= ((total_mass_1* g * sind(theta)) + ...
          (cr * total_mass_1 * g * cosd(theta)) + ...
          (0.5 * rho_air * cd * Af .* (v_udds/ 2.237).^2) + ... % Convert mph to m/s for calculation
          (total_mass_1 .* a_udds)) .* (v_udds / 2.237);
figure
sgtitle('Duty Cycle P(t)');
subplot(2,1,1)
plot(t_udds,P_udds_1,Linewidth=1),xlabel('time(seconds)');ylabel('Duty Cycle'),title('Battery 1(Tesla 2170) UDDS Duty Cycle')

P_us06_1= ((total_mass_1* g * sind(theta)) + ...
          (cr * total_mass_1 * g * cosd(theta)) + ...
          (0.5 * rho_air * cd * Af .* (v_us06/ 2.237).^2) + ... % Convert mph to m/s for calculation
          (total_mass_1 .* a_us06)) .* (v_us06 / 2.237);
subplot(2,1,2)
plot(t_us06,P_us06_1,Linewidth=1),xlabel('time(seconds)');ylabel('Duty Cycle'),title('Battery 1(Tesla 2170) US06 Duty Cycle')

% ----------------duty cycle for Battery 2(Tesla 4680)---------------------
P_udds_2= ((total_mass_2* g * sind(theta)) + ...
          (cr * total_mass_2 * g * cosd(theta)) + ...
          (0.5 * rho_air * cd * Af .* (v_udds/ 2.237).^2) + ... % Convert mph to m/s for calculation
          (total_mass_2 .* a_udds)) .* (v_udds / 2.237);
figure
sgtitle('Duty Cycle P(t)');

subplot(2,1,1)
plot(t_udds,P_udds_2,Linewidth=1),xlabel('time(seconds)');ylabel('Duty Cycle'),title('Battery 2(Tesla 4680) USSD Duty Cycle')

P_us06_2= ((total_mass_2* g * sind(theta)) + ...
          (cr * total_mass_2 * g * cosd(theta)) + ...
          (0.5 * rho_air * cd * Af .* (v_us06/ 2.237).^2) + ... % Convert mph to m/s for calculation
          (total_mass_2 .* a_us06)) .* (v_us06 / 2.237);
subplot(2,1,2)
plot(t_us06,P_us06_2,Linewidth=1),xlabel('time(seconds)');ylabel('Duty Cycle'),title('Battery 2(Tesla 4680) US06 Duty Cycle')

%------------------------ Pack Current I(t)--------------------------------
I_udds_1=P_udds_1./Vpack_1;
I_udds_2=P_udds_2./Vpack_2;
I_us06_1=P_us06_1./Vpack_1;
I_us06_2=P_us06_2./Vpack_2;
figure
sgtitle('Pack Current I(t)');
subplot(2,1,1)
plot(t_udds,I_udds_1,LineWidth=1),xlabel('Time(seconds)'),ylabel('Pack Current I(t) (Amphere)'),title('Battery 1(Tesla 2170) UDDS');
subplot(2,1,2)
plot(t_udds,I_udds_2,LineWidth=1),xlabel('Time(seconds)'),ylabel('Pack Current I(t) (Amphere)'),title('Battery 2(Tesla 4680) UDDS');

figure
sgtitle('Pack Current I(t)');
subplot(2,1,1)
plot(t_us06,I_us06_1,LineWidth=1),xlabel('Time(seconds)'),ylabel('Pack Current I(t) (Amphere)'),title('Battery 1(Tesla 2170) US06');
subplot(2,1,2)
plot(t_us06,I_us06_2,LineWidth=1),xlabel('Time(seconds)'),ylabel('Pack Current I(t) (Amphere)'),title('Battery 2(Tesla 4680) US06');

%------------------------------SOC Calculation-----------------------------
SOC_1_udds= zeros(size(t_udds));
SOC_1_udds(1) = 0.8; % Initial SOC (80%)
dt_udds_1= t_udds(2) - t_udds(1); % Assuming uniform time steps

% Loop through the time vector
for i = 2:length(t_udds)
    % Update SOC using the current at each step
    SOC_1_udds(i) = SOC_1_udds(i-1) - (I_udds_1(i) / Qpack_1) * dt_udds_1/3600;
end
figure
sgtitle('State of Charge(SOC)');
subplot(2,1,1)
plot(t_udds,SOC_1_udds,Linewidth=1.5);title('Battery 1(Tesla 2170) UDDS');xlabel('time(seconds)'),ylabel('SOC(%)');

SOC_2_udds= zeros(size(t_udds)); 
SOC_2_udds(1) = 0.8; % Initial SOC (80%)
dt_udds_2 = t_udds(2) - t_udds(1); % Assuming uniform time steps

% Loop through the time vector
for i = 2:length(t_udds)
    % Update SOC using the current at each step
    SOC_2_udds(i) = SOC_2_udds(i-1) - (I_udds_2(i) / Qpack_2) * dt_udds_2/3600;
end
subplot(2,1,2)
plot(t_udds,SOC_2_udds,Linewidth=1.5);title('Battery 2(Tesla 4680) UDDS');xlabel('time(seconds)'),ylabel('SOC(%)');

SOC_us06_1= zeros(size(t_us06));
SOC_us06_1(1) = 0.8; % Initial SOC (80%)
dt_us06_1 = t_us06(2) - t_us06(1); % Assuming uniform time steps

% Loop through the time vector
for i = 2:length(t_us06)
    % Update SOC using the current at each step
    SOC_us06_1(i) = SOC_us06_1(i-1) - (I_us06_1(i) / Qpack_1) * dt_us06_1/3600;
end
figure
sgtitle('State of Charge(SOC)');
subplot(2,1,1)
plot(t_us06,SOC_us06_1,Linewidth=1.5);title('Battery 1(Tesla 2170) US06');xlabel('time(seconds)'),ylabel('SOC(%)');

SOC_us06_2= zeros(size(t_us06));
SOC_us06_2(1) = 0.8; % Initial SOC (80%)
dt_us06_2 = t_us06(2) - t_us06(1); % Assuming uniform time steps

% Loop through the time vector
for i = 2:length(t_us06)
    % Update SOC using the current at each step
    SOC_us06_2(i) = SOC_us06_2(i-1) -(I_us06_2(i) / Qpack_1) * dt_us06_2/3600;
end
subplot(2,1,2)
plot(t_us06,SOC_us06_2,Linewidth=1.5);title('Battery 2(Tesla 4680) US06');xlabel('time(seconds)'),ylabel('SOC(%)');

%---------------- Battery 1(Tesla 2170) Energy Calculation -----------------
% Battery 1 Energy Calculations
% Discharge Energy (P_udds_1 > 0)
Ed_udds_1 = trapz(t_udds, max(0,P_udds_1)) / 3600; % Multiply by logical mask
% Charge Energy (P_udds_1 < 0)
Ec_udds_1 = trapz(t_udds, min(0,P_udds_1)) / 3600; % Multiply by logical mask

% Total Energy Consumption for UDDS
Evehicle_udds_1 = (Ed_udds_1 / eta + Ec_udds_1 * eta) * (1 - ca);

% Battery 1 - US06
Ed_us06_1 = trapz(t_us06, max(0,P_us06_1)) / 3600;
Ec_us06_1 = trapz(t_us06, min(0,P_us06_1)) / 3600;

Evehicle_us06_1 = (Ed_us06_1 / eta + Ec_us06_1 * eta) * (1 - ca);

% -----------Battery 2(Tesla 4680) Energy Calculations---------------------
% Discharge Energy (P_udds_2 > 0)
Ed_udds_2 = trapz(t_udds,max(0, P_udds_2)) / 3600;
% Charge Energy (P_udds_2 < 0)
Ec_udds_2 = trapz(t_udds, min(0,P_udds_2)) / 3600;
% Total Energy Consumption for UDDS
Evehicle_udds_2 = (Ed_udds_2 / eta + Ec_udds_2 * eta) * (1 - ca);

% Battery 2 - US06

Ed_us06_2 = trapz(t_us06, max(0,P_us06_2)) / 3600;
Ec_us06_2 = trapz(t_us06,min(0, P_us06_2)) / 3600;
Evehicle_us06_2 = (Ed_us06_2 / eta + Ec_us06_2 * eta) * (1 - ca);


%------------------------Distance covered----------------------------------
 D_1= trapz(t_udds, v_udds/ 2.237); % Distance (m) (convert mph to m/s for integration)
        D_1 = D_1/ 1000; % Distance (km)

 D_2 = trapz(t_us06, v_us06 / 2.237); % Distance (m) (convert mph to m/s for integration)
        D_2 = D_2 / 1000; % Distance (km)

%----------------------Energy Consumption----------------------------------
 Econ_udds_1=0;
 Econ_udds_2 =0;
 Econ_us06_1 =0;
 Econ_us06_2=0;
Econ_udds_1 = Evehicle_udds_1/ D_1;
 Econ_udds_2 = Evehicle_udds_2/ D_1;
 Econ_us06_1 = Evehicle_us06_1/ D_2;
 Econ_us06_2 = Evehicle_us06_2/ D_2;
 %-----------------------Range Calculation---------------------------------
 Range_udds_1=Epack_1/ Econ_udds_1;
 Range_udds_2=Epack_2/Econ_udds_2;
 Range_us06_1=Epack_1/Econ_us06_1;
 Range_us06_2=Epack_2/Econ_us06_2;

 %---------------------Priniting final results----------------------------
 fprintf('Battery Pack: Tesla 2170 | Drive Cycle: UDDS \n');
 fprintf('Range: %.2f km\n', Range_udds_1);
 fprintf('Energy Consumption: %.2f Wh/km\n', Econ_udds_1);
 fprintf('Battery Weight: %.2f kg\n\n', battery_weight_1);

 fprintf('Battery Pack: Tesla 2170 | Drive Cycle: US06 \n');
 fprintf('Range: %.2f km\n', Range_us06_1);
 fprintf('Energy Consumption: %.2f Wh/km\n', Econ_us06_1);
 fprintf('Battery Weight: %.2f kg\n\n', battery_weight_1);

 fprintf('Battery Pack: Tesla 4680 | Drive Cycle: UDDS \n');
 fprintf('Range: %.2f km\n', Range_udds_2);
 fprintf('Energy Consumption: %.2f Wh/km\n', Econ_udds_2);
 fprintf('Battery Weight: %.2f kg\n\n', battery_weight_2);

 fprintf('Battery Pack: Tesla 4680 | Drive Cycle: US06 \n');
 fprintf('Range: %.2f km\n', Range_us06_2);
 fprintf('Energy Consumption: %.2f Wh/km\n', Econ_us06_2);
 fprintf('Battery Weight: %.2f kg\n\n', battery_weight_2);