close all;
clear all;
clc;

% load eigenFun20;
% load eigenFun1_1_3;
% load eigenVal1_1_3;
load ../eigenFun2DNewmann_1_3;
load ../eigenFun2DNewmann_1_5

rng(41001);
% noise = rand(size(eigenFun20));
addpath '../pLaplace';

f = imread('T0_brain3.bmp');
f = imread('zebra_media_gmu.jpg');
f = double(rgb2gray(f));
f = imresize(f,0.16);
% f = imresize(f,0.5);

f = f - mean(f(:));
f = double(f)/double(max(f(:)));
u = f;
u = u - mean(u(:));
[row,col] = size(f);
h=figure();imshow(f,[])
h.InnerPosition(3)=col;
drawnow;
h.InnerPosition(4)=floor(h.InnerPosition(3)*90/64);
ha = gca;
set(ha,'position',[0 0 1 1]); %[left bottom width height]
h = gcf;
set(h,'color','w');

uini = u;



p = 1.01;
dt = 5e-5;
Delta_pu = lapi(u,p);
Jini = -Delta_pu(:)'*u(:);
J = Jini;
h = figure();imagesc(u)

ut = lapi(u,p);

numOitr = 1200000;
uT = zeros([size(u),numOitr]);
tic
hwait = waitbar(0,'message');
for iii=1:1:numOitr
    if(mod(iii,1e4)==0)
        figure(26)
        subplot(1,2,1);imagesc(u);colorbar;
        subplot(1,2,2);imagesc(ut);colorbar;
        drawnow;
        waitbar(iii/(numOitr),hwait,num2str(100*iii/(numOitr)));
    end
    uT(:,:,iii) = u;
    ut = lapi(u,p);
    u = u + ut*dt;
    
end
close(hwait);
toc
%% mean
N = 8;
tic
% uTT = zeros([size(u),numOitr/N]);
for jjj=1:1:numOitr/N
   uT(:,:,jjj) = mean(uT(:,:,[(jjj-1)*N+1:1:jjj*N]),3);
end
uT = uT(:,:,[1:1:numOitr/N]);
toc
%%

dt = dt*N;
[~,~,numOitr] = size(uT);
T = dt*[0:1:numOitr-1];


%% initial data

uini = uT(:,:,1);

alpha = 1/(2-p);

spec0 = squeeze(sum(sum(abs(uT))));
h= figure('Name',['der = ',num2str(0)]);plot(T,spec0);
h.Children.Children(1).LineWidth = 8;
grid on;
h.Children.FontSize = 60;
h.Children.TickLabelInterpreter = 'Latex';
h.Children.YLim = [0,1.05*max(spec0)];
h.Children.XLim = [T(1) floor(T(end)+1)];
h.Children.XTick = [0:ceil(T(end)/5):T(end)+1];
%% derivative
tic
% yyytemp = uT;
%mirror
FuT = cat(3,uT,uT(:,:,end:-1:1));
clear uT;
[~,~,numOitr] = size(FuT);
FuT = (fft(FuT,[],3));
k = [0:numOitr-1];
beta = alpha+1;
d = (1-exp(2*pi*1i*k/numOitr))/dt; % Euler Grunwald Letnikov
d = d.^(alpha+1);

for iii=1:1:numOitr
    FuT(:,:,iii) = FuT(:,:,iii).*d(iii);
end

for iii=1:1:row
    for jjj=1:1:col
        FuT(iii,jjj,:) = real(ifft(FuT(iii,jjj,:)));
    end
end
% FuT = real(ifft((FuT),[],3));


FuT = FuT(:,:,1:1:floor(numOitr/2));
[~,~,numOitr] = size(FuT);
T = dt*[0:1:numOitr-1];
spec1 = abs(squeeze((sum(sum(abs(FuT))))));

h = figure('Name',['der = ',num2str(alpha+1)]);plot(T,spec1);
h.Children.Children(1).LineWidth = 8;
grid on;
h.Children.FontSize = 60;
h.Children.TickLabelInterpreter = 'Latex';
h.Children.YLim = [0,1.05*max(spec1)];
h.Children.XLim = [T(1) floor(T(end)+1)];
h.Children.XTick = [0:ceil(T(end)/5):T(end)+1];



toc

%%
phi = zeros(size(FuT));
[~,~,numOitr]= size(FuT);
% T = [0,T(1:end-1)];
for iii=1:1:numOitr
    phi(:,:,iii) = -FuT(:,:,iii)*((T(iii)).^(alpha))/gamma(alpha+1);
end
spec1 = abs(squeeze((sum(sum(abs(phi))))));

h = figure('Name',['der = ',num2str(alpha+1)]);plot(T,spec1);
h.Children.Children(1).LineWidth = 8;
grid on;
h.Children.FontSize = 60;
h.Children.TickLabelInterpreter = 'Latex';
h.Children.YLim = [0,1.05*max(spec1)];
h.Children.XLim = [T(1) 6.5];
h.Children.XTick = [0:ceil(6.5/5):6.5];

%%
for iii=1:1:numOitr
    tempPhi = phi(:,:,iii);
    spec1(iii) = abs(tempPhi(:)'*f(:));
end
%%
h = figure('Name',['the spectrum der = ',num2str(alpha+1)]);plot(T,spec1);
h.Children.Children(1).LineWidth = 8;
grid on;
h.Children.FontSize = 60;
h.Children.TickLabelInterpreter = 'Latex';
h.Children.YLim = [0,1.05*max(spec1)];
h.Children.XLim = [T(1) 4.2];
% h.Children.XLim = [T(1) 4.2];
h.Children.XTick = [0:ceil(4.2/5):4.2];
% h.Children.XTick = [0:ceil(4.2/5):4.2];
pause(0.00001);
frame_h = get(handle(gcf),'JavaFrame');
set(frame_h,'Maximized',1);
drawnow
ax_s=gca; outerpos = ax_s.OuterPosition;
ti = ax_s.TightInset;
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3);
ax_height = outerpos(4) - ti(2) - ti(4);
ax_s.Position = [left bottom ax_width ax_height];

%% Reconstruction

fsh = zeros(size(u));
for iii=1:1:numOitr
    fsh = fsh + phi(:,:,iii)*dt;
end
fsh = -real(fsh);%+imag(fsh);

h = figure('Name','residue');imagesc(uini - fsh);
h.Children.XTick = [1028];
h.Children.YTick = [1028];
h = figure('Name','sh');imagesc(fsh);
h.Children.XTick = [1028];
h.Children.YTick = [1028];
h= figure('Name','source');imagesc(uini);
h.Children.XTick = [1028];
h.Children.YTick = [1028];
h=figure();imshow(fsh,[])
h.InnerPosition(3)=col;
drawnow;
%     h.InnerPosition(4)=col;
ha = gca;
h.InnerPosition(4)=floor(h.InnerPosition(3)*row/col);
set(ha,'position',[0 0 1 1]); %[left bottom width height]
%     set(ha,'OuterPosition',[0 0 1 1]); %[left bottom width height]
%     set(ha,'Units','pixels');
%     pos=get(ha,'position');
h = gcf;
set(h,'color','w');

%% filtering
maxT = 4.2;
tPoints = [0.015 0.075 0.2 1]*maxT;
for kkk=1:1:length(tPoints)
    fsh = zeros(size(u));
    if kkk==1
        firstInd = 1;
        [~,lastInd] = min(abs(T-tPoints(1)));
    else
        [~,firstInd] = min(abs(T-tPoints(kkk-1)));
        [~,lastInd] = min(abs(T-tPoints(kkk)));
    end
    kkk
    
    for iii=firstInd:1:lastInd
        fsh = fsh + phi(:,:,iii)*dt;
    end
    
    fsh = -real(fsh);%+imag(fsh);
    [row,col] = size(fsh);
    figure();imagesc(fsh);
    h=figure();imshow(fsh,[])
    h.InnerPosition(3)=col;
    drawnow;
    %     h.InnerPosition(4)=col;
    ha = gca;
    h.InnerPosition(4)=floor(h.InnerPosition(3)*row/col);
    set(ha,'position',[0 0 1 1]); %[left bottom width height]
    %     set(ha,'OuterPosition',[0 0 1 1]); %[left bottom width height]
    %     set(ha,'Units','pixels');
    %     pos=get(ha,'position');
    h = gcf;
    set(h,'color','w');
    %     pos_fig=get(h,'OuterPosition');
    %     set(h,'OuterPosition',[pos_fig(1:2) pos(3:4)]);
    
end

%%
% figure();imshow(fsh,[])
% ax_s=gca; outerpos = ax_s.OuterPosition;
% ti = ax_s.TightInset;
% left = outerpos(1) + ti(1);
% bottom = outerpos(2) + ti(2);
% ax_width = outerpos(3) - ti(1) - ti(3);
% ax_height = outerpos(4) - ti(2) - ti(4);
% ax_s.Position = [left bottom ax_width ax_height];
% 





