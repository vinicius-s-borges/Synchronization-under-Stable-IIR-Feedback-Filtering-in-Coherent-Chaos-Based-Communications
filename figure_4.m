clear all
clc

%% --------------------- Parâmetros do mapa ---------------------
alpha = 1.4;
beta  = 0.3;
Ntrans = 1000;            % amostras descartadas como transiente (PSD)
Npsd   = 10001;           % amostras usadas na PSD, após o transiente
Nitera = Ntrans + Npsd;   % total simulado

%% --------------------- Simulação (mapa sem filtro) ---------------------
x1 = zeros(1, Nitera+1);
x2 = zeros(1, Nitera+1);

% Condições iniciais
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

% Norma euclidiana do erro (caso sem filtro, painel (a))
erro_norma_a = sqrt((x1 - y1).^2 + (x2 - y2).^2);

%% --------------------- DEP (mapa sem filtro) ---------------------
% Descarta as primeiras Ntrans amostras (transiente) e usa as Npsd seguintes.
idxPSD = Ntrans+1 : Ntrans+Npsd;   % índices de 1001 a 11001
x1_psd = x1(idxPSD);
x_dc_1 = x1_psd - mean(x1_psd);
nfft     = 4096;
Njanela  = 1024;
Fs       = 1;     % amostragem unitária
noverlap = 512;

[PSD1, f1] = pwelch(x_dc_1, hamming(Njanela), noverlap, nfft, Fs);
PSD1 = PSD1 ./ max(PSD1);    % normaliza para [0,1]
wpi1 = 2*f1;                 % w/pi = 2f (pois f em [0,0.5])

%% --------------------- Projeto do filtro ---------------------
Nf  = 5;
Gz  = 1;
Rp  = 1;
Rs  = 10;
Wn  = 0.4;

% Chebyshev tipo I
[b, a] = cheby1(Nf, Rp, Wn, 'low');

% Resposta em frequência
[H, w] = freqz(b, a, 2048);

%% --------------------- Simulação (mapa filtrado - Mestre) ---------------------
Na = length(a);   % nº de coeficientes AR
Nb = length(b);   % nº de coeficientes MA
L  = Na + Nb;

dimensao_mapa    = 2;
dimensao_sistema = dimensao_mapa + L - 3;

x = zeros(dimensao_sistema, Nitera+1);
% Mestre: mesmas condições iniciais do mapa da Fig. 1; demais 9 estados nulos.
x(1,1) = 0.74;
x(2,1) = 0.18;

for it = 1:Nitera
    x(:, it+1) = HenonIIR(alpha, beta, dimensao_mapa, Nb, Na, b, a, x(:, it));
end

%% --------------------- Simulação (mapa filtrado - Escravo) ---------------------
y = zeros(dimensao_sistema, Nitera+1);
% Escravo: condições iniciais do mapa da Fig. 1 + os 9 estados de filtro fixados.
y(:,1) = [0.35 0.83 0.8566 0.7636 0.9762 0.7815 0.9356 0.7392 0.2536 0.7193 0.6935];

for it = 1:Nitera
    y(:, it+1) = HenonIIR_estravo(alpha, beta, dimensao_mapa, Nb, Na, b, a, y(:, it), x(3,it));
end

%% --------------------- Erro de sincronização ---------------------
erro_sincronizacao = abs(x(3,:) - y(3,:));

% Norma euclidiana do erro sobre todo o vetor de estados (painel (d))
erro_norma = sqrt(sum((x - y).^2, 1));

%% --------------------- DEP (mapa filtrado) ---------------------
x3_psd = x(3, idxPSD);
x_dc_2 = x3_psd - mean(x3_psd);
noverlap = 512;

[PSD2, f2] = pwelch(x_dc_2, hamming(Njanela), noverlap, nfft, Fs);
PSD2 = PSD2 ./ max(PSD2);
wpi2 = 2*f2;

%% --------------------- Cores ---------------------
verdeEscuro = [0 0.4 0];
cM1 = [0 0.45 0.74];      % mestre x1 (azul)
cS1 = [0.85 0.33 0.10];   % escravo y1 (laranja)
cM2 = [0.30 0.65 0.90];   % mestre x3 (azul claro)
cS2 = [0.95 0.60 0.30];   % escravo y3 (laranja claro)

%% --------------------- Rótulos (codificados) ---------------------
% Altere aqui e reflita no texto do artigo.
lbl_a = '(a)';   % temporal sem filtro + erro
lbl_b = '(b)';   % DEP sem filtro
lbl_c = '(c)';   % |Hs|
lbl_d = '(d)';   % temporal filtrado + erro
lbl_e = '(e)';   % DEP filtrado

ttl_left  = 'Time domain';
ttl_right = 'Frequency domain';

%% --------------------- Estilo comum ---------------------
lwCurve = 2.5;   % espessura das curvas (mestre e escravo IGUAIS)
lwErr   = 1.5;   % espessura da curva de erro
lwBox   = 3;   % espessura do box
fsAx    = 18;    % fonte dos ticks
fsYlab  = 18;    % fonte dos rótulos de eixo
fsLbl   = 18;    % fonte dos rótulos (a)-(e)
fsTtl   = 18;    % fonte dos títulos de coluna
fsLeg   = 18;    % fonte das legendas

%% --------------------- FIGURA ---------------------
figure('Color','w','Units','normalized','OuterPosition',[0.02 0.05 0.96 0.90]);

% Geometria (coordenadas normalizadas)
% Colunas largas, margens mínimas; painéis bem juntos, ocupando quase tudo.
xL = 0.045; wL = 0.445;   % coluna esquerda (tempo)
xR = 0.545; wR = 0.450;   % coluna direita  (frequência)

% Coluna direita: 3 linhas cheias, quase encostadas (gap vertical mínimo).
hRow  = 0.275;                 % altura de cada painel
gapR  = 0.015;                 % folga vertical entre b, c, e
yBot  = 0.095;                 % base do painel (e)
yMid  = yBot + hRow + gapR;    % base do painel (c)
yTop  = yMid + hRow + gapR;    % base do painel (b)

% Coluna esquerda: dois pares sinal(alto)+erro(baixo) preenchendo toda a
% altura da coluna, alinhados com a coluna direita [yBot ; yTop+hRow].
yColBot = yBot;              % base da coluna (= base do painel (e))
yColTop = yTop + hRow;      % topo da coluna (= topo do painel (b))
gapSE   = 0.015;            % folga entre sinal e seu erro (dentro do par)
gapPair = 0.04;            % folga entre o par (a) e o par (d)
hPair   = (yColTop - yColBot - gapPair)/2;   % altura de cada par
hErr    = 0.13;                             % altura do gráfico de erro
hSig    = hPair - hErr - gapSE;              % altura do gráfico temporal
yErrD   = yColBot;                 % base do erro do bloco (d) = base da coluna
yErrA   = yColBot + hPair + gapPair; % base do erro do bloco (a)

%% ===== ESQUERDA - bloco (a): sinal sem filtro + erro =====
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

% --- erro do bloco (a)  (sem rótulos de x; grid mantido)
axes('Position',[xL, yErrA, wL, hErr]);
plot(0:100, log10(erro_norma_a(1:101)), 'k-', 'LineWidth', lwErr);
xlim([-2,102]); ylim([-5.5 1.5]);
ylabel('$\log\|\mathbf{e}(n)\|$','FontSize',fsYlab,'Interpreter','latex');
grid on; set(gca,'XTickLabel',[]);
xticks([0 25 50 75 100]); yticks([-4 0]);
set(gca,'FontSize',fsAx,'LineWidth',lwBox,'TickLabelInterpreter','latex');

%% ===== ESQUERDA - bloco (d): sinal filtrado + erro =====
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

% --- erro do bloco (d)  (mantém o rótulo de x = n)
axes('Position',[xL, yErrD, wL, hErr]);
plot(0:100, log10(erro_norma(1:101)), 'k-', 'LineWidth', lwErr);
xlim([-2,102]); ylim([-5.5 1.5]);
xlabel('$n$','FontSize',fsYlab,'Interpreter','latex');
ylabel('$\log\|\mathbf{e}_{\mathrm{aug}}(n)\|$','FontSize',fsYlab,'Interpreter','latex');
grid on;
xticks([0 25 50 75 100]); yticks([-4 0]);
set(gca,'FontSize',fsAx,'LineWidth',lwBox,'TickLabelInterpreter','latex');

%% ===== DIREITA: (b), (c), (e) =====
% --- (b) DEP sem filtro
axes('Position',[xR, yTop, wR, hRow]);
plot(wpi1, PSD1, 'Color', verdeEscuro, 'LineWidth', 2);
xlim([-0.015,1.015]); ylim([-0.1,1.07]);
ylabel('$S_{x_{1}x_{1}}(e^{j\omega})$','FontSize',fsYlab,'Interpreter','latex');
text(0.02,0.89,lbl_b,'Units','normalized','FontSize',fsLbl,'Interpreter','tex');
grid on; set(gca,'XTickLabel',[]);
xticks([0 0.25 0.5 0.75 1]); yticks([0 0.5 1]);
set(gca,'FontSize',fsAx,'LineWidth',lwBox,'TickLabelInterpreter','latex');
title(ttl_right,'FontSize',fsTtl,'FontWeight','normal','Interpreter','tex');

% --- (c) |Hs|  -> rótulo à direita, longe da curva (que ocupa a esquerda)
axes('Position',[xR, yMid, wR, hRow]);
plot(w/pi, abs(H), 'k', 'LineWidth', 2);
xlim([-0.015,1.015]); ylim([-0.1,1.07]);
ylabel('$\left|H_{s}(e^{j\omega})\right|$','FontSize',fsYlab,'Interpreter','latex');
text(0.02,0.17,lbl_c,'Units','normalized','FontSize',fsLbl,'Interpreter','tex');
grid on; set(gca,'XTickLabel',[]);
xticks([0 0.25 0.5 0.75 1]); yticks([0 0.5 1]);
set(gca,'FontSize',fsAx,'LineWidth',lwBox,'TickLabelInterpreter','latex');

% --- (e) DEP filtrado
axes('Position',[xR, yBot, wR, hRow]);
plot(wpi2, PSD2, 'Color', verdeEscuro, 'LineWidth', 2);
xlim([-0.015,1.015]); ylim([-0.1,1.07]);
xlabel('$\omega / \pi$','FontSize',fsYlab,'Interpreter','latex');
ylabel('$S_{x_{3}x_{3}}(e^{j\omega})$','FontSize',fsYlab,'Interpreter','latex');
text(0.02,0.89,lbl_e,'Units','normalized','FontSize',fsLbl,'Interpreter','tex');
grid on;
xticks([0 0.25 0.5 0.75 1]); yticks([0 0.5 1]);
set(gca,'FontSize',fsAx,'LineWidth',lwBox,'TickLabelInterpreter','latex');

%% --------------------- Funções ---------------------
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