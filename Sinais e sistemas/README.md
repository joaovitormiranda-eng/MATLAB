# Processamento de Sinais e Filtragem Digital

Implementação em MATLAB (`processamento_sinais.mlx`) focada na remoção de ruídos e interferências eletromagnéticas (EMI) em sinais de instrumentos, utilizando uma arquitetura de filtro IIR Butterworth e análise espectral via FFT.

## ⚙️ Parâmetros do Projeto
* **Frequência de Amostragem ($f_s$):** 1000 Hz
* **Frequência de Corte ($f_c$):** 100 Hz
* **Ordem do Filtro:** 4ª Ordem (Topologia Butterworth Passa-Baixa)
* **Interferência Alvo:** 300 Hz (Senoidal + Ruído Branco Gaussiano)

## 🚀 Como Executar
1. Certifique-se de ter o **MATLAB** instalado com o *Signal Processing Toolbox*.
2. Abra o arquivo `processamento_sinais.mlx` no MATLAB Live Editor.
3. Execute as seções sequencialmente para visualizar a geração do sinal ruidoso, o mapeamento FFT e a resposta filtrada.
