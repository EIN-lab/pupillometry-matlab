function R = pupilMeasurement(videoPath,fitMethod,startFrame,frameInterval,pupilSize,thresVal,doPlot)
% Main Algorithm
% Pupil Detection and Measurement Algorithm for Videos
% 
% R = pupilMeasurement(videoPath,fitMethod,frameInterval,pupilSize,thresVal,doPlot)
% Inputs:
%       videoPath: Path of the video needed to be processed 
%                  For example,the video path is
%                  "D:\matlab\2017-05-30-trial3_cropped.mp4",then the input
%                  value should be defiend as videoPath='D:\matlab\pupil
%                  dilation\2017-05-30-trial3_cropped'
%
%                  Or, if videoPath is given as [],then the user can select
%                  the video path after running the algorithm.
%
%
%       fitMethod: input 1 for circular fit(if pupils are almost circular);
%                  input 2 for circular+elliptical fit.
%
%       startFrame: the number of the first frame to be processed. In some
%                   cases, the first a few frames of the video would be
%                   totally black, the input of startFrame should be the
%                   number of frame with pupils shown.
%
%       frameInterval: the interval between each processed frame, it should
%                      be an integer.
%
%       pupilSize: the diameter of pupil in pixel, should be measured
%                manually in a frame with small pupil size. When the pupil
%                diameter is 20 pixels or less, the frames will be defined
%                as small-size images and resized.
%
%       thresVal: threshould for the region-growing segmentation, which
%                 stands for the difference of the gray values between the
%                 pupil and the iris of the eye.Values from 15 to 30 would
%                 be reasonable for normal cases.
% 
%       doPlot: If doPlot is 0, only save the radii in a txt file.If doPlot
%               is 1, all fitted frames will also be saved in current
%               fold. The default value of doPlot is 0.
%
% Output: R -- a n*1 matrix which contain the radii of the pupil in each
%         processd frame, and these radii will also be saved as a txt file
%         in current folder.
%
%         If doPlot=1, all processed frames will also be saved in current
%         fold with fitted ellipse or circle shown on . 
%         
%
%
% Example1: R=pupilMeasurement([],1,7,5,10,20,1);
%   Meaning of the input arguments:
%      []- video will be selected after runing the algorithm;
%      1 - frames will be processd by circular fit;
%      7 - the number of frame in the video you want to start to process
%	   5 - frame 1,6,11,16.......will be processed;
%  	   10 - the mannually decided smallest diameter of the pupil is 10 pixels;
%	   20 - regionGrowing threshould is 20; 
%      1 - save all the processed frames in current folderwith fitted
%      circle or ellipse shown on;


if ~exist('videoPath') || isempty(videoPath)
    videoPath = uigetfile;
else
	videoPath = videoPath;
end

if fitMethod ~= 1 && fitMethod ~= 2
    error('Wrong input of fitMethod! Input value should be 1(for circular fit) or 2(for circular + elliptical fit)')
end

if ~exist('startFrame')|| isempty(startFrame)
    error('please input the startFrame! It should be an integer number of the frame you want to start to process.')
end

if round(frameInterval) ~= frameInterval
    error('Wrong input of frameInterval! It should be an integer!')
end

if ~exist('pupilSize')|| isempty(pupilSize)
    error('please input the pupilSize!')
end

if ~exist('thresVal')|| isempty(thresVal)
    error('please input the thresVal for regionGrowing!')
end

if ~exist('doPlot') || isempty(doPlot)
    doPlot = 0;
else
    doPlot=doPlot;
end

%input the video
v=VideoReader(videoPath);
%check the size of eye and select the seed point s for regionGrowing
%segmentation
if pupilSize > 20
    F=read(v,100);
    F=medfilt2(rgb2gray(F));
else 
    F=read(v,100);
    F=imresize(medfilt2(rgb2gray(F)),2);
end
figure,imshow(F),hold on;
title('Please select one seed point inside the pupil')
s=round(ginput(1));
s=[s(2),s(1),1];
close;


% Check the fit method and fit the pupil images
if fitMethod == 1   %circular fit only
    R=circularFit(v,s,startFrame,frameInterval,pupilSize,thresVal,doPlot);
elseif fitMethod == 2 
    R=circular_ellipticalFit(v,s,startFrame,frameInterval,pupilSize,thresVal,doPlot);    
end

end 

    