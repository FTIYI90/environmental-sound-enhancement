function finale_project_with_plots()
%% Adaptive FIR noise cancellation (same method as your good result/finale.m)
% Reads 3 WAVs (clean/noise/merged), shows required plots (time, freq, spectrogram),
% removes noise using adaptive FIR (NLMS/LMS), optional bandpass, and saves output.
%
% OUTPUT WAV files:
%   1) <audioDir>/final_output.wav
%   2) ~/Desktop/final_output.wav

clear; close all; clc;

%% --------- YOU CHANGE ONLY THESE PATHS/NAMES ---------
audioDir = '/Users/fahado/Desktop/Signals lab project /Wav files/manuall mix wav/Final_proj_isa';

fClean  = fullfile(audioDir,'clean_voice_1_female_speech_woman_speaking__-4c9EgbBqro_000030.wav'); % (2) clean
fNoise  = fullfile(audioDir,'rain2.wav');                                                       % (1) noise
fMerged = fullfile(audioDir,'final_merged.wav');                                                 % (3) merged

outFileAudioDir = fullfile(audioDir,'final_output.wav');
outFileDesktop  = fullfile(getenv('HOME'),'Desktop','final_output.wav');
%% ----------------------------------------------------

assert(isfile(fClean) && isfile(fNoise) && isfile(fMerged), 'One or more input WAV files not found.');

%% Read (force mono)
[xC, fsC] = audioread(fClean);  xC = mean(xC,2);
[xN, fsN] = audioread(fNoise);  xN = mean(xN,2);
[xM, fsM] = audioread(fMerged); xM = mean(xM,2);

%% Resample to common Fs (same as your good-result file)
fs0 = 44100;
if fsC ~= fs0, xC = resample(xC, fs0, fsC); end
if fsN ~= fs0, xN = resample(xN, fs0, fsN); end
if fsM ~= fs0, xM = resample(xM, fs0, fsM); end

%% Length align (common overlap)
N = min([numel(xC), numel(xN), numel(xM)]);
xC = xC(1:N);
xN = xN(1:N);
xM = xM(1:N);

t = (0:N-1)/fs0;

%% -------------------- PLOTS: Time domain --------------------
figure('Name','Time domain (first 2 seconds)');
subplot(3,1,1); plot(t, xC); grid on; title('Clean (reference)'); xlabel('Time (s)'); ylabel('Amp');
subplot(3,1,2); plot(t, xN); grid on; title('Noise (reference)'); xlabel('Time (s)'); ylabel('Amp');
subplot(3,1,3); plot(t, xM); grid on; title('Merged (clean + noise)'); xlabel('Time (s)'); ylabel('Amp');
xlim([0 min(2, t(end))]);

%% -------------------- PLOTS: Frequency domain (FFT + peaks) --------------------
maxPlotHz = min(8000, fs0/2);
figure('Name','Frequency domain (single-sided magnitude)');
tiledlayout(3,1,'Padding','compact','TileSpacing','compact');
plotSpectrumAndPeaks(xC, fs0, 'Clean (reference)', maxPlotHz);
plotSpectrumAndPeaks(xN, fs0, 'Noise (reference)', maxPlotHz);
plotSpectrumAndPeaks(xM, fs0, 'Merged (clean + noise)', maxPlotHz);

%% -------------------- PLOTS: Spectrograms --------------------
% Requires Signal Processing Toolbox (spectrogram)
if exist('spectrogram','file') == 2
    figure('Name','Spectrograms');
    tiledlayout(3,1,'Padding','compact','TileSpacing','compact');

    nexttile; spectrogram(xC, 1024, 768, 2048, fs0, 'yaxis'); title('Clean spectrogram');
    nexttile; spectrogram(xN, 1024, 768, 2048, fs0, 'yaxis'); title('Noise spectrogram');
    nexttile; spectrogram(xM, 1024, 768, 2048, fs0, 'yaxis'); title('Merged spectrogram');
else
    warning('spectrogram() not available on this MATLAB installation; skipping spectrogram plots.');
end

%% -------------------- Adaptive FIR noise cancellation (same as finale.m) --------------------
% Model: merged = clean + filtered(noise)
L  = 256;   % FIR length (try 128..1024)
mu = 0.05;  % step size (try 0.01..0.2)

useDSP = exist('dsp.LMSFilter','class') == 8;

if useDSP
    anc = dsp.LMSFilter('Length', L, 'StepSize', mu, 'Method', 'Normalized LMS');
    [~, eClean] = anc(xN, xM);
else
    w = zeros(L,1);
    xbuf = zeros(L,1);
    eClean = zeros(N,1);
    eps0 = 1e-6;

    for n = 1:N
        xbuf = [xN(n); xbuf(1:end-1)];
        yHat = w.' * xbuf;
        eClean(n) = xM(n) - yHat;
        w = w + (mu / ((xbuf.'*xbuf) + eps0)) * xbuf * eClean(n);
    end
end

%% Optional FIR bandpass (speech band) to reduce rumble/hiss
enableBandpass = true;
bpLowHz  = 300;
bpHighHz = 3400;

if enableBandpass
    bpOrd = 400;
    bBP = fir1(bpOrd, [bpLowHz bpHighHz]/(fs0/2), 'bandpass', hamming(bpOrd+1));
    yOut = filtfilt(bBP, 1, eClean);
else
    yOut = eClean;
end

%% Normalize + save output
yOut = yOut / (max(abs(yOut)) + 1e-9) * 0.98;

audiowrite(outFileAudioDir, yOut, fs0);
audiowrite(outFileDesktop,  yOut, fs0);
fprintf('Saved output to: %s\n', outFileAudioDir);
fprintf('Saved output to: %s\n', outFileDesktop);

%% -------------------- PLOTS: Before vs after --------------------
figure('Name','Before vs After (time, first 2 seconds)');
subplot(2,1,1); plot(t, xM);   grid on; title('Merged (before)'); xlabel('Time (s)'); ylabel('Amp'); xlim([0 min(2,t(end))]);
subplot(2,1,2); plot(t, yOut); grid on; title('Output (after)');  xlabel('Time (s)'); ylabel('Amp'); xlim([0 min(2,t(end))]);

figure('Name','Spectrum comparison');
tiledlayout(2,1,'Padding','compact','TileSpacing','compact');
nexttile; plotSpectrumOnly(xM, fs0, 'Merged (before)', maxPlotHz);
nexttile; plotSpectrumOnly(yOut, fs0, 'Output (after)', maxPlotHz);

if exist('spectrogram','file') == 2
    figure('Name','Before vs After (spectrogram)');
    subplot(2,1,1); spectrogram(xM, 1024, 768, 2048, fs0, 'yaxis'); title('Merged spectrogram (before)');
    subplot(2,1,2); spectrogram(yOut,1024, 768, 2048, fs0, 'yaxis'); title('Output spectrogram (after)');
end

end

%% ---- Local helper functions (from your good-result finale.m style) ----
function plotSpectrumAndPeaks(x, fs, ttl, maxHz)
nexttile;
[f, magDB] = spectrumDB(x, fs);
plot(f, magDB, 'LineWidth', 1); grid on;
xlim([0, maxHz]); xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
title(ttl);

inBand = (f >= 0) & (f <= maxHz);
f2 = f(inBand); m2 = magDB(inBand);

if exist('findpeaks','file') == 2
    [pks, locs] = findpeaks(m2, f2, ...
        'MinPeakDistance', 80, ...
        'MinPeakProminence', 6);

    [~, idx] = sort(pks, 'descend');
    idx = idx(1:min(8,numel(idx)));
    fprintf('\n%s - top peaks (Hz):\n', ttl);
    fprintf('  %7.1f Hz  (%5.1f dB)\n', [locs(idx) pks(idx)].');
end
end

function plotSpectrumOnly(x, fs, ttl, maxHz)
[f, magDB] = spectrumDB(x, fs);
plot(f, magDB, 'LineWidth', 1); grid on;
xlim([0, maxHz]); xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
title(ttl);
end

function [f, magDB] = spectrumDB(x, fs)
x = x(:);
N = numel(x);
w = hann(N,'periodic');
xw = x .* w;

Nfft = 2^nextpow2(max(N, 4096));
X = fft(xw, Nfft);

K = floor(Nfft/2) + 1;
X = X(1:K);
magDB = 20*log10(abs(X) + 1e-12);
f = (0:K-1)' * (fs/Nfft);
end
