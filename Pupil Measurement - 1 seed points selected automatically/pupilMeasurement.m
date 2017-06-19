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
%                  input 3 - elliptical fit only
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
%         If doPlot is true, all processed frames will also be saved in 
%         the seleted folder with fitted ellipse or circle shown on .


%% Check all the input arguments
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

%check the fitMethod
if fitMethod ~= 1 && fitMethod ~= 2 && fitMethod ~= 3
    error('Wrong input of fitMethod!')
end

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

% check the frame interval
if round(frameInterval) ~= frameInterval
    error('Wrong input of frameInterval! It should be an integer!')
end

%check the pupilSize
if isempty(pupilSize)
    figure,imshow(F);
    hold on;
    title('Please draw the longest diameter across the pupil by clicking on the image, the end point can be slected by right-click. ');
    [cx,cy,c]=improfile;
    lengthc = length(c);
    h = imdistline(gca,[cx(1),cx(lengthc)],[cy(1),cy(lengthc)]);
    pupilSize=getDistance(h);
    close
else
    pupilSize = pupilSize;
end


% check the threshould value for the region growing segmentation
if round(thresVal) ~= thresVal
    error('Wrong input of thresVal! It should be an integer!')
end

% select the folder to save all the processed images and radii text
if isempty(fileSavePath)
     fileSavePath=uigetdir('','Please create or select a folder to save the processed images and radii text');
else
    fileSavePath=fileSavePath;
end

% check if the user want to save all the images
if doPlot ~= true && doPlot ~= false
    doPlot = 0;
    error('Wrong input of doPlot! It should be either true or false!')
end


%% Start to process the videos

% use the point having the lowest grayvalue on the line as the first seed point
[minc,indexc]=min(c);
if pupilSize > 20
    sFirst=[round(cx(indexc)),round(cy(indexc)),1];
else
    cx2= round((cx(indexc)*2));cy2= round((cy(indexc)*2));
    sFirst=[cx2,cy2];
end

% find the threshould grayvalue for the seed point
K=1;
for k=1:length(c)
    if c(k)<150
        cNew(K) = c(k); K=K+1;
    end
end
sThres=prctile(cNew,50);

% Check the fit method and fit the pupil images
if NumberofVideos == 1   % only one video needed to be processed
    if fitMethod == 1   %circular fit only
        R=circularFit(v,sFirst,sThres,startFrame,frameInterval,pupilSize,thresVal,fileSavePath,doPlot);
    elseif fitMethod == 2
        R=circular_ellipticalFit(v,sFirst,sThres,startFrame,frameInterval,pupilSize,thresVal,fileSavePath,doPlot);
    elseif fitMethod == 3
        R=ellipticalFit(v,sFirst,sThres,startFrame,frameInterval,pupilSize,thresVal,fileSavePath,doPlot);
    end
else   % more than 1 video needed to be processed
    Rcell = cell(1,NumberofVideos);
    if fitMethod == 1   %circular fit only
        for j=1:NumberofVideos
            videoPath = fullfile(vpath,vname{j});
            v=VideoReader(videoPath);
            Rcell{j}=circularFit(v,sFirst,sThres,frameInterval,pupilSize,thresVal,fileSavePath,doPlot);
        end
        
    elseif fitMethod == 2
        for j=1:NumberofVideos
            videoPath = fullfile(vpath,vname{j});
            v=VideoReader(videoPath);
            Rcell{j}=circular_ellipticalFit(v,sFirst,sThres,startFrame,frameInterval,pupilSize,thresVal,fileSavePath,doPlot);
        end
        
    elseif fitMethod == 3
        for j=1:NumberofVideos
            videoPath = fullfile(vpath,vname{j});
            v=VideoReader(videoPath);
            Rcell{j}=ellipticalFit(v,sFirst,sThres,startFrame,frameInterval,pupilSize,thresVal,fileSavePath,doPlot);
        end
    end
    R=Rcell;
end

% disp(['pupilMeasurement Ending ']);
% disp(['Number of Processed Videos :' num2str(NumberofVideos)]);
% % disp(['Frame Interval : 'num2str(frameInterval)])
% disp(['Fit Method :' FitMethod]);
% % disp(['Threshold of the Region Growing Segmentation :'num2str(thresVal)]);
    
    