% =========================================================================
% AUDITORIA COMPARATIVA: CRISP vs. FUZZY
% Autor: João Vitor Miranda
% Descrição: Mapeia as superfícies dos modelos Booleano e Nebuloso, 
%            gerando a renderização 3D lado a lado e o erro MAE.
% Uso:
%   [TipC, TipF, mean_diff] = compare_tips()
% =========================================================================
function [TipC, TipF, mean_diff] = compare_tips()
    % Extração da malha Fuzzy Manual
    [~, F, S, TipF] = tip_fuzzy_manual();
    close(gcf); close(gcf); % Gerencia pop-ups das subfunções

    % Extração da malha Crisp (Vetorizada)
    [~, ~, ~, TipC] = tip_crisp();
    close(gcf); close(gcf);

    % --- Visualização Comparativa Integrada ---
    figure('Name', 'Auditoria: Crisp vs Fuzzy', 'Color', 'w', 'Position', [100, 100, 1100, 450]);

    subplot(1, 2, 1);
    surf(F, S, TipC, 'EdgeColor', 'none'); view(45, 30);
    colormap(jet); colorbar; zlim([0 20]);
    title('Modelo Crisp (Booleano / Degraus)');
    xlabel('Comida'); ylabel('Serviço'); zlabel('Gorjeta (%)');

    subplot(1, 2, 2);
    surf(F, S, TipF, 'EdgeColor', 'none'); view(45, 30);
    colormap(jet); colorbar; zlim([0 20]);
    title('Modelo Fuzzy (Mamdani / Suave)');
    xlabel('Comida'); ylabel('Serviço'); zlabel('Gorjeta (%)');

    % --- Métricas Estatísticas de Auditoria ---
    mean_diff = mean(abs(TipF(:) - TipC(:)));
    max_diff  = max(abs(TipF(:) - TipC(:)));

    fprintf('\n================ MÉTRICAS DE AUDITORIA ================\n');
    fprintf('Diferença Média Absoluta (MAE) : %0.3f p.p.\n', mean_diff);
    fprintf('Diferença Máxima Absoluta      : %0.3f p.p.\n', max_diff);
    fprintf('======================================================\n');
end