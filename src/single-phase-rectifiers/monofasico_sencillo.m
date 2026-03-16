freq=50;    %hz
T=1/freq;   %periodo
fs=10000;   %frecuencia de muestreo
a=1;        %amplitud de la señal
ciclos=3;   %cantidad de ciclos a mostrar

%definicion de la señal seno y rectificacion
t=0:1/fs:T; %vector de tiempo para un periodo
v_in=a*sin(2*pi*freq*t);   
for k=1:length(v_in)
    if v_in(k)<0
        v_out(k)=0;
    else
        v_out(k)=v_in(k);
    end
end

%generacion de varias señales
v_in_total=repmat(v_in,1,ciclos);
v_out_total=repmat(v_out,1,ciclos);
t_total=ciclos*fs;
vector_t_total=linspace(0,t_total,length(v_in_total));

%grafica
figure(1);
plot(vector_t_total,v_out_total,'b');
grid on;
hold on;
plot(vector_t_total,v_in_total,'r--');
hold off;
