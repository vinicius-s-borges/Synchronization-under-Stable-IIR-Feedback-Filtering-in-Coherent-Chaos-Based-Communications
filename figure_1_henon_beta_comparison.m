%% FIGURE_1_HENON_BETA_COMPARISON
%  Generates Figure 1 of the paper "Synchronization under Stable IIR Feedback
%  Filtering in Coherent Chaos-Based Communications": master-slave
%  synchronization of the unfiltered Henon map for beta = 0.3 (synchronizing)
%  and beta = 1 (non-synchronizing).
%
%  Requirements: MATLAB R2016b or newer. No toolboxes required.
%  Deterministic: all initial conditions are hard-coded, no random numbers.
%
%  Code structure
%    1. Henon map parameters ...... map constants, horizon and initial conditions
%    2. Case (a): beta = 0.3 ...... master-slave iteration and error norm
%    3. Case (b): beta = 1 ........ master-slave iteration and error norm
%    4. Colors .................... line colors of the master and slave curves
%    5. Labels .................... panel labels and column titles
%    6. Common style .............. line widths and font sizes
%    7. Figure .................... figure size, axes geometry and plotting
%         7.1 Left column  (a) beta = 0.3   - signal and error panels
%         7.2 Right column (b) beta = 1     - signal and error panels

clc
clear all

%% 1. --------------------- Henon map parameters ---------------------
a = 1.4;
N = 16;          % n = 0..15

% Initial conditions
x0 = [0.74 0.18];   % master
y0 = [0.35 0.83];   % slave

%% 2. --------------------- (a) beta = 0.3 ---------------------
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

%% 3. --------------------- (b) beta = 1 ---------------------
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

%% 4. --------------------- Colors ---------------------
cM1 = [0 0.45 0.74];      % master x1 (blue)
cS1 = [0.85 0.33 0.10];   % slave y1 (orange)

%% 5. --------------------- Labels (encoded) ---------------------
lbl_a = '(a)';
lbl_b = '(b)';

ttl_a = '$\beta = 0.3$';
ttl_b = '$\beta = 1$';

%% 6. --------------------- Common style ---------------------
lwCurve = 2.5;   % curve line width (master and slave are EQUAL)
lwErr   = 1.5;   % error curve line width
lwBox   = 3;     % box line width
fsAx    = 18;    % tick font size
fsYlab  = 15;    % axis label font size
fsLbl   = 20;    % font size of labels (a),(b)
fsTtl   = 20;    % column title font size
fsLeg   = 13;    % legend font size
yXlab   = -0.15; % vertical position of the "n" label, in axes-normalized units
                 % (0 = bottom of the panel; more negative moves it further down)

nn = 0:N-1;

%% 7. --------------------- FIGURE ---------------------
% Large window; the panels below fill almost all of it.
figure('Color','w','Units','normalized','OuterPosition',[0.02 0.05 0.96 0.90], ...
       'PaperPositionMode','auto');

% Geometry (normalized coordinates), chosen so that the panels fill almost the
% whole window: only the tick labels, the axis labels and the titles are left
% outside. The gap between the columns must keep the last tick label of the
% left column apart from the first tick label of the right one.
xLcol  = 0.048;   % left edge of the left column
wCol   = 0.448;   % width of each column
gapCol = 0.034;   % horizontal gap between the two columns
xRcol  = xLcol + wCol + gapCol;   % left edge of the right column

hSig  = 0.633;   % height of the time-domain panels
hErr  = 0.225;   % height of the error panels
gapSE = 0.008;   % vertical gap between a signal panel and its error panel
yErr  = 0.082;   % bottom edge of the error panels

%% 7.1 ===== Left column: (a) beta = 0.3 =====
axes('Position',[xLcol, yErr+hErr+gapSE, wCol, hSig]);
hx1 = plot(nn, x1a, '-',  'LineWidth', lwCurve, 'Color', cM1); hold on
hy1 = plot(nn, y1a, '--', 'LineWidth', lwCurve, 'Color', cS1); hold off
xlim([0 15]); ylim([-2.6 3.3]);
ylabel('$x_1(n);\, y_1(n)$','FontSize',fsYlab,'Interpreter','latex');
text(0.02,0.90,lbl_a,'Units','normalized','FontSize',fsLbl,'Interpreter','tex');
legend([hx1 hy1], {'$x_1(n)$','$y_1(n)$'}, ...
    'Interpreter','latex','Location','north','Orientation','horizontal', ...
    'FontSize',fsLeg,'Box','off');
grid on; set(gca,'XTickLabel',[]);
xticks([0 5 10 15]); yticks([-2 0 2]);
set(gca,'FontSize',fsAx,'LineWidth',lwBox,'TickLabelInterpreter','latex');
title(ttl_a,'FontSize',fsTtl,'FontWeight','normal','Interpreter','latex');

% --- error (a)
axes('Position',[xLcol, yErr, wCol, hErr]);
plot(nn, log10(ea), 'k-', 'LineWidth', lwErr);
xlim([0 15]); ylim([-5 0.8]);
hxl = xlabel('$n$','FontSize',fsYlab,'Interpreter','latex');
set(hxl,'Units','normalized','Position',[0.5 yXlab 0]);
ylabel('$\log\|\mathbf{e}(n)\|$','FontSize',fsYlab,'Interpreter','latex');
grid on;
xticks([0 5 10 15]); yticks([-4 -2 0]);
set(gca,'FontSize',fsAx,'LineWidth',lwBox,'TickLabelInterpreter','latex');

%% 7.2 ===== Right column: (b) beta = 1 =====
axes('Position',[xRcol, yErr+hErr+gapSE, wCol, hSig]);
hx1 = plot(nn, x1b, '-',  'LineWidth', lwCurve, 'Color', cM1); hold on
hy1 = plot(nn, y1b, '--', 'LineWidth', lwCurve, 'Color', cS1); hold off
xlim([0 15]); ylim([-2.6 3.3]);
text(0.02,0.90,lbl_b,'Units','normalized','FontSize',fsLbl,'Interpreter','tex');
legend([hx1 hy1], {'$x_1(n)$','$y_1(n)$'}, ...
    'Interpreter','latex','Location','north','Orientation','horizontal', ...
    'FontSize',fsLeg,'Box','off');
grid on; set(gca,'XTickLabel',[],'YTickLabel',[]);
xticks([0 5 10 15]); yticks([-2 0 2]);
set(gca,'FontSize',fsAx,'LineWidth',lwBox,'TickLabelInterpreter','latex');
title(ttl_b,'FontSize',fsTtl,'FontWeight','normal','Interpreter','latex');

% --- error (b)
axes('Position',[xRcol, yErr, wCol, hErr]);
plot(nn, log10(eb), 'k-', 'LineWidth', lwErr);
xlim([0 15]); ylim([-5 0.8]);
hxl = xlabel('$n$','FontSize',fsYlab,'Interpreter','latex');
set(hxl,'Units','normalized','Position',[0.5 yXlab 0]);
grid on;
xticks([0 5 10 15]); yticks([-4 -2 0]);
set(gca,'FontSize',fsAx,'LineWidth',lwBox,'TickLabelInterpreter','latex','YTickLabel',[]);