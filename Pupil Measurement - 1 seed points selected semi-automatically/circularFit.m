function R=circularFit(v,seedPoints,sThres,startFrame,frameInterval,pupilSize,thresVal,fileSavePath,doPlot)
% circular fit algorithm for the input video

[vpath,vname] = fileparts(v.Name);
mkdir(fileSavePath,vname);
folderPath=fullfile(fileSavePath,vname);
sFormer=[];
n=0;

% initialize axes if necessary
if doPlot
    hFigVid = figure;
    currAxes = axes;
end

rmin = floor(pupilSize*0.4);
if rmin <10
    rmin = 10;
end
rmax = rmin*3;


while hasFrame(v)
    message = strcat('processed video : ',v.name);
    progbar(v.CurrentTime/v.Duration,'msg',message);
    F=readFrame(v);
    frameNum = round(v.CurrentTime * v.FrameRate);
	
    % Increment video reader
    v.CurrentTime = min(v.CurrentTime + (frameInterval/v.FrameRate), v.Duration);
    if v.CurrentTime == v.Duration
        if ~exist('trail')
            v.CurrentTime = v.Duration;
            trail = 2;
        else
            break
        end
    end
    
    F=medfilt2(rgb2gray(F));
    if pupilSize < 20
        F = imresize(F, 2);
    end
    
    if n == 0
        aveGVold = mean(mean(F));
    end
    
    S=size(F);
    if S(2) > 300
        fontsize = 20;
    else
        fontsize = 10;
    end
    
    [s,sFormer,seedPoints,sThres,aveGVold] = checkSeedPoints(F,seedPoints,sThres,sFormer,aveGVold);
    if isempty(s)
        continue
    else
        n = n+1;
    end
    
    % segmentation of the image F
    [P, J] = regionGrowing(F,s,thresVal);
    % opening operation and find the boundary of the binary image J
    B=bwboundaries(J);
    BX =B{1}(:, 2);
    BY =B{1}(:, 1);
    %expand the concave boundary and fill inside the new boundary
    k=convhull(BX,BY);
    FI = poly2mask(BX(k), BY(k),S(1) ,S(2)); %filled binary image
    % find the origin and radius of the pupil
    [o,r]=imfindcircles(FI,[rmin,rmax],'ObjectPolarity','bright');
    if isempty(r)
        [o,r]=imfindcircles(FI,[rmax,rmax*2],'ObjectPolarity','bright');
    end
    
    
    % show the frame with fitted circle and seed point on it and save
    % it into the selected folder
    if doPlot
        str=sprintf('frame %d, r=%f   %f',frameNum,r);
        F=insertText(F,[1,1],str,'TextColor','r','BoxColor','w',...
            'FontSize',fontsize);
        imshow(F,'Border','tight', 'Parent', currAxes);
        hold on
        h=viscircles(o,r,'LineWidth',2.5);
        plot(s(2),s(1),'r+')
        filename=sprintf('frame %d.jpg',frameNum);
        Iname=fullfile(folderPath,filename);
        Fsave=getframe(hFigVid);
        imwrite(Fsave.cdata,Iname);
        hold off
    end
    
    % matrix O (n*2) - coordinates of the pupil center, where n is the number of frame
    % matrix R (n*1) - radius of the pupil
    
    if length(r) == 2 
        if n ~= 1
        [~,rminIndex]= min((abs(R((n-1),2)-r(:))));
        R(n,:)=[frameNum,r(rminIndex)];
        else
            R(n,:)=[frameNum,r(1)];
        end
    elseif length(r) == 1
        R(n,:)=[frameNum,r(1)];
    end
end

% save the matrix of Radii as a text file
Tname = fullfile(folderPath,'Pupil Radii- fitted by circle.txt');
dlmwrite(Tname,R,'newline','pc','delimiter','\t');

% plot the variation of the pupil radius and save it as a jpg figure.
if doPlot
    figure;
    plot(R(:,1),R(:,2)), hold on;
    title('Variation of Pupil Radius - fitted by circle')
    xlabel('frame number')
    ylabel('Pupil Radius/pixel')
    Pname = fullfile(folderPath,'Variation of Pupil Radius - fitted by circle' );
    saveas(gcf,Pname,'jpg');
    hold off
end
end