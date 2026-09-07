# Sistema de Inferência Fuzzy Mamdani em MATLAB

[![MATLAB](https://img.shields.io/badge/MATLAB-R2023b%2B-blue?style=flat&logo=mathworks)](https://www.mathworks.com)
[![GNU Octave](https://img.shields.io/badge/GNU%20Octave-Compatible-darkgreen?style=flat&logo=gnu)](https://www.gnu.org/software/octave/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Implementação de um motor de inferência nebulosa (*Fuzzy Logic*) baseado no método Mamdani, desenvolvido de forma nativa e vetorizada em MATLAB, sem dependência de toolboxes comerciais. O repositório inclui um baseline booleano para comparação, validação via API e rotinas para análise de desempenho e visualização gráfica.

---

## Estrutura do Repositório

| Arquivo | Descrição Técnica |
| :--- | :--- |
| `tip_fuzzy_manual.m` | Motor Fuzzy Mamdani nativo com defuzzificação por centroide, amostragem otimizada e plotagem tridimensional. |
| `tip_crisp.m` | Implementação de referência baseada em lógica booleana tradicional (regras `if/else` vetorizadas). |
| `tip_fuzzy.m` | Rotina de validação utilizando as funções padrão da Fuzzy Logic Toolbox. |
| `compare_tips.m` | Script de auditoria para comparação cruzada e cálculo do Erro Médio Absoluto (MAE). |

---

## Instruções de Utilização

### Execução Direta
Para calcular a saída do sistema para parâmetros específicos de entrada:

```matlab
% Exemplo: Avaliação para Serviço = 9 e Comida = 8
resultado = tip_fuzzy_manual(8, 9);
