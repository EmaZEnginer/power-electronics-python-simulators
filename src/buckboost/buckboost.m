clear; close all; clc;
%parametros de entrada:
D=0.3;    %ciclo de trabajo
Fsw=1000; % freq de los pulsos
vi=30;      %voltaje de entrada
L=50e-03;   %inductancia
R=100;      %resistencia de carga
C=10e-06;   %capacitor
ciclos = 100; 
Tsw=1/Fsw;
transitorio=false;
    
%parametros de corriente
vo=(vi*D)/(1-D);
io=vo/R;
il_dc=io/(1-D);
delta_il=(vi*D*Tsw)/L;
il_max=il_dc+(delta_il/2);
il_min=il_dc-(delta_il/2);

if il_min<=0
    disp('Modo discontinuo, modifique los parametros')
else
    %creacion de un vector de tiempos
    puntos = 1e4;
    t = 0:1/puntos:1-1/puntos;

    % comparacion y generacion del pwm
    xd=zeros(1,puntos);     %1 ciclo para el diodo
    xs=zeros(1,puntos);     %1 ciclo para el siwtch
    indice = round(D*puntos);
    
    xd(indice:end)=linspace(il_max, il_min, puntos - indice + 1); %recta de cte del diodo
    xs(1:indice)=linspace(il_min,il_max,indice); %recta de cte del switch
    % se necesita una señal "larga" para el regimen permanente:
    for k=1:ciclos %*10 (para lograr el estado transitorio)
        xxd(1+(k-1)*puntos:k*puntos) = xd;
        xxs(1+(k-1)*puntos:k*puntos)=xs;
    end
    
    %filtro para voltaje de salida
    num=R;
    den=[C*R 1];
    [b,a]=bilinear(num,den,Fsw*puntos);

    t_total=ciclos*Tsw;
    vector_t_total=linspace(0,t_total,length(xxd));     
    vo_filtrada=filter(b,a,xxd);
    
    %seleccion de transitorio
    if transitorio
        tiempo_transitorio=vector_t_total(1:puntos*5);
        vo_filtrada_transitorio=vo_filtrada(1:length(tiempo_transitorio));
        xxs_transitorio=xxs(1:length(tiempo_transitorio));
        xxd_transitorio=xxd(1:length(tiempo_transitorio));
    else
        tiempo_transitorio=vector_t_total(1:puntos*5);
        vo_filtrada_transitorio=vo_filtrada((length(vector_t_total)-length(tiempo_transitorio))+1:end);
        xxs_transitorio=xxs((length(vector_t_total)-length(tiempo_transitorio))+1:end);
        xxd_transitorio=xxd((length(vector_t_total)-length(tiempo_transitorio))+1:end);
    end    

    %grafica de vo 
    figure(1);
    plot(tiempo_transitorio, vo_filtrada_transitorio, 'r');
    grid on;
    title('Voltaje de salida filtrado (respuesta del filtro RC)');
    xlabel('Tiempo (s)');
    ylabel('Voltaje (V)');    

    %grafica de corriente por diodo
    figure(2);
    plot(tiempo_transitorio,xxd_transitorio);
    grid on;
    xlabel('Tiempo (s)');
    ylabel('Corriente (A)');  
    hold on;
    plot(tiempo_transitorio,xxs_transitorio,'--');
    legend('Corriente por el diodo de rueda libre','Corriente por el transistor');
    hold off;

    %curva de transferencia
    D_transf = linspace(0, 0.99, 100);
    M = -D_transf ./ (1 - D_transf);
    figure(3);
    plot(D_transf, M, 'b');
    grid on;
    title('Curva de transferencia');
    xlabel('Ciclo de trabajo D');
    xlim([0, 1]);
    ylim([-10, 0]);  
 
    M_punto=-D./(1-D);  %relacion actual
    hold on;
    plot(D, M_punto, 'ro');  
    hold off;

    %armonicos vo pdte
    f_vo=fftshift(abs(fft(vo_filtrada)))./length(vo_filtrada);
    %f_xxd=fftshift(abs(fft(xxd)))./length(xxd);
    FF=((0:length(vo_filtrada)-1)./length(vo_filtrada)-0.5).*Fsw*puntos;
    figure(4);
    plot(FF,f_vo,'b');
    grid on;
    hold on;
    %plot(FF,f_xxd);
    xlim([-8 8].*(Fsw));
    %envolvente del filtro
    [y_filter, x_filter] = freqz(b, a, length(vo_filtrada), Fsw * puntos);
    y_filter=abs(y_filter)/max(abs(y_filter))*max(f_vo);
    x_filter_rflex=x_filter*(-1);
    plot(x_filter,y_filter,'r-.');
    plot(x_filter_rflex,y_filter,'r-.');
end
