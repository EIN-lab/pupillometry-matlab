function [FI, R, rmin, rmax] = circularEllipticalFit(FI, pupilSize, frameNum, r, n, fitMethod, rmin, R)

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

nCircle = length(r);
isBig = (n==1 && abs(r-pupilSize/2)>(rmin*0.5)); % first frame
isBig = isBig || (n>1 && abs(r-R(n-1))>(Rdiff)); % subsequent frames

if (nCircle ~= 1 ||  isBig) && fitMethod ~= 1

    p=regionprops(FI,'Centroid','MajorAxisLength','MinorAxisLength','Orientation');
    a = p.MajorAxisLength/2;
    R(n,:)=[frameNum,a];
    rmin = floor(a*0.9);
    rmax = ceil(a*1.1);

else %circular fit
    if nCircle > 1
        warning('Multiple circles fitted, skipping');
        return
    end

    R(n,:)=[frameNum,r(1)];

    rmin = floor(r(1)*0.9);
    rmax = ceil(r(1)*1.1);
end
