% Add pupil-analysis to MATLAB path
addpath(genpath('D:\Code\Matlab\pupil-analysis'))

% Define parameters
fitMethod = 2;
spSelect = 'line';
doPlot = true;
thresVal = [];
frameInterval = 2;
videoPath = fullfile(utils.get_rootdir, 'example/sample_video.mp4');
fileSavePath = fullfile(utils.get_rootdir, 'example');
startFrame = 5;
enhanceContrast = true;
doCrop = true;
skipBadFrames = true;
fillBadData = 'linear';
saveLabeledFrames = false;
pixelSize = [];

% Run pupilMeasurement with pre-defined parameters
pup02 = pupilMeasurement('fitMethod', fitMethod, 'doPlot', doPlot, ...
    'thresVal', thresVal, 'frameInterval', frameInterval, ...
    'videoPath', videoPath, 'fileSavePath', fileSavePath, ...
    'startFrame', startFrame, 'enhanceContrast', enhanceContrast, ...
    'doCrop', doCrop, 'skipBadFrames', skipBadFrames, ...
    'fillBadData', fillBadData, 'saveLabeledFrames', saveLabeledFrames, ...
    'pixelSize', pixelSize)