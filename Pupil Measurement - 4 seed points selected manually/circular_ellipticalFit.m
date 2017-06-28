function R=circular_ellipticalFit(v,seedPoints,sThres,startFrame,frameInterval,pupilSize,thresVal,fileSavePath,doPlot)
% circular+elliptical fit algorithm for the input video

% creat a new folder to save the radii text and the processed frames
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

%
rmin = floor(pupilSize*0.4);
if rmin <10
    rmin = 10;
end
rmax = rmin*3;
while hasFrame(v)
    message = strcat('processed video : ',v.name);
    progbar(v.CurrentTime/v.Duration,'msg',message);
    F=readFrame(v);
    
    % Increment video reader
    v.CurrentTime = min(v.CurrentTime + (frameInterval/v.FrameRate), v.Duration);
    F=medfilt2(rgb2gray(F));
    if pupilSize < 20
        F = imresize(F, 2);
    end
    S=size(F);
    
    % select one of the input seed points which is located inside the black
    % part of the pupil
    [s,sFormer,seedPoints] =checkSeedPoints(F,seedPoints,sThres,sFormer);
    
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
    % find the origin and radius of the pupil
    [o,r]=imfindcircles(FI,[rmin,rmax],'ObjectPolarity','bright');
    if isempty(r)
        [o,r]=imfindcircles(FI,[rmax,rmax*2],'ObjectPolarity','bright');
    end
    n=n+1;
    % if there are more than 1 fitted circle, use elliptical fit, or
    % there is only one fitted circle, but its radius has big
    % difference(0.2*rmin) from the radius in the former frame,
    % use elliptical fit
    if (length(r)>1) || (length(r) == 0) ||...
            (length(r)==1 && n==1 && abs(r-pupilSize/2)>(rmin*0.5)) ||...
            (length(r)==1 && n>1 && abs(r-R(n-1))>(rmin*0.2))
        
        p=regionprops(FI,'Centroid','MajorAxisLength','MinorAxisLength','Orientation','PixelList');
        PixList = p.PixelList;
        x = p.Centroid(1);
        y = p.Centroid(2);
        a = p.MajorAxisLength/2;
        b = p.MinorAxisLength/2;
        angle = p.Orientation;
        steps = 50;
        R(n,:)=[n,a];
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
            imshow(F,'Border','tight', 'Parent', currAxes);
            hold on
            plot(s(2),s(1),'r+')
            plot(X,Y,'r','LineWidth',2.5)
            str=sprintf('frame %d, r=%f',n,a);
            annotation('textbox',[0.05,0.85,0.1,0.1],'string',str,...
                'Color','r','FontWeight','bold','LineStyle','none','FontSize',20);
            filename=sprintf('frame %d.jpg',n);
            Iname=fullfile(folderPath,filename);
            Fsave=getframe(hFigVid);
            imwrite(Fsave.cdata,Iname);
            hold off
        end
        
    else
        R(n,:)=[n,r(1)];
        
        % show the frame with fitted circle and seed point on it and
        % save the image into the selected folder
        if doPlot
            imshow(F,'Border','tight', 'Parent', currAxes);
            hold on
            h=viscircles(o,r,'LineWidth',2.5);
            plot(s(2),s(1),'r+')
            str=sprintf('frame %d, r=%f',n,r);
            annotation('textbox',[0.05,0.85,0.1,0.1],'string',str,'Color','r','FontWeight','bold','LineStyle','none','FontSize',20);
            filename=sprintf('frame %d.jpg',n);
            Iname=fullfile(folderPath,filename);
            Fsave=getframe(hFigVid);
            imwrite(Fsave.cdata,Iname);
            hold off
        end
    end
end

if doPlot
    delete(hFigVid)
end
% save the matrix of Radii as a text file
Tname = fullfile(folderPath,'Pupil Radii- fitted by ellipse and circle.txt');
dlmwrite(Tname,R,'newline','pc','delimiter','\t');

% plot the variation of the pupil radius and save it as a jpg figure.
if doPlot
    figure;
    plot(R), hold on;
    title('Variation of Pupil Radius - fitted by ellipse');
    xlabel('frame number');
    ylabel('Pupil Radius/pixel');
    Pname = fullfile(folderPath,'Variation of Pupil Radius - fitted by circle and ellipse' );
    saveas(gcf,Pname,'jpg');
    hold off
end