close all
clear all
clc
%%
m=22.6e-3;
g=9.81;
R=21;
Le=520e-3;
L0=24.9e-3;
a=6.72e-3;
ka=2.1;
he=4.5e-3;
ie=(1+he/a)*sqrt(2*a*m*g/L0);
ve=R*ie/ka;
c1=-1.7361e3;
h0=10e-3;
v0=0;
i0=0.39;
%% controlador de avanço de fase
tz=0.04;
tp=0.004;
kp=1;
%%
out=sim('simula_levitador_non_linear.slx');
%%
figure
plot(out.tout,out.simout.signals.values(:,2),'DisplayName','i',LineWidth=1.5)
xlabel('Tempo (s)')
ylabel('Corrente (A)')
title('Corrente da bobina')
grid on
figure
plot(out.tout,out.simout.signals.values(:,3),'DisplayName','v',LineWidth=1.5)
ylabel('Tensão (V)')
xlabel('Tempo (s)')
title('Tensão de alimentação da bobina')
grid on
% figure
% plot(out.tout,out.simout.signals.values(:,4),'DisplayName','d',LineWidth=1.5)
% ylabel('Tensão (V)')
% xlabel('Tempo (s)')
% title('Disturbio de alimentação da bobina')
% grid on
figure
plot(out.tout,out.simout.signals.values(:,1),'DisplayName','h',LineWidth=1.5)
xlabel('Tempo (s)')
ylabel('Altura (m)')
title('Altura da esfera de aço')
grid on
%%
fig = figure;
fig.Position = [100 100 800 500];
h=out.simout.signals.values(:,1);
levitador=plotLevitador(h(1),fig);
for k=1:numel(h)
    updateLevitador(h(k),levitador);
    pause(0.01)
end
