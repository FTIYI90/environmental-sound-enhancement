function finale_project_with_plots()

%% =========================================================
% FIR Noise Removal Project
%
% Methodology:
% 1) Read original WAV files
% 2) Analyze signals in time domain
% 3) Analyze signals using DTFT approximation (FFT)
% 4) Detect where noise frequencies exist
% 5) Design FIR filter based on frequency analysis
% 6) Apply FIR Bandpass Filter
% 7) Compare before/after results
%
% Speech Frequency Range:
%   300 Hz -> 3400 Hz
%
% FIR Equation:
%   y[n] = sum(b_k * x[n-k])
%
% DTFT Equation:
%   X(e^jw) = sum(x[n] * e^(-jwn))
%
%% =========================================================

clear;
close all;
clc;

%% ---------------- ORIGINAL FILE PATHS ----------------
audioDir = '/Users/fahado/Desktop/Final Working Demo/Matlab code/Matlab for Input 1';

fClean  = fullfile(audioDir,...
    'clean_voice_1_female_speech_woman_speaking__-4c9EgbBqro_000030.wav');

fNoise  = fullfile(audioDir,'rain2.wav');

fMerged = fullfile(audioDir,'final_merged.wav');

outFileAudioDir = fullfile(audioDir,'final_output.wav');

outFileDesktop = fullfile(getenv('HOME'),...
    'Desktop','final_output.wav');

%% ---------------- CHECK FILES ----------------
assert(isfile(fClean),  'Clean WAV file not found');
assert(isfile(fNoise),  'Noise WAV file not found');
assert(isfile(fMerged), 'Merged WAV file not found');

%% =========================================================
% STEP 1 — READ AUDIO FILES
%% =========================================================

[xC, fsC] = audioread(fClean);
[xN, fsN] = audioread(fNoise);
[xM, fsM] = audioread(fMerged);

% Convert to mono
xC = mean(xC,2);
xN = mean(xN,2);
xM = mean(xM,2);

%% =========================================================
% STEP 2 — RESAMPLE TO SAME Fs
%% =========================================================

fs0 = 44100;

if fsC ~= fs0
    xC = resample(xC, fs0, fsC);
end

if fsN ~= fs0
    xN = resample(xN, fs0, fsN);
end

if fsM ~= fs0
    xM = resample(xM, fs0, fsM);
end

%% =========================================================
% STEP 3 — ALIGN LENGTHS
%% =========================================================

N = min([length(xC), length(xN), length(xM)]);

xC = xC(1:N);
xN = xN(1:N);
xM = xM(1:N);

t = (0:N-1)/fs0;

%% =========================================================
% STEP 4 — TIME DOMAIN ANALYSIS
%% =========================================================

figure('Name','Time Domain Analysis');

subplot(3,1,1);
plot(t,xC);
grid on;
title('Clean Speech Signal');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(3,1,2);
plot(t,xN);
grid on;
title('Noise Signal');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(3,1,3);
plot(t,xM);
grid on;
title('Merged Signal (Speech + Noise)');
xlabel('Time (s)');
ylabel('Amplitude');

xlim([0 2]);

%% =========================================================
% STEP 5 — DTFT ANALYSIS USING FFT
%% =========================================================
%
% DTFT:
%
% X(e^jw) = sum(x[n] * e^(-jwn))
%
% FFT is used as practical implementation of DTFT
%
%% =========================================================

NFFT = 2^nextpow2(N);

% FFT
XC = fft(xC, NFFT);
XN = fft(xN, NFFT);
XM = fft(xM, NFFT);

% Single-sided spectrum
K = NFFT/2;

f = (0:K-1)*(fs0/NFFT);

magClean  = abs(XC(1:K));
magNoise  = abs(XN(1:K));
magMerged = abs(XM(1:K));

%% =========================================================
% STEP 6 — FREQUENCY DOMAIN ANALYSIS
%% =========================================================

figure('Name','Frequency Domain Analysis');

subplot(3,1,1);
plot(f,magClean);
grid on;
title('DTFT Magnitude of Clean Speech');
xlabel('Frequency (Hz)');
ylabel('|X(f)|');
xlim([0 8000]);

subplot(3,1,2);
plot(f,magNoise);
grid on;
title('DTFT Magnitude of Noise');
xlabel('Frequency (Hz)');
ylabel('|X(f)|');
xlim([0 8000]);

subplot(3,1,3);
plot(f,magMerged);
grid on;
title('DTFT Magnitude of Merged Signal');
xlabel('Frequency (Hz)');
ylabel('|X(f)|');
xlim([0 8000]);

%% =========================================================
% STEP 7 — PEAK FREQUENCY DETECTION
%% =========================================================

fprintf('\n=================================================\n');
fprintf('DOMINANT NOISE FREQUENCIES\n');
fprintf('=================================================\n');

[pks,locs] = findpeaks(magNoise, f,...
    'MinPeakProminence', max(magNoise)*0.05,...
    'MinPeakDistance', 100);

[~,idx] = sort(pks,'descend');

numPeaks = min(10,length(idx));

for i = 1:numPeaks
    fprintf('Peak %d: %.2f Hz\n', i, locs(idx(i)));
end

%% =========================================================
% STEP 8 — FIR FILTER DESIGN
%% =========================================================
%
% Speech exists mainly between:
%   300 Hz -> 3400 Hz
%
% FIR Filter Equation:
%
% y[n] = sum(b_k * x[n-k])
%
%% =========================================================

filterOrder = 200;

lowCutoff  = 300;
highCutoff = 3400;

fprintf('\n=================================================\n');
fprintf('FIR FILTER PARAMETERS\n');
fprintf('=================================================\n');

fprintf('Filter Type   : FIR Bandpass\n');
fprintf('Filter Order  : %d\n', filterOrder);
fprintf('Low Cutoff    : %d Hz\n', lowCutoff);
fprintf('High Cutoff   : %d Hz\n', highCutoff);

% FIR Bandpass Filter
b = fir1(filterOrder,...
    [lowCutoff highCutoff]/(fs0/2),...
    'bandpass',...
    hamming(filterOrder+1));

%% =========================================================
% STEP 9 — FILTER RESPONSE
%% =========================================================

figure('Name','FIR Filter Frequency Response');

freqz(b,1,2048,fs0);

title('FIR Bandpass Filter Response');

%% =========================================================
% STEP 10 — APPLY FIR FILTER
%% =========================================================

% Zero-phase filtering
yOut = filtfilt(b,1,xM);

%% =========================================================
% STEP 11 — NORMALIZATION
%% =========================================================

yOut = yOut ./ (max(abs(yOut)) + 1e-9);

%% =========================================================
% STEP 12 — SAVE OUTPUT AUDIO
%% =========================================================

audiowrite(outFileAudioDir, yOut, fs0);
audiowrite(outFileDesktop,  yOut, fs0);

fprintf('\n=================================================\n');
fprintf('OUTPUT SAVED\n');
fprintf('=================================================\n');

fprintf('Saved to:\n');
fprintf('%s\n', outFileAudioDir);
fprintf('%s\n', outFileDesktop);

%% =========================================================
% STEP 13 — BEFORE VS AFTER ANALYSIS
%% =========================================================

Y = fft(yOut, NFFT);

magOutput = abs(Y(1:K));

figure('Name','Before vs After FFT');

subplot(2,1,1);
plot(f,magMerged);
grid on;
title('Before Filtering');
xlabel('Frequency (Hz)');
ylabel('|X(f)|');
xlim([0 8000]);

subplot(2,1,2);
plot(f,magOutput);
grid on;
title('After FIR Filtering');
xlabel('Frequency (Hz)');
ylabel('|Y(f)|');
xlim([0 8000]);

%% =========================================================
% STEP 14 — TIME DOMAIN COMPARISON
%% =========================================================

figure('Name','Before vs After Time Domain');

subplot(2,1,1);
plot(t,xM);
grid on;
title('Merged Signal Before Filtering');
xlabel('Time (s)');
ylabel('Amplitude');
xlim([0 2]);

subplot(2,1,2);
plot(t,yOut);
grid on;
title('Output Signal After FIR Filtering');
xlabel('Time (s)');
ylabel('Amplitude');
xlim([0 2]);

%% =========================================================
% STEP 15 — SPECTROGRAM ANALYSIS
%% =========================================================

figure('Name','Spectrogram Analysis');

subplot(2,1,1);
spectrogram(xM,1024,768,2048,fs0,'yaxis');
title('Before Filtering');

subplot(2,1,2);
spectrogram(yOut,1024,768,2048,fs0,'yaxis');
title('After FIR Filtering');

%% =========================================================
% FINAL MESSAGE
%% =========================================================

fprintf('\n=================================================\n');
fprintf('PROJECT COMPLETED SUCCESSFULLY\n');
fprintf('=================================================\n');

end