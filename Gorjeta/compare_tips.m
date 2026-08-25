% compare_tips.m
% Uso:
%   [TipC, TipF, mean_diff] = compare_tips()
% Retorna as matrizes TipC (crisp) e TipF (fuzzy) e a diferença média absoluta

function [TipC, TipF, mean_diff] = compare_tips()
    % Gera grade igual à do fuzzy manual
    [F, S] = meshgrid(0:0.5:10, 0:0.5:10);
    TipF = zeros(size(F));
    TipC = zeros(size(F));
    % calcula fuzzy (usa a funcao que já plota)
    [~, ~, ~, TipGridF] = tip_fuzzy_manual(); % já plota
    TipF = TipGridF;

    % calcula crisp para cada ponto
    for i = 1:size(F,1)
        for j = 1:size(F,2)
            TipC(i,j) = tip_crisp(F(i,j), S(i,j));
        end
    end

    % plota lado a lado
    figure('Name','Comparacao Crisp x Fuzzy');
    subplot(1,2,1);
    surf(F,S,TipC,'EdgeColor','none'); view(45,30);
    title('Tip - Crisp'); xlabel('Food'); ylabel('Service'); zlabel('Tip (%)');
    subplot(1,2,2);
    surf(F,S,TipF,'EdgeColor','none'); view(45,30);
    title('Tip - Fuzzy'); xlabel('Food'); ylabel('Service'); zlabel('Tip (%)');

    mean_diff = mean(abs(TipF(:) - TipC(:)));
    fprintf('\nDiferença média absoluta entre superfícies: %0.3f pontos percentuais\n', mean_diff);
end
