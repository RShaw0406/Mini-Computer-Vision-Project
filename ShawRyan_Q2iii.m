%%
clear variables;

%% Video3 experiment

% Retrieve the video file
Vid_Filename = 'Video1.mp4';

% Declare VideoReader
vReader1 = VideoReader(Vid_Filename);

% Get frameCount of vReader1 - needed for looping over frame below
frameCount = vReader1.NumFrames;

% Create array to store each video frame
videoFrames = {};

% Read each of the frames in the video
while hasFrame(vReader1)
    % Add each frame to the videoFrames array
    videoFrames{end+1} = im2single(readFrame(vReader1));
end

% Create backgroundFrameMode by getting mode values between columns 1-300 in
% the videoFrames array (This will create a background containing the 
% pixel values which appear most often meaning the static bag will be
% included in the background - this will be used when creating the 
% foreground mask below)
backgroundFrameMode = mode(cat(4, videoFrames{: , 1:end}), 4);

% Convert backgroundFrameMode to uint8
backgroundFrameMode = im2uint8(backgroundFrameMode);

% Get the backgroundFrame by selecting the first frame in the videoFrames
% array (This will be used in the background subtraction below)
backgroundFrame = videoFrames{1};

% Convert the backgroundFrame to unit8
backgroundFrame = im2uint8(backgroundFrame);

% Identify the number of rows and columns in backgroundFrame
[My,Nx,Sz]=size(backgroundFrame);

% Convert the backgroundFrame to grayscale so we have it in 2-D - used for
% working out backgroundDifference below
backgroundFrameGray = rgb2gray(backgroundFrame);

% Convert the backgroundFrameMode to grayscale so we have it in 2-D - used
% for working out backgroundDifferenceMode below
backgroundFrameGrayMode = rgb2gray(backgroundFrameMode);

% Define 8x8 averaging filter - needed for smoothing frames below
hs=8;
h_average=fspecial('average',[hs hs]);

% Smooth the backgroundFrameGray using convolution
backgroundFrameGray = conv2(backgroundFrameGray,h_average, 'same');

% Smooth the backgroundFrameGrayMode using convolution
backgroundFrameGrayMode = conv2(backgroundFrameGrayMode,h_average, 'same');

% Create figure for displaying results
figVid1 = figure('Name','Video1 Experiment','NumberTitle','off','WindowState', 'maximized');
figure(figVid1);

% Display the backgroundFrame on the figure
subplot(3,4,1), imshow(backgroundFrame);
title('BG Frame')

% Display the backgroundFrame on the figure
subplot(3,4,2), imshow(backgroundFrameMode);
title('Mode BG Frame')

% Declare threshold value for populating Background Difference Indicator
th=24;

% Define orevFrame - used for frame differencing below
prevFrame = [];

% Loop over each of the frames in video
for frame = 1 : frameCount

   if frame == 1
       % Set prevFrame to the current frame
       prevFrame = videoFrames{frame};
   else
       % Set prevFrame to the current frame - 1
       prevFrame = videoFrames{frame - 1};
   end
   
   % Background Difference Indicator - used to highlight where currentFrame
   % is different from backgroundFrame (Background will be represented by 0
   % and Foreground by 255)
   BGI=zeros(My,Nx);
  
   % Get the currentFrame from the videoFrames array using the index of the
   % currentFrame
   currentFrame = videoFrames{frame};

   % Display the currentFrame on the figure
   subplot(3,4,3), imshow(currentFrame);
   title(sprintf('Current Frame:%4d of %d', frame, frameCount));

   % Convert the currentFrame to unit8
   currentFrame = im2uint8(currentFrame);

   % Convert the currentFrame to grayscale so we have it in 2-D - used for
   % working out frameDifference below
   currentFrameGray = rgb2gray(currentFrame);

   % Smooth the currentFrameGray using convolution
   currentFrameGray = conv2(currentFrameGray,h_average, 'same');

   % Calculate the backgroundDifference by subtracting the backgroundFrameGray
   % from the currentFrameGray
   backgroundDifference = abs(currentFrameGray - backgroundFrameGray);

   % Set Background Difference Indicator to 255 where backgroundDifference is
   % greater than threshold value
   BGI(backgroundDifference>th)=255;

   % Convert Background Difference Indicator to unit8
   BGI=uint8(BGI);

   % Display the Background Difference Indicator
   subplot(3,4,4), imshow(BGI);
   title(sprintf('BGS:%4d of %d', frame, frameCount))

   % Calculate the backgroundDifference by subtracting the backgroundFrameGrayMode
   % from the currentFrameGray (This will create a frame without the static
   % bag being included as part of the foreground)
   backgroundDifferenceMode = abs(currentFrameGray - backgroundFrameGrayMode);

   % Background Difference Indicator Mode - used to highlight where currentFrame
   % is different from backgroundFrameMode (Background will be represented by 0
   % and Foreground by 255)
   BGIMODE=zeros(My,Nx);

   % Set Background Difference Indicator Mode to 255 where 
   % backgroundDifferenceMode is greater than threshold value
   BGIMODE(backgroundDifferenceMode>th)=255;

   % Convert Background Difference Indicator Mode to unit8
   BGIMODE=uint8(BGIMODE);

   % Define 17x17 averaging filter - needed for smoothing Background 
   % Difference Indicator Mode below
   hsMODE=17;
   h_averageMODE=fspecial('average',[hsMODE hsMODE]);

   % Smooth the Background Difference Indicator Mode using convolution
   % (This is needed to ensure that all pixels in the Background Difference
   % Indicator can be masked by the Background Difference Indicator Mode to
   % create a foreground mask below
   BGIMODE = conv2(BGIMODE,h_averageMODE, 'same');

   % Display the Background Difference Indicator Mode
   subplot(3,4,5), imshow(BGIMODE);
   title(sprintf('Mode BGS Smoothed:%4d of %d', frame, frameCount))

   % Foreground Mask - used to highlight currentFrame foreground 
   % (Background will be represented by 0 and Foreground by 255)
   FGM=zeros(My,Nx);

   % Set Foreground Mask to 255 where Background Difference Indicator Mode
   % is greater than 1
   FGM(BGIMODE>1)=255;

   % Set Foreground Mask to 255 where Background Difference Indicator is 
   % less than 1
   FGM(BGI<1)=0;

   % Convert Foreground Mask to unit8
   FGM=uint8(FGM);

   % Display the Foreground Mask Mode
   subplot(3,4,6), imshow(FGM);
   title(sprintf('FG Mask:%4d of %d', frame, frameCount))

   % Display the prevFrame
   subplot(3,4,7), imshow(prevFrame);
   title(sprintf('Prev Frame:%4d of %d', frame, frameCount))

   % Convert the prevFrame to unit8
   prevFrame = im2uint8(prevFrame);

   % Convert the prevFrame to grayscale so we have it in 2-D - used for
   % working out frameDifference below
   prevFrameGray = rgb2gray(prevFrame);

   % Smooth the currentFrameGray using convolution
   prevFrameGray = conv2(prevFrameGray,h_average, 'same');

   % Calculate the frameDifference by subtracting the prevFrameGray
   % from the currentFrameGray
   frameDifference = abs(currentFrameGray - prevFrameGray);

   % Frame Difference Indicator - used to highlight the difference 
   % between currentFrame and prevFrame (Background will be represented by 
   % 0 and difference by 255)
   FDI=zeros(My,Nx);

   % Set Frame Difference Indicator to 255 where frameDifference
   % is greater than 8
   FDI(frameDifference>8)=255;

   % Convert Frame Difference Indicator to unit8
   FDI=uint8(FDI);

   % Display the Frame Difference Indicator
   subplot(3,4,8), imshow(FDI);
   title(sprintf('Frame Diff:%4d of %d', frame, frameCount))

   % Create Frame Difference Foreground Mask by adding the Foreground Mask to
   % the Frame Difference Indicator
   FDFGM = FDI + FGM;

   % Display the Frame Difference Foreground Mask
   subplot(3,4,9), imshow(FDFGM);
   title(sprintf('Frame Diff FG Mask:%4d of %d', frame, frameCount))

   % Static Object Indicator - used to highlight where static objects have
   % appeared in frame (Background will be represented by 0 and object by 255)
   SOI=zeros(My,Nx);

   % Set Static Object Indicator to 255 where Background Difference Indicator
   % is greater than Frame Difference Foreground Mask
   SOI(BGI>FDFGM)=255;

   % Convert Static Object Indicator to unit8
   SOI=uint8(SOI);

   % Display the Static Object Indicator
   subplot(3,4,10), imshow(SOI);
   title(sprintf('Static Object Mask:%4d of %d', frame, frameCount))

   % Static Object Detected - used to highlight where static objects have
   % appeared in frame and to provide translucent mask the staticObjectFrame 
   % (Background will be represented by 0 and object by 1)
   SOD=zeros(My,Nx);

   % Set Static Object Detected to 1 where Static Object Indicator
   % is greater than 0
   SOD(SOI>0)=1;

   % Convert Static Object Detected to unit8
   SOD=uint8(SOD);

   % Create staticObjectFrame by masking the currentFrame with Static 
   % Object Detected
   staticObjectFrame = currentFrame;
   staticObjectFrame(:,:,1)=SOD.*currentFrame(:,:,1);
   staticObjectFrame(:,:,2)=SOD.*currentFrame(:,:,2);
   staticObjectFrame(:,:,3)=SOD.*currentFrame(:,:,3);
   
   % Check if any static objects have been detected
   if any(staticObjectFrame(:) > 0)
       disp(['Static Object Detected on Frame: ', num2str(frame)]);
   end

   % Show only the red channel for the staticObjectFrame
   staticObjectFrame(:,:,2:3) = 0;

   % Display the staticObjectFrame
   subplot(3,4,11), imshow(staticObjectFrame);
   title(sprintf('Static Object Frame:%4d of %d', frame, frameCount))

   % Create staticObjectDetectionFrame by adding the staticObjectFrame to
   % the currentFrame - this will highlight the static objects in red in
   % the currentFrame
   staticObjectDetectionFrame = currentFrame + staticObjectFrame;

   % Display the staticObjectDetectionFrame
   subplot(3,4,12), imshow(staticObjectDetectionFrame);
   title(sprintf('Static Object Detection:%4d of %d', frame, frameCount))

   % Force Figure to refresh
   drawnow;
end