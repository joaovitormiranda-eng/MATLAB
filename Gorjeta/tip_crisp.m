% =========================================================================
% SISTEMA DE REGRAS BOOLEANAS (BASE CRISP)
% Autor: João Vitor Miranda
% Descrição: Modelo baseline determinístico baseado em regras rígidas.
% Uso:
%   val = tip_crisp(8, 9)               -> Retorna a gorjeta pontual (%)
%   [val, F, S, TipGrid] = tip_crisp()  -> Plota malha 3D e retorna dados
% =========================================================================
function [val, F, S, TipGrid] = tip_crisp(food, service)
    % Avaliação pontual rápida sem efeitos colaterais
    if nargin >= 2
        val = rule_based(food, service);
        return;
    end

    % --- Geração da Malha 3D e Diagnóstico Visual ---
    [F, S] = meshgrid(0:0.5:10, 0:0.5:10);
    TipGrid = arrayfun(@rule_based, F, S);

    figure('Name', 'Superfície Crisp (Baseline)', 'Color', 'w');
    surf(F, S, TipGrid, 'EdgeColor', 'none'); view(45, 30);
    colormap(jet); colorbar;
    xlabel('Comida (0-10)'); ylabel('Serviço (0-10)'); zlabel('Gorjeta (%)');
    title('Superfície de Resposta - Lógica Booleana (Crisp)');

    figure('Name', 'Mapa de Contorno Crisp', 'Color', 'w');
    contourf(F, S, TipGrid, 20); colorbar; colormap(jet);
    xlabel('Comida (0-10)'); ylabel('Serviço (0-10)');
    title('Zonas de Decisão Descontínuas (Crisp)');

    % Log de exemplos no terminal
    examples = [2 2; 2 8; 7 9; 4 4; 1 9];
    fprintf('\n--- Exemplos de Resposta Crisp ---\n');
    for i = 1:size(examples, 1)
        v = rule_based(examples(i,1), examples(i,2));
        fprintf('Comida: %g | Serviço: %g -> Gorjeta: %0.2f%%\n', examples(i,1), examples(i,2), v);
    end

    val = [];
end

% --- Função Auxiliar de Decisão Directa ---
function t = rule_based(food, service)
    food = max(0, min(10, food));
    service = max(0, min(10, service));

    if (food < 4 && service < 4)
        t = 5;
    elseif (food >= 4 && food < 7 && service >= 4 && service < 7)
        t = 10;
    elseif (food >= 8 || service >= 8)
        t = 15;
    elseif (food < 4 && service >= 4)
        t = 10;
    elseif (food >= 4 && service >= 8)
        t = 15;
    else
        t = 10;
    end
end