clear all
close all
%从已知地震数据读取道头
seis='D:\软件\matlab\segymat-1.6\7L3_99_122.sgy';
[Data, SegyTraceHeaders, SegyHeader] = ReadSegy(seis);
% 数据截取
seis=Data;
figure;
image(seis);
d=seis;
%%%整个剖面
nt=4000; %采样点数
dx=2;  %1m的检波器间隔
dt=0.0005; %采样时间间隔
nx=241; %地震道集数
t=[0:nt-1]*dt;
x=[0:nx-1]*dx;
df=1/(dt*nt);
f=(0:nt-1)*df;
fmin=min(f);fmax=max(f);
ff=[fmin fmax];
%%%频率—空间谱的绘制
%1. 步骤1 傅里叶变换d(x,f)
% % N=size(d,1);%t
% % M=size(d,2);%x(道）
% % fx=fft(d,nt,1)/nt*2;
% % figure,imagesc(1:nx,f,abs(fx));
% % ylim([0 200]);
% % set(gca,'Fontsize',12,'Fontweight','bold');
% % xlabel('道(n)');ylabel('频率（Hz）');

%%%频率—波速谱的绘制
dk=1/(dx*nx);
fk=fft2(d);
fk=fftshift(fk);
y_axis=[-(nt/2:-1:-1),(1:1:nt/2)]*df;
x_axis=[-(nx/2:-1:-1),(1:1:nx/2)]*dk;
figure;imagesc(x_axis,y_axis,abs(fk));
set(gca,'yTick',-100:10:100);
axis([-0.25,0.25, -100, 100]);
set(gca,'Fontsize',12,'Fontweight','bold');
xlabel('波数（1/m)');ylabel('频率（Hz）');

showmax = 200;
plimage=1;
figure;
wiggle(x,t,seis,'wiggle',[],showmax,plimage);
set(gca,'Fontsize',16,'Fontweight','bold');
xlabel('x(m)');ylabel('t（s）');
title('x-t域');




