function R=ellipticalFit(v,seedPoints,sThres,startFrame,frameInterval,pupilSize,thresVal,fileSavePath,doPlot)
% circular+elliptical fit algorithm for the input video

[vpath,vname] = fileparts(v.Name);
mkdir(fileSavePath,vname);
folderPath=fullfile(fileSavePath,vname);
sFormer=[];
n=0;

if doPlot
    hFigVid = figure;
    currAxes = axes;
end

while hasFrame(v)
    message = strcat('processed video : ',v.name);
    progbar(v.CurrentTime/v.Duration,'msg',message);
    F=readFrame(v);
    
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
    frameNum = round(v.CurrentTime * v.FrameRate);
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
    
    % select one of the input seed points which is located inside the black
    % part of the pupil
    [s,sFormer,seedPoints,sThres,aveGVold] = checkSeedPoints(F,seedPoints,sThres,sFormer,aveGVold);
    if isempty(s)
        continue
    end
    
    % use regionGrowing to segment the pupil
    % P is the detected pupil boundary, and J is a binary image of the pupil
    [P, J] = regionGrowing(F,s,thresVal);
    % opening operation and find the boundary of the binary image J
    B=bwboundaries(J);
    BX =B{1}(:, 2);
    BY =B{1}(:, 1);
    %expand the concave boundary and fill inside the new boundary
    k=convhull(BX,BY);
    FI = poly2mask(BX(k), BY(k),S(1) ,S(2)); %filled binary image
    n=n+1;
    
    p=regionprops(FI,'Centroid','MajorAxisLength','MinorAxisLength','Orientation','PixelList');
    PixList = p.PixelList;
    x = p.Centroid(1);
    y = p.Centroid(2);
    a = p.MajorAxisLength/2;
    b = p.MinorAxisLength/2;
    angle = p.Orientation;
    steps = 50;
    R(n,:)=[frameNum,a];
    % show the frame with fitted ellipse and seed point on it and
    % save the image into the selected folder
    if doPlot
        beta = angle * (pi / 180);
        sinbeta = sin(beta);
        cosbeta = cos(beta);
        alpha = linspace(0, 360, steps)' .* (pi / 180);
        sinalpha = sin(alpha);
        cosalpha = cos(alpha);
        X = x + (a * cosalpha * cosbeta - b * sinalpha * sinbeta);
        Y = y + (a * cosalpha * sinbeta + b * sinalpha * cosbeta);
        str=sprintf('frame %d, r=%f',frameNum,a);
        F=insertText(F,[1,1],str,'TextColor','r','BoxColor','w',...
            'FontSize',fontsize);
        imshow(F,'Border','tight', 'Parent', currAxes);
        hold on
        plot(s(2),s(1),'r+')
        plot(X,Y,'r','LineWidth',2.5)
        filename=sprintf('frame %d.jpg',frameNum);
        Iname=fullfile(folderPath,filename);
        Fsave=getframe(hFigVid);
        imwrite(Fsave.cdata,Iname);
        hold off
    end
end


% save the matrix of Radii as a text file
Tname = fullfile(folderPath,'Pupil Radii- fitted by ellipse.txt');
dlmwrite(Tname,R,'newline','pc','delimiter','\t');

% plot the variation of the pupil radius and save it as a jpg figure.
if doPlot
    figure;
    plot(R(:,1),R(:,2)), hold on;
    title('Variation of Pupil Radius - fitted by ellipse');
    xlabel('frame number');
    ylabel('Pupil Radius/pixel');
    Pname = fullfile(folderPath,'Variation of Pupil Radius - fitted by ellipse' );
    saveas(gcf,Pname,'jpg');
    hold off
end

end