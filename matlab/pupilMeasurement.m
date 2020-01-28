function allR = pupilMeasurement(varargin)
% Pupil Detection and Measurement Algorithm for Videos
%
% R = pupilMeasurement(fitMethod, doPlot, thresVal, frameInterval, videoPath,
% fileSavePath, startFrame, pupilSize)
%
% Syntax:
%   R = pupilMeasurement()
%   R = pupilMeasurement('fitMethod',1,'frameInterval',50,...)
%
% Inputs:
%       fitMethod:  1 - circular fit(if pupils are almost circular, 
%                       doesn't perform very well);
%                   2 - circular and elliptical fit.
%                   Default = 2
%
%       spSelect:   Whether to estimate seedpoint from darkest point
%                   ('line') or manually selecting 4 seed points
%                   ('points').
%                   Default = 'line'
%
%       doPlot:     Whether to show a live plot of measured radii.
%                   Default = false
%
%       thresVal:   Threshold for the region-growing segmentation, which
%                   stands for the difference of the gray values between
%                   the pupil and the iris of the eye. Values from 15 to 30
%                   are reasonable for normal cases.
%                   Default = []
%
%       frameInterval: The interval between processed frames.
%                      Default = 5
%
%       videoPath:  A path or cell array of paths to the file(s) to
%                   process. Leave empty to prompt user for selection.
%                   Default = []
%
%       fileSavePath: A path to the folder where results are stored. Leave
%                     empty to prompt user for selection.
%                     Default = []
%
%       startFrame: The first frame to be processed.
%                   Default = 1
%
%       enhanceContrast: Flag whether to attempt automatic contrast
%                        enhancement.
%                        Default = false
%
%       doCrop:     Flag whether to promt user for cropping of video.
%                   Default = false
%
%       skipBadFrames: Flag whether to skip bad frames automatically.
%                      Default = false
%
%       fillBadData: Which method to apply to fill bad data (i.e. skipped
%                    frames). Options are:
%                       'previous'  - Previous non-missing entry.
%                       'next'      - Next non-missing entry.
%                       'nearest'   - Nearest non-missing entry.
%                       'movmean'   - Moving average of neighboring non-missing entries.
%                       'movmedian' - Moving median of neighboring non-missing entries.
%
%                       Note: 'movmean' and 'movmeadian' will only fill data,
%                       if less than 5 subsequent values are missing.
%                       Otherwise, NaNs will be filled in.
%
%       saveLabeledFrames:  Whether or not to also save labeled frames to
%                           the results folder. 
%                           Default = false
%
%       pixelSize:  The size of a single pixel in mm. If pixelSize is
%                   provided, output will be given in mm instead of pixels.
%                   Default = []
%
% Output:
%       R:  A 1*n cell which contain the radii of the pupil in each
%       processed frame, and these radii will be saved as a csv file
%

%   Copyright (C) 2019  Mattia Privitera, Kim David Ferrari et al.
%
%   This program is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This program is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this program.  If not, see <http://www.gnu.org/licenses/>.

% Declare a persistent variable to remeber file save location
persistent fnGuess

% Check all the input arguments
pNames = {'fitMethod', 'spSelect', 'doPlot', 'thresVal', 'frameInterval', ...
    'videoPath', 'fileSavePath', 'startFrame', 'enhanceContrast', 'doCrop', ...
    'skipBadFrames', 'fillBadData', 'saveLabeledFrames', 'pixelSize'};
pValues = {2, 'line', false, [], 5, ...
    [], [], 1, false, false, ...
    true, 'movmedian', false, []};
params = cell2struct(pValues, pNames, 2);

% Parse function input arguments
params = utils.parsepropval2(params, varargin{:});

spSelect = params.spSelect;
videoPath = params.videoPath;
startFrame = params.startFrame;
enhanceContrast = params.enhanceContrast;
doCrop = params.doCrop;

% Select videos
if isempty(videoPath)
    [vname, vpath] = uigetfile({'*.mp4;*.m4v;*.avi;*.mov;*.mpg'},...
        'Please select the video file(s)',fnGuess,'multiselect','on');
    if isnumeric(vname) && vname == 0
        error('Please select a file to load')
    end
    videoPath = fullfile(vpath, vname);
end

% convert videoPath to cell
videoPath = cellstr(videoPath);
numVideos = numel(videoPath);

% Remember videoPath for next run
if ~exist('vpath','var')
    vpath = fileparts(videoPath{1});
end
fnGuess = vpath;

% Check the fitMethod
if ~isfinite(params.fitMethod) || ~isscalar(params.fitMethod)
    error('''fitMethod'' must be a scalar, finite value.')
end

if ~(floor(params.fitMethod) == params.fitMethod)
    error('''fitMethod'' must be an integer value.')
end

if ~any(params.fitMethod == [1, 2])
    error('''fitMethod'' must be one of [1, 2].')
end

% Check spSelect
if ~ischar(params.spSelect)
    error('''spSelect must'' be a character array')
end

% Check fillBadData
if ~any(strcmp(params.fillBadData, ...
        {'nan', 'movmedian', 'movmean', 'previous', 'linear', 'next', 'nearest'}))
    error(['''fillBadData'' must be one of [''nan'', ''movmedian'' , ', ...
        '''movmean'', ''previous'', ''linear'', ''next'', ''nearest'']']);
end

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

% Check the frame interval
if ~(floor(params.frameInterval) == params.frameInterval)
    error('''frameInterval'' must be an integer value.')
end

% Check the threshold value for the region growing segmentation
if floor(params.thresVal) ~= params.thresVal
    error('''threshVal'' must be an integer value.')
end

% Check doPlot flag
try
    logical(params.doPlot);
catch
    error('''doPlot'' must be convertible to logical.')
end

% Check enhanceContrast flag
try
    logical(params.enhanceContrast );
catch
    error('''enhanceContrast '' must be convertible to logical.')
end

% Check if the user wants to see a plot
try
    logical(params.skipBadFrames);
catch
    error('''skipBadFrames'' must be convertible to logical.')
end

% Select the folder to save all the processed images and radii text
if isempty(params.fileSavePath)
    params.fileSavePath = uigetdir(vpath,'Please create or select a folder to save the processed images and radii text');
end

% Check saveLabeledFrames flag
try
    logical(params.saveLabeledFrames);
catch
    error('''saveLabeledFrames'' must be convertible to logical.')
end

%% Start to process the videos
R = cell(1,numVideos);
for j=1:numVideos
    
    % Read video frames while available
    v = VideoReader(videoPath{j});
    
    % Set video start time
    v.CurrentTime = startFrame/v.FrameRate;
    F = rgb2gray(readFrame(v));
    
    % Close video reader
    clearvars v
    
    % Auto-adjust image contrast
    if enhanceContrast
        F = imadjust(F);
    end
    
    % pre-processing: crop
    mask = 1;
    if doCrop
        hFig = figure; hImgData = imshow(F);
        
        strInstructions = 'Double click inside to complete the ROI.';
        strFigTitle = sprintf('Select a square ROI to crop.\n%s', ...
            strInstructions);
        
        roiFun = @imrect;
        title(strFigTitle);
        hImPoly = roiFun();
        wait(hImPoly);
        mask = hImPoly.createMask(hImgData);
        
        close(hFig)
        
        xDim = any(mask, 1);
        yDim = any(mask, 2);
        rectDims = [sum(yDim), sum(xDim)];
        F = reshape(F(mask), rectDims);
    end
    
    % Ask the user to draw a line across the pupil
    hFig = figure('units','normalized','outerposition',[0 0 1 1]); imshow(F);
    
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
            sThresh = max(sThresh, 50); % fix for really dark pupils
            
            % Seed Point Selection
            %[~, indexc] = min(c);
            if pupilSize > 20
                seedPoints=[round(cx), round(cy)];
            else
                cx2 = round(cx*2);
                cy2 = round(cy*2);
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
    v = VideoReader(videoPath{j});
    R = doFit(v, pupilSize, seedPoints, sThresh, params, mask);
    
    switch params.fillBadData
        case 'nan'
            % do nothing
        case {'movmedian', 'movmean'}
            R = fillmissing(R, params.fillBadData, 5);
        otherwise
            R = fillmissing(R, params.fillBadData);
    end
    
    % convert to mm, if pixel size was provided
    if ~isempty(params.pixelSize)
        R(:,2) = R(:,2) .* params.pixelSize;
    end
    
    % save the matrix or cell of R as a .mat file
    [~, fname] = fileparts(v.name);
    radiiMat=fullfile(params.fileSavePath, [fname, '_radii.mat']);
    save(radiiMat, 'R');
    
    % save the matrix of Radii as a csv file
    Tname = fullfile(params.fileSavePath, [fname, 'Pupil Radii.csv']);
    dlmwrite(Tname,R,'newline','pc','delimiter',';');

    allR{j} = R;
end
end
