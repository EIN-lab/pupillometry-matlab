i = 1;
while true
    
% Image file
%videoPath = 'P:\Kim\Data\Pupillometry\18_05_17\LCstim\out.mp4';

% Settings
doPlot = 1;
fileSavePath = 'C:\Users\Kim\Desktop\PupilVideo\converted\';

% Run
diam{i} = pupilMeasurement(...
    'doPlot', doPlot, ...
    'videoPath', [], ...
    'fileSavePath', fileSavePath,...
    'startFrame', 10, ...
    'fitMethod', 2, ...
    'frameInterval', 5);

i = i + 1;
end