close all
clear all
clc
%% Parametros
g=9.81;
l=0.4;
M=2.4;
m=0.23;
I=0.099;
b=0.05;
d=0.005;
%% Controlador PID1 - posição x
Kp1=0;
Kd1=0;
Ki1=0;
N1=100;
%% Controlador PID2 - angulo theta
Kp2=0;
Kd2=0;
Ki2=0;
N2=100;
%% condições iniciais
x0=0.2;
v0=0;
theta0=deg2rad(5);
dtheta0=0;
%% referencia
x_ref=0;
theta_ref=0;
%%
out=sim('nonlinear_model_inverted_pendulum.slx');
%%
x=out.simout.signals.values(:,1);
theta=rad2deg(out.simout.signals.values(:,2));
F=out.simout.signals.values(:,3);
err_x=out.simout.signals.values(:,4);
err_theta=out.simout.signals.values(:,5);
u1=out.simout.signals.values(:,6);
u2=out.simout.signals.values(:,7);
t=out.simout.time;
%%
figure
plot(t,F,'DisplayName','Force (F)',LineWidth=1.5)
hold on
grid on
xlabel('time (s)')
legend('Location','best')
figure
subplot(2,1,1)
hold on
grid on
plot(t,x,'DisplayName','Position (x)',LineWidth=1.5)
plot(t,x_ref*ones(size(t)),'k--','DisplayName','Ref Position')
% plot(t,1.05*x_ref*ones(size(t)),'r--','DisplayName','1.05*Ref Position')
% plot(t,0.95*x_ref*ones(size(t)),'r--','DisplayName','0.95*Ref Position')
plot(t,x_ref*ones(size(t)),'k--','DisplayName','Ref Position')
legend('Location','best')
ylabel('Position (m)')
subplot(2,1,2)
%figure
plot(t,theta,'DisplayName','Angle (\theta)',LineWidth=1.5)
hold on
plot(t,theta_ref*ones(size(t)),'k--','DisplayName','Ref Angle')
plot(t,0.05+theta_ref*ones(size(t)),'r--','DisplayName','+0.05')
plot(t,-0.05+theta_ref*ones(size(t)),'r--','DisplayName','-0.05')
legend('Location','best')
ylabel('Angle (°)')
grid on
xlabel('time (s)')
%% Custo (integral do erro ao quadrado+energia do sinal de controle)
J=norm(theta-theta_ref)^2+norm(x-x_ref)^2+norm(F)^2
%% animacao
state=zeros(4,numel(t));
state(1,:)=x*100;
state(3,:)=deg2rad(theta);
fig = figure;
fig.Position = [100 100 1200 500];
pendulo=plotPendulo(state(:,1),fig);
for k=1:numel(t)
      %% atualiza frame da animacao 
      if abs(state(1,k))>50
        break
      end
        updatePendulo(state(:,k)',pendulo);
        pause(0.05)
end