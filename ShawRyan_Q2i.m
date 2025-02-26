%%
clear variables;
close all;

%% Video1 Experiment - No Noise

% Retrieve the video file
Vid_Filename = 'Video1.mp4';

% Declare VideoReader
vReader1 = VideoReader(Vid_Filename);

% Get frameCount of vReader1 - needed for looping over frame below
frameCount = vReader1.NumFrames;

% Create figure for displaying results
figVid1 = figure('Name','Video1 Experiment - No Noise','NumberTitle','off','WindowState', 'maximized');
figure(figVid1);

% Create array to store each video frame
videoFrames = {};

% Read each of the frames in the video
while hasFrame(vReader1)
    % Add each frame to the videoFrames array
    videoFrames{end+1} = im2single(readFrame(vReader1));
end

% Create array to store each motion frame - this is used later for MSE
% comparison
motionFramesNoNoise = {};

% Create backgroundFrame by getting mean values between columns 280-390 in
% the videoFrames array (280-390 selected through trial and error to create
% the clearest background image possible without any subjects/people in it)
backgroundFrame = mean(cat(4, videoFrames{: , 280:390}), 4);

% Convert the backgroundFrame to unit8
backgroundFrame = im2uint8(backgroundFrame);

% Identify the number of rows and columns in backgroundFrame
[My,Nx,Sz]=size(backgroundFrame);

% Convert the backgroundFrame to grayscale so we have it in 2-D - used for
% working out backgroundDifference below
backgroundFrameGray = rgb2gray(backgroundFrame);

% Define 8x8 averaging filter - needed for smoothing backgroundFrame and
% currentFrame below
hs=8;
h_average=fspecial('average',[hs hs]);

% Smooth the backgroundFrameGray using convolution
backgroundFrameGray = conv2(backgroundFrameGray,h_average, 'same');

% Declare threshold value for populating Background Difference Indicator
th=30;

% % Create array to store the meanBackgroundDifference - this will be used for
% % plotting the meanBackgroundDifference as each video frame is played
% meanBackgroundDifferenceNoNoise = zeros(frameCount, 1);

% Loop over each of the frames in video
for frame = 1 : frameCount

    if frame == 1
       % Get the firstFrame in the video
       firstFrame = videoFrames{frame};

       % Display the firstFrame and selected backgroundFrame
       subplot(1,2,1), imshowpair(firstFrame, backgroundFrame, 'montage');
       title('Frame 1 & Mean Background Frame')
    end
   
   % Background Difference Indicator - used to highlight where currentFrame
   % is different from backgroundFrame (Background will be represented by 0
   % and Foreground by 1)
   BGI=zeros(My,Nx);
  
   % Get the currentFrame from the videoFrames array using the index of the
   % currentFrame
   currentFrame = videoFrames{frame};

   % Convert the currentFrame to unit8
   currentFrame = im2uint8(currentFrame);

   % Convert the currentFrame to grayscale so we have it in 2-D - used for
   % working out backgroundDifference below
   currentFrameGray = rgb2gray(currentFrame);

   % Smooth the currentFrameGray using convolution
   currentFrameGray = conv2(currentFrameGray,h_average, 'same');

   % Calculate the backgroundDifference by subtracting the backgroundFrameGray
   % from the currentFrameGray
   backgroundDifference = abs(currentFrameGray - backgroundFrameGray);

   % Set Background Difference Indicator to 1 where backgroundDifference is
   % greater than threshold value
   BGI(backgroundDifference>th)=1;

   % Convert Background Difference Indicator to unit8
   BGI=uint8(BGI);

   % Highlight only the pixels in the currentFrame that are different from
   % the backgroundFrame
   motionFrame = currentFrame;
   motionFrame(:,:,1)=BGI.*currentFrame(:,:,1);
   motionFrame(:,:,2)=BGI.*currentFrame(:,:,2);
   motionFrame(:,:,3)=BGI.*currentFrame(:,:,3);

   % Display the currentFrame and motionFrame
   subplot(1,2,2), imshowpair(currentFrame, motionFrame, 'montage');
   title(sprintf('Current Frame & Motion Frame:%4d of %d', frame, frameCount))

   % Add each frame to the motionFramesNoNoise array
    motionFramesNoNoise{end+1} = im2single(motionFrame);

   % Force Figure to refresh
   drawnow nocallbacks;
end
%% Video1 Experiment - 0.3 Noise Density

% Retrieve the video file
Vid_Filename = 'Video1.mp4';

% Declare VideoReader
vReader1 = VideoReader(Vid_Filename);

% Get frameCount of vReader1 - needed for looping over frame below
frameCount = vReader1.NumFrames;

% Create figure for displaying results
figVid1Noise1 = figure('Name','Video1 Experiment - 0.3 Noise Density','NumberTitle','off','WindowState', 'maximized');
figure(figVid1Noise1);

% Create array to store each video frame
videoFrames = {};

% Read each of the frames in the video
while hasFrame(vReader1)
    % Add each frame to the videoFrames array
    videoFrames{end+1} = im2single(readFrame(vReader1));
end

% Create backgroundFrame by getting mean values between columns 280-390 in
% the videoFrames array (280-390 selected through trial and error to create
% the clearest background image possible without any subjects/people in it)
backgroundFrame = mean(cat(4, videoFrames{: , 280:390}), 4);

% Convert the backgroundFrame to unit8
backgroundFrame = im2uint8(backgroundFrame);

% Add salt and pepper noise to the backgroundFrame
noisyBackgroundFrame = imnoise(backgroundFrame,'salt & pepper',0.3);

% Identify the number of rows and columns in backgroundFrame
[My,Nx,Sz]=size(backgroundFrame);

% Convert the currentFrame to backgroundFrame so we have it in 2-D - used for
% working out backgroundDifference below
backgroundFrameGray = rgb2gray(noisyBackgroundFrame);

% Define 8x8 averaging filter - needed for smoothing backgroundFrame and
% currentFrame below
hs=8;
h_average=fspecial('average',[hs hs]);

% Smooth the backgroundFrameGray using convolution
backgroundFrameGray = conv2(backgroundFrameGray,h_average, 'same');

% Declare threshold value for populating Background Difference Indicator
th=30;

% Create array to store the Mean-squared error - this will be used for
% plotting the Mean-squared error as each video frame is played
meanSquaredError = zeros(frameCount, 1);

% Loop over each of the frames in video
for frame = 1 : frameCount

   % Get the currentFrame from the videoFrames array using the index of the
   % currentFrame
   currentFrame = videoFrames{frame};

   % Convert the currentFrame to unit8
   currentFrame = im2uint8(currentFrame);

   % Add salt and pepper noise to the currentFrame
   noisyCurrentFrame = imnoise(currentFrame,'salt & pepper',0.3);

   % Check if the frame index is 1
   if frame == 1
      % Get the firstFrame in the video
      firstFrame = noisyCurrentFrame;

      % Display the firstFrame and selected noisyBackgroundFrame
      subplot(2,2,1), imshowpair(firstFrame, noisyBackgroundFrame, 'montage');
      title('Frame 1 & Selected Background Frame')
   end
   
   % Background Difference Indicator - used to highlight where currentFrame
   % is different from backgroundFrame (Background will be represented by 0
   % and Foreground by 1)
   BGI=zeros(My,Nx);

   % Convert the currentFrame to grayscale so we have it in 2-D - used for
   % working out backgroundDifference below
   currentFrameGray = rgb2gray(noisyCurrentFrame);

   % Smooth the currentFrameGray using convolution
   currentFrameGray = conv2(currentFrameGray,h_average, 'same');

   % Calculate the backgroundDifference by subtracting the backgroundFrameGray
   % from the currentFrameGray
   backgroundDifference = abs(currentFrameGray - backgroundFrameGray);

   % Set Background Difference Indicator to 1 where backgroundDifference is
   % greater than threshold value
   BGI(backgroundDifference>th)=1;

   % Convert Background Difference Indicator to unit8
   BGI=uint8(BGI);

   % Highlight only the pixels in the currentFrame that are different from
   % the backgroundFrame
   motionFrameNoise = currentFrame;
   motionFrameNoise(:,:,1)=BGI.*currentFrame(:,:,1);
   motionFrameNoise(:,:,2)=BGI.*currentFrame(:,:,2);
   motionFrameNoise(:,:,3)=BGI.*currentFrame(:,:,3);

   % Display the currentFrame and motionFrameNoise
   subplot(2,2,2), imshowpair(noisyCurrentFrame, motionFrameNoise, 'montage');
   title(sprintf('Current Frame & Motion Frame:%4d of %d', frame, frameCount))

   % Calculate the Mean-squared error for each frame compared with no noise
   meanSquaredError(frame) = immse(motionFrameNoise, im2uint8(motionFramesNoNoise{frame}));

   % Display the Accuray Results
   subplot('Position', [0.1, 0.1, 0.8, 0.4]);
   hold off;
   plot(meanSquaredError, 'g');
   hold on;
   grid on;
   xlabel(sprintf('Frame:%4d of %d', frame, frameCount))
   ylabel('MSE Value');
   title('Mean Squared Error (Compared to No Noise)')

   % Force Figure to refresh
   drawnow nocallbacks;
end
%% Video1 Experiment - 0.6 Noise Density
% Retrieve the video file
Vid_Filename = 'Video1.mp4';

% Declare VideoReader
vReader1 = VideoReader(Vid_Filename);

% Get frameCount of vReader1 - needed for looping over frame below
frameCount = vReader1.NumFrames;

% Create figure for displaying results
figVid1Noise2 = figure('Name','Video1 Experiment - 0.6 Noise Density','NumberTitle','off','WindowState', 'maximized');
figure(figVid1Noise2);

% Create array to store each video frame
videoFrames = {};

% Read each of the frames in the video
while hasFrame(vReader1)
    % Add each frame to the videoFrames array
    videoFrames{end+1} = im2single(readFrame(vReader1));
end

% Create backgroundFrame by getting mean values between columns 280-390 in
% the videoFrames array (280-390 selected through trial and error to create
% the clearest background image possible without any subjects/people in it)
backgroundFrame = mean(cat(4, videoFrames{: , 280:390}), 4);

% Convert the backgroundFrame to unit8
backgroundFrame = im2uint8(backgroundFrame);

% Add salt and pepper noise to the backgroundFrame
noisyBackgroundFrame = imnoise(backgroundFrame,'salt & pepper',0.6);

% Identify the number of rows and columns in backgroundFrame
[My,Nx,Sz]=size(backgroundFrame);

% Convert the currentFrame to backgroundFrame so we have it in 2-D - used for
% working out backgroundDifference below
backgroundFrameGray = rgb2gray(noisyBackgroundFrame);

% Define 8x8 averaging filter - needed for smoothing backgroundFrame and
% currentFrame below
hs=8;
h_average=fspecial('average',[hs hs]);

% Smooth the backgroundFrameGray using convolution
backgroundFrameGray = conv2(backgroundFrameGray,h_average, 'same');

% Declare threshold value for populating Background Difference Indicator
th=30;

% Create array to store the Mean-squared error - this will be used for
% plotting the Mean-squared error as each video frame is played
meanSquaredError2 = zeros(frameCount, 1);

% Loop over each of the frames in video
for frame = 1 : frameCount

   % Get the currentFrame from the videoFrames array using the index of the
   % currentFrame
   currentFrame = videoFrames{frame};

   % Convert the currentFrame to unit8
   currentFrame = im2uint8(currentFrame);

   % Add salt and pepper noise to the currentFrame
   noisyCurrentFrame = imnoise(currentFrame,'salt & pepper',0.6);

   % Check if the frame index is 1
   if frame == 1
      % Get the firstFrame in the video
      firstFrame = noisyCurrentFrame;

      % Display the firstFrame and selected noisyBackgroundFrame
      subplot(2,2,1), imshowpair(firstFrame, noisyBackgroundFrame, 'montage');
      title('Frame 1 & Selected Background Frame')
   end
   
   % Background Difference Indicator - used to highlight where currentFrame
   % is different from backgroundFrame (Background will be represented by 0
   % and Foreground by 1)
   BGI=zeros(My,Nx);

   % Convert the currentFrame to grayscale so we have it in 2-D - used for
   % working out backgroundDifference below
   currentFrameGray = rgb2gray(noisyCurrentFrame);

   % Smooth the currentFrameGray using convolution
   currentFrameGray = conv2(currentFrameGray,h_average, 'same');

   % Calculate the backgroundDifference by subtracting the backgroundFrameGray
   % from the currentFrameGray
   backgroundDifference = abs(currentFrameGray - backgroundFrameGray);

   % Set Background Difference Indicator to 1 where backgroundDifference is
   % greater than threshold value
   BGI(backgroundDifference>th)=1;

   % Convert Background Difference Indicator to unit8
   BGI=uint8(BGI);

   % Highlight only the pixels in the currentFrame that are different from
   % the backgroundFrame
   motionFrameNoise2 = currentFrame;
   motionFrameNoise2(:,:,1)=BGI.*currentFrame(:,:,1);
   motionFrameNoise2(:,:,2)=BGI.*currentFrame(:,:,2);
   motionFrameNoise2(:,:,3)=BGI.*currentFrame(:,:,3);

   % Display the currentFrame and motionFrame
   subplot(2,2,2), imshowpair(noisyCurrentFrame, motionFrameNoise2, 'montage');
   title(sprintf('Current Frame & Motion Frame:%4d of %d', frame, frameCount))

   % Calculate the Mean-squared error for each frame compared with no noise
   meanSquaredError2(frame) = immse(motionFrameNoise2, im2uint8(motionFramesNoNoise{frame}));

   % Display the meanBackgroundDifference
   subplot('Position', [0.1, 0.1, 0.8, 0.4]);
   hold off;
   plot(meanSquaredError2, 'r');
   hold on;
   plot(meanSquaredError, 'g');
   grid on;
   legend('0.6 Noise', '0.3 Noise')
   xlabel(sprintf('Frame:%4d of %d', frame, frameCount))
   ylabel('MSE Value');
   title('Mean Squared Error (Compared to No Noise)')

   % Force Figure to refresh
   drawnow nocallbacks;
end