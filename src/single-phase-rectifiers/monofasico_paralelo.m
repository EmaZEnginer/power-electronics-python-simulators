%puente monofasico en paralelo
freq=50;    %hz
T=1/freq;   %periodo
fs=10000;   %frecuencia de muestreo
a=1;        %amplitud de la señal
R=100;      %resistencia de carga
C=10e-06;   %capacitor
transitorio=false;  
ciclos_transitorio=4;
armonicos=3;

%definicion de la señal seno y rectificacion
t=0:1/fs:T; %vector de tiempo para un periodo
v_in=a*sin(2*pi*freq*t);   
v_out=abs(v_in);

%varios ciclos (NOTA: otra forma es hacerlo con el for)
% for k=1:ciclos
%     v_in_total(1+(k-1)*length(t):k*length(t))=v_in;
%     v_out_total(1+(k-1)*length(t):k*length(t))=v_out;
% end
v_in_total=repmat(v_in,1,100);      %repite 100 ciclos para 
v_out_total=repmat(v_out,1,100);    %una señal completa
t_total=100*fs;
vector_t_total=linspace(0,t_total,length(v_in_total));

%filtrado de la señal 
num=1;
den=[R*C, 1];
[b,a]=bilinear(num,den,fs);

v_out_filtrada=filter(b,a,v_out_total);

if transitorio
    tiempo_transitorio=vector_t_total(1:length(v_in)*ciclos_transitorio);
    v_in_transitorio=v_in_total(1:length(v_in)*ciclos_transitorio);
    v_out_transitorio=v_out_total(1:length(v_in)*ciclos_transitorio);
    v_out_filtrada_transitorio=v_out_filtrada(1:length(v_in)*ciclos_transitorio);
else
    tiempo_transitorio=vector_t_total(1:length(v_in)*ciclos_transitorio);
    v_in_transitorio=v_in_total(length(vector_t_total)-length(v_in)*ciclos_transitorio+1:end);
    v_out_transitorio=v_out_total(length(vector_t_total)-length(v_in)*ciclos_transitorio+1:end);
    v_out_filtrada_transitorio=v_out_filtrada(length(vector_t_total)-length(v_in)*ciclos_transitorio+1:end);
end

%analisis de fourier y envolvente del filtro
f_vo=fftshift(abs(fft(v_out_filtrada)))./length(v_out_filtrada);
f_vi=fftshift(abs(fft(v_in_total)))./length(v_in_total);
FF=((0:length(v_out_filtrada)-1)./length(v_out_filtrada)-0.5).*fs;
[y_filter, x_filter]=freqz(b, a, length(v_out_filtrada),fs);
y_filter=abs(y_filter)/max(abs(y_filter))*max(f_vo);
x_filter_reflex=x_filter*(-1);

%graficas
figure(1);
plot(tiempo_transitorio,v_out_transitorio,'b');
grid on;
hold on;
plot(tiempo_transitorio,v_in_transitorio,'r--');
hold off;

figure(2);
plot(tiempo_transitorio,v_out_filtrada_transitorio);
grid on;

figure(3);
plot(FF,f_vo,'b');
grid on;
xlim([-armonicos armonicos].*freq);
hold on;
plot(FF,f_vi,'r:');
plot(x_filter_reflex,y_filter,'g--');
plot(x_filter,y_filter,'g--');



