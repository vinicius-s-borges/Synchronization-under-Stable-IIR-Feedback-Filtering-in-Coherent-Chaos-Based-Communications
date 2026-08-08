# Synchronization under Stable IIR Feedback Filtering in Coherent Chaos-Based Communications

MATLAB code that reproduces the numerical figures of the paper

> V. S. Borges and M. Eisencraft, *"Synchronization under Stable IIR Feedback Filtering in
> Coherent Chaos-Based Communications."*

Each script is self-contained: running it from start to finish regenerates one figure of the
paper, with the same parameters, initial conditions and layout used in the manuscript.

---

## Contents

- [1. Requirements](#1-requirements)
- [2. Repository structure](#2-repository-structure)
- [3. Figures](#3-figures)
- [4. Running the code](#4-running-the-code)
- [5. Citation](#5-citation)
- [6. Funding, contact and license](#6-funding-contact-and-license)

---

## 1. Requirements

This section lists what is needed to run the scripts and explains why the results are identical
on every run.

### 1.1. Software

The code runs on a standard MATLAB installation; only one of the two scripts depends on a
toolbox.

| Item | Version / notes |
|---|---|
| MATLAB | R2016b or newer (the scripts use `xticks` / `yticks`, introduced in R2016b). Tested on R2018a. |
| Signal Processing Toolbox | Required **only** by `figure4_henon_iir_sync.m` (`cheby1`, `freqz`, `pwelch`, `hamming`) |
| Other toolboxes | None |

The following two lines report the MATLAB release in use and whether the Signal Processing
Toolbox is available:

```matlab
fprintf('MATLAB %s\n', version('-release'));
fprintf('Signal Processing Toolbox available: %d\n', exist('pwelch','file') == 2);
```

### 1.2. Reproducibility

No random number generators are used anywhere. All initial conditions are hard-coded in the
scripts, so repeated runs produce bit-identical results, and no seed needs to be set.

---

## 2. Repository structure

The repository contains one script per numerical figure, plus this file.

```
.
├── figure1_henon_beta_comparison.m   % Figure 1 - Hénon map, beta = 0.3 vs beta = 1
├── figure4_henon_iir_sync.m          % Figure 4 - Hénon map under IIR feedback filtering
└── README.md
```

Figures 2 and 3 of the paper are block diagrams of the system architecture and are not generated
by code.

---

## 3. Figures

This section describes, for each figure, the script that generates it, its dependencies, and the
parameters used.

### 3.1. Figure 1 — Master–slave synchronization of the Hénon map

Figure 1 contrasts a synchronizing and a non-synchronizing choice of the Hénon-map parameter
`beta`, using the unfiltered system.

* **Script:** `figure1_henon_beta_comparison.m`
* **Toolboxes:** none (base MATLAB only)
* **External files:** none
* **Runtime:** < 1 s
* **Content:** upper panels, the first state of the master and of the slave, `x1(n)` and `y1(n)`,
  over the first 16 iterations; lower panels, the base-10 logarithm of the synchronization-error
  norm. Column (a) uses `beta = 0.3`, for which the error converges to zero; column (b) uses
  `beta = 1`, for which synchronization is not achieved.
* **Parameters:** `alpha = 1.4`; `beta` as above; 16 samples; master initial condition
  `[0.74 0.18]`, slave `[0.35 0.83]`.

### 3.2. Figure 4 — Synchronization and power spectral density under IIR feedback filtering

Figure 4 is the numerical illustration of the main theorem: identical BIBO-stable IIR filters are
inserted into the master and slave feedback paths, and the figure shows that synchronization is
preserved while the transmitted spectrum is reshaped.

* **Script:** `figure4_henon_iir_sync.m`
* **Toolboxes:** **Signal Processing Toolbox** — `cheby1` (filter design), `freqz` (frequency
  response), `pwelch` and `hamming` (spectral estimation)
* **External files:** none. The functions `HenonIIR` (master) and `HenonIIR_estravo` (slave) are
  local functions at the end of the script.
* **Runtime:** a few seconds (11 001 iterations of an 11-dimensional augmented map)
* **Content:** panels (a) and (d), time-domain trajectories and synchronization-error norms for
  the unfiltered and the filtered systems, respectively; panel (b), normalized power spectral
  density of `x1(n)`; panel (c), magnitude response of the feedback filter; panel (e), normalized
  power spectral density of the filtered output `x3(n)`.
* **Parameters:** `alpha = 1.4`, `beta = 0.3`; fifth-order low-pass Chebyshev Type I filter with
  1 dB maximum passband ripple and passband edge at `0.4*pi` rad/sample; master and slave filters
  initialized with distinct internal states; Welch estimate with a 1024-sample Hamming window,
  512-sample overlap and a 4096-point FFT, computed over 10 001 samples after discarding a
  1000-sample transient.

---

## 4. Running the code

This section covers how to execute the scripts and how to export the resulting figures.

### 4.1. Execution

Add the repository folder to the MATLAB path (or make it the current folder) and call each script
by name. Each call opens a new figure window.

```matlab
figure1_henon_beta_comparison
figure4_henon_iir_sync
```

### 4.2. Exporting

The figures in the paper are vector graphics. With the figure window in focus:

```matlab
exportgraphics(gcf, 'figure1.eps', 'ContentType', 'vector');   % R2020a or newer
exportgraphics(gcf, 'figure4.eps', 'ContentType', 'vector');
```

### 4.3. Editing the panel labels

The panel labels `(a)`–`(e)` are set through the `lbl_*` variables near the top of each script.
Changing them there updates every occurrence, which is convenient if the panel ordering changes
during review.

---

## 5. Citation

If this code is useful in your work, please cite the paper.

```bibtex
@article{Borges2026Synchronization,
  author  = {Borges, Vin{\'i}cius S. and Eisencraft, Marcio},
  title   = {Synchronization under Stable {IIR} Feedback Filtering in Coherent
             Chaos-Based Communications},
  journal = {IEEE Open Journal of Signal Processing},
  year    = {},
  volume  = {},
  pages   = {},
  note    = {Submitted}
}
```

The `year`, `volume`, `pages` and `doi` fields will be completed once the paper is published.

---

## 6. Funding, contact and license

This section gathers the administrative information related to the work and to the reuse of this
code.

### 6.1. Funding

This work was supported in part by the Brazilian National Council for Scientific and
Technological Development (CNPq) under Grants 140081/2022-4 and 404081/2023-1, and by the
Brazilian Federal Agency for Support and Evaluation of Graduate Education (CAPES),
Finance Code 001.

### 6.2. Contact

Questions about the code or the paper may be addressed to the corresponding author.

Marcio Eisencraft — marcioft@usp.br
Department of Telecommunications and Control Engineering, Escola Politécnica,
University of São Paulo, São Paulo, Brazil.

### 6.3. License

The code in this repository is released under the MIT License (see `LICENSE`). The paper itself
is subject to the publisher's copyright.
