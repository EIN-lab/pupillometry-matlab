% Add pupil-analysis to MATLAB path
addpath(genpath('D:\Code\Matlab\pupil-analysis'))

% Image file
videoPath = fullfile(utils.get_rootdir,'example\sample_video.mp4');

% Settings
doPlot = false;
fileSavePath = fullfile(utils.get_rootdir,'example\');

% Run
diam = pupilMeasurement(...
    'doPlot', doPlot, ...
    'videoPath', videoPath, ...
    'fileSavePath', fileSavePath,...
    'startFrame', 5, ...
    'fitMethod', 2, ...
    'frameInterval', 5, ...
    'enhanceContrast', true);