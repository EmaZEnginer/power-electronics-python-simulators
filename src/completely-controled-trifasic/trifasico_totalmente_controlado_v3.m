%parametros
clear;

f=60;
T=1/f;
w=2*pi*f;
A=60;

alpha_g=0;
alpha=(alpha_g*pi)/180;

ciclos=7;
muestreo=10000;
t_total=ciclos*T;
t=linspace(0,t_total,ciclos*muestreo);

logs=true;

%voltajes de linea
phi_g=[0, 120, 240];
phi=deg2rad(phi_g);
theta=w*t;

vab=A*sin(theta+phi(1));
vba=(-1)*vab;

vca=A*sin(theta+phi(2));
vac=(-1)*vca;

vbc=A*sin(theta+phi(3));
vcb=(-1)*vbc;

%%
%RECTIFICACION UNA SOLA FASE:
%busca indice de conduccion entre vab y vac (conduccion para vab)
idx_vab=find(theta>=deg2rad(60)+alpha,1);
idx_vac=find(theta>=2*deg2rad(60)+alpha,1);

%~disp(['idx_ini: ',num2str(idx_vab)]);
%~disp(['idx_fin: ',num2str(idx_vac)]);
%~disp(['idx_dif: ',num2str(idx_vac-idx_vab)]);

%
y_fase=vab(idx_vab:idx_vac);    %extrae la rectificacion de una fase
num_fases=round(muestreo./length(y_fase));   %numero de fases en un ciclo
puntos_unafase=length(y_fase);  %puntos de una sola fase

%%
%CONSTRUCCION DE RECTIFICACION DE UN SOLO CICLO (PERIODO)

y_ciclo=zeros(1,muestreo); %vector salia para un ciclo (periodo)
for k=1:num_fases
    %calcula indices inicio y fin para cada fase partiendo del inicial
    %vab y desplazando
    inicio_fase=(k-1)*puntos_unafase+idx_vab+1;
    fin_fase=k*puntos_unafase+idx_vab;
    %~disp(['fase: ',num2str(k)]);
    %~disp(['inicio: ',num2str(inicio_fase),';fin: ',num2str(fin_fase)]);

    %si se sale del ciclo
    if fin_fase>muestreo
        %corta ultimo pedazo de grafica para no exceder
        %calcula diferencia para completar ultima fase
        diferencia_final=muestreo-inicio_fase+1;
        %~disp(['diferencia final: ',num2str(diferencia_final)])
        y_ciclo(inicio_fase:end)=y_fase(1:diferencia_final);

        %pega ultimo pedazo de grafica excedido (del anterior) al
        %inicio
        %calcula diferencia excedida para anadir al inicio y hacer
        %ciclico. 
        diferencia_inicial=fin_fase-muestreo+1;
        %~disp(['diferencia inicial: ',num2str(diferencia_inicial)])
        y_ciclo(1:diferencia_inicial)=y_fase(diferencia_final:end);
   
        %calcula fases intermedias no calculadas al inicio partiendo desde
        %ultimo pedazo anadido al principio (diferencia_inicial) hasta vab
        diferencia_faltantes=idx_vab-diferencia_inicial;
        ciclos_faltantes=round(diferencia_faltantes/puntos_unafase);
        %~disp(['ciclos_faltantes: ',num2str(ciclos_faltantes)])
        for j=1:ciclos_faltantes
            %puntos de inicio y fin para cada ciclo intermedio a partir
            %del pedazo puesto al inicio
            inicio_fase_faltante=((j-1)*puntos_unafase)+diferencia_inicial+1;
            fin_fase_faltante=(j*puntos_unafase)+diferencia_inicial;
            %~disp(['faltantes: ',num2str(inicio_fase_faltante),',',num2str(fin_fase_faltante)])
            %~disp(['vab: ',num2str(idx_vab)])

            %si ultima fase intermedia se solapa con la que ya estaba a
            %partir de vab
            if fin_fase_faltante>=idx_vab
                %calcula sobrante ultima fase faltante para llegar a vab
                %y lo asigna
                dif_ultimo_faltante_vab=idx_vab-inicio_fase_faltante;
                y_ciclo(inicio_fase_faltante:idx_vab)=y_fase(1:dif_ultimo_faltante_vab+1);
            else
                %asigna las fases intermedias
                y_ciclo(inicio_fase_faltante:fin_fase_faltante)=y_fase;
            end
        end
        
        break
    else
        y_ciclo(inicio_fase:fin_fase)=y_fase(1:fin_fase-inicio_fase+1);
    end
end


%%
%CONSTRUCCION DE RECTIFICACION PARA VARIOS CICLOS (SEÑAL COMPLETA)

y_out=zeros(1,length(theta));

%une pedazos de cada ciclo en señal completa
for i=1:ciclos
    y_out((i-1)*length(y_ciclo)+1:i*length(y_ciclo))=y_ciclo;
end

%el inicio es 0 hasta angulo de disparo
y_out(1:idx_vab)=0;

%%
%filtrado de la señal
emf=0;  %fuerza electromotriz
v_out=y_out-emf;

%diesño de filtro: L/R>>T (al menos 20 veces)
tau=10*T;
L=1e-03; %fijamos inductancia de motor (de acuerdo a valor de motor)
R=L/tau;                                    

num=1;  %o R
den=[L, R];
[b,a]=bilinear(num,den,ciclos*muestreo);

io=filter(b,a,v_out);

%%
%GRAFICACION
figure(1);
plot(theta,vab,'b');
hold on;
plot(theta,vba,'b--');
plot(theta,vac,'g');
plot(theta,vca,'g--');
plot(theta,vbc,'r--');
plot(theta,vcb,'r');
plot(theta,y_out,'LineWidth',2);
grid on;
hold off;
legend('Vab','Vba','Vac','Vca','Vbc','Vcb');
xticks([0 pi 2*pi 3*pi 4*pi 5*pi 6*pi 7*pi 8*pi]); %
xticklabels({'0', '\pi', '2\pi', '3\pi', '4\pi', '5\pi', ...
            '6\pi', '7\pi', '8\pi',}); %

figure(2);
plot(theta,io);
