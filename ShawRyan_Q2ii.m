%%
clear variables;

%% Video2 experiment

% Retrieve the video file
Vid_Filename = 'Video2.mp4';

% Declare VideoReader
vReader1 = VideoReader(Vid_Filename);

% Get frameCount of vReader1 - needed for looping over frame below
frameCount = vReader1.NumFrames;

% Create figure for displaying results
figVid1 = figure('Name','Video1 Experiment','NumberTitle','off','WindowState', 'maximized');
figure(figVid1);

% Create array to store each video frame
videoFrames = {};

% Read each of the frames in the video
while hasFrame(vReader1)
    % Add each frame to the videoFrames array
    videoFrames{end+1} = im2single(readFrame(vReader1));
end

% Create backgroundFrame by getting mean values between columns 1-200 in
% the videoFrames array (In this case this invloves the entire video as
% every frame is suitable to be used to calculate a background)
backgroundFrame = mean(cat(4, videoFrames{: , 1:200}), 4);

% Convert the backgroundFrame to unit8
backgroundFrame = im2uint8(backgroundFrame);

% Display the backgroundFrame on the figure
subplot(2,2,2), imshow(backgroundFrame);
title('Mean Background Frame')

% Identify the number of rows and columns in backgroundFrame
[My,Nx,Sz]=size(backgroundFrame);

% Convert the backgroundFrame to grayscale so we have it in 2-D - used for
% working out backgroundDifference below
backgroundFrameGray = rgb2gray(backgroundFrame);

% Define 5x5 averaging filter - needed for smoothing backgroundFrame and
% currentFrame below
hs=5;
h_average=fspecial('average',[hs hs]);

% Smooth the backgroundFrameGray using convolution
backgroundFrameGray = conv2(backgroundFrameGray,h_average, 'same');

% Declare threshold value for populating Background Difference Indicator
th=20;

% Loop over each of the frames in video
for frame = 1 : frameCount

    if frame == 1
       % Get the firstFrame in the video
       firstFrame = videoFrames{frame};

       % Display the firstFrame on the figure
       subplot(2,2,1), imshow(firstFrame);
       title('Frame 1')
    end
   
   % Background Difference Indicator - used to highlight where currentFrame
   % is different from backgroundFrame (Background will be represented by 0
   % and Foreground by 1)
   BGI=zeros(My,Nx);
  
   % Get the currentFrame from the videoFrames array using the index of the
   % currentFrame
   currentFrame = videoFrames{frame};

   % Display the currentFrame on the figure
   subplot(2,2,3), imshow(currentFrame);
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

   % Display the motionFrame
   subplot(2,2,4), imshow(motionFrame);
   title(sprintf('Motion Frame:%4d of %d', frame, frameCount))

   % Force Figure to refresh
   drawnow;
end