% =========================================================================
% PROGRAMA PRINCIPAL - ANÁLISE MATRICIAL DE TRELIÇAS
% Exercício 2 - Profa. Laís De Bortoli Lecchi (UFES)
% =========================================================================
clc; clear all; close all;

%% 1. DADOS DE ENTRADA (Convertidos para o SI)

% Matriz de coordenadas dos nós: [NÓ, X (m), Y (m)]
% Considerando o apoio articulado da esquerda como a origem (0,0)
COORD = [
    1,  0.0, 0.0;  % Apoio Fixo (Esquerda)
    2,  7.2, 0.0;  % Nó inferior central (Carga de 330 kN)
    3, 14.4, 0.0;  % Apoio Móvel (Direita interno)
    4, 21.6, 0.0;  % Apoio Móvel (Direita extremo)
    5,  7.2, 5.4;  % Nó superior esquerdo (Carga de 110 kN)
    6, 14.4, 5.4   % Nó superior direito (Carga de 270 kN)
];

% Matriz de conectividade das barras: [ELEMENTO, NÓ_I, NÓ_J]
ELEM = [
    1,  1, 2;  % Banzo inferior 1
    2,  2, 3;  % Banzo inferior 2
    3,  3, 4;  % Banzo inferior 3 (Alumínio)
    4,  1, 5;  % Diagonal esquerda
    5,  2, 5;  % Montante esquerdo
    6,  5, 6;  % Banzo superior
    7,  2, 6;  % Diagonal inclinada para direita (/)
    8,  3, 5;  % Diagonal inclinada para esquerda (\)
    9,  3, 6;  % Montante direito
    10, 6, 4   % Diagonal direita (Alumínio)
];

% Condições de apoio: [NÓ, Restrição_X, Restrição_Y] (1 = Restringido, 0 = Livre)
APOIOS = [
    1, 1, 1;  % Apoio 1: Fixo (Restringe X e Y)
    2, 0, 0;  % Nó 2: Livre
    3, 0, 1;  % Apoio 3: Móvel (Restringe Y)
    4, 0, 1;  % Apoio 4: Móvel (Restringe Y)
    5, 0, 0;  % Nó 5: Livre
    6, 0, 0   % Nó 6: Livre
];

% Propriedades dos Materiais (E em Pa) e Seções Transversais (A em m²)
% Áreas: A1 = 52e-4 m², A2 = 77e-4 m², A3 = 103e-4 m²
% Módulos: E_aço = 200e9 Pa, E_al = 69e9 Pa
MAT = [
    1, 200e9; 2, 200e9; 3, 69e9; 4, 200e9; 5, 200e9;
    6, 200e9; 7, 200e9; 8, 200e9; 9, 200e9; 10, 69e9
];

SEC = [
    1, 52e-4; 2, 52e-4; 3, 103e-4; 4, 77e-4; 5, 52e-4;
    6, 52e-4; 7, 77e-4; 8, 77e-4;  9, 52e-4; 10, 103e-4
];

% Matriz de forças nodais: [NÓ, Força_X (N), Força_Y (N)]
FORCAS = [
    1,       0,       0;
    2,       0, -330e3;  % F2 = 330 kN para baixo
    3,       0,       0;
    4,       0,       0;
    5,  110e3,       0;  % F1 = 110 kN para a direita
    6,       0, -270e3   % F3 = 270 kN para baixo
];

%% 2. PROCESSAMENTO E RESOLUÇÃO

num_nos = size(COORD, 1);
num_elem = size(ELEM, 1);

% Funções de cálculo de geometria
L = comprimento(COORD, ELEM);
s_c = seno_cosseno(COORD, L, ELEM);

% Montagem da Matriz de Rigidez Global
KG = matriz_global(L, ELEM, MAT, SEC, s_c, num_nos);

% Resolução do sistema (Deslocamentos e Reações)
[d_total, R] = resolver_trelica(APOIOS, COORD, FORCAS, KG);

% Cálculo dos Esforços Axiais nas barras
N = forcas_axiais(COORD, ELEM, MAT, SEC, L, s_c, d_total);

%% 3. EXIBIÇÃO DOS RESULTADOS NO TERMINAL

disp('=====================================================')
disp('             RESULTADOS DA ANÁLISE                   ')
disp('=====================================================')

disp('--- Deslocamentos Nodais (m) ---')
for i = 1:num_nos
    fprintf('Nó %d -> U_x: %12.4e m | U_y: %12.4e m\n', i, d_total(2*i-1), d_total(2*i));
end

fprintf('\n--- Reações de Apoio (kN) ---\n')
for i = 1:num_nos
    if APOIOS(i,2) == 1 || APOIOS(i,3) == 1
        fprintf('Nó %d -> R_x: %8.2f kN | R_y: %8.2f kN\n', i, R(2*i-1)/1000, R(2*i)/1000);
    end
end

fprintf('\n--- Forças Axiais nas Barras (kN) [ + Tração / - Compressão ] ---\n')
for i = 1:num_elem
    fprintf('Barra %2d (%d-%d) -> Força Axial: %8.2f kN\n', i, ELEM(i,2), ELEM(i,3), N(i)/1000);
end


%% =========================================================================
%% FUNÇÕES LOCAIS (Agrupadas para simplificar a execução)
%% =========================================================================

function [L] = comprimento(COORD, ELEM)
    for i = 1:size(ELEM,1)
        no_i = ELEM(i,2);
        no_j = ELEM(i,3);
        L(i,1) = sqrt((COORD(no_j,2) - COORD(no_i,2))^2 + (COORD(no_j,3) - COORD(no_i,3))^2);
    end
end

function [s_c] = seno_cosseno(COORD, L, ELEM)
    for i = 1:size(L,1)
        no_i = ELEM(i,2);
        no_j = ELEM(i,3);
        dx = COORD(no_j,2) - COORD(no_i,2);
        dy = COORD(no_j,3) - COORD(no_i,3);
        s_c(i,:) = [dy/L(i), dx/L(i)]; % [seno, cosseno]
    end
end

function [KG] = matriz_global(L, ELEM, MAT, SEC, s_c, num_nos)
    KG = zeros(2 * num_nos);
    for i = 1:size(ELEM,1)
        sen = s_c(i,1);
        cos = s_c(i,2);
        
        % Matriz de transformação expandida
        T = [ cos, sen,   0,   0;
             -sen, cos,   0,   0;
                0,   0, cos, sen;
                0,   0,-sen, cos];
        
        % Matriz local de rigidez da barra
        k_loc = (MAT(i,2) * SEC(i,2) / L(i)) * [ 1, 0, -1, 0;
                                                 0, 0,  0, 0;
                                                -1, 0,  1, 0;
                                                 0, 0,  0, 0];
        no_i = ELEM(i,2);
        no_j = ELEM(i,3);
        gl = [(2*no_i-1), 2*no_i, (2*no_j-1), 2*no_j];
        
        % Acumulação na rigidez global
        KG(gl,gl) = KG(gl,gl) + T' * k_loc * T;
    end
end

function [d_total, R] = resolver_trelica(APOIOS, COORD, FORCAS, KG)
    num_nos = size(COORD, 1);
    restricoes = zeros(2 * num_nos, 1);
    v_forcas = zeros(2 * num_nos, 1);
    
    for i = 1:num_nos
        restricoes(2*i-1,1) = APOIOS(i,2);
        restricoes(2*i,1) = APOIOS(i,3);
        v_forcas(2*i-1,1) = FORCAS(i,2);
        v_forcas(2*i,1) = FORCAS(i,3);
    end
    
    % Identifica Graus de Liberdade livres
    dgl = find(restricoes == 0);
    
    % Calcula deslocamentos livres
    d = KG(dgl,dgl) \ v_forcas(dgl);
    
    % Vetor completo de deslocamentos
    d_total = zeros(2 * num_nos, 1);
    d_total(dgl) = d;
    
    % Calcula reações de apoio globais
    R = KG * d_total;
end

function [N] = forcas_axiais(COORD, ELEM, MAT, SEC, L, s_c, d_total)
    num_elem = size(ELEM,1);
    N = zeros(num_elem,1);
    for i = 1:num_elem
        no_i = ELEM(i,2);
        no_j = ELEM(i,3);
        
        sen = s_c(i,1);
        cos = s_c(i,2);
        
        % Deslocamentos dos nós da barra atual
        u_xi = d_total(2*no_i-1);   u_yi = d_total(2*no_i);
        u_xj = d_total(2*no_j-1);   u_yj = d_total(2*no_j);
        
        % Deformação axial calculada por projeção trigonométrica
        dl = (u_xj - u_xi)*cos + (u_yj - u_yi)*sen;
        
        % Lei de Hooke (N = E * A * delta_L / L)
        N(i,1) = (MAT(i,2) * SEC(i,2) / L(i)) * dl;
    end
end