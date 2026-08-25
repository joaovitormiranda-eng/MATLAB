% tip_fuzzy_manual.m
% Uso:
%   [val, F, S, TipGrid] = tip_fuzzy_manual(food, service)
%   [~, F, S, TipGrid] = tip_fuzzy_manual()  % plota e retorna a grade
%
% val: escalar (gorjeta %) para o par (food,service)
% F,S,TipGrid: matriz de grade usada nos plots

function [val, F, S, TipGrid] = tip_fuzzy_manual(food, service)
    % universo da saida
    y = 0:0.1:20; % porcentagem de gorjeta

    % Funcoes de pertinencia
    trapmf = @(x,params) max( min( (x-params(1))./(params(2)-params(1)), ...
                                  min(1, (params(4)-x)./(params(4)-params(3))) ), 0);
    trimf  = @(x,params) max( min( (x-params(1))./(params(2)-params(1)), ...
                                  (params(3)-x)./(params(3)-params(2)) ), 0);

    mu_food_ruim = @(x) trapmf(x,[0 0 1.5 4]);
    mu_food_bom  = @(x) trimf(x,[3 5 7]);
    mu_food_exc  = @(x) trapmf(x,[6 8.5 10 10]);

    mu_serv_ruim = @(x) trapmf(x,[0 0 1.5 4]);
    mu_serv_bom  = @(x) trimf(x,[3 5 7]);
    mu_serv_exc  = @(x) trapmf(x,[6 8.5 10 10]);

    mu_tip_pequena = @(z) trimf(z,[0 5 7]);
    mu_tip_media    = @(z) trimf(z,[8 10 12]);
    mu_tip_generosa = @(z) trimf(z,[13 15 20]);

    % cria grade para plot (sempre)
    [F, S] = meshgrid(0:0.5:10, 0:0.5:10);
    TipGrid = zeros(size(F));
    for i = 1:numel(F)
        TipGrid(i) = eval_point(F(i), S(i), ...
            mu_food_ruim, mu_food_bom, mu_food_exc, ...
            mu_serv_ruim, mu_serv_bom, mu_serv_exc, ...
            mu_tip_pequena, mu_tip_media, mu_tip_generosa, y);
    end
    TipGrid = reshape(TipGrid, size(F));

    % PLOT: sempre mostrar superficie e contorno
    figure('Name','Fuzzy - Superfície');
    surf(F, S, TipGrid, 'EdgeColor','none'); view(45,30);
    xlabel('Food (0-10)'); ylabel('Service (0-10)'); zlabel('Tip (%)');
    title('Superfície de resposta — Sistema Fuzzy (manual)');

    figure('Name','Fuzzy - Contorno');
    contourf(F, S, TipGrid, 20);
    colorbar;
    xlabel('Food (0-10)'); ylabel('Service (0-10)');
    title('Mapa de contorno — Gorjeta (%)');

    % Se chamaram sem argumentos, imprime exemplos e retorna TipGrid
    if nargin == 0
        examples = [2 2; 2 8; 7 9; 4 4; 1 9];
        fprintf('\nExemplos (food, service) -> tip (%%)\n');
        for i = 1:size(examples,1)
            v = eval_point(examples(i,1), examples(i,2), ...
                mu_food_ruim, mu_food_bom, mu_food_exc, ...
                mu_serv_ruim, mu_serv_bom, mu_serv_exc, ...
                mu_tip_pequena, mu_tip_media, mu_tip_generosa, y);
            fprintf('(%g, %g) -> %0.2f%%\n', examples(i,1), examples(i,2), v);
        end
        val = [];
        return;
    end

    % Se recebeu (food,service), calcula e tambem garante que os plots foram gerados
    val = eval_point(food, service, ...
            mu_food_ruim, mu_food_bom, mu_food_exc, ...
            mu_serv_ruim, mu_serv_bom, mu_serv_exc, ...
            mu_tip_pequena, mu_tip_media, mu_tip_generosa, y);

    % imprime valor pontual tambem no Command Window
    fprintf('\nResultado pontual: (food=%g, service=%g) -> tip = %0.2f%%\n', food, service, val);
end

% função auxiliar que faz inferência + agregação + defuzz
function out = eval_point(food, service, ...
    mu_food_ruim, mu_food_bom, mu_food_exc, ...
    mu_serv_ruim, mu_serv_bom, mu_serv_exc, ...
    mu_tip_pequena, mu_tip_media, mu_tip_generosa, y)

    % pertinencias entradas
    a1 = mu_food_ruim(food); a2 = mu_food_bom(food); a3 = mu_food_exc(food);
    b1 = mu_serv_ruim(service); b2 = mu_serv_bom(service); b3 = mu_serv_exc(service);

    % regras (AND=min, OR=max)
    r1 = min(a1, b1);       % ruim & ruim -> pequena
    r2 = min(a2, b2);       % bom & bom -> media
    r3 = max(a3, b3);       % excelente OR excelente -> generosa
    r4 = min(a1, b2);       % ruim & bom -> media
    r5 = min(a2, b3);       % bom & excelente -> generosa

    % agrega por clipping e max
    agg = zeros(size(y));
    if r1>0, agg = max(agg, min(r1, mu_tip_pequena(y))); end
    if r2>0, agg = max(agg, min(r2, mu_tip_media(y))); end
    if r3>0, agg = max(agg, min(r3, mu_tip_generosa(y))); end
    if r4>0, agg = max(agg, min(r4, mu_tip_media(y))); end
    if r5>0, agg = max(agg, min(r5, mu_tip_generosa(y))); end

    % defuzz centroid
    if sum(agg) == 0
        out = 0;
    else
        out = sum(agg .* y) / sum(agg);
    end
end
