% tip_fuzzy_legacy.m
% Versao compatível com newfis/addvar/addmf/addrule (MATLAB < R2018b ou toolbox antiga)
function fis = tip_fuzzy_legacy()
    % Cria um FIS Mamdani (versão antiga)
    fis = newfis('FIS_Gorjeta');

    % ----- Entradas -----
    fis = addvar(fis,'input','food',[0 10]);
    fis = addmf(fis,'input',1,'ruim','trapmf',[0 0 1.5 4]);
    fis = addmf(fis,'input',1,'bom','trimf',[3 5 7]);
    fis = addmf(fis,'input',1,'excelente','trapmf',[6 8.5 10 10]);

    fis = addvar(fis,'input','service',[0 10]);
    fis = addmf(fis,'input',2,'ruim','trapmf',[0 0 1.5 4]);
    fis = addmf(fis,'input',2,'bom','trimf',[3 5 7]);
    fis = addmf(fis,'input',2,'excelente','trapmf',[6 8.5 10 10]);

    % ----- Saída -----
    fis = addvar(fis,'output','tip',[0 20]);
    fis = addmf(fis,'output',1,'pequena','trimf',[0 5 7]);
    fis = addmf(fis,'output',1,'media','trimf',[8 10 12]);
    fis = addmf(fis,'output',1,'generosa','trimf',[13 15 20]);

    % ----- Regras -----
    % formato: [in1 in2 out weight oper], oper:1=AND,2=OR
    ruleList = [
        1 1 1 1 1;  % ruim & ruim -> pequena
        2 2 2 1 1;  % bom & bom -> media
        3 3 3 1 2;  % excelente OR excelente -> generosa
        1 2 2 1 1;  % ruim & bom -> media
        2 3 3 1 1;  % bom & excelente -> generosa
    ];
    fis = addrule(fis, ruleList);

    % Opcional: Mostrar e testar
    % showrule(fis)
    % Exemplo:
    % disp( evalfis([2 8], fis) )
end
