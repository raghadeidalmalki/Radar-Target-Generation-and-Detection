# Radar Target Generation and Detection Project

## Project Layout


![image](https://github.com/user-attachments/assets/94db9840-d547-4a65-a7eb-9b24cefb1152)

- Configure the FMCW waveform based on the system requirements.
- Define the range and velocity of target and simulate its displacement.
- For the same simulation loop process the transmit and receive signal to determine the beat signal
- Perform Range FFT on the received signal to determine the Range
- Towards the end, perform the CFAR processing on the output of 2nd FFT to display the target.

### 1. RADAR System requirements
![image](https://github.com/user-attachments/assets/48662d5c-d640-40a9-9ec8-acbaa8c2977d)


```
% Radar Specifications
frequency = 77e9; % Frequency of operation = 77GHz
maxRange = 200; 
rangeResolution = 1;
maxVelocity = 100; 

```
