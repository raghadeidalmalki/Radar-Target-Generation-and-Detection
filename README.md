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

<img width="200" alt="image" src="https://github.com/user-attachments/assets/2065ea4d-7e81-404c-b408-e74ed92fa3e5">

The received signal is the time delayed version of the Transmit Signal which is defined by (t−τ), where τ represents the delay time, which in radar processing is the trip time for the signal.
Replacing t with (t−τ) gives the Receive Signal:

<img width="240" alt="image" src="https://github.com/user-attachments/assets/a0d9d233-a229-41df-9d6b-85b33b74727c">

```ruby
% FMCW Waveform Generation
B = c / (2 * rangeResolution); % Bandwidth
Tchirp = 5.5 * (2 * maxRange / c); % Chirp time (factor of 5.5 is typical)
slope = B / Tchirp; % Slope of the FMCW chirp
% Operating carrier frequency of Radar 
fc= 77e9;                                                 
% The number of chirps in one sequence. Its ideal to have 2^ value for the ease of running the FFT for Doppler Estimation. 
Nd=128;
% The number of samples on each chirp. 
Nr=1024;
% Timestamp for running the displacement scenario for every sample on each chirp
t=linspace(0,Nd*Tchirp,Nr*Nd); %total time for samples

% Creating the vectors for Tx, Rx and Mix based on the total samples input.
Tx=zeros(1,length(t)); %transmitted signal
Rx=zeros(1,length(t)); %received signal
Mix = zeros(1,length(t)); %beat signal

% Similar vectors for range_covered and time delay.
r_t=zeros(1,length(t));
td=zeros(1,length(t));


for i=1:length(t)         
    
    

    % For each time stamp update the Range of the Target for constant velocity. 
    r_t(i) = initialPosition + velocity * t(i);
    td(i) = 2 * r_t(i) / c; % Time delay

    % For each time sample we need update the transmitted and received signal. 
    Tx(i) = cos(2 * pi * (frequency * t(i) + (slope * t(i)^2) / 2));
    Rx(i) = cos(2 * pi * (frequency * (t(i) - td(i)) + (slope * (t(i) - td(i))^2) / 2));

    % Now by mixing the Transmit and Receive generate the beat signal
    % This is done by element wise matrix multiplication of Transmit and Receiver Signal
    % Generate the beat signal by mixing Tx and Rx
    Mix(i) = Tx(i) .* Rx(i);    
end
```
