clear variables;

morseImageData = load('Morse.mat');

morseImage256 = morseImageData.Morse256;

minVal256Image = min(morseImage256(:));
maxVal256Image = max(morseImage256(:));
sum256Image = numel(morseImage256(:));

medianGreyLevel = median(morseImage256);

% Create figure to display new images
figGreyLevels = figure('Name','Morse Grey Level Images','NumberTitle','off','WindowState', 'maximized');
figure(figGreyLevels);

% Display original 256 image
subplot(3,4,1), imshow(morseImage256, [0 255]);
title('256 Image')

% Display original 256 image histogram
subplot(3,4,2), imhist(morseImage256);
title('256 Image Histogram')

% Will need a maximum of 7 bits for grey level reduction 
% (128 levels = 7 bits)
requiredBits = 7;

% Used for determining the position on the figure
displayOrder = 3;

% Execute loop until number of bits is 3 
% (8 levels = 3 bits)
while (requiredBits > 2)
    % Determine the grey level
    greyLevel = 2^requiredBits;
    % Determine the factor to compress the original 256 by
    compressionFactor = 256 / greyLevel;
    % Generate a new compressed image using quantization
    newImage = uint8(floor(double(morseImage256)/256 * greyLevel) * compressionFactor);
    % Display new image on figure
    subplot(3, 4, displayOrder), imshow(newImage, [0 255]);
    title([num2str(greyLevel),' Image'])
     % Add 1 to display position
    displayOrder = displayOrder + 1;
    % Display new image histogram
    subplot(3,4,displayOrder), imhist(newImage);
    title([num2str(greyLevel),' Histogram'])
    % Subtract 1 from number of bits to prepare for next grey level
    requiredBits = requiredBits - 1;
    % Add 1 to display position
    displayOrder = displayOrder + 1;
end