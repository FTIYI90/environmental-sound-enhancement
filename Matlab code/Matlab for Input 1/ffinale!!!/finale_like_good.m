function finale_like_good()
 %% Same method as: good result/finale.m  (Adaptive FIR NLMS + optional bandpass)
 clear; close all; clc;

 audioDir = '/Users/fahado/Desktop/Signals lab project /Wav files/manuall mix wav/Final_proj_isa';

 % (Change these 3 if you want)
 fVoice  = fullfile(audioDir,'clean_voice_1_female_speech_woman_speaking__-4c9EgbBqro_000030.wav'); % clean (for plots)
 fRain   = fullfile(audioDir,'rain2.wav');        % noise reference
 fMerged = fullfile(audioDir,'final_merged.wav'); % merged
 outFile = fullfile(audioDir,'final_output.wav'); % output

 assert(isfile(fVoice) && isfile(fRain) && isfile(fMerged), 'One or more files not found.');

 % --- Read (force mono) ---
 [xV, fsV] = audioread(fVoice);  xV = mean(xV,2);
 [xR, fsR] = audioread(fRain);   xR = mean(xR,2);
 [xM, fsM] = audioread(fMerged); xM = mean(xM,2);

 % --- Resample to a common Fs ---
 fs0 = 44100;
 if fsV ~= fs0, xV = resample(xV, fs0, fsV); end
 if fsR ~= fs0, xR = resample(xR, fs0, fsR); end
 if fsM ~= fs0, xM = resample(xM, fs0, fsM); end

 % --- Length align (use common overlap) ---
 N = min([numel(xV), numel(xR), numel(xM)]);
 xV = xV(1:N); xR = xR(1:N); xM = xM(1:N);

 %% Frequency-domain plots + "needed frequencies" (top peaks)
 figure('Name','Frequency domain (single-sided magnitude)');
 tiledlayout(3,1,'Padding','compact','TileSpacing','compact');
 plotSpectrumAndPeaks(xV, fs0, 'Voice (clean)');
 plotSpectrumAndPeaks(xR, fs0, 'Rain (noise reference)');
 plotSpectrumAndPeaks(xM, fs0, 'Merged (voice + rain)');

 %% FIR filter approach to remove rain: Adaptive Noise Cancellation (LMS/NLMS)
 L  = 256;      % FIR length (try 128..1024)
 mu = 0.05;     % step size (try 0.01..0.2). Smaller = safer/slower.
 useDSP = exist('dsp.LMSFilter','class') == 8;

 if useDSP
     lms = dsp.LMSFilter('Length',L,'StepSize',mu,'Method','Normalized LMS');
     [~, eClean] = lms(xR, xM);
 else
     w = zeros(L,1);
     xbuf = zeros(L,1);
     eClean = zeros(N,1);
     eps0 = 1e-6;

     for n = 1:N
         xbuf = [xR(n); xbuf(1:end-1)];
         yHat = w.' * xbuf;
         eClean(n) = xM(n) - yHat;
         w = w + (mu/((xbuf.'*xbuf) + eps0)) * xbuf * eClean(n);
     end
 end

 % Optional: bandpass to keep "speech band"
 bpOrd = 400;
 bBP = fir1(bpOrd, [300 3400]/(fs0/2), 'bandpass', hamming(bpOrd+1));
 xRec = filtfilt(bBP, 1, eClean);

 % Normalize + save
 xRec = xRec / (max(abs(xRec)) + 1e-9) * 0.98;
 audiowrite(outFile, xRec, fs0);
 fprintf('Saved recovered signal: %s\n', outFile);

 %% Compare spectra (before/after)
 figure('Name','Spectrum comparison');
 tiledlayout(2,1,'Padding','compact','TileSpacing','compact');
 nexttile; plotSpectrumOnly(xM, fs0, 'Merged (before)');
 nexttile; plotSpectrumOnly(xRec, fs0, 'Recovered (after ANC + bandpass)');

 end

 %% ---- Local helper functions (same as finale.m) ----
 function plotSpectrumAndPeaks(x, fs, ttl)
 nexttile;
 [f, magDB] = spectrumDB(x, fs);
 plot(f, magDB, 'LineWidth', 1); grid on;
 xlim([0, 8000]); xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
 title(ttl);

 inBand = f >= 0 & f <= 8000;
 f2 = f(inBand); m2 = magDB(inBand);

 if exist('findpeaks','file') == 2
     [pks, locs] = findpeaks(m2, f2, 'MinPeakDistance',80, 'MinPeakProminence',6);
     [~, idx] = sort(pks, 'descend');
     idx = idx(1:min(8,numel(idx)));
     fprintf('\n%s - top peaks (Hz):\n', ttl);
     fprintf('  %7.1f Hz  (%5.1f dB)\n', [locs(idx) pks(idx)].');
 end
 end

 function plotSpectrumOnly(x, fs, ttl)
 [f, magDB] = spectrumDB(x, fs);
 plot(f, magDB, 'LineWidth', 1); grid on;
 xlim([0, 8000]); xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
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