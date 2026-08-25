%% EXPERIMENTO 3 - PARTE 3 - MAGLEV
% Codigo limpo para MATLAB
% Gera as figuras principais e salva na pasta images

close all
clear
clc

%% Configuracoes

s = tf('s');

pastaFiguras = fullfile(pwd,'images');

if ~exist(pastaFiguras,'dir')
    mkdir(pastaFiguras);
end

%% Parametros do sistema

m  = 22.6e-3;
g  = 9.81;
R  = 21;
Le = 520e-3;
L0 = 24.9e-3;
a  = 6.72e-3;
ka = 2.1;
c1 = -1.7361e3;

he = 4.5e-3;

%% Ponto de equilibrio

ie = (1 + he/a)*sqrt(2*a*m*g/L0);
ve = R*ie/ka;

k1 = L0*ie/(a*(1 + he/a)^2);
k2 = L0*ie^2/(a^2*(1 + he/a)^3);

fprintf('\nPONTO DE EQUILIBRIO\n');
fprintf('he = %.6f m = %.3f mm\n',he,he*1000);
fprintf('ie = %.6f A\n',ie);
fprintf('ve = %.6f V\n',ve);
fprintf('k1 = %.6f\n',k1);
fprintf('k2 = %.6f\n',k2);

%% Modelo linearizado

G = -k1*ka/(m*Le*s^3 + m*R*s^2 - k2*Le*s - R*k2);

disp('Funcao de transferencia G(s):')
G

disp('Polos de G(s):')
disp(pole(G))

disp('Zeros de G(s):')
disp(zero(G))

%% Malha aberta com sensor

Lsem = c1*G;

disp('Polos de c1*G(s):')
disp(pole(Lsem))

%% Figura 1 - Polos e zeros em malha aberta

figure(1)
pzmap(Lsem)
grid on
title('MAGLEV: polos e zeros em malha aberta')
saveas(gcf,fullfile(pastaFiguras,'maglev_pzmap_aberta.png'))

%% Figura 2 - LGR sem compensador

figure(2)
rlocus(Lsem)
grid on
title('MAGLEV: LGR sem compensador')
saveas(gcf,fullfile(pastaFiguras,'maglev_rlocus_sem_comp.png'))

%% Figura 3 - Impulso em malha aberta

figure(3)
impulse(Lsem)
grid on
title('Resposta ao impulso em malha aberta')
saveas(gcf,fullfile(pastaFiguras,'maglev_impulse_aberta.png'))

%% Figura 4 - Degrau em malha aberta

figure(4)
step(Lsem)
grid on
title('Resposta ao degrau em malha aberta')
saveas(gcf,fullfile(pastaFiguras,'maglev_step_aberta.png'))

%% Controlador de avanco de fase

tz = 0.04;
tp = 0.004;

C = (tz*s + 1)/(tp*s + 1);

kp = 0.40;

fprintf('\nCONTROLADOR DE AVANCO DE FASE\n');
fprintf('Zero = %.2f rad/s\n',-1/tz);
fprintf('Polo = %.2f rad/s\n',-1/tp);
fprintf('kp escolhido = %.4f\n',kp);

Lbase = C*c1*G;
Lcomp = kp*C*c1*G;

%% Figura 5 - LGR com compensador

figure(5)
rlocus(Lbase)
grid on
xlim([-300 70])
ylim([-250 250])
title('MAGLEV: LGR com controlador de avanco de fase')
saveas(gcf,fullfile(pastaFiguras,'maglev_rlocus_com_comp.png'))

%% Faixa de estabilidade de kp

kpVec = linspace(1e-4,1.2,8000);
maxReal = nan(size(kpVec));

for ii = 1:length(kpVec)
    Ttmp = feedback(kpVec(ii)*C*G,c1);
    polosTmp = pole(Ttmp);

    if ~isempty(polosTmp)
        maxReal(ii) = max(real(polosTmp));
    end
end

idxEstavel = find(maxReal < 0 & ~isnan(maxReal));

if isempty(idxEstavel)
    kp_min = NaN;
    kp_max = NaN;
else
    kp_min = kpVec(idxEstavel(1));
    kp_max = kpVec(idxEstavel(end));
end

fprintf('\nFAIXA APROXIMADA DE kp ESTAVEL\n');
fprintf('kp_min = %.4f\n',kp_min);
fprintf('kp_max = %.4f\n',kp_max);
fprintf('kp escolhido = %.4f\n',kp);

%% Figura 6 - Faixa de estabilidade

figure(6)
plot(kpVec,maxReal,'LineWidth',1.5)
hold on
yline(0,'k--','LineWidth',1.2)

if ~isnan(kp_min)
    xline(kp_min,'r--','LineWidth',1.2)
    xline(kp_max,'r--','LineWidth',1.2)
end

xline(kp,'g','LineWidth',1.5)

grid on
xlabel('kp')
ylabel('Maior parte real dos polos')
title('Faixa de estabilidade em funcao de kp')
legend('max Re(polos)','Limite','kp minimo','kp maximo','kp escolhido','Location','best')
saveas(gcf,fullfile(pastaFiguras,'maglev_faixa_kp.png'))

%% Figura 7 - Bode do controlador

figure(7)
bode(kp*C)
grid on
title('Bode do controlador de avanco de fase')
saveas(gcf,fullfile(pastaFiguras,'maglev_bode_controlador.png'))

%% Malha fechada com kp escolhido

T = feedback(kp*C*G,c1);

disp('Polos de malha fechada com kp escolhido:')
disp(pole(T))

%% Figura 8 - Impulso em malha fechada

figure(8)
impulse(T)
grid on
title('Resposta ao impulso em malha fechada')
saveas(gcf,fullfile(pastaFiguras,'maglev_impulse_fechada.png'))

%% Figura 9 - Degrau em malha fechada

figure(9)
step(T)
grid on
title('Resposta ao degrau em malha fechada')
saveas(gcf,fullfile(pastaFiguras,'maglev_step_fechada.png'))

%% Figura 10 - Bode comparativo

figure(10)
bode(Lsem,Lcomp,kp*C)
grid on
title('Bode comparativo')
legend('Sem compensador','Com compensador','Controlador','Location','best')
saveas(gcf,fullfile(pastaFiguras,'maglev_bode_comparativo.png'))

%% Figura 11 - Nyquist sem compensador

figure(11)
nyquist(Lsem)
grid on
title('Nyquist sem compensador')
saveas(gcf,fullfile(pastaFiguras,'maglev_nyquist_sem_comp.png'))

%% Figura 12 - Nyquist com compensador

figure(12)
nyquist(Lcomp)
grid on
title('Nyquist com controlador de avanco de fase')
saveas(gcf,fullfile(pastaFiguras,'maglev_nyquist_com_comp.png'))

%% Ganho critico e margens

[GM,PM,Wcg,Wcp] = margin(Lbase);

kc = GM;

fprintf('\nGANHO CRITICO E MARGENS\n');
fprintf('kc = %.6f\n',kc);
fprintf('PM = %.4f graus\n',PM);
fprintf('Wcg = %.4f rad/s\n',Wcg);
fprintf('Wcp = %.4f rad/s\n',Wcp);

%% Figura 13 - Margin

figure(13)
margin(Lbase)
grid on
title('Margens de estabilidade com controlador de avanco de fase')
saveas(gcf,fullfile(pastaFiguras,'maglev_margin_compensado.png'))

%% Figura 14 - Degrau com ganho critico

Tc = feedback(kc*C*G,c1);

disp('Polos com ganho critico kc:')
disp(pole(Tc))

figure(14)
[y,t] = step(Tc,0:1e-6:1);
plot(t,y,'LineWidth',1.5)
grid on
title('Resposta ao degrau com ganho critico Kc')
xlabel('Tempo (s)')
ylabel('Saida')
saveas(gcf,fullfile(pastaFiguras,'maglev_step_kc.png'))

%% Simulacao nao linear no Simulink

fprintf('\nSIMULACAO NAO LINEAR NO SIMULINK\n');

if exist('simula_levitador_non_linear.slx','file') == 2

    h0 = 10e-3;
    v0 = 0;
    i0 = 0.39;

    try
        out = sim('simula_levitador_non_linear.slx');

        tNL = out.tout;
        dados = out.simout.signals.values;

        hNL = dados(:,1);
        iNL = dados(:,2);
        vNL = dados(:,3);

        figure(15)
        plot(tNL,hNL,'LineWidth',1.5)
        grid on
        xlabel('Tempo (s)')
        ylabel('Altura h (m)')
        title('Simulacao nao linear: altura da esfera')
        saveas(gcf,fullfile(pastaFiguras,'maglev_nao_linear_altura.png'))

        figure(16)
        plot(tNL,iNL,'LineWidth',1.5)
        grid on
        xlabel('Tempo (s)')
        ylabel('Corrente i (A)')
        title('Simulacao nao linear: corrente da bobina')
        saveas(gcf,fullfile(pastaFiguras,'maglev_nao_linear_corrente.png'))

        figure(17)
        plot(tNL,vNL,'LineWidth',1.5)
        grid on
        xlabel('Tempo (s)')
        ylabel('Tensao v (V)')
        title('Simulacao nao linear: tensao da bobina')
        saveas(gcf,fullfile(pastaFiguras,'maglev_nao_linear_tensao.png'))

        figure(18)
        tLin = linspace(0,max(tNL),1000);
        [xLin,tLin] = step(T,tLin);

        plot(tLin,xLin,'LineWidth',1.5)
        hold on
        plot(tNL,hNL-he,'--','LineWidth',1.5)
        grid on
        xlabel('Tempo (s)')
        ylabel('Variacao de altura x = h - he (m)')
        title('Comparacao linearizado x nao linear')
        legend('Modelo linearizado','Modelo nao linear','Location','best')
        saveas(gcf,fullfile(pastaFiguras,'maglev_comparacao_linear_naolinear.png'))

        if exist('plotLevitador.m','file') == 2 && exist('updateLevitador.m','file') == 2
            figure(19)
            fig19 = gcf;
            set(fig19,'Position',[200 100 800 500])

            levitador = plotLevitador(hNL(1),fig19);

            for kk = 1:10:numel(hNL)
                updateLevitador(hNL(kk),levitador);
                pause(0.005)
            end

            saveas(fig19,fullfile(pastaFiguras,'maglev_animacao_print.png'))
        end

    catch ME
        warning('Nao foi possivel rodar o Simulink automaticamente.')
        disp(ME.message)
    end

else
    warning('Arquivo simula_levitador_non_linear.slx nao encontrado.')
end

%% Resumo final

fprintf('\nRESUMO FINAL\n');
fprintf('Sistema em malha aberta instavel devido ao polo positivo.\n');
fprintf('Controlador de avanco de fase usado: C(s)=kp*(0.04s+1)/(0.004s+1).\n');
fprintf('kp escolhido = %.4f.\n',kp);
fprintf('Faixa estavel aproximada: %.4f < kp < %.4f.\n',kp_min,kp_max);
fprintf('Ganho critico kc = %.6f.\n',kc);
fprintf('Figuras salvas em: %s\n',pastaFiguras);