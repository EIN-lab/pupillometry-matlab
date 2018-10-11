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

    % show the frame with fitted circle and seed point on it and
    % save the image into the selected folder
%    if doPlot
%        str=sprintf('frame %d, r=%f',frameNum,r);
%        F=insertText(F,[1,1],str,'TextColor','r','BoxColor','w',...
%            'FontSize',fontsize);
%        imshow(F,'Border','tight', 'Parent', currAxes);
%        %             imshow(F,'Border','tight')
%        hold on
%        h=viscircles(o,r,'LineWidth',2.5);
%        plot(s(2),s(1),'r+')
%        filename=sprintf('frame %d.jpg',frameNum);
%        Iname=fullfile(folderPath,filename);
%        Fsave=getframe(hFigVid);
%        imwrite(Fsave.cdata,Iname);
%        hold off
%    end
    rmin = floor(r(1)*0.9);
    rmax = ceil(r(1)*1.1);
end
