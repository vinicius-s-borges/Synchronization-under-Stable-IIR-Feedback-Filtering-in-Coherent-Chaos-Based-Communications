%% FIGURE_4_HENON_IIR_SYNC
%  Generates Figure 4 of the paper "Synchronization under Stable IIR Feedback
%  Filtering in Coherent Chaos-Based Communications": master-slave
%  synchronization of the Henon map with and without a BIBO-stable IIR filter
%  in the feedback paths, together with the corresponding power spectral
%  densities.
%
%  Requirements: MATLAB R2016b or newer and the Signal Processing Toolbox
%  (cheby1, freqz, pwelch, hamming).
%  Deterministic: all initial conditions are hard-coded, no random numbers.
%
%  Code structure
%     1. Map parameters ............ map constants and simulation horizon
%     2. Unfiltered map ............ master-slave iteration and error norm
%     3. Unfiltered PSD ............ Welch estimate of the unfiltered output
%     4. Filter design ............. Chebyshev type I lowpass and its response
%     5. Filtered map, master ...... augmented state iteration
%     6. Filtered map, slave ....... augmented state iteration driven by x3
%     7. Synchronization error ..... error of the augmented state vector
%     8. Filtered PSD .............. Welch estimate of the filtered output
%     9. Colors .................... line colors of the master and slave curves
%    10. Labels .................... panel labels and column titles
%    11. Common style .............. line widths and font sizes
%    12. Figure .................... figure size, axes geometry and plotting
%          12.1 Left column, block (a)  - unfiltered signal and error panels
%          12.2 Left column, block (d)  - filtered signal and error panels
%          12.3 Right column (b), (c), (e) - spectra and filter response
%    13. Functions ................. master and slave augmented state updates

clear all
clc

%% 1. --------------------- Map parameters ---------------------
alpha = 1.4;
beta  = 0.3;
Ntrans = 1000;            % samples discarded as transient (PSD)
Npsd   = 10001;           % samples used in the PSD, after the transient
Nitera = Ntrans + Npsd;   % total number of simulated samples

%% 2. --------------------- Simulation (map without filter) ---------------------
x1 = zeros(1, Nitera+1);
x2 = zeros(1, Nitera+1);

% Initial conditions
x1(1,1) = 0.74;
x2(1,1) = 0.18;
y1(1,1) = 0.35;
y2(1,1) = 0.83;

for n = 1:Nitera
    x1(n+1) = alpha - x1(n)^2 + beta * x2(n);
    x2(n+1) = x1(n);
end

for n = 1:Nitera
    y1(n+1) = alpha - x1(n)^2 + beta * y2(n);
    y2(n+1) = y1(n);
end

% Euclidean norm of the error (unfiltered case, panel (a))
erro_norma_a = sqrt((x1 - y1).^2 + (x2 - y2).^2);

%% 3. --------------------- PSD (map without filter) ---------------------
% Discards the first Ntrans samples (transient) and uses the following Npsd ones.
idxPSD = Ntrans+1 : Ntrans+Npsd;   % indices from 1001 to 11001
x1_psd = x1(idxPSD);
x_dc_1 = x1_psd - mean(x1_psd);
nfft     = 4096;
Njanela  = 1024;
Fs       = 1;     % unit sampling rate
noverlap = 512;

[PSD1, f1] = pwelch(x_dc_1, hamming(Njanela), noverlap, nfft, Fs);
PSD1 = PSD1 ./ max(PSD1);    % normalizes to [0,1]
wpi1 = 2*f1;                 % w/pi = 2f (since f lies in [0,0.5])

%% 4. --------------------- Filter design ---------------------
Nf  = 5;
Gz  = 1;
Rp  = 1;
Rs  = 10;
Wn  = 0.4;

% Chebyshev type I
[b, a] = cheby1(Nf, Rp, Wn, 'low');

% Frequency response
[H, w] = freqz(b, a, 2048);

%% 5. --------------------- Simulation (filtered map - Master) ---------------------
Na = length(a);   % number of AR coefficients
Nb = length(b);   % number of MA coefficients
L  = Na + Nb;

dimensao_mapa    = 2;
dimensao_sistema = dimensao_mapa + L - 3;

x = zeros(dimensao_sistema, Nitera+1);
% Master: same initial conditions as the unfiltered map above; the other 9
% states are zero.
x(1,1) = 0.74;
x(2,1) = 0.18;

for it = 1:Nitera
    x(:, it+1) = HenonIIR(alpha, beta, dimensao_mapa, Nb, Na, b, a, x(:, it));
end

%% 6. --------------------- Simulation (filtered map - Slave) ---------------------
y = zeros(dimensao_sistema, Nitera+1);
% Slave: initial conditions of the unfiltered map above plus the 9 fixed
% filter states.
y(:,1) = [0.35 0.83 0.8566 0.7636 0.9762 0.7815 0.9356 0.7392 0.2536 0.7193 0.6935];

for it = 1:Nitera
    y(:, it+1) = HenonIIR_estravo(alpha, beta, dimensao_mapa, Nb, Na, b, a, y(:, it), x(3,it));
end

%% 7. --------------------- Synchronization error ---------------------
erro_sincronizacao = abs(x(3,:) - y(3,:));

% Euclidean norm of the error over the whole state vector (panel (d))
erro_norma = sqrt(sum((x - y).^2, 1));

%% 8. --------------------- PSD (filtered map) ---------------------
x3_psd = x(3, idxPSD);
x_dc_2 = x3_psd - mean(x3_psd);
noverlap = 512;

[PSD2, f2] = pwelch(x_dc_2, hamming(Njanela), noverlap, nfft, Fs);
PSD2 = PSD2 ./ max(PSD2);
wpi2 = 2*f2;

%% 9. --------------------- Colors ---------------------
verdeEscuro = [0 0.4 0];
cM1 = [0 0.45 0.74];      % master x1 (blue)
cS1 = [0.85 0.33 0.10];   % slave y1 (orange)
cM2 = [0.30 0.65 0.90];   % master x3 (light blue)
cS2 = [0.95 0.60 0.30];   % slave y3 (light orange)

%% 10. --------------------- Labels (encoded) ---------------------
% Changing a label here updates every occurrence of it in the figure.
lbl_a = '(a)';   % time domain without filter + error
lbl_b = '(b)';   % PSD without filter
lbl_c = '(c)';   % |Hs|
lbl_d = '(d)';   % time domain filtered + error
lbl_e = '(e)';   % PSD filtered

ttl_left  = 'Time domain';
ttl_right = 'Frequency domain';

%% 11. --------------------- Common style ---------------------
lwCurve = 2.5;   % curve line width (master and slave are EQUAL)
lwErr   = 1.5;   % error curve line width
lwBox   = 3;     % box line width
fsAx    = 18;    % tick font size
fsYlab  = 18;    % axis label font size
fsLbl   = 18;    % font size of labels (a)-(e)
fsTtl   = 18;    % column title font size
fsLeg   = 18;    % legend font size

%% 12. --------------------- FIGURE ---------------------
% Large window; the panels below fill almost all of it.
figure('Color','w','Units','normalized','OuterPosition',[0.02 0.05 0.96 0.90]);

% Geometry (normalized coordinates)
% Wide columns, minimal margins; panels close together, filling almost everything.
xL = 0.045; wL = 0.445;   % left column (time)
xR = 0.545; wR = 0.450;   % right column (frequency)

% Right column: 3 full rows, nearly touching (minimal vertical gap).
hRow  = 0.275;                 % height of each panel
gapR  = 0.015;                 % vertical gap between b, c, e
yBot  = 0.095;                 % bottom of panel (e)
yMid  = yBot + hRow + gapR;    % bottom of panel (c)
yTop  = yMid + hRow + gapR;    % bottom of panel (b)

% Left column: two signal(top)+error(bottom) pairs filling the whole column
% height, aligned with the right column [yBot ; yTop+hRow].
yColBot = yBot;              % bottom of the column (= bottom of panel (e))
yColTop = yTop + hRow;      % top of the column (= top of panel (b))
gapSE   = 0.015;            % gap between signal and its error (within the pair)
gapPair = 0.04;            % gap between pair (a) and pair (d)
hPair   = (yColTop - yColBot - gapPair)/2;   % height of each pair
hErr    = 0.13;                             % height of the error plot
hSig    = hPair - hErr - gapSE;              % height of the time-domain plot
yErrD   = yColBot;                 % bottom of the error in block (d) = bottom of the column
yErrA   = yColBot + hPair + gapPair; % bottom of the error in block (a)

%% 12.1 ===== LEFT - block (a): unfiltered signal + error =====
axes('Position',[xL, yErrA+hErr+gapSE, wL, hSig]);
hM = plot(0:100, x1(1,1:101), '-',  'LineWidth', lwCurve, 'Color', cM1); hold on
hS = plot(0:100, y1(1,1:101), '--', 'LineWidth', lwCurve, 'Color', cS1); hold off
xlim([-2,102]); ylim([-3,3]);
ylabel('$x_{1}(n);\, y_{1}(n)$','FontSize',fsYlab,'Interpreter','latex');
text(0.02,0.92,lbl_a,'Units','normalized','FontSize',fsLbl,'Interpreter','tex');
legend([hM hS], {'$x_{1}(n)$','$y_{1}(n)$'}, ...
    'Interpreter','latex','Location','north','Orientation','horizontal', ...
    'FontSize',fsLeg,'Box','off');
grid on; set(gca,'XTickLabel',[]);
xticks([0 25 50 75 100]); yticks([-2 0 2]);
set(gca,'FontSize',fsAx,'LineWidth',lwBox,'TickLabelInterpreter','latex');
title(ttl_left,'FontSize',fsTtl,'FontWeight','normal','Interpreter','tex');

% --- error of block (a)  (no x labels; grid kept)
axes('Position',[xL, yErrA, wL, hErr]);
plot(0:100, log10(erro_norma_a(1:101)), 'k-', 'LineWidth', lwErr);
xlim([-2,102]); ylim([-5.5 1.5]);
ylabel('$\log\|\mathbf{e}(n)\|$','FontSize',fsYlab,'Interpreter','latex');
grid on; set(gca,'XTickLabel',[]);
xticks([0 25 50 75 100]); yticks([-4 0]);
set(gca,'FontSize',fsAx,'LineWidth',lwBox,'TickLabelInterpreter','latex');

%% 12.2 ===== LEFT - block (d): filtered signal + error =====
axes('Position',[xL, yErrD+hErr+gapSE, wL, hSig]);
hM3 = plot(0:100, x(3,1:101), '-',  'LineWidth', lwCurve, 'Color', cM2); hold on
hS3 = plot(0:100, y(3,1:101), '--', 'LineWidth', lwCurve, 'Color', cS2); hold off
xlim([-2,102]); ylim([-2.2,3]);
ylabel('$x_{3}(n);\, y_{3}(n)$','FontSize',fsYlab,'Interpreter','latex');
text(0.02,0.92,lbl_d,'Units','normalized','FontSize',fsLbl,'Interpreter','tex');
legend([hM3 hS3], {'$x_{3}(n)$','$y_{3}(n)$'}, ...
    'Interpreter','latex','Location','north','Orientation','horizontal', ...
    'FontSize',fsLeg,'Box','off');
grid on; set(gca,'XTickLabel',[]);
xticks([0 25 50 75 100]); yticks([-2 0 2]);
set(gca,'FontSize',fsAx,'LineWidth',lwBox,'TickLabelInterpreter','latex');

% --- error of block (d)  (keeps the x label = n)
axes('Position',[xL, yErrD, wL, hErr]);
plot(0:100, log10(erro_norma(1:101)), 'k-', 'LineWidth', lwErr);
xlim([-2,102]); ylim([-5.5 1.5]);
xlabel('$n$','FontSize',fsYlab,'Interpreter','latex');
ylabel('$\log\|\mathbf{e}_{\mathrm{aug}}(n)\|$','FontSize',fsYlab,'Interpreter','latex');
grid on;
xticks([0 25 50 75 100]); yticks([-4 0]);
set(gca,'FontSize',fsAx,'LineWidth',lwBox,'TickLabelInterpreter','latex');

%% 12.3 ===== RIGHT: (b), (c), (e) =====
% --- (b) PSD without filter
axes('Position',[xR, yTop, wR, hRow]);
plot(wpi1, PSD1, 'Color', verdeEscuro, 'LineWidth', 2);
xlim([-0.015,1.015]); ylim([-0.1,1.07]);
ylabel('$S_{x_{1}x_{1}}(e^{j\omega})$','FontSize',fsYlab,'Interpreter','latex');
text(0.02,0.89,lbl_b,'Units','normalized','FontSize',fsLbl,'Interpreter','tex');
grid on; set(gca,'XTickLabel',[]);
xticks([0 0.25 0.5 0.75 1]); yticks([0 0.5 1]);
set(gca,'FontSize',fsAx,'LineWidth',lwBox,'TickLabelInterpreter','latex');
title(ttl_right,'FontSize',fsTtl,'FontWeight','normal','Interpreter','tex');

% --- (c) |Hs|  -> label on the right, away from the curve (which occupies the left side)
axes('Position',[xR, yMid, wR, hRow]);
plot(w/pi, abs(H), 'k', 'LineWidth', 2);
xlim([-0.015,1.015]); ylim([-0.1,1.07]);
ylabel('$\left|H_{s}(e^{j\omega})\right|$','FontSize',fsYlab,'Interpreter','latex');
text(0.02,0.17,lbl_c,'Units','normalized','FontSize',fsLbl,'Interpreter','tex');
grid on; set(gca,'XTickLabel',[]);
xticks([0 0.25 0.5 0.75 1]); yticks([0 0.5 1]);
set(gca,'FontSize',fsAx,'LineWidth',lwBox,'TickLabelInterpreter','latex');

% --- (e) filtered PSD
axes('Position',[xR, yBot, wR, hRow]);
plot(wpi2, PSD2, 'Color', verdeEscuro, 'LineWidth', 2);
xlim([-0.015,1.015]); ylim([-0.1,1.07]);
xlabel('$\omega / \pi$','FontSize',fsYlab,'Interpreter','latex');
ylabel('$S_{x_{3}x_{3}}(e^{j\omega})$','FontSize',fsYlab,'Interpreter','latex');
text(0.02,0.89,lbl_e,'Units','normalized','FontSize',fsLbl,'Interpreter','tex');
grid on;
xticks([0 0.25 0.5 0.75 1]); yticks([0 0.5 1]);
set(gca,'FontSize',fsAx,'LineWidth',lwBox,'TickLabelInterpreter','latex');

%% 13. --------------------- Functions ---------------------
function x_next = HenonIIR(alpha, beta, K, M, N, b, a, x)

x_mapa_original = [alpha - x(3)^2 + beta*x(2);
                   x(1)];

x_filtro_mapa       = [b(1)*(alpha - x(3)^2 + beta*x(2)) + b(2)*x(1)];
x_filtro_mediamovel = [b(3:end)*x(M+2:end)];
x_filtro_autoregre  = [a(2:end)*x(K+1:K+M-1)];
x_filtro            = x_filtro_mapa - x_filtro_autoregre + x_filtro_mediamovel;

x_aux_autoregre1 = [x(K+1)];
x_aux_autoregre2 = [x(K+2:K+M-2)];

x_aux_mediamovel1 = [x(1)];
x_aux_mediamovel2 = [x(K+M:K+M+N-4)];

x1     = vertcat(x_mapa_original, x_filtro);
x2     = vertcat(x1, x_aux_autoregre1);
x3     = vertcat(x2, x_aux_autoregre2);
x4     = vertcat(x3, x_aux_mediamovel1);
x_next = vertcat(x4, x_aux_mediamovel2);
end

function x_next = HenonIIR_estravo(alpha, beta, K, M, N, b, a, x, s)

x_mapa_original = [alpha - s^2 + beta*x(2);
                   x(1)];

x_filtro_mapa       = [b(1)*(alpha - s^2 + beta*x(2)) + b(2)*x(1)];
x_filtro_mediamovel = [b(3:end)*x(M+2:end)];
x_filtro_autoregre  = [a(2:end)*x(K+1:K+M-1)];
x_filtro            = x_filtro_mapa - x_filtro_autoregre + x_filtro_mediamovel;

x_aux_autoregre1 = [x(K+1)];
x_aux_autoregre2 = [x(K+2:K+M-2)];

x_aux_mediamovel1 = [x(1)];
x_aux_mediamovel2 = [x(K+M:K+M+N-4)];

x1     = vertcat(x_mapa_original, x_filtro);
x2     = vertcat(x1, x_aux_autoregre1);
x3     = vertcat(x2, x_aux_autoregre2);
x4     = vertcat(x3, x_aux_mediamovel1);
x_next = vertcat(x4, x_aux_mediamovel2);
end