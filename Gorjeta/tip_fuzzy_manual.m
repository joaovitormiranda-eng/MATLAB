% =========================================================================
% SISTEMA DE INFERÊNCIA FUZZY MAMDANI (IMPLEMENTAÇÃO VETORIAL NATIVA)
% Autor: João Vitor Miranda
% Descrição: Motor Fuzzy completo desenvolvido sem dependência de Toolboxes.
% Uso:
%   val = tip_fuzzy_manual(8, 9)     -> Retorna a gorjeta pontual (escalar)
%   [val, F, S, TipGrid] = tip_fuzzy_manual() -> Plota malhas e retorna dados
% =========================================================================
function [val, F, S, TipGrid] = tip_fuzzy_manual(food, service)
    y = 0:0.1:20; % Universo de discurso da saída (Gorjeta %)

    % --- Funções de Pertinência Robustas (Proteção contra NaN) ---
    trapmf = @(x, p) max(min( ...
        min((p(2)==p(1)) + (p(2)~=p(1))*(x - p(1))/max(p(2)-p(1), eps), ...
            (p(4)==p(3)) + (p(4)~=p(3))*(p(4) - x)/max(p(4)-p(3), eps)), 1), 0);
    trimf  = @(x, p) max(min((x - p(1))/max(p(2)-p(1), eps), ...
                             (p(3) - x)/max(p(3)-p(2), eps)), 0);

    % --- Dicionário de Conjuntos Fuzzy ---
    mf.food_ruim = @(x) trapmf(x, [0 0 1.5 4]);
    mf.food_bom  = @(x) trimf(x,  [3 5 7]);
    mf.food_exc  = @(x) trapmf(x, [6 8.5 10 10]);

    mf.serv_ruim = @(x) trapmf(x, [0 0 1.5 4]);
    mf.serv_bom  = @(x) trimf(x,  [3 5 7]);
    mf.serv_exc  = @(x) trapmf(x, [6 8.5 10 10]);

    mf.tip_peq   = @(z) trimf(z,  [0 5 7]);
    mf.tip_med   = @(z) trimf(z,  [8 10 12]);
    mf.tip_gen   = @(z) trimf(z,  [13 15 20]);

    % --- Avaliação Pontual Rápida ---
    if nargin >= 2
        val = eval_engine(food, service, mf, y);
        fprintf('[INFO] Entrada: (Food=%.1f, Service=%.1f) -> Gorjeta: %.2f%%\n', food, service, val);
        F = []; S = []; TipGrid = [];
        return;
    end

    % --- Geração de Malha de Alta Resolução ---
    [F, S] = meshgrid(0:0.1:10, 0:0.1:10);
    TipGrid = arrayfun(@(f, s) eval_engine(f, s, mf, y), F, S);

    % Cor de fundo Dark Navy (Idêntica ao site)
    darkBg = [0.03 0.05 0.09];

    % --- 1. Renderização 3D (Dark Theme + Parula do Site) ---
    figure('Name', 'Superfície de Resposta Fuzzy (Manual)', 'Color', darkBg);
    surf(F, S, TipGrid, 'EdgeColor', 'none');
    shading interp; % Gradiente continuo sem sombras artificiais

    colormap(parula);
    cb = colorbar;
    cb.Color = 'w';

    ax1 = gca;
    ax1.Color = darkBg;
    ax1.XColor = 'w';
    ax1.YColor = 'w';
    ax1.ZColor = 'w';
    ax1.GridColor = [0.4 0.4 0.4];
    ax1.GridAlpha = 0.3;
    grid on; box on;
    zlim([0 20]);

    xlabel('Qualidade da Comida (0-10)', 'FontWeight', 'bold', 'FontSize', 11, 'Color', 'w');
    ylabel('Qualidade do Serviço (0-10)', 'FontWeight', 'bold', 'FontSize', 11, 'Color', 'w');
    zlabel('Gorjeta Estimada (%)', 'FontWeight', 'bold', 'FontSize', 11, 'Color', 'w');
    title('Superficie de Resposta Fuzzy (Mamdani)', 'FontSize', 13, 'FontWeight', 'bold', 'Color', 'w');
    view(45, 30);

    % --- 2. Mapa de Contorno Fuzzy ---
    figure('Name', 'Mapa de Contorno Fuzzy', 'Color', darkBg);
    contourf(F, S, TipGrid, 25, 'LineColor', 'none');
    colormap(parula);
    cb2 = colorbar;
    cb2.Color = 'w';

    ax2 = gca;
    ax2.Color = darkBg;
    ax2.XColor = 'w';
    ax2.YColor = 'w';
    ax2.GridColor = [0.4 0.4 0.4];
    ax2.GridAlpha = 0.3;
    grid on; box on;

    xlabel('Qualidade da Comida (0-10)', 'FontWeight', 'bold', 'FontSize', 11, 'Color', 'w');
    ylabel('Qualidade do Serviço (0-10)', 'FontWeight', 'bold', 'FontSize', 11, 'Color', 'w');
    title('Zonas de Atuação Proporcional (Gorjeta %)', 'FontSize', 13, 'FontWeight', 'bold', 'Color', 'w');

    val = [];
end

% --- Engine de Inferência e Defuzzificação ---
function out = eval_engine(food, service, mf, y)
    food = max(0, min(10, food));
    service = max(0, min(10, service));

    % Fuzzificação
    a1 = mf.food_ruim(food); a2 = mf.food_bom(food); a3 = mf.food_exc(food);
    b1 = mf.serv_ruim(service); b2 = mf.serv_bom(service); b3 = mf.serv_exc(service);

    % Avaliação das Regras (Mamdani: T-norma Min / S-norma Max)
    r1 = min(a1, b1); % Ruim & Ruim -> Pequena
    r2 = min(a2, b2); % Bom & Bom -> Média
    r3 = max(a3, b3); % Excelente OR Excelente -> Generosa
    r4 = min(a1, b2); % Ruim & Bom -> Média
    r5 = min(a2, b3); % Bom & Excelente -> Generosa

    % Agregação dos Conjuntos Fuzzy de Saída (Clipping)
    agg = zeros(size(y));
    if r1 > 0, agg = max(agg, min(r1, mf.tip_peq(y))); end
    if r2 > 0, agg = max(agg, min(r2, mf.tip_med(y))); end
    if r3 > 0, agg = max(agg, min(r3, mf.tip_gen(y))); end
    if r4 > 0, agg = max(agg, min(r4, mf.tip_med(y))); end
    if r5 > 0, agg = max(agg, min(r5, mf.tip_gen(y))); end

    % Defuzzificação pelo Método do Centroide
    sum_agg = sum(agg);
    if sum_agg == 0
        out = 0;
    else
        out = sum(agg .* y) / sum_agg;
    end
end

% Executa e gera as figuras
[~, F, S, TipGrid] = tip_fuzzy_manual();

% Exporta a Superfície 3D (Figura 1)
exportgraphics(figure(1), 'fuzzy-superficie-resposta-3d.png', 'Resolution', 300);

% Exporta o Mapa de Contorno (Figura 2)
exportgraphics(figure(2), 'fuzzy-mapa-contorno-2d.png', 'Resolution', 300);