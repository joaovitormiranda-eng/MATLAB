\# 🧠 Sistema de Inferência Fuzzy Mamdani em MATLAB / GNU Octave



!\[MATLAB](https://img.shields.io/badge/MATLAB-R2023b%2B-blue?style=flat\&logo=mathworks)

!\[GNU Octave](https://img.shields.io/badge/GNU%20Octave-Compatible-darkgreen?style=flat\&logo=gnu)

!\[License](https://img.shields.io/badge/License-MIT-yellow?style=flat)



Motor de Inferência Nebulosa (\*Fuzzy Logic\*) Mamdani desenvolvido integralmente em MATLAB vetorial nativo, sem necessidade de toolboxes pagas. Inclui baseline booleano (Crisp), validação via API legada e rotinas de auditoria visual em Dark Mode.



\---



\## 📂 Estrutura de Arquivos



| Arquivo | Descrição |

| :--- | :--- |

| `tip\_fuzzy\_manual.m` | \*\*Core Engine:\*\* Motor Fuzzy Mamdani nativo com defuzzificação por Centroide, amostragem 0.1 e visualização 3D Dark Theme. |

| `tip\_crisp.m` | \*\*Baseline Crisp:\*\* Sistema booleano de regras rígidas (\*if/else\*) vetorizado com `arrayfun`. |

| `tip\_fuzzy.m` | \*\*Validação FIS:\*\* Implementação legada via `newfis`/`addvar` (Fuzzy Logic Toolbox / Octave). |

| `compare\_tips.m` | \*\*Auditoria:\*\* Script comparativo 3D lado a lado com cálculo de MAE (Erro Médio Absoluto). |

| `fuzzy-superficie-resposta-3d.png` | Renderização 3D da superfície de resposta em Dark Mode (Parula). |

| `fuzzy-mapa-contorno-2d.png` | Mapa de contorno 2D para análise de zonas de transição. |



\---



\## 🚀 Como Executar



\### 1. Avaliação Pontual (Rápida)

Para calcular a saída exata para uma determinada entrada (ex: Comida = 8, Serviço = 9):



&#x20;   >> val = tip\_fuzzy\_manual(8, 9)

&#x20;   \[INFO] Entrada: (Food=8.0, Service=9.0) -> Gorjeta: 14.98%



\### 2. Geração da Superfície 3D e Diagnóstico Visual

Execute a função sem argumentos para renderizar as malhas em alta definição e mapas de contorno:



&#x20;   >> tip\_fuzzy\_manual()



\### 3. Auditoria Comparativa (Crisp vs. Fuzzy)

Rode o script de auditoria para obter as diferenças estatísticas entre a abordagem clássica e a nebulosa:



&#x20;   >> \[TipC, TipF, MAE] = compare\_tips()



\---



\## 📊 Arquitetura do Motor Fuzzy



\* \*\*Fuzzificação:\*\* Funções geométricas trapezoidais e triangulares protegidas contra indefinições de divisão por zero (`eps`).

\* \*\*Inferência:\*\* Método Mamdani com Operador T-Norma (`min`) para conjuntivas e S-Norma (`max`) para disjuntivas.

\* \*\*Defuzzificação:\*\* Centroide (Centro de Gravidade) contínuo sobre universo de discurso discretizado (0 a 20%).



\---

\*Desenvolvido por \[João Vitor Miranda](https://github.com/joaovitormiranda-eng)\*

