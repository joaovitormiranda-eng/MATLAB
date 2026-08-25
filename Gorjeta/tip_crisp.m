% tip_crisp.m
% Uso:
%   val = tip_crisp(food, service)
%   tip_crisp()  % gera gráfico comparativo

function val = tip_crisp(food, service)
    % Se chamado sem argumentos, gera gráficos e imprime exemplos
    if nargin == 0
        [F,S] = meshgrid(0:0.5:10, 0:0.5:10);
        TipGrid = zeros(size(F));
        for i = 1:numel(F)
            TipGrid(i) = rule_based(F(i), S(i));
        end
        TipGrid = reshape(TipGrid, size(F));

        % Superfície
        figure('Name','Cálculo Crisp - Superfície');
        surf(F,S,TipGrid,'EdgeColor','none'); view(45,30);
        xlabel('Food (0-10)'); ylabel('Service (0-10)'); zlabel('Tip (%)');
        title('Superfície de resposta — Sistema sem Fuzzy');

        % Contorno
        figure('Name','Cálculo Crisp - Contorno');
        contourf(F,S,TipGrid,20); colorbar;
        xlabel('Food (0-10)'); ylabel('Service (0-10)');
        title('Mapa de contorno — Gorjeta (%)');

        % Exemplos
        examples = [2 2; 2 8; 7 9; 4 4; 1 9];
        fprintf('\nExemplos (food, service) -> tip (%%)\n');
        for i = 1:size(examples,1)
            v = rule_based(examples(i,1), examples(i,2));
            fprintf('(%g, %g) -> %0.2f%%\n', examples(i,1), examples(i,2), v);
        end
        val = [];
        return;
    end

    % Se foi passado food e service
    val = rule_based(food, service);
    fprintf('\nResultado pontual: (food=%g, service=%g) -> tip = %0.2f%%\n', food, service, val);
end

% ---- Função auxiliar de regras diretas ----
function t = rule_based(food, service)
    % normaliza pra 0-10
    food = max(0, min(10, food));
    service = max(0, min(10, service));

    % Define gorjeta base (crisp)
    if (food < 4 && service < 4)
        t = 5; % ruim e ruim → pequena
    elseif (food >= 4 && food < 7 && service >= 4 && service < 7)
        t = 10; % bom e bom → média
    elseif (food >= 8 || service >= 8)
        t = 15; % excelente em um dos dois → generosa
    elseif (food < 4 && service >= 4)
        t = 10; % ruim & bom → média
    elseif (food >= 4 && service >= 8)
        t = 15; % bom & excelente → generosa
    else
        t = 10; % default média
    end
end

