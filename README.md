# Radar Target Generation and Detection Project

## Project Layout


![image](https://github.com/user-attachments/assets/94db9840-d547-4a65-a7eb-9b24cefb1152)

- Configure the FMCW waveform based on the system requirements.
- Define the range and velocity of target and simulate its displacement.
- For the same simulation loop process the transmit and receive signal to determine the beat signal
- Perform Range FFT on the received signal to determine the Range
- Towards the end, perform the CFAR processing on the output of 2nd FFT to display the target.

### 1. RADAR System Requirements
![image](https://github.com/user-attachments/assets/48662d5c-d640-40a9-9ec8-acbaa8c2977d)


```
% Radar Specifications
frequency = 77e9; % Frequency of operation = 77GHz
maxRange = 200; 
rangeResolution = 1;
maxVelocity = 100;

% Speed of light
c = 3e8; % speed of light = 3e8 m/s
```

### 2. Signal Propagation

![image](https://github.com/user-attachments/assets/0daef51b-ffe4-470e-8769-256a038d24a1)


Theory :

FMCW transmit and received signals are defined using wave equations, where 
α = Slope  of  the  signal. The Transmit Signal is given by:
<img width="250" alt="image" src="https://github.com/user-attachments/assets/2065ea4d-7e81-404c-b408-e74ed92fa3e5">

The received signal is the time delayed version of the Transmit Signal which is defined by (t−τ), where τ represents the delay time, which in radar processing is the trip time for the signal.

Rx=cos(2π(fc(t−τ) + (α(t−τ)2)/2) ))
