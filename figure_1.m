clc
clear all

%% --------------------- Hénon map parameters ---------------------
a = 1.4;
N = 16;          % n = 0..15

% Initial conditions
x0 = [0.74 0.18];   % master
y0 = [0.35 0.83];   % slave

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
ea = sqrt((y1a-x1a).^2 + (y2a-x2a).^2);   % Euclidean norm of the error

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
eb = sqrt((y1b-x1b).^2 + (y2b-x2b).^2);   % Euclidean norm of the error

%% --------------------- Colors ---------------------
cM1 = [0 0.45 0.74];      % master x1 (blue)
cS1 = [0.85 0.33 0.10];   % slave y1 (orange)

%% --------------------- Labels (encoded) ---------------------
lbl_a = '(a)';
lbl_b = '(b)';

ttl_a = '$\beta = 0.3$';
ttl_b = '$\beta = 1$';

%% --------------------- Common style ---------------------
lwCurve = 2.5;   % curve line width (master and slave are EQUAL)
lwErr   = 1.5;   % error curve line width
lwBox   = 1.5;   % box line width
fsAx    = 18;    % tick font size
fsYlab  = 15;    % axis label font size
fsLbl   = 20;    % font size of labels (a),(b)
fsTtl   = 20;    % column title font size
fsLeg   = 13;    % legend font size

nn = 0:N-1;

%% --------------------- FIGURE ---------------------
figure('Color','w');

% Geometry (normalized coordinates)
xLcol = 0.10;  wCol = 0.36;   % left column
xRcol = 0.60;                 % right column

hSig  = 0.480;   % height of the time-domain plot
hErr  = 0.180;   % height of the error plot
gapSE = 0.010;   % tight gap between signal and its error
yErr  = 0.130;   % bottom of the error plots

%% ===== Left column: (a) beta = 0.3 =====
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

% --- error (a)
axes('Position',[xLcol, yErr, wCol, hErr]);
plot(nn, log10(ea), 'k-', 'LineWidth', lwErr);
xlim([0 15]); ylim([-6.5 1.5]);
xlabel('$n$','FontSize',fsYlab,'Interpreter','latex');
ylabel('$\log\|\mathbf{e}(n)\|$','FontSize',fsYlab,'Interpreter','latex');
grid on;
xticks([0 5 10 15]); yticks([-6 -3 0]);
set(gca,'FontSize',fsAx,'LineWidth',lwBox,'TickLabelInterpreter','latex');

%% ===== Right column: (b) beta = 1 =====
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

% --- error (b)
axes('Position',[xRcol, yErr, wCol, hErr]);
plot(nn, log10(eb), 'k-', 'LineWidth', lwErr);
xlim([0 15]); ylim([-6.5 1.5]);
xlabel('$n$','FontSize',fsYlab,'Interpreter','latex');
grid on;
xticks([0 5 10 15]); yticks([-6 -3 0]);
set(gca,'FontSize',fsAx,'LineWidth',lwBox,'TickLabelInterpreter','latex','YTickLabel',[]);