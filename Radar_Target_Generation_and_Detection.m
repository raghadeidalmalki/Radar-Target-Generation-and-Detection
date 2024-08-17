
clear all
clc;

% Radar Specifications
frequency = 77e9; % Frequency of operation = 77GHz
maxRange = 200; % Max Range = 200m
rangeResolution = 1; % Range Resolution = 1 m
maxVelocity = 100; % Max Velocity = 100 m/s

% Speed of light
c = 3e8; % speed of light = 3e8 m/s


% 1:
% define the target's initial position and velocity. Note : Velocity remains contant
initialPosition = 50; % Example: 50 meters
velocity = 30; % Example: 30 m/s (constant velocity)

% 2:
% FMCW Waveform Generation
%Design the FMCW waveform by giving the specs of each of its parameters.
% Calculate the Bandwidth (B), Chirp Time (Tchirp) and Slope (slope) of the FMCW
% chirp using the requirements above.

B = c / (2 * rangeResolution); % Bandwidth
Tchirp = 5.5 * (2 * maxRange / c); % Chirp time (factor of 5.5 is typical)
slope = B / Tchirp; % Slope of the FMCW chirp

%Operating carrier frequency of Radar 
fc= 77e9;                                       
%The number of chirps in one sequence. Its ideal to have 2^ value for the ease of running the FFT
%for Doppler Estimation. 
Nd=128;                
%The number of samples on each chirp. 
Nr=1024;              
% Timestamp for running the displacement scenario for every sample on each
% chirp
t=linspace(0,Nd*Tchirp,Nr*Nd); %total time for samples

%Creating the vectors for Tx, Rx and Mix based on the total samples input.
Tx=zeros(1,length(t)); %transmitted signal
Rx=zeros(1,length(t)); %received signal
Mix = zeros(1,length(t)); %beat signal

%Similar vectors for range_covered and time delay.
r_t=zeros(1,length(t));
td=zeros(1,length(t));


% Signal generation and Moving Target simulation
% Running the radar scenario over the time. 
% 3:
for i=1:length(t)         
    
    % 3.1:
    %For each time stamp update the Range of the Target for constant velocity.     
    % Update the Range of the Target for constant velocity
    r_t(i) = initialPosition + velocity * t(i);
    td(i) = 2 * r_t(i) / c; % Time delay

    % 3.2:
    %For each time sample we need update the transmitted and
    %received signal. 
    % Update the transmitted and received signal
    Tx(i) = cos(2 * pi * (frequency * t(i) + (slope * t(i)^2) / 2));
    Rx(i) = cos(2 * pi * (frequency * (t(i) - td(i)) + (slope * (t(i) - td(i))^2) / 2));



    
    % 3.3:
    %Now by mixing the Transmit and Receive generate the beat signal
    %This is done by element wise matrix multiplication of Transmit and
    %Receiver Signal
    % Generate the beat signal by mixing Tx and Rx
    Mix(i) = Tx(i) .* Rx(i);    
end

% RANGE MEASUREMENT
% 4:
%reshape the vector into Nr*Nd array. Nr and Nd here would also define the size of Range and Doppler FFT respectively.
Mix = reshape(Mix, [Nr, Nd]);

% 5:
%run the FFT on the beat signal along the range bins dimension (Nr) and normalize.
sig_fft1 = fft(Mix, Nr);
sig_fft1 = sig_fft1 / Nr;

% 6:
% Take the absolute value of FFT output
sig_fft1 = abs(sig_fft1);

% 7:
% Output of FFT is double sided signal, but we are interested in only one side of the spectrum.
% Hence we throw out half of the samples.


% Keep one side of the spectrum
sig_fft1 = sig_fft1(1:Nr/2);



%plotting the range
figure ('Name','Range from First FFT')
subplot(2,1,1)

% 8:
% plot FFT output 
plot(sig_fft1); 
axis ([0 200 0 1]);

% RANGE DOPPLER RESPONSE
% The 2D FFT implementation is already provided here. This will run a 2DFFT  on the mixed signal (beat signal) output and generate a range doppler map.You will implement CFAR on the generated RDM

% Range Doppler Map Generation.
% The output of the 2D FFT is an image that has reponse in the range and doppler FFT bins. So, it is important to convert the axis from bin sizes to range and doppler based on their Max values.

Mix=reshape(Mix,[Nr,Nd]);

% 2D FFT using the FFT size for both dimensions.
sig_fft2 = fft2(Mix,Nr,Nd);

% Taking just one side of signal from Range dimension.
sig_fft2 = sig_fft2(1:Nr/2,1:Nd);
sig_fft2 = fftshift (sig_fft2);
RDM = abs(sig_fft2);
RDM = 10*log10(RDM) ;

%use the surf function to plot the output of 2DFFT and to show axis in both
%dimensions
doppler_axis = linspace(-100,100,Nd);
range_axis = linspace(-200,200,Nr/2)*((Nr/2)/400);
figure,surf(doppler_axis,range_axis,RDM);

% CFAR implementation
%Slide Window through the complete Range Doppler Map
% 9:
%Select the number of Training Cells in both the dimensions.
% Number of Training Cells in both dimensions
Tr = 10; % Training cells for range
Td = 8; % Training cells for doppler

% 10:
%Select the number of Guard Cells in both dimensions around the Cell under 
%test (CUT) for accurate estimation

% Number of Guard Cells in both dimensions
Gr = 4; % Guard cells for range
Gd = 4; % Guard cells for doppler

% 11:
% offset the threshold by SNR value in dB
offset = 6;

% 12:
%Create a vector to store noise_level for each iteration on training cells
noise_level = zeros(1,1);

% 13:
%design a loop such that it slides the CUT across range doppler map by
%giving margins at the edges for Training and Guard Cells.
%For every iteration sum the signal level within all the training
%cells. To sum convert the value from logarithmic to linear using db2pow
%function. Average the summed values for all of the training
%cells used. After averaging convert it back to logarithimic using pow2db.
%Further add the offset to it to determine the threshold. Next, compare the
%signal under CUT with this threshold. If the CUT level > threshold assign
%it a value of 1, else equate it to 0.


   % Use RDM[x,y] as the matrix from the output of 2D FFT for implementing
   % CFAR
   
% 14:
% The process above will generate a thresholded block, which is smaller 
%than the Range Doppler Map as the CUT cannot be located at the edges of
%matrix. Hence,few cells will not be thresholded. To keep the map size same
% set those values to 0. 

% Initialize a thresholded RDM
thresholded_RDM = zeros(size(RDM));

% Loop through the RDM, excluding the edges for Training and Guard Cells
for i = Tr+Gr+1:(Nr/2)-(Gr+Tr)
    for j = Td+Gd+1:Nd-(Gd+Td)
        % Compute noise level
        noise_level = sum(db2pow(RDM(i-(Tr+Gr):i+(Tr+Gr), j-(Td+Gd):j+(Td+Gd))), 'all');
        noise_level = noise_level - sum(db2pow(RDM(i-Gr:i+Gr, j-Gd:j+Gd)), 'all');
        noise_level = noise_level / ((2*(Tr+Gr)+1)*(2*(Td+Gd)+1) - (2*Gr+1)*(2*Gd+1));

        % Convert noise level to dB and add offset
        threshold = pow2db(noise_level) + offset;

        % Compare the signal under CUT with the threshold
        if RDM(i,j) > threshold
            thresholded_RDM(i,j) = 1;
        else
            thresholded_RDM(i,j) = 0;
        end
    end
end

% Set the edges of thresholded RDM to zero
thresholded_RDM(union(1:Tr+Gr, end-(Tr+Gr-1):end), :) = 0; 
thresholded_RDM(:, union(1:Td+Gd, end-(Td+Gd-1):end)) = 0;


% 15:
%display the CFAR output using the Surf function like we did for Range
%Doppler Response output.

% Display the CFAR output using the Surf function
figure, surf(doppler_axis, range_axis, thresholded_RDM);
colorbar;

figure,surf(doppler_axis,range_axis,'replace this with output');
colorbar;


 
 
