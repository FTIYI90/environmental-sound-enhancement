function finale_project_with_plots1234()
%% =========================================================
% ADAPTIVE FIR + PROFESSIONAL FILTER VISUALIZATION
%% =========================================================
clear; close all; clc;

%% =========================================================
% LOAD AND ENFORCE CLEAN SIGNAL RANGE (300 - 3400 Hz)
%% =========================================================
audioDir = '/Users/fahado/Desktop/Final Working Demo/Matlab code/Matlab for Input 1';
fClean = fullfile(audioDir, 'clean_voice_1_female_speech_woman_speaking__-4c9EgbBqro_000030.wav');

% Check if file exists to avoid errors
if ~exist(fClean, 'file')
    error('Audio file not found at: %s', fClean);
end

[xC_raw, fs] = audioread(fClean);
xC_raw = mean(xC_raw,2); % Convert to mono

% Define the specific Clean Signal Range
cleanMin = 300; 
cleanMax = 3400;

% Apply a Bandpass filter to ensure signal is strictly 300-3400Hz
% We use a high order (400) for a sharp cutoff
bpClean = fir1(400, [cleanMin cleanMax]/(fs/2), 'bandpass');
xC = filtfilt(bpClean, 1, xC_raw); 

N = length(xC);
t = (0:N-1)/fs;

%% =========================================================
% SYNTHETIC LOW-FREQUENCY NOISE (50–300 Hz)
%% =========================================================
noiseMinFreq = 50;
noiseMaxFreq = 300;
whiteNoise = randn(N,1);
bpNoise = fir1(300, [noiseMinFreq noiseMaxFreq]/(fs/2), ...
    'bandpass', hamming(301));
xN = filtfilt(bpNoise,1,whiteNoise);
xN = 0.3 * xN; % Scale noise amplitude

%% =========================================================
% MERGED SIGNAL
%% =========================================================
xM = xC + xN;
xM = xM ./ max(abs(xM)); % Normalize

%% =========================================================
% FFT ANALYSIS (PRE-FILTERING)
%% =========================================================
NFFT = 2^nextpow2(N);
K = NFFT/2;
f = (0:K-1)*(fs/NFFT);

XC = fft(xC,NFFT);
XN = fft(xN,NFFT);
magC = abs(XC(1:K)); magC = magC./max(magC);
magN = abs(XN(1:K)); magN = magN./max(magN);

%% =========================================================
% PRINT SIGNAL RANGES
%% =========================================================
fprintf('\n========================================\n');
fprintf('SIGNAL FREQUENCY ANALYSIS\n');
fprintf('========================================\n');
fprintf('Clean Signal Range : %.2f Hz – %.2f Hz\n', cleanMin, cleanMax);
fprintf('Noise Signal Range : %.2f Hz – %.2f Hz\n', noiseMinFreq, noiseMaxFreq);

%% =========================================================
% ================= HIGH-PASS FIR FILTER =================
%% =========================================================
% This filter targets the noise below 300Hz
M = 250;          % Filter order
fc = 350;         % Cutoff frequency (slightly above noise ceiling)
wc = 2*pi*fc/fs;
n = 0:M;
alpha = M/2;
hd = zeros(size(n));

for i = 1:length(n)
    k = n(i) - alpha;
    if k == 0
        hd(i) = 1 - (wc/pi);
    else
        hd(i) = -sin(wc*k)/(pi*k);
    end
end

w = hamming(M+1)';
h = hd .* w;

%% =========================================================
% FILTER PARAMETER PRINT
%% =========================================================
fprintf('\n========================================\n');
fprintf('FILTER PARAMETERS\n');
fprintf('========================================\n');
fprintf('Type       : High-Pass FIR (Windowed Sinc)\n');
fprintf('Order (M)  : %d\n', M);
fprintf('Cutoff     : %.2f Hz\n', fc);
fprintf('Window     : Hamming\n');

%% =========================================================
% FILTER APPLICATION
%% =========================================================
yOut = filtfilt(h,1,xM);
yOut = yOut ./ max(abs(yOut)); % Normalize output

%% =========================================================
% FFT OUTPUT ANALYSIS
%% =========================================================
XM = fft(xM,NFFT);
XY = fft(yOut,NFFT);
magM = abs(XM(1:K)); magM = magM./max(magM);
magY = abs(XY(1:K)); magY = magY./max(magY);

%% =========================================================
% VISUALIZATION
%% =========================================================

% FIGURE 1 - FILTER IMPULSE RESPONSE
figure('Name','Impulse Response');
stem(h,'filled');
grid on;
title('FIR High-Pass Impulse Response h[n]');
xlabel('n'); ylabel('Amplitude');

% FIGURE 2 - FREQUENCY RESPONSE
figure('Name','Frequency Response');
freqz(h,1,4096,fs);
hold on;
xline(fc,'--r','Cutoff','LineWidth',1.5);
title('High-Pass FIR Frequency Response');

% FIGURE 3 - TIME DOMAIN
figure('Name','Time Domain');
subplot(3,1,1);
plot(t,xC); grid on;
title('Clean Signal (300-3400 Hz)');
subplot(3,1,2);
plot(t,xN); grid on;
title('Noise (50–300 Hz)');
subplot(3,1,3);
plot(t,xM); grid on;
title('Merged Signal');

% FIGURE 4 - BEFORE VS AFTER
figure('Name','Before vs After');
subplot(2,1,1);
plot(t,xM); grid on;
title('Before Filtering');
subplot(2,1,2);
plot(t,yOut); grid on;
title('After Filtering (Noise Removed)');

% FIGURE 5 - FFT
figure('Name','FFT Comparison');
subplot(3,1,1);
plot(f,magC); grid on;
title('Clean FFT (Telephony Band 300-3400Hz)'); xlim([0 8000]);
subplot(3,1,2);
plot(f,magN); grid on;
title('Noise FFT (Low Freq 50-300Hz)'); xlim([0 8000]);
subplot(3,1,3);
plot(f,magM); hold on;
plot(f,magY); grid on;
title('Merged vs Output FFT'); xlim([0 8000]);
legend('Before','After');

%% =========================================================
% SAVE OUTPUT
%% =========================================================
desktopPath = fullfile(getenv('HOME'), 'Desktop', 'final_output.wav');
audiowrite(desktopPath, yOut, fs);
fprintf('\nSaved Output: %s\n', desktopPath);
fprintf('PROJECT COMPLETED\n');

end