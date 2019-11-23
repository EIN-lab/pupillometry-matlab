function [s,sFormer,seedPoints,sThres,avgIntensity] = checkSeedPoints(F,...
    seedPoints,sThres,sFormer,avgIntensityOld,skipBadFrames)
% checkSeedPoints - check or select a valid seed point whose gray value is
% lower than the sThres on image F.

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

s = [];
val = [];

% the gray-value threshould for seed points, sThres is varied with the
% average gray value on current frame.
avgIntensity = mean(mean(F));

% check that the correction factor isn't too big
if abs(avgIntensity - avgIntensityOld) < sThres
    sThres = sThres + (avgIntensity - avgIntensityOld);
end
avgIntensityOld = avgIntensity;

% Make sure we have a valid seed point
for j=1:size(seedPoints,1)
    val(j) = min(impixel(F,seedPoints(j,1),seedPoints(j,2)));
end
idx = val < sThres;

if any(idx)
    [~, sIdx] = min(val);
    s = [seedPoints(sIdx,2),seedPoints(sIdx,1),1];
end

% If there is no valid seed point, the user have to select a new
% seed point for this frame
if isempty(s)
    if ~isempty(sFormer) && any(impixel(F,sFormer(1),sFormer(2)) <= sThres)
        s=sFormer;
    elseif skipBadFrames
        s = [];
        return
    elseif (isempty(sFormer) || any(impixel(F,sFormer(1),sFormer(2)) > sThres))
        hFig = figure;
        hAxes = axes;
        imshow(F, 'Parent', hAxes)
        title({'No valid seed point in this frame.', 'Please select a new seed point inside the pupil.'});
        try s=round(ginput(1));
        catch ME
            if (strcmp(ME.message,'Interrupted by figure deletion'))
                s=[];
                return
            else
                rethrow(ME)
            end
        end
        delete(hFig);
        %         % check the gray value of the seed point

        while any(impixel(F,s(1),s(2)) > sThres)
            warning(['The selected pixel is too bright. Please select another ', ...
                'seed point inside the pupil.']);
            hFig = figure;
            hAxes = axes;
            imshow(F, 'Parent', hAxes)
            title({'Please select another seed point inside the pupil.', 'Close window to skip this frame.'});
            try s=round(ginput(1));
            catch ME
                if (strcmp(ME.message,'Interrupted by figure deletion'))
                    s=[];
                    return
                else
                    rethrow(ME)
                end
            end
            delete(hFig);
            %         trials = trials + 1;
        end
    end

%             sFormer=s;
    if ~isempty(s)
        seedPoints = [seedPoints;s(1),s(2)];
        sFormer=s;
        s=[s(2),s(1),1];
    end
end
end
