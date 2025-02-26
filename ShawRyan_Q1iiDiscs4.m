% Notch Filtering of Discs4
clear variables;

% Load Discs data
discsData = load('Discs.mat');

% Load original discs image
discs1 = discsData.Discs1;

discs1Mean = mean(double(discs1(:)));
discs1SD = mean(std(double(discs1(:))));

% Load noisy discs image
discs4 = discsData.Discs4;

discs4Mean = mean(double(discs4(:)));
discs4SD = mean(std(double(discs4(:))));

% Create figure to display results
figDisc4Restoration = figure('Name','Discs4 Restoration','NumberTitle','off','WindowState', 'maximized');
figure(figDisc4Restoration);

% Display the Discs1 image
subplot(2, 3, 1), imshow(discs1, [0 255]);
title('Discs1')

% Calculate fourier transform of Discs1 image
ftDiscs1 = fft2(double(discs1)); 

% Shift origin to centre of image
ftDiscs1 = fftshift(ftDiscs1); 

% Calculate magnitude of FT
ftMagDiscs1 = abs(ftDiscs1);    

% Calculate the fourier spectrum
ftSpectrumDiscs1 = log(ftMagDiscs1);  

% Display the fourier spectrum of Discs1
subplot(2, 3, 2), imshow(uint8(rescale(ftSpectrumDiscs1, 0, 255)));
axis on;
title('Discs1 Fourier Spectrum')

% Display the noisy Discs4 image
subplot(2, 3, 3), imshow(discs4, [0 255]);
title('Discs4')

% Calculate fourier transform of noisy Discs4 image
ftDiscs4 = fft2(double(discs4)); 

% Shift origin to centre of image
ftDiscs4 = fftshift(ftDiscs4); 

% Calculate magnitude of FT
ftMagDiscs4 = abs(ftDiscs4);    

% Calculate the fourier spectrum
ftSpectrumDiscs4 = log(ftMagDiscs4);  

% Display the fourier spectrum of Discs4
subplot(2, 3, 4), imshow(uint8(rescale(ftSpectrumDiscs4, 0, 255)));
axis on;
zoom(5)
title('Discs4 Fourier Spectrum (zoomed on bright spots)')

% Set a threshold used for determining where bright spots appear on the
% ftSpectrum (14 comes from studying the ftSpectrum values)
ftThreshold = 14;

% Calculate where the ftSpectrum value is greater than the ftThreshold set
% above (This will determine where bright spots exist in the ftSpectrum)
ftBrightSpots = ftSpectrumDiscs4 > ftThreshold;

% ftBrightSpots matrix will is binary and will contain a 1 where a bright
% spot has been found (row 257, column 247 for example)

% Set all found bright spots to 0 excluding those in columns 252-262 to 
% ensure the center of the spectrum is not changed which will result in 
% the image being obscured (columns 252-262 comes from studying the image 
% of the ftSpectrum)
ftBrightSpots(: , 252:262) = 0;

% Filter the Discs4 fourier spectrum by setting values to 0 at
% corresponding positions to those in the found bright spots
ftDiscs4(ftBrightSpots) = 0;

% Recalculate magnitude of FT
ftMagDiscs4 = abs(ftDiscs4);    

% Recalculate the fourier spectrum
ftSpectrumDiscs4 = log(ftMagDiscs4);

% Calculate the max and min values of the new fourier spectrum (this is
% needed to ensure the image of the spectrum is displayed properly)
ftSpectrumMax = max(max(ftSpectrumDiscs4));
ftSpectrumMin = min(min(ftSpectrumDiscs4));

% Display the new fourier spectrum with the bright spots blocked out
subplot(2, 3, 5), imshow(ftSpectrumDiscs4, [ftSpectrumMin ftSpectrumMax]);
axis on;
zoom(5)
title('Discs4 Fourier Spectrum (zoomed on blocked bright spots)')

% Invert ftDiscs4 for displying the new restored image
ftDiscs4 = ifftshift(ftDiscs4);
ftDiscs4Inv = ifft2(ftDiscs4);
restoredftDiscs4 = uint8(rescale(abs(ftDiscs4Inv), 0, 255));

restoredftDiscs4Mean = mean(double(restoredftDiscs4(:)));
restoredftDiscs4SD = mean(std(double(restoredftDiscs4(:))));

% Display new restored Discs4 image
subplot(2, 3, 6), imshow(restoredftDiscs4);
title('Discs4 Restored')

% Print out means / SDs
disp(['Original Mean: ', num2str(discs1Mean), ' Original SD: ', num2str(discs1SD)]);
disp(['Discs 4 Mean: ', num2str(discs4Mean), ' Discs 4 SD: ', num2str(discs4SD)]); 
disp(['Discs4 Restored Mean: ', num2str(restoredftDiscs4Mean), ' Discs4 Restored SD: ', num2str(restoredftDiscs4SD)]);