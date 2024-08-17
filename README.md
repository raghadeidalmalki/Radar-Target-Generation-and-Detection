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

<img width="188" alt="image" src="https://github.com/user-attachments/assets/2065ea4d-7e81-404c-b408-e74ed92fa3e5">


The received signal is the time delayed version of the Transmit Signal which is defined by (t−τ), where τ represents the delay time, which in radar processing is the trip time for the signal.
Replacing t with (t−τ) gives the Receive Signal:

<img width="240" alt="image" src="https://github.com/user-attachments/assets/a0d9d233-a229-41df-9d6b-85b33b74727c">


On mixing these two signals, we get the beat signal, which holds the values for both range as well as doppler. By implementing the 2D FFT on this beat signal, we can extract both Range and Doppler information

The beat signal can be calculated by multiplying the Transmit signal with Receive signal. This process in turn works as frequency subtraction. It is implemented by element by element multiplication of transmit and receive signal matrices.

Mixed or Beat Signal = (Tx.*Rx) 
The above operation gives:

<img width="240" alt="image" src="https://github.com/user-attachments/assets/f93de931-4738-4bc4-87cd-87d86846fb0b">



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
```

The for loop bellow simulates the behavior of an FMCW (Frequency Modulated Continuous Wave) radar system over time. It calculates the radar signals for each time step, considering a target moving with a constant velocity. By doing the following steps:
1. Iterating Over Time:
` for i = 1:length(t)`: The loop runs for each time step in the time vector t. The `length(t)` function returns the total number of time points, so the loop will execute that many times.

2. Updating the Target's Range:
- `r_t(i) = initialPosition + velocity * t(i);`:
The loop calculates the position of the target at each time step. The target's range `(r_t(i))` is updated by adding the distance it has traveled to its initial position. The distance traveled is the product of the target's constant velocity (velocity) and the current time `(t(i))`.
- `td(i) = 2 * r_t(i) / c;`:
The time delay `(td(i))` is computed based on the updated range. This represents the time it takes for the radar signal to travel to the target and back to the radar receiver. The factor of `2` accounts for the round trip, and `c` is the speed of light.

3. Generating the Transmitted and Received Signals:
- `Tx(i) = cos(2 * pi * (frequency * t(i) + (slope * t(i)^2) / 2));`:
This generates the transmitted signal `(Tx)` for the current time step. The signal is a cosine wave whose frequency changes over time according to the slope. This chirped signal is what the radar sends out.
- `Rx(i) = cos(2 * pi * (frequency * (t(i) - td(i)) + (slope * (t(i) - td(i))^2) / 2));`:
The received signal `(Rx)` is generated similarly, but it is delayed by `td(i)` due to the time it takes for the signal to travel to the target and back. This delay causes a frequency shift in the received signal compared to the transmitted signal.

4. Generating the Beat Signal:
`Mix(i) = Tx(i) .* Rx(i);` :
The beat signal `(Mix)` is generated by multiplying the transmitted `(Tx)` and received `(Rx)` signals element-wise. The beat signal contains information about the difference in frequency between the two signals, which is related to the range and velocity of the target. This signal is later used to extract information about the target's position and speed.





```ruby

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
### 3. FFT Operation 
