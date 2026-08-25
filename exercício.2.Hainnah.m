% =========================================================================
% Análise Estrutural 3
% Análise Computacional de Estruturas - Treliças
% Exercício 2: 
% =========================================================================

clc;        % Limpa a tela do terminal do MATLAB
clear all;  % Apaga todas as variáveis da memória para evitar conflitos
close all;  % Fecha todas as janelas de gráficos abertas

%% 1. DADOS DE ENTRADA (Convertidos e padronizados para o SI):

% --- MATRIZ DE COORDENADAS DOS NÓS ---
% Formato: [ Número_do_Nó , Coordenada_X (m) , Coordenada_Y (m) ]
% O apoio fixo inferior esquerdo (Nó 1) foi adotado como a origem do plano (0,0)
COORD = [
    1,  0.0, 0.0;  % Nó 1: Apoio Fixo de segunda ordem (Esquerda inferior)
    2,  7.2, 0.0;  % Nó 2: Nó livre inferior central (Onde atua a carga de 330 kN)
    3, 14.4, 0.0;  % Nó 3: Apoio Móvel de primeira ordem (Direita interno)
    4, 21.6, 0.0;  % Nó 4: Apoio Móvel de primeira ordem (Extremidade direita)
    5,  7.2, 5.4;  % Nó 5: Nó livre superior esquerdo (Onde atua a carga de 110 kN)
    6, 14.4, 5.4   % Nó 6: Nó livre superior direito (Onde atua a carga de 270 kN)
];

% --- MATRIZ DE CONECTIVIDADE DAS BARRAS (ELEMENTOS) ---
% Formato: [ Número_da_Barra , Nó_Inicial_I , Nó_Final_J ]
% Define graficamente onde cada barra começa e termina para o cálculo vetorial
ELEM = [
    1,  1, 2;  % Barra 1: Banzo inferior esquerdo
    2,  2, 3;  % Barra 2: Banzo inferior central
    3,  3, 4;  % Barra 3: Banzo inferior direito (Feito de Alumínio)
    4,  1, 5;  % Barra 4: Diagonal externa esquerda
    5,  2, 5;  % Barra 5: Montante (vertical) esquerdo
    6,  5, 6;  % Barra 6: Banzo superior horizontal
    7,  2, 6;  % Barra 7: Diagonal inclinada para a direita (/)
    8,  3, 5;  % Barra 8: Diagonal inclinada para a esquerda (\)
    9,  3, 6;  % Barra 9: Montante (vertical) direito
    10, 6, 4   % Barra 10: Diagonal externa direita (Feito de Alumínio)
];

% --- MATRIZ DE CONDIÇÕES DE APOIO (RESTRIÇÕES) ---
% Formato: [ Número_do_Nó , Restrição_em_X , Restrição_em_Y ]
% Regra: Coloca-se 1 se o movimento for IMPEDIDO (apoio) e 0 se for LIVRE para se mover
APOIOS = [
    1, 1, 1;  % Nó 1: Engastado/Fixo -> Não anda em X e não anda em Y (1, 1)
    2, 0, 0;  % Nó 2: Livre -> Pode se mover em ambas as direções (0, 0)
    3, 0, 1;  % Nó 3: Apoio Móvel -> Livre em X (0), mas impede descida/subida em Y (1)
    4, 0, 1;  % Nó 4: Apoio Móvel -> Livre em X (0), mas impede descida/subida em Y (1)
    5, 0, 0;  % Nó 5: Livre -> Pode se mover em ambas as direções (0, 0)
    6, 0, 0   % Nó 6: Livre -> Pode se mover em ambas as direções (0, 0)
];

% --- MATRIZ DE PROPRIEDADES DOS MATERIAIS (Módulo de Elasticidade E) ---
% Formato: [ Número_da_Barra , Módulo_E (Pa) ]
% Convertido de GPa para Pa (N/m²): E_aço = 200 GPa = 200e9 Pa | E_al = 69 GPa = 69e9 Pa
MAT = [
    1, 200e9; 2, 200e9; 3, 69e9; 4, 200e9; 5, 200e9;
    6, 200e9; 7, 200e9; 8, 200e9; 9, 200e9; 10, 69e9
];

% --- MATRIZ DE ÁREAS DA SEÇÃO TRANSVERSAL (A) ---
% Formato: [ Número_da_Barra , Área_A (m²) ]
% Convertido de cm² para m² (Multiplica-se por 10^-4)
% Dados: A1 = 52 cm² (52e-4), A2 = 77 cm² (77e-4), A3 = 103 cm² (103e-4)
SEC = [
    1, 52e-4; 2, 52e-4; 3, 103e-4; 4, 77e-4; 5, 52e-4;
    6, 52e-4; 7, 77e-4; 8, 77e-4;  9, 52e-4; 10, 103e-4
];

% --- MATRIZ DE FORÇAS EXTERNAS APLICADAS (CARREGAMENTO NODAL) ---
% Formato: [ Número_do_Nó , Força_Horizontal_X (N) , Força_Vertical_Y (N) ]
% Sinais: +X (Direita), -X (Esquerda) | +Y (Cima), -Y (Baixo). Convertido de kN para N.
FORCAS = [
    1,       0,       0; % Sem carga externa aplicada
    2,       0, -330e3;  % Força vertical de 330 kN para BAIXO (por isso o sinal negativo)
    3,       0,       0; % Sem carga externa aplicada
    4,       0,       0; % Sem carga externa aplicada
    5,  110e3,       0;  % Força horizontal de 110 kN para a DIREITA (sinal positivo)
    6,       0, -270e3   % Força vertical de 270 kN para BAIXO (por isso o sinal negativo)
];

%% 2. ETAPA DE PROCESSAMENTO (Execução dos Cálculos Matriciais):

% Armazena a quantidade total de nós e elementos lendo o tamanho das matrizes
num_nos = size(COORD, 1);
num_elem = size(ELEM, 1);

% Passo 1: Calcula o comprimento geométrico (L) de cada uma das 10 barras
L = comprimento(COORD, ELEM);

% Passo 2: Calcula as projeções de ângulo (Seno e Cosseno) de orientação de cada barra
s_c = seno_cosseno(COORD, L, ELEM);

% Passo 3: Monta a grande Matriz de Rigidez Global (KG) da estrutura (Tamanho 12x12)
% Une os comportamentos locais de todas as barras levando em conta suas inclinações
KG = matriz_global(L, ELEM, MAT, SEC, s_c, num_nos);

% Passo 4: Particiona o sistema, aplica as restrições dos apoios e resolve as equações
% Retorna o vetor total de deslocamentos calculados e as reações nos apoios
[d_total, R] = resolver_trelica(APOIOS, COORD, FORCAS, KG);

% Passo 5: Utiliza os deslocamentos dos nós para achar a Força Interna Axial (N) em cada barra
N = forcas_axiais(COORD, ELEM, MAT, SEC, L, s_c, d_total);

%% 3. EXIBIÇÃO DOS RESULTADOS FORMATADOS NO TERMINAL:

disp('=====================================================')
disp('             RESULTADOS DA ANÁLISE                   ')
disp('=====================================================')

% Exibe os deslocamentos horizontais (U_x) e verticais (U_y) em notação científica
disp('--- Deslocamentos Nodais (m) ---')
for i = 1:num_nos
    fprintf('Nó %d -> U_x: %12.4e m | U_y: %12.4e m\n', i, d_total(2*i-1), d_total(2*i));
end

% Exibe as reações de apoio convertendo os valores de volta de Newtons para kN
fprintf('\n--- Reações de Apoio (kN) ---\n')
for i = 1:num_nos
    % Se o nó possuir qualquer tipo de restrição (apoio), imprime os resultados
    if APOIOS(i,2) == 1 || APOIOS(i,3) == 1
        fprintf('Nó %d -> R_x: %8.2f kN | R_y: %8.2f kN\n', i, R(2*i-1)/1000, R(2*i)/1000);
    end
end

% Exibe as forças internas normais das barras (Tração = Positivo, Compressão = Negativo)
fprintf('\n--- Forças Axiais nas Barras (kN) [ + Tração / - Compressão ] ---\n')
for i = 1:num_elem
    fprintf('Barra %2d (%d-%d) -> Força Axial: %8.2f kN\n', i, ELEM(i,2), ELEM(i,3), N(i)/1000);
end


%% =========================================================================
%%                       FUNÇÕES LOCAIS DO ALGORITMO UTILIZADAS:
%% =========================================================================

% --- FUNÇÃO 1: CÁLCULO DOS COMPRIMENTOS ---
% Aplica o Teorema de Pitágoras baseado nas coordenadas cartesianas dos nós extremos
function [L] = comprimento(COORD, ELEM)
    for i = 1:size(ELEM,1)
        no_i = ELEM(i,2); % Identifica quem é o nó inicial da barra
        no_j = ELEM(i,3); % Identifica quem é o nó final da barra
        % Fórmula da distância entre dois pontos: L = sqrt( (Xj - Xi)² + (Yj - Yi)² )
        L(i,1) = sqrt((COORD(no_j,2) - COORD(no_i,2))^2 + (COORD(no_j,3) - COORD(no_i,3))^2);
    end
end

% --- FUNÇÃO 2: CÁLCULO DOS SENOS E COSSENOS ---
% Determina a inclinação direcional para projetar as forças locais no plano global
function [s_c] = seno_cosseno(COORD, L, ELEM)
    for i = 1:size(L,1)
        no_i = ELEM(i,2);
        no_j = ELEM(i,3);
        dx = COORD(no_j,2) - COORD(no_i,2); % Variação espacial em X
        dy = COORD(no_j,3) - COORD(no_i,3); % Variação espacial em Y
        % Armazena [Seno, Cosseno] baseado nas relações trigonométricas básicas
        s_c(i,:) = [dy/L(i), dx/L(i)]; 
    end
end

% --- FUNÇÃO 3: MONTAGEM DA MATRIZ DE RIGIDEZ GLOBAL ---
% Constrói o esqueleto de rigidez total somando a contribuição de cada elemento
function [KG] = matriz_global(L, ELEM, MAT, SEC, s_c, num_nos)
    % Inicializa a matriz global preenchida com zeros (2 equações por nó)
    KG = zeros(2 * num_nos);
    
    for i = 1:size(ELEM,1)
        sen = s_c(i,1);
        cos = s_c(i,2);
        
        % Matriz de Transformação Cinematica (Rotaciona do sistema local pro global)
        T = [ cos, sen,   0,   0;
             -sen, cos,   0,   0;
                0,   0, cos, sen;
                0,   0,-sen, cos];
        
        % Matriz de Rigidez Local do elemento de treliça (fórmula clássica EA/L)
        k_loc = (MAT(i,2) * SEC(i,2) / L(i)) * [ 1, 0, -1, 0;
                                                 0, 0,  0, 0;
                                                -1, 0,  1, 0;
                                                 0, 0,  0, 0];
        no_i = ELEM(i,2);
        no_j = ELEM(i,3);
        
        % Mapeamento dos Graus de Liberdade (GL) globais associados aos nós da barra
        % Cada nó "N" comanda as posições (2*N-1) para o eixo X e (2*N) para o eixo Y
        gl = [(2*no_i-1), 2*no_i, (2*no_j-1), 2*no_j];
        
        % Transforma a matriz local e soma na posição correspondente da Matriz Global
        % Aplica o conceito matemático: K_global_da_barra = T' * k_local * T
        KG(gl,gl) = KG(gl,gl) + T' * k_loc * T;
    end
end

% --- FUNÇÃO 4: RESOLUÇÃO DO SISTEMA LINEAR ---
% Separa o que é incógnita do que é conhecido e resolve a equação fundamental [K]*{d}={F}
function [d_total, R] = resolver_trelica(APOIOS, COORD, FORCAS, KG)
    num_nos = size(COORD, 1);
    restricoes = zeros(2 * num_nos, 1);
    v_forcas = zeros(2 * num_nos, 1);
    
    % Organiza em vetores coluna lineares as restrições e as forças externas aplicadas
    for i = 1:num_nos
        restricoes(2*i-1,1) = APOIOS(i,2); % Restrição em X
        restricoes(2*i,1) = APOIOS(i,3);   % Restrição em Y
        v_forcas(2*i-1,1) = FORCAS(i,2);   % Carga em X
        v_forcas(2*i,1) = FORCAS(i,3);     % Carga em Y
    end
    
    % O comando 'find' localiza onde estão as linhas livres (onde restrição é igual a zero)
    % Chamamos isso de Graus de Liberdade Livres (dgl)
    dgl = find(restricoes == 0);
    
    % Resolve o sistema de equações reduzido apenas para os nós livres usando a barra invertida (\)
    % Equivale a fazer: Deslocamentos = (Matriz Rigidez Condensada)^-1 * Vetor de Forças
    d = KG(dgl,dgl) \ v_forcas(dgl);
    
    % Monta o vetor completo preenchendo com os deslocamentos achados e mantendo zero nos apoios
    d_total = zeros(2 * num_nos, 1);
    d_total(dgl) = d;
    
    % Multiplica a rigidez global inteira pelos deslocamentos totais para achar as forças internas/reações
    % Equação constitutiva global: {R} = [KG] * {d_total}
    R = KG * d_total;
end

% --- FUNÇÃO 5: CÁLCULO DOS ESFORÇOS AXIAIS ---
% Extrai a força final interna que atua no eixo longitudinal de cada barra
function [N] = forcas_axiais(COORD, ELEM, MAT, SEC, L, s_c, d_total)
    num_elem = size(ELEM,1);
    N = zeros(num_elem,1);
    
    for i = 1:num_elem
        no_i = ELEM(i,2);
        no_j = ELEM(i,3);
        
        sen = s_c(i,1);
        cos = s_c(i,2);
        
        % Captura os 4 deslocamentos globais (iniciais e finais) pertencentes a essa barra
        u_xi = d_total(2*no_i-1);   u_yi = d_total(2*no_i);
        u_xj = d_total(2*no_j-1);   u_yj = d_total(2*no_j);
        
        % Projeta os deslocamentos globais no eixo inclinado local da barra (Variação de comprimento dl)
        dl = (u_xj - u_xi)*cos + (u_yj - u_yi)*sen;
        
        % Aplica a Lei de Hooke generalizada para barras: N = (E * A / L) * delta_L
        N(i,1) = (MAT(i,2) * SEC(i,2) / L(i)) * dl;
    end
end