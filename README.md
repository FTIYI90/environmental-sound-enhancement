# Environmental Sound Enhancement for Recognition Systems

## 📋 Project Overview

This project implements a **Finite Impulse Response (FIR) bandpass filter** for environmental sound enhancement and noise removal. The system is designed to extract clean speech signals from noisy environments by filtering out frequency components outside the speech range (300-3400 Hz).

### Key Objectives
- Remove environmental noise (e.g., rain, background sounds) from audio signals
- Enhance speech clarity and recognition in noisy environments
- Implement digital signal processing techniques in both software and hardware
- Analyze signal characteristics in time and frequency domains

---

## 🎯 Technical Approach

### Signal Processing Pipeline

1. **Input Signal Analysis**: Read and analyze original WAV files in the time domain
2. **Frequency Domain Analysis**: Apply DTFT approximation using FFT for spectral analysis
3. **Noise Detection**: Identify noise frequency components in the signal
4. **FIR Filter Design**: Design a bandpass filter optimized for the speech frequency range
5. **Filtering**: Apply FIR bandpass filter to remove out-of-band noise
6. **Output Comparison**: Compare before/after results using spectrograms and frequency plots

### Core Equations

**FIR Filter Equation:**
```
y[n] = Σ(b_k * x[n-k])
```

**DTFT Equation:**
```
X(e^jw) = Σ(x[n] * e^(-jwn))
```

**Target Speech Frequency Range:** 300 Hz → 3400 Hz

---

## 📁 Project Structure

```
Final Working Demo/
├── README.md                                    # This file
├── finale_project_with_plots.m                 # Main Matlab implementation
├── Project3_Concise_Report_ELEC353.pdf         # Detailed project report
├── Project-3-Environmental-Sound-Enhancement...# Presentation slides
│
├── Matlab code/
│   └── Matlab for Input 1/
│       ├── clean_voice_*.wav                   # Clean speech recordings
│       ├── rain2.wav                           # Noise samples
│       ├── final_merged.wav                    # Merged noisy signal
│       └── final_output.wav                    # Filtered output
│
├── C++ code/
│   ├── code_1.ino                              # Arduino implementation
│   ├── code_2.ini                              # Configuration file
│   └── code_2/                                 # Additional C++ modules
│
├── input_data_1/                               # Test dataset 1
├── input_data_2/                               # Test dataset 2
│
├── Pictures/                                   # Analysis results and plots
│   ├── Time domain (first 2 seconds).png       # Time-domain analysis
│   ├── Frequency domain (single-sided magnitude).png
│   ├── Bandpass Frequency Response |H(f)|.png # Filter response
│   ├── Before vs After (spectrogram).png       # Quality improvement
│   ├── Spectrum comparison.png
│   ├── Spectrograms.png
│   ├── GREEN_ON_HARDWARE.png                   # Hardware execution (success)
│   ├── RED_ON_HARDWARE.png                     # Hardware execution (indicator)
│   └── SD-CARD_CONNECTION.jpeg                 # Hardware setup
│
└── relevant signals lab material/              # Reference materials and notes
```

---

## 🛠️ Implementation Details

### Matlab Implementation

**Main File:** `finale_project_with_plots.m`

Features:
- Automated audio file processing
- Time-domain signal visualization
- FFT-based frequency analysis
- FIR filter design and application
- Comprehensive comparison plots (spectrograms, magnitude spectra)
- Real-time audio playback for verification

**Usage:**
```matlab
% Run the main project function
finale_project_with_plots()
```

### C++ / Arduino Implementation

**Files:**
- `code_1.ino` - Primary Arduino sketch for real-time filtering
- `code_2.ini` - Configuration parameters
- `code_2/` - Supporting C++ modules

**Hardware Features:**
- Real-time audio processing on microcontroller
- SD card integration for data logging
- Green/Red indicator LEDs for status monitoring
- Configurable filter parameters via SD card

---

## 📊 Results & Analysis

### Signal Characteristics

The project includes detailed analysis of:

| Aspect | Details |
|--------|---------|
| **Time Domain** | First 2 seconds of signal waveforms |
| **Frequency Domain** | Single-sided magnitude spectrum |
| **Filter Response** | Bandpass frequency response \|H(f)\| |
| **Quality Improvement** | Before/after spectrograms showing noise reduction |
| **Spectrum Comparison** | Side-by-side frequency comparison |

### Key Results

- ✅ Successful noise removal from speech signals
- ✅ Maintained speech clarity in the 300-3400 Hz range
- ✅ Effective environmental noise suppression
- ✅ Real-time processing capability on embedded hardware
- ✅ Verified performance on multiple test datasets

---

## 🚀 Getting Started

### Prerequisites

**For Matlab:**
- MATLAB R2020b or later
- Signal Processing Toolbox
- Audio processing capabilities

**For Arduino/C++:**
- Arduino IDE
- PlatformIO (optional, for enhanced development)
- SD card module (optional, for data logging)

### Running the Matlab Implementation

1. Navigate to the project directory
2. Open `finale_project_with_plots.m` in MATLAB
3. Ensure input audio files are in the correct paths (specified in the script)
4. Run the function:
   ```matlab
   finale_project_with_plots()
   ```
5. Review generated plots for signal analysis and filter effectiveness

### Deploying to Arduino

1. Open Arduino IDE
2. Load `C++ code/code_1.ino`
3. Configure SD card paths and filter parameters in `code_2.ini`
4. Upload to your Arduino board
5. Monitor output via Serial Monitor or check LED indicators

---

## 📈 Filter Specifications

### Bandpass Filter Parameters

- **Type:** FIR (Finite Impulse Response)
- **Passband:** 300 Hz - 3400 Hz
- **Stopband:** Below 300 Hz and above 3400 Hz
- **Design Method:** Window-based (Hamming/Hann window)
- **Order:** Optimized for real-time performance

### Performance Metrics

- Signal-to-Noise Ratio (SNR) improvement
- Total Harmonic Distortion (THD) reduction
- Frequency response flatness in passband
- Transition band characteristics

---

## 📝 Key Files Reference

| File | Purpose |
|------|---------|
| `finale_project_with_plots.m` | Main signal processing algorithm |
| `Project3_Concise_Report_ELEC353.pdf` | Comprehensive project documentation |
| `Project-3-Environmental-Sound-Enhancement...pptx` | Presentation and results summary |
| `code_1.ino` | Embedded real-time implementation |

---

## 👥 Course Information

- **University:** Qatar University
- **Course:** ELEC353 - Signals & Filtering Laboratory
- **Semester:** Spring 2026
- **Lab:** Signals Filtering Project

---

## 📚 References & Materials

The `relevant signals lab material/` directory contains:
- Course notes and lecture materials
- Reference implementations
- Signal processing theory
- DSP fundamentals

---

## 🎓 Learning Outcomes

Upon completing this project, you will understand:

✓ FIR filter design and implementation  
✓ Frequency domain analysis using FFT  
✓ Real-time digital signal processing  
✓ Embedded systems integration  
✓ Audio signal enhancement techniques  
✓ Hardware/software co-design  

---

## 📧 Notes

- All MATLAB code includes audio file path specifications - adjust these based on your directory structure
- Arduino implementation includes SD card write operations - ensure proper hardware setup
- Test datasets (input_data_1, input_data_2) provide validation for the filtering algorithm
- Generated audio files (`final_merged.wav`, `final_output.wav`) can be compared for quality assessment

---

## 📄 License

This project is part of the Qatar University ELEC353 course curriculum.

---

**Last Updated:** Spring 2026  
**Status:** Complete and Fully Functional ✓
