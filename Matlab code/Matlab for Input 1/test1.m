function finale_project_with_plots()

% =========================================================
FIR FILTER AUDIO DENOISING PROJECT

METHODOLOGY:

1) Read clean, noise, and merged WAV files
2) Convert signals to mono
3) Resample to same sampling frequency
4) Analyze signals in time domain
5) Compute Fourier Transform (FFT / DTFT approximation)
6) Detect clean and noise frequency ranges
7) Design FIR Bandpass Filter
8) Apply FIR filter
9) Compare before vs after filtering
10) Save output WAV to Desktop

FIGURES:

Fig 1 -> FIR Filter Frequency Response
Fig 2 -> Time Domain Signals
Fig 3 -> Time Domain Comparison
Fig 4 -> Fourier Transform of Clean/Noise/Merged
Fig 5 -> FT Comparison Before vs After

% =========================================================

clear;
close all;
clc;

% =========================================================
FILE PATHS
% =========================================================

audioDir = '/Users/fahado/Desktop/Final Working Demo/Matlab code/Matlab for Input 1';

fClean = fullfile(audioDir,...
'clean_voice_1_female_speech_woman_speaking__-4c9EgbBqro_000030.wav');

fNoise = fullfile(audioDir,'rain2.wav');

fMerged = fullfile(audioDir,'final_merged.wav');

% =========================================================
READ AUDIO FILES
% =========================================================

[xC, fsC] = audioread(fClean);
[xN, fsN] = audioread(fNoise);
[xM, fsM] = audioread(fMerged);

% =========================================================
CONVERT TO MONO
% =========================================================

xC = mean(xC,2);
xN = mean(xN,2);
xM = mean(xM,2);

% =========================================================
RESAMPLE TO SAME SAMPLING FREQUENCY
% =========================================================

fs = 44100;

if fsC ~= fs
    xC = resample(xC,fs,fsC);
end

if fsN ~= fs
    xN = resample(xN,fs,fsN);
end

if fsM ~= fs
    xM = resample(xM,fs,fsM);
end

% =========================================================
PRINT SAMPLING INFORMATION
% =========================================================

fprintf('\n========================================\n');
fprintf('SAMPLING INFORMATION\n');
fprintf('========================================\n');

fprintf('Sampling Frequency = %d Hz\n',fs);

Ts = 1/fs;

fprintf('Sampling Period = %.10f seconds\n',Ts);

% =========================================================
ALIGN SIGNAL LENGTHS
% =========================================================

N = min([length(xC), length(xN), length(xM)]);

xC = xC(1:N);
xN = xN(1:N);
xM = xM(1:N);

% =========================================================
CREATE TIME VECTOR
% =========================================================

t = (0:N-1)/fs;

% =========================================================
COMPUTE FFT (DTFT APPROXIMATION)
% =========================================================

NFFT = 2^nextpow2(N);

XC = fft(xC,NFFT);
XN = fft(xN,NFFT);
XM = fft(xM,NFFT);

K = NFFT/2;

f = (0:K-1)*(fs/NFFT);

% =========================================================
MAGNITUDE SPECTRUM
% =========================================================

magClean  = abs(XC(1:K));
magNoise  = abs(XN(1:K));
magMerged = abs(XM(1:K));

% =========================================================
NORMALIZE SPECTRUM
% =========================================================

magClean = magClean ./ max(magClean);
magNoise = magNoise ./ max(magNoise);

% =========================================================
DETECT CLEAN SIGNAL FREQUENCY RANGE
% =========================================================

thresholdClean = 0.10;

idxClean = find(magClean > thresholdClean);

cleanFreqRange = f(idxClean);

Remove DC frequencies
cleanFreqRange = cleanFreqRange(cleanFreqRange > 20);

cleanMinFreq = min(cleanFreqRange);
cleanMaxFreq = max(cleanFreqRange);

% =========================================================
DETECT NOISE SIGNAL FREQUENCY RANGE
% =========================================================

thresholdNoise = 0.10;

idxNoise = find(magNoise > thresholdNoise);

noiseFreqRange = f(idxNoise);

noiseFreqRange = noiseFreqRange(noiseFreqRange > 20);

noiseMinFreq = min(noiseFreqRange);
noiseMaxFreq = max(noiseFreqRange);

% =========================================================
PRINT DETECTED FREQUENCY RANGES
% =========================================================

fprintf('\n========================================\n');
fprintf('DETECTED FREQUENCY RANGES\n');
fprintf('========================================\n');

fprintf('\nClean Signal Frequency Range:\n');
fprintf('Minimum Frequency = %.2f Hz\n',cleanMinFreq);
fprintf('Maximum Frequency = %.2f Hz\n',cleanMaxFreq);

fprintf('\nNoise Signal Frequency Range:\n');
fprintf('Minimum Frequency = %.2f Hz\n',noiseMinFreq);
fprintf('Maximum Frequency = %.2f Hz\n',noiseMaxFreq);

% =========================================================
SAFETY LIMITS FOR FIR FILTER
% =========================================================

lowCutoff = max(50, cleanMinFreq);

highCutoff = min(cleanMaxFreq, fs/2 - 100);

if highCutoff <= lowCutoff

    lowCutoff = 300;
    highCutoff = 3400;

end

% =========================================================
FIR FILTER DESIGN
% =========================================================

filterOrder = 200;

b = fir1(filterOrder,...
         [lowCutoff highCutoff]/(fs/2),...
         'bandpass',...
         hamming(filterOrder+1));

% =========================================================
PRINT FILTER PARAMETERS
% =========================================================

fprintf('\n========================================\n');
fprintf('FIR FILTER PARAMETERS\n');
fprintf('========================================\n');

fprintf('Filter Type  : FIR Bandpass\n');
fprintf('Filter Order : %d\n',filterOrder);
fprintf('Window Type  : Hamming\n');
fprintf('Low Cutoff   : %.2f Hz\n',lowCutoff);
fprintf('High Cutoff  : %.2f Hz\n',highCutoff);

% =========================================================
APPLY FIR FILTER
% =========================================================

yOut = filtfilt(b,1,xM);

% =========================================================
NORMALIZE OUTPUT SIGNAL
% =========================================================

yOut = yOut ./ (max(abs(yOut)) + 1e-9);

% =========================================================
SAVE OUTPUT TO DESKTOP
% =========================================================

desktopPath = fullfile(getenv('HOME'),...
                      'Desktop',...
                      'final_output.wav');

audiowrite(desktopPath,yOut,fs);

fprintf('\n========================================\n');
fprintf('OUTPUT SAVED SUCCESSFULLY\n');
fprintf('========================================\n');

fprintf('Saved to:\n%s\n',desktopPath);

% =========================================================
FFT OF FILTERED OUTPUT
% =========================================================

Y = fft(yOut,NFFT);

magOutput = abs(Y(1:K));

% =========================================================
COLORS
% =========================================================

bgColor = [0 0 0];

cleanColor = [0 0.8 1];

noiseColor = [1 0.3 0.3];

mergeColor = [1 1 0];

outputColor = [0 1 0];

textColor = [1 1 1];

% =========================================================
FIGURE 1
FIR FILTER FREQUENCY RESPONSE
% =========================================================

figure('Name','Fig 1',...
       'Color',bgColor);

freqz(b,1,4096,fs);

ax = gca;

ax.Color = bgColor;
ax.XColor = textColor;
ax.YColor = textColor;

title('Fig 1: FIR Filter Frequency Response',...
      'Color',textColor);

lines = findall(gcf,'Type','line');

for i = 1:length(lines)

    set(lines(i),...
        'Color',outputColor,...
        'LineWidth',1.5);

end

% =========================================================
FIGURE 2
TIME DOMAIN SIGNALS
% =========================================================

figure('Name','Fig 2',...
       'Color',bgColor);

subplot(3,1,1);

plot(t,xC,...
    'Color',cleanColor,...
    'LineWidth',1);

grid on;

title('Clean Signal',...
      'Color',textColor);

xlabel('Time (s)','Color',textColor);

ylabel('Amplitude','Color',textColor);

xlim([0 2]);

set(gca,...
    'Color',bgColor,...
    'XColor',textColor,...
    'YColor',textColor);

subplot(3,1,2);

plot(t,xN,...
    'Color',noiseColor,...
    'LineWidth',1);

grid on;

title('Noise Signal',...
      'Color',textColor);

xlabel('Time (s)','Color',textColor);

ylabel('Amplitude','Color',textColor);

xlim([0 2]);

set(gca,...
    'Color',bgColor,...
    'XColor',textColor,...
    'YColor',textColor);

subplot(3,1,3);

plot(t,xM,...
    'Color',mergeColor,...
    'LineWidth',1);

grid on;

title('Merged Signal',...
      'Color',textColor);

xlabel('Time (s)','Color',textColor);

ylabel('Amplitude','Color',textColor);

xlim([0 2]);

set(gca,...
    'Color',bgColor,...
    'XColor',textColor,...
    'YColor',textColor);

sgtitle('Fig 2: Time Domain Signals',...
        'Color',textColor);

% =========================================================
FIGURE 3
TIME DOMAIN COMPARISON
% =========================================================

figure('Name','Fig 3',...
       'Color',bgColor);

subplot(2,1,1);

plot(t,xM,...
    'Color',mergeColor,...
    'LineWidth',1);

grid on;

title('Before Filtering',...
      'Color',textColor);

xlabel('Time (s)','Color',textColor);

ylabel('Amplitude','Color',textColor);

xlim([0 2]);

set(gca,...
    'Color',bgColor,...
    'XColor',textColor,...
    'YColor',textColor);

subplot(2,1,2);

plot(t,yOut,...
    'Color',outputColor,...
    'LineWidth',1);

grid on;

title('After FIR Filtering',...
      'Color',textColor);

xlabel('Time (s)','Color',textColor);

ylabel('Amplitude','Color',textColor);

xlim([0 2]);

set(gca,...
    'Color',bgColor,...
    'XColor',textColor,...
    'YColor',textColor);

sgtitle('Fig 3: Time Domain Comparison',...
        'Color',textColor);

% =========================================================
FIGURE 4
FOURIER TRANSFORM OF ALL SIGNALS
% =========================================================

figure('Name','Fig 4',...
       'Color',bgColor);

subplot(3,1,1);

plot(f,magClean,...
    'Color',cleanColor,...
    'LineWidth',1);

grid on;

title('FT of Clean Signal',...
      'Color',textColor);

xlabel('Frequency (Hz)','Color',textColor);

ylabel('|X(f)|','Color',textColor);

xlim([0 8000]);

set(gca,...
    'Color',bgColor,...
    'XColor',textColor,...
    'YColor',textColor);

subplot(3,1,2);

plot(f,magNoise,...
    'Color',noiseColor,...
    'LineWidth',1);

grid on;

title('FT of Noise Signal',...
      'Color',textColor);

xlabel('Frequency (Hz)','Color',textColor);

ylabel('|X(f)|','Color',textColor);

xlim([0 8000]);

set(gca,...
    'Color',bgColor,...
    'XColor',textColor,...
    'YColor',textColor);

subplot(3,1,3);

plot(f,magMerged,...
    'Color',mergeColor,...
    'LineWidth',1);

grid on;

title('FT of Merged Signal',...
      'Color',textColor);

xlabel('Frequency (Hz)','Color',textColor);

ylabel('|X(f)|','Color',textColor);

xlim([0 8000]);

set(gca,...
    'Color',bgColor,...
    'XColor',textColor,...
    'YColor',textColor);

sgtitle('Fig 4: Fourier Transform Analysis',...
        'Color',textColor);

% =========================================================
FIGURE 5
FT BEFORE VS AFTER FILTERING
% =========================================================

figure('Name','Fig 5',...
       'Color',bgColor);

subplot(2,1,1);

plot(f,magMerged,...
    'Color',mergeColor,...
    'LineWidth',1);

grid on;

title('Before Filtering',...
      'Color',textColor);

xlabel('Frequency (Hz)','Color',textColor);

ylabel('|X(f)|','Color',textColor);

xlim([0 8000]);

set(gca,...
    'Color',bgColor,...
    'XColor',textColor,...
    'YColor',textColor);

subplot(2,1,2);

plot(f,magOutput,...
    'Color',outputColor,...
    'LineWidth',1);

grid on;

title('After FIR Filtering',...
      'Color',textColor);

xlabel('Frequency (Hz)','Color',textColor);

ylabel('|Y(f)|','Color',textColor);

xlim([0 8000]);

set(gca,...
    'Color',bgColor,...
    'XColor',textColor,...
    'YColor',textColor);

sgtitle('Fig 5: FT Comparison',...
        'Color',textColor);

fprintf('\n========================================\n');
fprintf('PROJECT COMPLETED SUCCESSFULLY\n');
fprintf('========================================\n');

end