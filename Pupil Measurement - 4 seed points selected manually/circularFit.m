function R=circularFit(v,seedPoints,sThres,startFrame,frameInterval,pupilSize,thresVal,fileSavePath,doPlot)
% circular fit algorithm for the input video

[vpath,vname] = fileparts(v.Name);
mkdir(fileSavePath,vname);
folderPath=fullfile(fileSavePath,vname);
sFormer=[];
n=0;

if pupilSize > 20   % no need to resize the frames
    rmin = floor(pupilSize*0.4);
    if rmin < 10
        rmin = 10;
    end
    rmax = rmin*3;
    for i=startFrame:frameInterval:v.NumberofFrames
        message = strcat('processed video : ',v.name);
        progbar(i/v.NumberofFrames,'msg',message);
        F=read(v,i);
        F=medfilt2(rgb2gray(F)); 
        S=size(F);
        
        % select one of the input seed points which is located inside the black
        % part of the pupil
        [s,sFormer] =checkSeedPoints(F,seedPoints,sThres,sFormer);
        
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
           figure,imshow(F,'Border','tight');
           h=viscircles(o,r,'LineWidth',2.5);
           hold on;
           plot(s(2),s(1),'r+')
           str=sprintf('frame %d, r=%f',i,r);
           annotation('textbox',[0.05,0.85,0.1,0.1],'string',str,'Color','r','FontWeight','bold','LineStyle','none','FontSize',20);
           filename=sprintf('frame %d.jpg',i);
           Iname=fullfile(folderPath,filename);
           Fsave=getframe(gcf);
           imwrite(Fsave.cdata,Iname);
           hold off
           close;
       end
   
        % matrix O (n*2) - coordinates of the pupil center, where n is the number of frame
        % matrix R (n*1) - radius of the pupil
        n=n+1;
        if length(r) == 2
            if abs(R(n-1,2)-r(1))>abs(R(n-1,2)-r(2))
                R(n,:)=[i,r(2)];
            else
                R(n,:)=[i,r(1)];
            end
        elseif length(r) == 1
            R(n,:)=[i,r(1)];
        end
    end
    
else % frame size will be doubled
    rmin = 10;
    rmax = rmin*3;
    for i=startFrame:frameInterval:v.NumberofFrames
        message = strcat('processed video : ',v.name);
        progbar(i/v.NumberofFrames,'msg',message);
        F=read(v,i);
        F=imresize(medfilt2(rgb2gray(F)),2); %size of the frame is doubled
        S=size(F);
        
        % select one of the input seed points which is located inside the black
        % part of the pupil
        [s,sFormer] =checkSeedPoints(F,seedPoints,sThres,sFormer);
        
        % segmentation of the image F  
        [P, J] = regionGrowing(F,s,thresVal);
        % find the boundary of the binary image and dilate it on the concave parts of boundary;
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
            figure,imshow(F,'Border','tight');
            h=viscircles(o,r,'LineWidth',2.5);
            hold on;
            plot(s(2),s(1),'r+')
            str=sprintf('frame %d, r=%f',i,r);
            annotation('textbox',[0.05,0.85,0.1,0.1],'string',str,'Color','r','FontWeight','bold','LineStyle','none','FontSize',10);
            filename=sprintf('frame %d.jpg',i);
            Iname=fullfile(folderPath,filename);
            Fsave=getframe(gcf);
            imwrite(Fsave.cdata,Iname);
            hold off
            close;
        end
        
        % matrix O (n*2) - coordinates of the pupil center, where n is the number of frame
        % matrix R (n*1) - radius of the pupil
        n=n+1;
        if length(r) == 2
            if abs(R(n-1,2)-r(1))>abs(R(n-1,2)-r(2))
                R(n,:)=[i,r(2)];
            else
                R(n,:)=[i,r(1)];
            end
        elseif length(r) == 1
            R(n,:)=[i,r(1)];
        end
    end
end
% save the matrix of Radii as a text file
Tname = fullfile(folderPath,'Pupil Radii- fitted by circle.txt');
dlmwrite(Tname,R,'newline','pc','delimiter','\t'); 

% plot the variation of the pupil radius and save it as a jpg figure.
if doPlot
    close all
    plot(R(:,1),R(:,2)), hold on;
    title('Variation of Pupil Radius - fitted by circle')
    xlabel('frame number')
    ylabel('Pupil Radius/pixel')
    Pname = fullfile(folderPath,'Variation of Pupil Radius - fitted by circle' );
    saveas(gcf,Pname,'jpg');
    hold off
    close
end

end

