function R = pupilMeasurement(varargin)
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
% Output:
%       R:  a 1*n matrix or a 1*h cell which contain the radii of the pupil in
%           each processed frame, and these radii will also be saved as a txt
%           file
%
%         If doPlot is true, all processed frames will also be saved in
%         the selected folder with fitted ellipse or circle shown on.


% Check all the input arguments
pNames = {'fitMethod', 'doPlot', 'thresVal', 'frameInterval', ...
    'videoPath', 'fileSavePath', 'startFrame', 'pupilSize'};
pValues = {2, false, [], 5, [], [], [], []};
params = cell2struct(pValues, pNames, 2);

% Parse function input arguments
params = parsepropval2(params, varargin{:});

fitMethod = params.fitMethod;
doPlot = params.doPlot;
thresVal = params.thresVal;
frameInterval = params.frameInterval;
videoPath = params.videoPath;
fileSavePath = params.fileSavePath;
startFrame = params.startFrame;
pupilSize = params.pupilSize;

% Select videos
if isempty(videoPath)
    [vname, vpath] = uigetfile({'*.mp4;*.m4v;*.avi;*.mov;*.mj2;*.mpg;*.wmv;*.asf;*.asx'},...
        'Please select the video file(s)','multiselect','on');
    if isnumeric(vname) && vname == 0
        error('Please select a file to load')
    end
    videoPath = fullfile(vpath, vname);
end

NumberofVideos = numel(cellstr(videoPath));

% Check the fitMethod
if isfinite(params.fitMethod) || ~isscalar(params.fitMethod)
    error('''fitMethod'' must be a scalar, finite integer value.')
end

if ~(floor(params.fitMethod) == params.fitMethod)
  error('''fitMethod'' must be a scalar, finite integer value.')
end

if ~any(params.fitMethod == [1, 2, 3])
    error('''fitMethod'' must be one of [1, 2, 3].')
end

% Instantiate video reader
if NumberofVideos ~= 1
    sourcePath = fullfile(videoPath{1});
else
    sourcePath = videoPath;
end

% Read video frames while available
v=VideoReader(sourcePath);

% Find the start frame
if isempty(startFrame)
    while hasFrame(v)
        F=rgb2gray(readFrame(v));
        maxGrayLevel = max(max(F(:)));
        if maxGrayLevel > 200
            startFrame = v.CurrentTime*v.FrameRate;
            break
        end
    end
else
    % Check startFrame property
    isnum = isnumeric(startFrame);
    isscal = isscalar(startFrame);
    if ~isnum || ~isscal
        error('startFrame property must be scalar integer')
    end

    if ~(floor(startFrame) == startFrame)
        warning('startFrame property should be an integer.')
        startFrame = round(startFrame);
    end

    % Set video start time
    v.CurrentTime = startFrame/v.FrameRate;
    F=rgb2gray(readFrame(v));
end

% Check the frame interval
if ~(floor(params.frameInterval) == params.frameInterval)
    error('''frameInterval'' must be an integer value.')
end

% Adjust image contrast
F = imadjust(F, [0,0.5], [0, 1]);

% Check the pupilSize
% If the puilSize is empty, the user will be asked to draw a line across
% the pupil as the pupil diameter.
if isempty(pupilSize)
    hFig=figure;imshow(F);
    title('Please draw the longest diameter across the pupil by clicking on the edge of the pupil, the end point can be slected by right-click. ');
    [cx,cy,c]=improfile;
    lengthc = length(c);
    h = imdistline(gca,[cx(1),cx(lengthc)],[cy(1),cy(lengthc)]);
    pupilSize=getDistance(h);
    delete(hFig);
else
    pupilSize = pupilSize;
end

% Check the threshould value for the region growing segmentation
if floor(params.thresVal) ~= params.thresVal
    error('''threshVal'' must be an integer value.')
end

% Select the folder to save all the processed images and radii text
if isempty(fileSavePath)
     fileSavePath=uigetdir(vpath,'Please create or select a folder to save the processed images and radii text');
end

% Check if the user want to save all the images
if ~islogical(params.doPlot)
    error('Wrong input of doPlot. It should be either true or false.')
end

%% Start to process the videos

% find the threshould grayvalue sThres for the seed point
% delete points whose grayvalues are higher than 150 (i.e., points inside
% the iris or corneal reflection part).
for k=length(c):-1:1
    if c(k)>150
        c(k) = [];
    end
end
sThres=prctile(c,95);

%check the size of eye and select the seed point s for regionGrowing
%segmentation
if pupilSize <= 20
    F=imresize(medfilt2(F),2);
end
hFig=imshow(F);

% title({'Please select 4 seed points inside the BLACK PART OF THE PUPIL.',...
%         'The seed points should be located as far away from each other as possible.',...
%         'The best selection would be the top, bottom, left and right sides of the pupil.'})
title(sprintf(['Please select 4 seed points inside the BLACK PART OF THE PUPIL.\n', ...
    'The seed points should be located as far away from each other as possible. \n', ...
    'The best selection would be the top, bottom, left and right sides of the pupil.']))
seedPoints=round(ginput(4));
delete(hFig);
pause(.2);

% Check the fit method and fit the pupil images
if NumberofVideos == 1   % only one video needed to be processed
    if fitMethod == 1   %circular fit only
        R=circularFit(v,seedPoints,sThres,startFrame,frameInterval,pupilSize,thresVal,fileSavePath,doPlot);
    elseif fitMethod == 2  % circular + elliptical fit
        R=circular_ellipticalFit(v,seedPoints,sThres,startFrame,frameInterval,pupilSize,thresVal,fileSavePath,doPlot);
    elseif fitMethod == 3  % elliptical fit only
        R=ellipticalFit(v,seedPoints,sThres,startFrame,frameInterval,pupilSize,thresVal,fileSavePath,doPlot);
    end

else   % more than 1 video needed to be processed
    Rcell = cell(1,NumberofVideos);
    if fitMethod == 1   %circular fit only
        for j=1:NumberofVideos
            videoPath = fullfile(vpath,vname{j});
            v=VideoReader(videoPath);
            Rcell{j}=circularFit(v,seedPoints,sThres,startFrame,frameInterval,pupilSize,thresVal,fileSavePath,doPlot);
        end

    elseif fitMethod == 2
        for j=1:NumberofVideos
            videoPath = fullfile(vpath,vname{j});
            v=VideoReader(videoPath);
            Rcell{j}=circular_ellipticalFit(v,seedPoints,sThres,startFrame,frameInterval,pupilSize,thresVal,fileSavePath,doPlot);
        end
    elseif fitMethod == 3
        for j=1:NumberofVideos
            videoPath = fullfile(vpath,vname{j});
            v=VideoReader(videoPath);
            Rcell{j}=ellipticalFit(v,seedPoints,sThres,startFrame,frameInterval,pupilSize,thresVal,fileSavePath,doPlot);
        end
    end
    R=Rcell;
end
% save the matrix or cell of R as a .mat file
radiiMat=fullfile(fileSavePath,'radii.mat');
save(radiiMat,'R');
end
