function R = pupilMeasurement(varargin)
% Main Algorithm
% Pupil Detection and Measurement Algorithm for Videos
%
% R =pupilMeasurement(fitMethod,doPlot,thresVal,frameInterval,videoPath,fileSavePath,startFrame,pupilSize)
%
% Syntax:
%   R = pupilMeasurement;
%   R = pupilMeasurement('fitMethod',1,'frameInterval',50);
%   R = pupilMeasurement('doPlot',true,'thresVal',25);
%
% Inputs:
%       fitMethod: input 1 - circular fit(if pupils are almost circular);
%                  input 2 - circular+elliptical fit.
%                  Default value - 2
%
%       doPlot: input false - only save the radii in a txt file.
%               input true - all fitted frames will also be saved
%               Default value - 0
%
%       thresVal: threshould for the region-growing segmentation, which
%                 stands for the difference of the gray values between the
%                 pupil and the iris of the eye.Values from 15 to 30 would
%                 be reasonable for normal cases.
%                 Default value - 18
%
%       frameInterval: the interval between each processed frame, it must
%                      be an integer.
%                      Default value - 5
%
%       videoPath: should be given as [],then the user needs to select one
%                  or more video after running the algorithm.
%
%       fileSavePath: should be given as [], then the user needs to select (or
%                 create) a folder, which will be used to save the images
%                 and text file.
%
%       startFrame: the number of the first frame to be processed. 
%                   Default value - the number of the first frame whose
%                   maximal gray value is higher than 100
%
%       pupilSize: the diameter of pupil in the startFrame in pixel. User
%                  can draw a line cross the pupil on the displayed
%                  image,then the diameter will be measured automatically.
%                  If the diameter is 20 pixels or less, the frames will be
%                  defined as small-size images and resized.
%
% Output: R -- a 1*n matrix or a 1*h cell which contain the radii of the
%              pupil in each processd frame, and these radii will also be
%              saved as a txt file
%
%         If doPlot=1, all processed frames will also be saved in current
%         fold with fitted ellipse or circle shown on .


%=========================================================================
%check all the input arguments
close all

if nargin > 8
    error('Wrong number of input arguments!')
end

pNames = {'fitMethod';'doPlot';'thresVal';'frameInterval';'videoPath';...
            'fileSavePath';'startFrame';'pupilSize'};
pValues = {2;false;18;5;[];[];[];[]};
dflts = cell2struct(pValues, pNames);
% Parse function input arguments
params = parsepropval2(dflts, varargin{:});

fitMethod = params.fitMethod;
doPlot = params.doPlot;
thresVal = params.thresVal;
frameInterval = params.frameInterval;
videoPath = params.videoPath;
fileSavePath = params.fileSavePath;
startFrame = params.startFrame;
pupilSize = params.pupilSize;

%select videos%
if isempty(videoPath)
    [vname,vpath] = uigetfile({'*.mp4;*.m4v;*.avi;*.mov;*.mj2;*.mpg;*.wmv;*.asf;*.asx'},...
        'Please select the video file(s)','multiselect','on');
end
NumberofVideos = numel(cellstr(vname));

% %check the fitMethod
% if ~exist('fitMethod') || isempty(fitMethod)
%     fitMethod = 2; % default input of fitMethod is circular+elliptical fit;
% else
%     fitMethod = fitMethod;
% end

%check the start frame
if isempty(startFrame)
    if NumberofVideos == 1
        videoPath = fullfile(vpath,vname);
    else
        videoPath = fullfile(vpath,vname{1});
    end
    v=VideoReader(videoPath);
    maxGrayLevel=0;
    for i=1:v.NumberOfFrames;
        F=rgb2gray(read(v,i));
        maxGrayLevel = max(max(F(:)));
        if maxGrayLevel > 200
            startFrame = i;
            break
        end
    end
elseif round(startFrame) ~= startFrame
    error('Wrong input of startFrame! It should be an integer!')
    % When there is no input for startFrame, the algorithm will select the
    % first frame of the video,whose maximal gray value is higher than 100, as
    % the startFrame.
else
    startFrame = startFrame
end

% % check the frame interval
% if isempty(frameInterval)
%     frameInterval = 5;  % default value of frameInterval is 5;
% elseif round(frameInterval) ~= frameInterval
%     error('Wrong input of frameInterval! It should be an integer!')
% else
%     frameInterval = frameInterval;
% end

%check the pupilSize
if isempty(pupilSize)
    figure,imshow(F);
    hold on;
    title('Please draw the longest diameter across the pupil');
    h=imline;
    pos=getPosition(h);
    h = imdistline(gca,pos(:,1),pos(:,2));
    pupilSize=getDistance(h);
    close
else
    pupilSize = pupilSize;
end

% % check the threshould value for the region growing segmentation
% if ~exist('thresVal')|| isempty(thresVal)
%     thresVal=18;
% else
%     thresVal=thresVal;
% end

% select the folder to save all the processed images and radii text
if isempty(fileSavePath)
     fileSavePath=uigetdir('','Please create or select a folder to save the processed images and radii text');
else
    fileSavePath=fileSavePath;
end

% % check if the user want to save all the images
% if ~exist('doPlot') || isempty(doPlot)
%     doPlot = 0;
% else
%     doPlot=doPlot;
% end

%=========================================================================
%start to process the videos

%check the size of eye and select the seed point s for regionGrowing
%segmentation
if pupilSize <= 20
    F=imresize(medfilt2(F),2);
end
figure,imshow(F),hold on;
title('Please select one seed point inside the BLACK PART OF THE PUPIL')
s=round(ginput(1));
grayValues = impixel(F,s(2),s(1));
% check the gray value of the seed point
if grayValues(1) > 80
    warning('The selected pixel is too bright!Please select the other seed point inside the BLACK PART OF THE PUPIL!');
    imshow(F),hold on;
    title('Please select the other seed point inside the BLACK PART OF THE PUPIL!');
    s=round(ginput(1));
    grayValues = impixel(F,s(2),s(1));
end
s=[s(2),s(1),1];
close;


% Check the fit method and fit the pupil images
if NumberofVideos == 1   % only one video needed to be processed
    if fitMethod == 1   %circular fit only
        FitMethod = 'Circular Fit';
        R=circularFit(v,s,startFrame,frameInterval,pupilSize,thresVal,fileSavePath,doPlot);
    elseif fitMethod == 2
        FitMethod = 'Circular + Elliptical Fit';
        R=circular_ellipticalFit(v,s,startFrame,frameInterval,pupilSize,thresVal,fileSavePath,doPlot);
    end
else   % more than 1 video needed to be processed
    Rcell = cell(1,NumberofVideos);
    if fitMethod == 1   %circular fit only
        FitMethod = 'Circular Fit';
        for j=1:NumberofVideos
            videoPath = fullfile(vpath,vname{j});
            v=VideoReader(videoPath);
            Rcell{j}=circularFit(v,s,startFrame,frameInterval,pupilSize,thresVal,fileSavePath,doPlot);
        end
    elseif fitMethod == 2
        FitMethod = 'Circular + Elliptical Fit';
        for j=1:NumberofVideos
            videoPath = fullfile(vpath,vname{j});
            v=VideoReader(videoPath);
            Rcell{j}=circular_ellipticalFit(v,s,startFrame,frameInterval,pupilSize,thresVal,fileSavePath,doPlot);
        end
    end
    R=Rcell;
end

% disp(['pupilMeasurement Ending ']);
% disp(['Number of Processed Videos :' num2str(NumberofVideos)]);
% % disp(['Frame Interval : 'num2str(frameInterval)])
% disp(['Fit Method :' FitMethod]);
% % disp(['Threshold of the Region Growing Segmentation :'num2str(thresVal)]);
    
    