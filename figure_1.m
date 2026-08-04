clc
clear all

%% --------------------- Parâmetros do mapa de Hénon ---------------------
a = 1.4;
N = 16;          % n = 0..15

% Condições iniciais
x0 = [0.74 0.18];   % mestre
y0 = [0.35 0.83];   % escravo

%% --------------------- (a) beta = 0.3 ---------------------
b = 0.3;
x1a(1) = x0(1); x2a(1) = x0(2);
y1a(1) = y0(1); y2a(1) = y0(2);
for n = 1:1:N-1
    x1a(n+1) = b*x2a(n) + a - x1a(n)^2;
    x2a(n+1) = x1a(n);
    y1a(n+1) = b*y2a(n) + a - x1a(n)^2;
    y2a(n+1) = y1a(n);
end
ea = sqrt((y1a-x1a).^2 + (y2a-x2a).^2);   % norma euclidiana do erro

%% --------------------- (b) beta = 1 ---------------------
b = 1;
x1b(1) = x0(1); x2b(1) = x0(2);
y1b(1) = y0(1); y2b(1) = y0(2);
for n = 1:1:N-1
    x1b(n+1) = b*x2b(n) + a - x1b(n)^2;
    x2b(n+1) = x1b(n);
    y1b(n+1) = b*y2b(n) + a - x1b(n)^2;
    y2b(n+1) = y1b(n);
end
eb = sqrt((y1b-x1b).^2 + (y2b-x2b).^2);   % norma euclidiana do erro

%% --------------------- Cores (iguais às da Fig. 4) ---------------------
cM1 = [0 0.45 0.74];      % mestre x1 (azul)
cS1 = [0.85 0.33 0.10];   % escravo y1 (laranja)

%% --------------------- Rótulos (codificados) ---------------------
lbl_a = '(a)';
lbl_b = '(b)';

ttl_a = '$\beta = 0.3$';
ttl_b = '$\beta = 1$';

%% --------------------- Estilo comum (igual ao da Fig. 4) ---------------------
lwCurve = 2.5;   % espessura das curvas (mestre e escravo IGUAIS)
lwErr   = 1.5;   % espessura da curva de erro
lwBox   = 1.5;   % espessura do box
fsAx    = 18;    % fonte dos ticks
fsYlab  = 15;    % fonte dos rótulos de eixo
fsLbl   = 20;    % fonte dos rótulos (a),(b)
fsTtl   = 20;    % fonte dos títulos de coluna
fsLeg   = 13;    % fonte das legendas

nn = 0:N-1;

%% --------------------- FIGURA ---------------------
figure('Color','w');

% Geometria (coordenadas normalizadas)
xLcol = 0.10;  wCol = 0.36;   % coluna esquerda
xRcol = 0.60;                 % coluna direita

hSig  = 0.480;   % altura do gráfico temporal
hErr  = 0.180;   % altura do gráfico de erro
gapSE = 0.010;   % folga justa entre sinal e seu erro
yErr  = 0.130;   % base dos gráficos de erro

%% ===== Coluna esquerda: (a) beta = 0.3 =====
axes('Position',[xLcol, yErr+hErr+gapSE, wCol, hSig]);
hx1 = plot(nn, x1a, '-',  'LineWidth', lwCurve, 'Color', cM1); hold on
hy1 = plot(nn, y1a, '--', 'LineWidth', lwCurve, 'Color', cS1); hold off
xlim([0 15]); ylim([-3.4 3.4]);
ylabel('$x_1(n);\, y_1(n)$','FontSize',fsYlab,'Interpreter','latex');
text(0.02,0.90,lbl_a,'Units','normalized','FontSize',fsLbl,'Interpreter','tex');
legend([hx1 hy1], {'$x_1(n)$','$y_1(n)$'}, ...
    'Interpreter','latex','Location','south','Orientation','horizontal', ...
    'FontSize',fsLeg,'Box','off');
grid on; set(gca,'XTickLabel',[]);
xticks([0 5 10 15]); yticks([-2 0 2]);
set(gca,'FontSize',fsAx,'LineWidth',lwBox,'TickLabelInterpreter','latex');
title(ttl_a,'FontSize',fsTtl,'FontWeight','normal','Interpreter','latex');

% --- erro (a)
axes('Position',[xLcol, yErr, wCol, hErr]);
plot(nn, log10(ea), 'k-', 'LineWidth', lwErr);
xlim([0 15]); ylim([-6.5 1.5]);
xlabel('$n$','FontSize',fsYlab,'Interpreter','latex');
ylabel('$\log\|\mathbf{e}(n)\|$','FontSize',fsYlab,'Interpreter','latex');
grid on;
xticks([0 5 10 15]); yticks([-6 -3 0]);
set(gca,'FontSize',fsAx,'LineWidth',lwBox,'TickLabelInterpreter','latex');

%% ===== Coluna direita: (b) beta = 1 =====
axes('Position',[xRcol, yErr+hErr+gapSE, wCol, hSig]);
hx1 = plot(nn, x1b, '-',  'LineWidth', lwCurve, 'Color', cM1); hold on
hy1 = plot(nn, y1b, '--', 'LineWidth', lwCurve, 'Color', cS1); hold off
xlim([0 15]); ylim([-3.4 3.4]);
text(0.02,0.90,lbl_b,'Units','normalized','FontSize',fsLbl,'Interpreter','tex');
legend([hx1 hy1], {'$x_1(n)$','$y_1(n)$'}, ...
    'Interpreter','latex','Location','south','Orientation','horizontal', ...
    'FontSize',fsLeg,'Box','off');
grid on; set(gca,'XTickLabel',[],'YTickLabel',[]);
xticks([0 5 10 15]); yticks([-2 0 2]);
set(gca,'FontSize',fsAx,'LineWidth',lwBox,'TickLabelInterpreter','latex');
title(ttl_b,'FontSize',fsTtl,'FontWeight','normal','Interpreter','latex');

% --- erro (b)
axes('Position',[xRcol, yErr, wCol, hErr]);
plot(nn, log10(eb), 'k-', 'LineWidth', lwErr);
xlim([0 15]); ylim([-6.5 1.5]);
xlabel('$n$','FontSize',fsYlab,'Interpreter','latex');
grid on;
xticks([0 5 10 15]); yticks([-6 -3 0]);
set(gca,'FontSize',fsAx,'LineWidth',lwBox,'TickLabelInterpreter','latex','YTickLabel',[]);