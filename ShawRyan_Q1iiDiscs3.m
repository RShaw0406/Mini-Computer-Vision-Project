% Widner Filtering of Discs4

clear variables;

% Load Discs data
discsData = load('Discs.mat');

% Load original discs image
discs1 = discsData.Discs1;

discs1Mean = mean(double(discs1(:)));
discs1SD = mean(std(double(discs1(:))));

% Load noisy discs image
discs3 = discsData.Discs3;

discs3Mean = mean(double(discs3(:)));
discs3SD = mean(std(double(discs3(:))));

% Create figure to display results
figDisc3Restoration = figure('Name','Discs3 Restoration','NumberTitle','off','WindowState', 'maximized');
figure(figDisc3Restoration);

% Display the Discs1 image
subplot(1,4,1), imshow(discs1);
title('Discs1')

% Display the noisy Discs3 image
subplot(1,4,2), imshow(discs3);
title('Discs3')

% Calculate the only the noise
imageNoise = double(discs3) - double(discs1);

% Calculate the variance of the noise
estimatedNoiseVariance = var(imageNoise(:));

% Calculate the noise-to-signal ratio
estimatedNoiseSignalPowerRatio =  estimatedNoiseVariance / var(double(discs1(:)));

% Fourier Transform of original image
ftDiscs1 = fft2(discs1);

% Fourier Transform of noisy image
ftDiscs3 = fft2(discs3);

% Estimate Fourier Transform for restored image
ftEstimate = ftDiscs3./ftDiscs1;

% Calculate Point Spread Function
PSF = ifftshift(ifft2(ftEstimate));

% Filter Image using Weiner algorithm with estimated noise
weinerFilterImage1 = deconvwnr(discs3, PSF, estimatedNoiseSignalPowerRatio);

weinerFilterImage1Mean = mean(double(weinerFilterImage1(:)));
weinerFilterImage1SD = mean(std(double(weinerFilterImage1(:))));

% Display the estimated noise filtered image
subplot(1,4,3), imshow(weinerFilterImage1);
title('Discs3 Restored: Estimated Noise')

% Filter Image using Weiner algorithm assuming no noise
weinerFilterImage2 = deconvwnr(discs3, PSF, 0);

weinerFilterImage2Mean = mean(double(weinerFilterImage2(:)));
weinerFilterImage2SD = mean(std(double(weinerFilterImage2(:))));

% Display the no noise filtered image
subplot(1,4,4), imshow(weinerFilterImage2);
title('Discs3 Restored: Assuming No Noise')

% Print out means / SDs
disp(['Original Mean: ', num2str(discs1Mean), ' Original SD: ', num2str(discs1SD)]);
disp(['Discs 3 Mean: ', num2str(discs3Mean), ' Discs 3 SD: ', num2str(discs3SD)]); 
disp(['Discs3 Restored: Estimated Noise Mean: ', num2str(weinerFilterImage1Mean), ' Discs3 Restored: Estimated Noise SD: ', num2str(weinerFilterImage1SD)]);
disp(['Discs3 Restored: No Noise Mean: ', num2str(weinerFilterImage2Mean), ' Discs3 Restored: Estimated Noise SD: ', num2str(weinerFilterImage2SD)]);