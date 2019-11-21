function plotImages(frame, frameNum, folderPath, varargin)
% plotImages - Save labeled frames
%
% plotImages(frame, frameNum, folderPath)
%
% Syntax:
%   R = plotImages(frame, frameNum, folderPath)
%   R = plotImages(..., 'mode','ellipse','props',p)
%   R = plotImages(..., 'mode','circle','origin',o,'radius',r)
%
% Inputs:
%       F:          Video frame
%       frameNum:   frame Number
%       folderPath: Destination folder

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

% Check optional input arguments
pNames = {'mode', 'origin', 'radius', 'props'};
pValues = {'', [], 0, []};
params = cell2struct(pValues, pNames, 2);

% Parse function input arguments
params = utils.parsepropval2(params, varargin{:});
radius = params.radius;

% Create invisible figure
hFig = figure('visible', 'off');
hAxes = axes('Parent', hFig, 'visible', 'off');
imshow(frame,'Border','tight','Parent', hAxes);
hold(hAxes, 'on');

% Check drawing mode - ellipse or circle
switch params.mode
    case 'ellipse'
        x = params.props.Centroid(1);
        y = params.props.Centroid(2);
        radius = params.props.MajorAxisLength/2;
        b = params.props.MinorAxisLength/2;
        angle = params.props.Orientation;
        steps = 50;      
        
        beta = angle * (pi / 180);
        sinbeta = sin(beta);
        cosbeta = cos(beta);
        alpha = linspace(0, 360, steps)' .* (pi / 180);
        sinalpha = sin(alpha);
        cosalpha = cos(alpha);
        X = x + (radius * cosalpha * cosbeta - b * sinalpha * sinbeta);
        Y = y + (radius * cosalpha * sinbeta + b * sinalpha * cosbeta);
        
        plot(X,Y,'r','LineWidth',2.5, 'Parent', hAxes)
        
    case 'circle'
        viscircles(hAxes, params.origin,radius,'LineWidth',2.5);
        
    otherwise
        Warning('Unknown mode. Plotting frame without fit.');
end

% Annotate frame and save
str=sprintf('frame %d, r=%f',frameNum,radius);
annotation(hFig, 'textbox',[0.05,0.85,0.1,0.1],...
    'string',str,'Color','r','FontWeight','bold','LineStyle','none',...
    'FontSize',20);
filename=sprintf('frame_%05d.jpg',frameNum);
Iname=fullfile(folderPath,filename);
Fsave=getframe(hFig);
imwrite(Fsave.cdata,Iname);

% Close invisible figure
close(hFig);

end