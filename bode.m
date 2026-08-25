clc;
clear;
close all;

% Função de transferência:
% H(s) = 1000*s / (s^2 + 1000*s + 4000000)

% Vetor de frequências em rad/s
w = logspace(1, 5, 2000); % de 10 até 100000 rad/s

% Resposta em frequência H(jw)
s = 1j*w;
H = 1000*s ./ (s.^2 + 1000*s + 4000000);

% Módulo em dB
mag_dB = 20*log10(abs(H));

% Dados do sistema
w0 = 2000;   % rad/s
beta = 1000; % rad/s

% Assíntotas do ganho
% Para w << w0:
% |H(jw)| ≈ 1000*w/4000000 = w/4000
%
% Para w >> w0:
% |H(jw)| ≈ 1000/w

mag_asym = zeros(size(w));

for k = 1:length(w)
    if w(k) <= w0
        mag_asym(k) = w(k)/4000;
    else
        mag_asym(k) = 1000/w(k);
    end
end

mag_asym_dB = 20*log10(mag_asym);

% Plot
figure;
semilogx(w, mag_dB, 'LineWidth', 2);
hold on;
semilogx(w, mag_asym_dB, '--', 'LineWidth', 2);
grid on;

xline(w0, ':', '\omega_0 = 2000 rad/s', 'LineWidth', 1.5);

xlabel('\omega (rad/s)');
ylabel('Ganho (dB)');
title('Diagrama de Bode - ganho');
legend('Ganho real', 'Assíntotas do ganho', 'Location', 'best');

ylim([-60 10]);