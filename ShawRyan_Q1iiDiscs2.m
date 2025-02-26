% Median Filtering of Discs4

clear variables;

% Load Discs data
discsData = load('Discs.mat');

% Load original discs image
discs1 = discsData.Discs1;

discs1Mean = mean(double(discs1(:)));
discs1SD = mean(std(double(discs1(:))));

% Load noisy discs image
discs2 = discsData.Discs2;

discs2Mean = mean(double(discs2(:)));
discs2SD = mean(std(double(discs2(:))));

% Create figure to display results
figDisc2Restoration = figure('Name','Discs2 Restoration','NumberTitle','off','WindowState', 'maximized');
figure(figDisc2Restoration);

% Display the Discs1 image 
subplot(2,4,1), imshow(discs1);
title('Discs1')

% Display the noisy Discs3 image
subplot(2,4,2), imshow(discs2);
title('Discs2')

% Apply median filter to image as this is more effective than convolution
% for preserving edges.

% Filter the noisy image using 3-by-3 neighbourhood
medianFilterImage1 = medfilt2(discs2);

medianFilterImage1Mean = mean(double(medianFilterImage1(:)));
medianFilterImage1SD = mean(std(double(medianFilterImage1(:))));

% Display the 3-by-3 filtered image
subplot(2,4,3), imshow(medianFilterImage1);
title('3-by-3 neighbourhood')

% Increase size of neighbourhood used to 6-by-6 - noise is still present
medianFilterImage2 = medfilt2(discs2, [6 6]);

medianFilterImage2Mean = mean(double(medianFilterImage2(:)));
medianFilterImage2SD = mean(std(double(medianFilterImage2(:))));

% Display the 6-by-6 filtered image
subplot(2,4,4), imshow(medianFilterImage2);
title('6-by-6 neighbourhood')

% Increase size of neighbourhood used to 9-by-9 - noise is still present
medianFilterImage3 = medfilt2(discs2, [9 9]);

medianFilterImage3Mean = mean(double(medianFilterImage3(:)));
medianFilterImage3SD = mean(std(double(medianFilterImage3(:))));

% Display the 9-by-9 filtered image
subplot(2,4,5), imshow(medianFilterImage3);
title('9-by-9 neighbourhood')

% Noise has been removed from image
% Add zeros image padding - border around image present
medianFilterImage4 = medfilt2(discs2, [9 9], "zeros");

medianFilterImage4Mean = mean(double(medianFilterImage4(:)));
medianFilterImage4SD = mean(std(double(medianFilterImage4(:))));

% Display the 9-by-9 filtered & zeros padding image
subplot(2,4,6), imshow(medianFilterImage4);
title('9-by-9 neighbourhood & zeros padding')

% Add indexed image padding - border around image still present
medianFilterImage5 = medfilt2(discs2, [9 9], "indexed");

medianFilterImage5Mean = mean(double(medianFilterImage5(:)));
medianFilterImage5SD = mean(std(double(medianFilterImage5(:))));

% Display the 9-by-9 filtered & indexed padding image
subplot(2,4,7), imshow(medianFilterImage5);
title('9-by-9 neighbourhood & indexed padding')

% Add symmetric image padding - border around image still present
medianFilterImage6 = medfilt2(discs2, [9 9], "symmetric");

medianFilterImage6Mean = mean(double(medianFilterImage6(:)));
medianFilterImage6SD = mean(std(double(medianFilterImage6(:))));

% Display the 9-by-9 filtered & symmetric padding image
subplot(2,4,8), imshow(medianFilterImage6);
title('9-by-9 neighbourhood & symmetric padding')

% Noise has now been removed and border no longer exsists

% Print out means / SDs
disp(['Original Mean: ', num2str(discs1Mean), ' Original SD: ', num2str(discs1SD)]);
disp(['Discs 2 Mean: ', num2str(discs2Mean), ' Discs 2 SD: ', num2str(discs2SD)]); 
disp(['3-by-3 neighbourhood Mean: ', num2str(medianFilterImage1Mean), ' 3-by-3 neighbourhood SD: ', num2str(medianFilterImage1SD)]);
disp(['6-by-6 neighbourhood Mean: ', num2str(medianFilterImage2Mean), ' 6-by-6 neighbourhood SD: ', num2str(medianFilterImage2SD)]);
disp(['9-by-9 neighbourhood Mean: ', num2str(medianFilterImage3Mean), ' 9-by-9 neighbourhood SD: ', num2str(medianFilterImage3SD)]);
disp(['9-by-9 neighbourhood & zeros padding Mean: ', num2str(medianFilterImage4Mean), ' 9-by-9 neighbourhood & zeros padding SD: ', num2str(medianFilterImage4SD)]);
disp(['9-by-9 neighbourhood & indexed padding Mean: ', num2str(medianFilterImage5Mean), ' 9-by-9 neighbourhood & indexed padding SD: ', num2str(medianFilterImage5SD)]);
disp(['9-by-9 neighbourhood & symmetric padding Mean: ', num2str(medianFilterImage6Mean), ' 9-by-9 neighbourhood & symmetric padding SD: ', num2str(medianFilterImage6SD)]);