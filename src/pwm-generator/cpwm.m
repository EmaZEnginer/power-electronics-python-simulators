clear; close all; clc;

% Parametros:
D = 1/3; % ciclo de trabajo
N = 1; % orden del filtro;
Fsw = 1000; % Frecuencia de los pulsos
Fc = 200; % frecuencia de corte del filtro
ciclos = 5; 
transitorio = 0;

% creacion de un vector de tiempos
puntos = 1e4;
t = 0:1/puntos:1-1/puntos;

% comparacion y generacion del pwm
x = zeros(1,puntos);
indice = round(D*puntos);
x(1:indice) = 1;
% se necesita una señal "larga" para el regimen permanente:
for k=1:ciclos*10
    xx(1+(k-1)*puntos:k*puntos) = x;
end

% diseño del filtro:
[b,a] = butter(N,Fc/(Fsw*puntos/2),'low');

% aplicacion del filtro:
yy = filter(b,a,xx);

% pasar al dominio de la frecuencia:
XX = fftshift(abs(fft(xx)))./length(xx);
YY = fftshift(abs(fft(yy)))./length(yy);
FF = ((0:length(xx)-1)./length(xx)-0.5).*Fsw*puntos;

% graficas:
graph_width=1;
indices = 1:ciclos*puntos;
figure(1);
subplot(2,1,1);
plot(((indices-1)/puntos)./Fsw,xx(indices),'b:','LineWidth',graph_width);
xlabel('Tiempo [S]');
grid minor;
hold on;
if transitorio
    title(sprintf("Respuesta transitoria \nCiclo de trabajo = %.2f",D));
    plot(((indices-1)/puntos)./Fsw,yy(indices),'r','LineWidth',graph_width);
    ylabel('Voltaje [V]');
else
    title(sprintf("Respuesta estacionaria \nCiclo de trabajo = %.2f",D));
    plot(((indices-1)/puntos)./Fsw,...
    yy(length(yy)-ciclos*puntos+1:length(yy)),'r','LineWidth',graph_width);
    legend('Señal PWM','Señal filtrada');
    ylabel('Voltaje [V]');
end

%grafica de espectro
figure(1);
subplot(2,1,2);
plot(FF,XX,'c:','LineWidth',graph_width);
grid minor;
hold on;
xlim([-0.34 0.34].*(Fsw*12));   
plot(FF,YY,'r','LineWidth',graph_width);
%envolvente del filtro
[y_filter, x_filter]=freqz(b,a,length(FF),Fsw*puntos);
x_filter_reflex=x_filter*(-1);
plot(x_filter_reflex,abs(y_filter).*max(YY),'b-.');
plot(x_filter,abs(y_filter).*max(YY),'b-.');
xlabel("Frecuencia [Hz]");
ylabel("Peso de armonico");
title("Espectro de frecuencia");
legend('Señal PWM','Señal filtrada','Envolvente del filtro');



