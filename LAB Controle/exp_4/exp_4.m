% =========================================================================
% EXPERIMENTO 4 - PÊNDULO INVERTIDO (Análise e Controle PID)
% =========================================================================
clear; clc; close all;

%% 1. PARÂMETROS NOMINAIS DO SISTEMA
% ATENÇÃO: Substitua pelos valores exatos se o seu .zip forneceu outros!
M = 0.5;    % Massa do carrinho (kg)
m = 0.2;    % Massa do pêndulo (kg)
l = 0.3;    % Distância do pivô ao centro de massa (m)
g = 9.81;   % Aceleração da gravidade (m/s^2)
b = 0.1;    % Coeficiente de atrito do carrinho (N.s/m)
I = 0.006;  % Momento de inércia do pêndulo (kg.m^2)

%% 2. MODELAGEM SIMBÓLICA (Obtenção de G1 e G2)
disp('--- Funções de Transferência Simbólicas ---');
syms s X Theta F

% Equações linearizadas clássicas em Laplace (theta = 0, para cima):
% Eq(6): (M + m)*s^2*X + b*s*X + m*l*s^2*Theta == F
% Eq(7): m*l*s^2*X + (I + m*l^2)*s^2*Theta - m*g*l*Theta == 0

% Isolando X(s) na Eq(7):
% X = -((I + m*l^2)*s^2 - m*g*l) * Theta / (m*l*s^2)

% Denominador comum (determinante):
q = (M+m)*(I + m*l^2) - (m*l)^2;

% G1(s) = Theta(s) / F(s)
num_G1 = m*l*s^2;
den_G1 = q*s^4 + b*(I + m*l^2)*s^3 - (M+m)*m*g*l*s^2 - b*m*g*l*s;
G1_sym = num_G1 / den_G1;

% G2(s) = X(s) / F(s)
num_G2 = (I + m*l^2)*s^2 - m*g*l;
den_G2 = q*s^4 + b*(I + m*l^2)*s^3 - (M+m)*m*g*l*s^2 - b*m*g*l*s;
G2_sym = num_G2 / den_G2;

%% 3. FUNÇÕES DE TRANSFERÊNCIA NUMÉRICAS E BODE
disp('--- Diagramas de Bode ---');
s_tf = tf('s');
q_num = (M+m)*(I + m*l^2) - (m*l)^2;

% G1(s): Theta/F
G1 = (m*l) / (q_num*s^2 + b*(I + m*l^2)*s - (M+m)*m*g*l - b*m*g*l/s); % Simplificado
G1 = minreal(tf([m*l 0 0], [q_num, b*(I+m*l^2), -(M+m)*m*g*l, -b*m*g*l, 0]));

% G2(s): X/F
G2 = minreal(tf([(I + m*l^2), 0, -m*g*l], [q_num, b*(I+m*l^2), -(M+m)*m*g*l, -b*m*g*l, 0]));

figure(1);
bode(G1, 'r', G2, 'b');
grid on;
legend('G_1(s) = \Theta(s)/F(s)', 'G_2(s) = X(s)/F(s)');
title('Diagrama de Bode do Sistema Linearizado em Malha Aberta');

%% 4. ESPAÇO DE ESTADOS (theta = 0 graus)
disp('--- Modelo em Espaço de Estados (\theta = 0) ---');
% Vetor de estados: x = [x; x_ponto; theta; theta_ponto]
A_0 = [0, 1, 0, 0;
       0, -(I+m*l^2)*b/q_num, (m^2*g*l^2)/q_num, 0;
       0, 0, 0, 1;
       0, -(m*l*b)/q_num, m*g*l*(M+m)/q_num, 0];
   
B_0 = [0; (I+m*l^2)/q_num; 0; m*l/q_num];
C_0 = [1 0 0 0; 0 0 1 0]; % Medindo posição x e ângulo theta
D_0 = [0; 0];

sys_0 = ss(A_0, B_0, C_0, D_0);
polos_0 = pole(sys_0);
disp('Polos para theta = 0 (Equilíbrio Instável):');
disp(polos_0);

%% 5. ESPAÇO DE ESTADOS (theta = 180 graus - Pendente para baixo)
disp('--- Modelo em Espaço de Estados (\theta = 180) ---');
% Sinal da gravidade inverte
A_180 = [0, 1, 0, 0;
         0, -(I+m*l^2)*b/q_num, -(m^2*g*l^2)/q_num, 0;
         0, 0, 0, 1;
         0, (m*l*b)/q_num, -m*g*l*(M+m)/q_num, 0];
     
sys_180 = ss(A_180, B_0, C_0, D_0);
polos_180 = pole(sys_180);
disp('Polos para theta = 180 (Equilíbrio Estável):');
disp(polos_180);

%% 6. ROTEIRO DE AJUSTE DO PID (Deixe os ganhos aqui para rodar o Simulink)
disp('--- Variáveis do PID Carregadas ---');
% Roteiro 1.3.1 (Ajuste fino final - Passo 8)
% (Ajuste estes valores e rode o seu modelo Simulink para calcular J)

Kp2 = 50;   % Controlador de ângulo (Dica: 30 a 70)
Kd2 = 10;   % Derivativo do ângulo (Dica: 5 a 15)
Ki2 = 0.3;  % Integral do ângulo (Dica: 0.1 a 0.5)

Kp1 = 0.4;  % Controlador de posição (Dica: 0.1 a 0.7)
Kd1 = 3.5;  % Derivativo da posição (Dica: 2 a 5)
Ki1 = 0.003; % Integral da posição (Dica: 0.001 a 0.005)

disp('Abra o seu arquivo .slx e rode a simulação para ver a resposta!');