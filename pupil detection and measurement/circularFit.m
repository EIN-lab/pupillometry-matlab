function R=circularFit(v,seedPoints,startFrame,frameInterval,pupilSize,thresVal,fileSavePath,doPlot)
% circular fit algorithm for the input video

[vpath,vname] = fileparts(v.Name);
mkdir(fileSavePath,vname);
folderPath=fullfile(fileSavePath,vname);

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
        F=rgb2gray(F);
        S=size(F);
        
        % select one of the input seed points which is located inside the black
        % part of the pupil
        s=[];
        for j=1:4
            if impixel(F,seedPoints(j,1),seedPoints(j,2)) < 100
                s=[seedPoints(j,2),seedPoints(j,1),1];
                break
            end 
        end
        % If there is no valid seed point, the user have to select a new
        % seed point for this frame
        if isempty(s)
            if isempty(sFormer)
                imshow(F),hold on
                title('No valid seed point in this frame. Please select a new seed point');
                s=round(ginput(1));
                sFormer=s;
                s=[s(2),s(1),1];
                close
            elseif ~isempty(sFormer) && impixel(F,sFormer(1),sFormer(2)) < 100
                s=[sFormer(2),sFormer(1),1];
            else
                imshow(F),hold on
                title('No valid seed point in this frame. Please select a new seed point');
                s=round(ginput(1));
                sFormer=s;
                s=[s(2),s(1),1];
                close
            end          
        end       
        
        [P, J] = regionGrowing(F,s,thresVal);
        % opening operation and find the boundary of the binary image
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
            figure,imshow(F);
            h=viscircles(o,r,'LineWidth',0.001);
            hold on;
            plot(s(2),s(1),'r+');
            str=sprintf('frame %d, r=%f',i,r);
            title(str);
            filename=sprintf('frame %d',i);
            Iname=fullfile(folderPath,filename);
            saveas(gcf,filename,'jpg');
            close;
        end
   
        % matrix O (n*2) - coordinates of the pupil center, where n is the number of frame
        % matrix R (n*1) - radius of the pupil
        n=n+1;
        if length(r)==2
            if abs(R(n)-r(1))>abs(R(n)-r(2))
                O(n,:)=o(2,:);
                R(n)=r(2);
            else
                O(n,:)=o(1,:);
                R(n)=r(1);
            end
        else
            O(n,:)=o(1,:);
            R(n)=r(1);
        end
    end

else
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
        s=[];
        for j=1:4
            if impixel(F,seedPoints(j,1),seedPoints(j,2)) < 100
                s=[seedPoints(j,2),seedPoints(j,1),1];
                break
            end
        end
        % If there is no valid seed point, the user have to select a new
        % seed point for this frame
        if isempty(s)
            if isempty(sFormer)
                imshow(F),hold on
                title('No valid seed point in this frame. Please select a new seed point');
                s=round(ginput(1));
                sFormer=s;
                s=[s(2),s(1),1];
                close
            elseif ~isempty(sFormer) && impixel(F,sFormer(1),sFormer(2)) < 100
                s=[sFormer(2),sFormer(1),1];
            else
                imshow(F),hold on
                title('No valid seed point in this frame. Please select a new seed point');
                s=round(ginput(1));
                sFormer=s;
                s=[s(2),s(1),1];
                close
            end   
        end
        
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
            figure,imshow(F);
            h=viscircles(o,r,'LineWidth',0.1);
            hold on;
            plot(s(2),s(1),'r+');
            str=sprintf('frame %d, r=%f',i,r);
            title(str);
            filename=sprintf('frame %d',i);
            Iname=fullfile(folderPath,filename);
            saveas(gcf,Iname,'jpg');
            close;
        end
        
        % matrix O (n*2) - coordinates of the pupil center, where n is the number of frame
        % matrix R (n*1) - radius of the pupil
        n=n+1;
        if length(r)==2
            if abs(R(n)-r(1))>abs(R(n)-r(2))
                O(n,:)=o(2,:);
                R(n)=r(2);
            else
                O(n,:)=o(1,:);
                R(n)=r(1);
            end
        else
            O(n,:)=o(1,:);
            R(n)=r(1);
        end
    end
end
% save the matrix of Radii as a text file
Tname = fullfile(folderPath,'Pupil Radii- fitted by circle.txt');
dlmwrite(Tname,R);

% plot the variation of the pupil radius and save it as a jpg figure.
if doPlot
    close all
    plot(R), hold on;
    title('Variation of Pupil Radius - fitted by circle')
    xlabel('frame number')
    ylabel('Pupil Radius/pixel')
    Pname = fullfile(folderPath,'Variation of Pupil Radius - fitted by circle' );
    saveas(gcf,Pname,'jpg');
end

end

