function R = pupilMeasurement(varargin)
% Pupil Detection and Measurement Algorithm for Videos
%
% R = pupilMeasurement(fitMethod, doPlot, thresVal, frameInterval, videoPath,
% fileSavePath, startFrame, pupilSize)
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
%     spSelect: Whether to estimate seedpoint from darkest point ('line') or
%               manually selecting 4 seed points ('points').
%
%       doPlot: input false - only save the radii in a txt file.
%               input true - all fitted frames will also be saved
%               Default value - 0
%
%       thresVal: threshold for the region-growing segmentation, which
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
%
% Output:
%       R:  a 1*n matrix or a 1*h cell which contain the radii of the pupil in
%           each processed frame, and these radii will also be saved as a txt
%           file
%
%         If doPlot is true, all processed frames will also be saved in
%         the selected folder with fitted ellipse or circle shown on.


% Check all the input arguments
pNames = {'fitMethod', 'spSelect', 'doPlot', 'thresVal', 'frameInterval', ...
    'videoPath', 'fileSavePath', 'startFrame', 'enhanceContrast'};
pValues = {2, 'line', false, [], 5, [], [], 1, false};
params = cell2struct(pValues, pNames, 2);

% Parse function input arguments
params = utils.parsepropval2(params, varargin{:});

fitMethod = params.fitMethod;
spSelect = params.spSelect;
doPlot = params.doPlot;
thresVal = params.thresVal;
frameInterval = params.frameInterval;
videoPath = params.videoPath;
fileSavePath = params.fileSavePath;
startFrame = params.startFrame;
enhanceContrast = params.enhanceContrast;

% Select videos
if isempty(videoPath)
    [vname, vpath] = uigetfile({'*.mp4;*.m4v;*.avi;*.mov;*.mj2;*.mpg;*.wmv;*.asf;*.asx'},...
        'Please select the video file(s)','multiselect','on');
    if isnumeric(vname) && vname == 0
        error('Please select a file to load')
    end
    videoPath = fullfile(vpath, vname);
end

numVideos = numel(cellstr(videoPath));

% Check the fitMethod
if ~isfinite(params.fitMethod) || ~isscalar(params.fitMethod)
    error('''fitMethod'' must be a scalar, finite integer value.')
end

if ~(floor(params.fitMethod) == params.fitMethod)
  error('''fitMethod'' must be a scalar, finite integer value.')
end

if ~any(params.fitMethod == [1, 2, 3])
    error('''fitMethod'' must be one of [1, 2, 3].')
end

% Check spSelect
if ~ischar(params.spSelect)
    error('''spSelect must'' be a character array')
end

% Instantiate video reader
if numVideos ~= 1
    sourcePath = fullfile(videoPath{1});
else
    sourcePath = videoPath;
end

% Read video frames while available
v = VideoReader(sourcePath);

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

% Close video reader
clearvars v

% Check the frame interval
if ~(floor(params.frameInterval) == params.frameInterval)
    error('''frameInterval'' must be an integer value.')
end

% Check the threshold value for the region growing segmentation
if floor(params.thresVal) ~= params.thresVal
    error('''threshVal'' must be an integer value.')
end

% Check if the user want to save all the images
try
    logical(params.doPlot);
catch
    error('''doPlot'' must be convertible to logical.')
end

% Auto-adjust image contrast
if enhanceContrast
    F = imadjust(F);
end

% Select the folder to save all the processed images and radii text
if isempty(fileSavePath)
     fileSavePath = uigetdir(vpath,'Please create or select a folder to save the processed images and radii text');
end

% Ask the user to draw a line across the pupil
hFig = figure; imshow(F);

%% Start to process the videos

switch spSelect
    case 'line'
        title('Please draw the longest diameter across the pupil by clicking on the edge of the pupil, the end point can be slected by right-click. ');
        [cx, cy, c] = improfile;
        lengthc = length(c);
        h = imdistline(gca, [cx(1), cx(lengthc)], [cy(1), cy(lengthc)]);
        pupilSize = getDistance(h);
        delete(hFig);

        % find the threshold gray value sThres for the seed point
        % delete points whose gray values are higher than 150 (i.e., points inside
        % the iris or corneal reflection part).
        c(c > 150) = [];
        sThresh = prctile(c, 95);

        % Seed Point Selection : use the point having the lowest gray value on the
        % drawn line as the first seed point.
        [~, indexc] = min(c);
        if pupilSize > 20
            seedPoints=[round(cx(indexc)), round(cy(indexc))];
        else
            cx2 = round((cx(indexc)*2));
            cy2 = round((cy(indexc)*2));
            seedPoints = [cx2, cy2];
        end

    case 'points'
        %check the size of eye and select the seed point s for regionGrowing
        %segmentation


        title(sprintf(['Please select 4 seed points inside the BLACK PART OF THE PUPIL.\n', ...
            'The seed points should be located as far away from each other as possible. \n', ...
            'The best selection would be the top, bottom, left and right sides of the pupil.']))
        seedPoints=round(ginput(4));
        delete(hFig);
        pause(.2);

    otherwise
        error('Unknown seed point selection method "%s"', method.spSelect)
end


% Check the fit method and fit the pupil images
if numVideos > 1
    R = cell(1,numVideos);
    for j=1:numVideos
        v = VideoReader(videoPath);
        R{j} = doFit(v, pupilSize, seedPoints, sThresh, params);
    end
else
    v = VideoReader(videoPath);
    R = doFit(v, pupilSize, seedPoints, sThresh, params);
end

% save the matrix or cell of R as a .mat file
[~, fname] = fileparts(v.name);
radiiMat=fullfile(fileSavePath, [fname, '_radii.mat']);
save(radiiMat, 'R');

% save the matrix of Radii as a text file
Tname = fullfile(fileSavePath, [fname, 'Pupil Radii.csv']);
dlmwrite(Tname,R,'newline','pc','delimiter',';');
end
