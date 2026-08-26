% =========================================================================
% SISTEMA FUZZY - COMPATIBILIDADE LEGADA / GNU OCTAVE
% Autor: João Vitor Miranda
% Descrição: Construção via FIS Toolbox usando APIs clássicas (newfis/addvar).
% Nota: Compatível com GNU Octave. Para MATLAB R2018b+, recomenda-se 'mamfis'.
% Uso:
%   fis = tip_fuzzy_legacy();
%   evalfis([8 9], fis)
% =========================================================================
function fis = tip_fuzzy_legacy()
    % Inicialização do FIS Mamdani
    fis = newfis('FIS_Gorjeta');

    % ----- Entradas Linguísticas -----
    fis = addvar(fis, 'input', 'food', [0 10]);
    fis = addmf(fis, 'input', 1, 'ruim', 'trapmf', [0 0 1.5 4]);
    fis = addmf(fis, 'input', 1, 'bom', 'trimf', [3 5 7]);
    fis = addmf(fis, 'input', 1, 'excelente', 'trapmf', [6 8.5 10 10]);

    fis = addvar(fis, 'input', 'service', [0 10]);
    fis = addmf(fis, 'input', 2, 'ruim', 'trapmf', [0 0 1.5 4]);
    fis = addmf(fis, 'input', 2, 'bom', 'trimf', [3 5 7]);
    fis = addmf(fis, 'input', 2, 'excelente', 'trapmf', [6 8.5 10 10]);

    % ----- Saída Linguística -----
    fis = addvar(fis, 'output', 'tip', [0 20]);
    fis = addmf(fis, 'output', 1, 'pequena', 'trimf', [0 5 7]);
    fis = addmf(fis, 'output', 1, 'media', 'trimf', [8 10 12]);
    fis = addmf(fis, 'output', 1, 'generosa', 'trimf', [13 15 20]);

    % ----- Matriz de Inferência -----
    % Formato: [in1, in2, out, peso, operador] (1=AND, 2=OR)
    ruleList = [
        1 1 1 1 1;  % Ruim & Ruim -> Pequena
        2 2 2 1 1;  % Bom & Bom -> Média
        3 3 3 1 2;  % Excelente OR Excelente -> Generosa
        1 2 2 1 1;  % Ruim & Bom -> Média
        2 3 3 1 1;  % Bom & Excelente -> Generosa
    ];
    fis = addrule(fis, ruleList);
end