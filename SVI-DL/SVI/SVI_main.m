%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                                                       %%
%%                         SVI                           %%
%%                                                       %%
%%                     Main Program                      %%
%%                Version 1.0 ; APR. 2025                %%
%%                                                       %%
%%                  Author:  Xuefeng Gao                 %%
%%                Supervisor: Weiping Cao                %%
%%                                                       %%
%%       Developed at Southwest Petroleum University     %%
%%                        China                          %%
%%                     Year 2025                         %%
%%                                                       %%
%%                                                       %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc;clear;close all;fclose all;
plt='y';                                                                   %plot figures 'y' (yes) or 'n' (no)
segy='n';                                                                  %output segy 'y' (yes) or 'n' (no)
%% 1) Data preprocessing
nt=900;                                                                    %Number of sampling points
nx=120;                                                                    %Number of traces
ns=120;                                                                    %Number of sources
dt=0.002;                                                                  %Time sampling interval
drx=20;                                                                    %Trace interval
dsx=20;                                                                    %Source interval
S_coor=0:dsx:(ns-1)*dsx;                                                   %Coordinate of source.
R_coor=0:drx:(nx-1)*drx;                                                   %Coordinate of source.
folderPath = '.\Noise-free_data';
% Get the contents of the folder
files = dir(folderPath);
% Initialize an empty array of cells to store the file names;
fileNames = {};
% Traverse and store the file names.
for i = 1:length(files)
    if ~files(i).isdir
        fileNames{end+1} = files(i).name;
    end
end
fileNamesChar = char(fileNames);
oridata_all=zeros(nt,nx,ns);
for S=1:ns
    oridata_all(:,:,S)=ReadSegy([folderPath,'\',fileNamesChar(S,:)]);
end
fclose all;
folderPath = '.\Noise-contaminated_data';
% Get the contents of the folder
files = dir(folderPath);
% Initialize an empty array of cells to store the file names;
fileNames = {};
% Traverse and store the file names.
for i = 1:length(files)
    if ~files(i).isdir
        fileNames{end+1} = files(i).name;
    end
end
fileNamesChar = char(fileNames);
data_all=zeros(nt,nx,ns);
for S=1:ns
    data_all(:,:,S)=ReadSegy([folderPath,'\',fileNamesChar(S,:)]);
end
fclose all;
fbwindow=zeros(ns,nx);                                                     %fbwindow_y is the baseline of the time window
% time_windowing_point refers to the points required for fitting the time window curve.
% Generally, five points are selected, which are approximately the center point of the
% seismic source, two starting points of the refracted waves, the starting trace point,
%and the final trace point (the specific positions can be flexibly adjusted according to
%the actual situation of the data).
for S=1:ns
    time_windowing_point = [
        S - 60, 250;
        S - 25, 150;
        S,     1;
        S + 25, 150;
        S + 60, 250
        ];
    [~, fbwindow(S,:)]=windowdata(time_windowing_point,1,ns,nx);
end
up=-1;                                                                     %Upper time window
down=50;                                                                   %Lower time window
data_window = zeros(nt,nx,ns);                                             %data_window is the data after applying the time window.
for S=1:ns
    [m,n] = size(data_all(:,:,S));
    for j=1:nx
        data_window(fbwindow(S,j)-up:fbwindow(S,j)+down,j,S)=data_all(fbwindow(S,j)-up:fbwindow(S,j)+down,j,S);
    end
end

%% 2) Data SVI processing
%This module conducts supervirtual interferometry processing on seismic
%data with a low signal-to-noise ratio, corresponding to the content in
%Section 2.1 of the article.
Data = cell(ns, 1);
for S= 1:ns
    Data{S, 1} = zeros(nt,nx);
end
for S=1:ns
    for i=1:nx
        Data{S,1}(1:nt,i)=data_window(:,i,S);
    end
end
data_SVI=SVI(Data,S_coor,R_coor);
%% 3) Data SVI afterprocessing
equalizedData=zeros(nt,nx,ns);
equilibrium_factor=5;
for S=1:ns
    seismicData = data_SVI(:,:,S)./equilibrium_factor;
    rmsValues = sqrt(mean(seismicData.^2, 1));
    averageRMS = mean(rmsValues);
    equalizationFactors = averageRMS ./ rmsValues;
    equalizedData(:,:,S) = seismicData .* repmat(equalizationFactors, nt, 1);
end
data_SVI_window= zeros(nt,nx,ns);
data_res= zeros(nt,nx,ns);
for S=1:ns
    
    for j=1:nx
        data_SVI_window(fbwindow(S,j)-up:fbwindow(S,j)+down,j,S)=equalizedData(fbwindow(S,j)-up:fbwindow(S,j)+down,j,S);
    end
    data_res(:,:,S)=data_all(:,:,S);
    for j=1:nx
        if data_SVI_window(fbwindow(S,j)-up:fbwindow(S,j)+down,j,S)~=0
            data_res(fbwindow(S,j)-up:fbwindow(S,j)+down,j,S)=data_SVI_window(fbwindow(S,j)-up:fbwindow(S,j)+down,j,S);
        end
    end
    if segy=='y'
        WriteSegy(['SVI_',fileNamesChar(S,end-7:end-5),'.segy'],data_res(:,:,S),'dt',dt)
    end
end
%% Plots
if plt=='y'
    scrnsz = get(0,'screensize');
% Plot the seismic data and the time window.
    fig1 = figure;
    fig1w = 2500;
    fig1h = 800;
    pos = get(fig1,'Position');
    outpos = get(fig1,'OuterPosition');
    bord = outpos - pos; clear pos outpos
    topb = bord(4)-abs(bord(2));
    leftb = abs(bord(1));
    set(fig1,'Position',[leftb scrnsz(4)-(topb+fig1h) fig1w fig1h])
    subplot(1,3,1)
    hold on
    wigb((oridata_all(:,:,38)),1,R_coor,0:dt:(nt-1)*dt)
    timewindowpup=plot(R_coor,(fbwindow(38,:)'-up)*dt,'r','lineWidth',3);
    timewindowpdown=plot(R_coor,(fbwindow(38,:)'+down)*dt,'r','lineWidth',3);
    xlabel('Trace ','FontSize',24)
    ylabel('Time(s)','FontSize',24)
    set(gca,'fontsize',24)
    title('Noise-free traces','FontSize',24)
    legend(timewindowpup, {'Time-window curve'});
    hold off
    subplot(1,3,2)
    hold on
    wigb((data_all(:,:,38)),1,R_coor,0:dt:(nt-1)*dt)
    timewindowpup=plot(R_coor,(fbwindow(38,:)'-up)*dt,'r','lineWidth',3);
    timewindowpdown=plot(R_coor,(fbwindow(38,:)'+down)*dt,'r','lineWidth',3);
    xlabel('X (m)','FontSize',24)
    ylabel('Time(s)','FontSize',24)
    set(gca,'fontsize',24)
    title('Noise-contaminated traces','FontSize',24)
    hold off
    legend(timewindowpup, {'Time-window curve'});
    subplot(1,3,3)
    hold on
    wigb((data_window(:,:,38)),1,R_coor,0:dt:(nt-1)*dt)
    timewindowpup=plot(R_coor,(fbwindow(38,:)'-up)*dt,'r','lineWidth',3);
    timewindowpdown=plot(R_coor,(fbwindow(38,:)'+down)*dt,'r','lineWidth',3);
    xlabel('X (m)','FontSize',24)
    ylabel('Time(s)','FontSize',24)
    set(gca,'fontsize',24)
    title('Time-windowing traces','FontSize',24)
    hold off
    legend(timewindowpup, {'Time-window curve'});
%Plot the original trace gather, the supervirtual interferometry trace
%gather, and the trace gather after supervirtual interferometry.
    fig2 = figure;
    fig2w = 2500;
    fig2h = 1500;
    pos = get(fig2,'Position');
    outpos = get(fig2,'OuterPosition');
    bord = outpos - pos; clear pos outpos
    topb = bord(4)-abs(bord(2));
    leftb = abs(bord(1));
    set(fig2,'Position',[leftb scrnsz(4)-(topb+fig2h) fig2w fig2h])
    subplot(2,3,1)
    hold on
    wigb((data_all(:,:,38)),2,R_coor,0:dt:(nt-1)*dt)
    xlabel('X (m)','FontSize',24)
    ylabel('Time(s)','FontSize',24)
    set(gca,'fontsize',24)
    title('Original  traces','FontSize',24)
    hold off
    subplot(2,3,2)
    hold on
    wigb((equalizedData(:,:,38)),2,R_coor,0:dt:(nt-1)*dt)
    xlabel('X (m)','FontSize',24)
    ylabel('Time(s)','FontSize',24)
    set(gca,'fontsize',24)
    title('SVI traces','FontSize',24)
    hold off
    subplot(2,3,3)
    hold on
    wigb((data_res(:,:,38)),2,R_coor,0:dt:(nt-1)*dt)
    xlabel('X (m)','FontSize',24)
    ylabel('Time(s)','FontSize',24)
    set(gca,'fontsize',24)
    title('Put SVI traces in the original traces','FontSize',24)
    hold off
    subplot(2,3,4)
    hold on
    wigb((data_all(150:400,70:120,38)),2,R_coor(70:120),(150-1)*dt:dt:(400-1)*dt)
    xlabel('X (m)','FontSize',24)
    ylabel('Time(s)','FontSize',24)
    set(gca,'fontsize',24)
    title('Original traces','FontSize',24)
    hold off
    subplot(2,3,5)
    hold on
    wigb((equalizedData(150:400,70:120,38)),2,R_coor(70:120),(150-1)*dt:dt:(400-1)*dt)
    xlabel('X (m)','FontSize',24)
    ylabel('Time(s)','FontSize',24)
    set(gca,'fontsize',24)
    title('SVI traces','FontSize',24)
    hold off
    subplot(2,3,6)
    hold on
    wigb((data_res(150:400,70:120,38)),2,R_coor(70:120),(150-1)*dt:dt:(400-1)*dt)
    xlabel('X (m)','FontSize',24)
    ylabel('Time(s)','FontSize',24)
    set(gca,'fontsize',24)
    title('Put SVI traces in the original traces','FontSize',24)
    hold off
end
