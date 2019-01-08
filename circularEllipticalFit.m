function [FI, R, rmin, rmax] = circularEllipticalFit(FI, pupilSize, frameNum, r, n, fitMethod, rmin, R)

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
