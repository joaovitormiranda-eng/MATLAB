%% ========================================================
%  GERADOR AUTOMÁTICO DE IMAGENS PARA O LATEX
%  Rode este script para salvar as 10 imagens diretamente 
%  na pasta 'images/' com os nomes exatos do seu relatório!
%% ========================================================
close all; clear all; clc;

% Criar a pasta 'images' automaticamente se ela não existir
if ~exist('images', 'dir')
    mkdir('images');
end

%% --- 1. GERAÇÃO DOS DIAGRAMAS DE BODE (G1 e G2) ---
disp('>> Gerando Diagramas de Bode (G1.png e G2.png)...');
A = [0 1 0 0; 0 -0.0195 0.2381 -0.0013; 0 0 0 1; 0 -0.0132 6.8073 -0.0377];
B = [0; 0.3895; 0; 0.2638];
C = [1 0 0 0; 0 0 1 0]; % Linha 1: Posição (G2), Linha 2: Ângulo (G1)
D = [0; 0];
sys = ss(A, B, C, D);

% Bode de G1 (Ângulo - Filtro Passa-Faixa conforme seu texto)
figBode1 = figure('Color', 'w');
bode(sys(2), {1e-1, 1e3});
grid on;
title('Diagrama de Bode de G1 (\Theta(s)/F(s)) - Angulo');
saveas(figBode1, 'images/G1.png');
close(figBode1);

% Bode de G2 (Posição - Filtro Passa-Baixa conforme seu texto)
figBode2 = figure('Color', 'w');
bode(sys(1), {1e-1, 1e3});
grid on;
title('Diagrama de Bode de G2 (X(s)/F(s)) - Posicao');
saveas(figBode2, 'images/G2.png');
close(figBode2);


%% --- 2. CONFIGURAÇÕES DA SIMULAÇÃO (GANHOS DO SEU LATEX) ---
g=9.81; l=0.4; M=2.4; m=0.23; I=0.099; b=0.05; d=0.005;
N1=100; N2=100;
x0=0.2; v0=0; theta0=deg2rad(5); dtheta0=0;
x_ref=0; theta_ref=0;

% Matriz de ganhos extraída exatamente do seu texto em LaTeX!
% Colunas: [Kp1, Kd1, Ki1, Kp2, Kd2, Ki2]
ganhos_etapas = [
    0,    0,   0,       0,  0,  0;    % Malha Aberta
    0,    0,   0,       60, 0,  0;    % Etapa 1: Só Kp2 (resp_kp2)
    0,    0,   0,       60, 12, 0;    % Etapa 2: Kp2 + Kd2 (resp_kd2)
    0,    0,   0,       60, 12, 0.2;  % Etapa 3: PID Angular (resp_ki2)
    0.03, 0,   0,       60, 12, 0.2;  % Etapa 4: + Kp1 (resp_kp1)
    0.03, 3.0, 0,       60, 12, 0.2;  % Etapa 5: + Kd1 (resp_kd1)
    0.03, 3.0, 0.002,   60, 12, 0.2   % Etapa 6: PID Completo Otimizado (resp_final)
];

nomes_arquivos = {
    'malha_aberta.png', ...
    'resp_kp2.png', ...
    'resp_kd2.png', ...
    'resp_ki2.png', ...
    'resp_kp1.png', ...
    'resp_kd1.png', ...
    'resp_final.png'
};

titulos = {
    'Malha Aberta (Sem Controle)', ...
    'Etapa 1: Resposta apenas com Kp2 = 60', ...
    'Etapa 2: Resposta com Kp2 = 60 e Kd2 = 12', ...
    'Etapa 3: Resposta com PID angular completo', ...
    'Etapa 4: Resposta com o acrescimo de Kp1 = 0.03', ...
    'Etapa 5: Resposta com o acrescimo de Kd1 = 3.0', ...
    'Etapa 6: Resposta final com todos os ganhos ajustados'
};

%% --- 3. LOOP DE SIMULAÇÃO (Roda o Simulink 7 vezes) ---
disp('>> Iniciando simulacoes do Simulink...');
for i = 1:7
    Kp1 = ganhos_etapas(i,1); Kd1 = ganhos_etapas(i,2); Ki1 = ganhos_etapas(i,3);
    Kp2 = ganhos_etapas(i,4); Kd2 = ganhos_etapas(i,5); Ki2 = ganhos_etapas(i,6);
    
    fprintf('Rodando simulação %d/7: %s...\n', i, nomes_arquivos{i});
    
    % Executa o modelo do Simulink
    out = sim('nonlinear_model_inverted_pendulum.slx');
    
    % Extrai os dados salvos pelo Scope/ToWorkspace
    x = out.simout.signals.values(:,1);
    theta = rad2deg(out.simout.signals.values(:,2));
    F = out.simout.signals.values(:,3);
    t = out.simout.time;
    
    % Criar a figura com formatação limpa para artigo científico
    fig = figure('Color', 'w', 'Units', 'inches', 'Position', [1, 1, 6.5, 4.5]);
    
    % Subplot 1: Posição
    subplot(2,1,1)
    plot(t, x, 'b', 'LineWidth', 1.5, 'DisplayName', 'Posicao x(t)');
    hold on; grid on;
    plot(t, x_ref*ones(size(t)), 'k--', 'LineWidth', 1, 'DisplayName', 'Referencia');
    ylabel('Posicao (m)');
    title(titulos{i});
    legend('Location', 'best');
    
    % Subplot 2: Ângulo
    subplot(2,1,2)
    plot(t, theta, 'r', 'LineWidth', 1.5, 'DisplayName', 'Angulo \theta(t)');
    hold on; grid on;
    plot(t, theta_ref*ones(size(t)), 'k--', 'LineWidth', 1, 'DisplayName', 'Referencia');
    plot(t, 2.86+theta_ref*ones(size(t)), 'm:', 'LineWidth', 1, 'DisplayName', '+0.05 rad'); % 0.05 rad =~ 2.86 deg
    plot(t, -2.86+theta_ref*ones(size(t)), 'm:', 'LineWidth', 1, 'DisplayName', '-0.05 rad');
    ylabel('Angulo (graus)');
    xlabel('Tempo (s)');
    legend('Location', 'best');
    
    % Salva na pasta automática 'images/'
    saveas(fig, fullfile('images', nomes_arquivos{i}));
    close(fig);
    
    % Se for a última etapa, gera o gráfico extra da Força de Controle
    if i == 7
        figF = figure('Color', 'w', 'Units', 'inches', 'Position', [1, 1, 6.5, 3]);
        plot(t, F, 'Color', [0 0.5 0], 'LineWidth', 1.5);
        grid on;
        title('Sinal de forca de controle F(t) - PID Otimizado');
        xlabel('Tempo (s)');
        ylabel('Forca (N)');
        saveas(figF, 'images/forca_controle.png');
        close(figF);
    end
end

disp('>> SUCESSO! Todas as 10 imagens estao salvas na pasta "images/".');