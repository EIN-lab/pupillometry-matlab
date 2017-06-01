function R=circularFit(v,s,frameInterval,pupilSize,thresVal,doPlot)
% circular fit algorithm for the input video

n=0;
if pupilSize > 20
    for i=1:frameInterval:v.NumberofFrames
        F=read(v,i);
        F=rgb2gray(F);
        S=size(F);
        [P, J] = regionGrowing(F,s,thresVal);
        % opening operation and find the boundary of the binary image
        B=bwboundaries(J);
        BX =B{1}(:, 2);
        BY =B{1}(:, 1);
        %expand the concave boundary and fill inside the new boundary
        k=convhull(BX,BY);
        FI = poly2mask(BX(k), BY(k),S(1) ,S(2)); %filled binary image
        % find the origin and radius of the pupil
       [o,r]=imfindcircles(FI,[10,50],'ObjectPolarity','bright');
    
        % show the frame with fitted circle on it and save it into current folder
        if doPlot
            figure,imshow(F);
            h=viscircles(o,r,'LineWidth',0.001);
            hold on;
            str=sprintf('frame %d, r=%f',i,r);
            title(str);
            filename=sprintf('frame %d',i);
            saveas(gcf,filename,'jpg');
            close;
        end
   
        % matrix O (n*2) - coordinates of the pupil center, where n is the number of frame
        % matrix R (n*1) - radius of the pupil
        n=n+1;
        if length(r)==2
            if r(1)>=r(2)
                O(n,:)=o(1,:);
                R(n)=r(1);
            else
                O(n,:)=o(2,:);
                R(n)=r(2);
            end
        else
            O(n,:)=o(1,:);
            R(n)=r(1);
        end
    end

else
    for i=1:frameInterval:v.NumberofFrames
        F=read(v,i);
        F=imresize(medfilt2(rgb2gray(F)),2);
        S=size(F);
        [P, J] = regionGrowing(F,s,thresVal);
        % find the boundary of the binary image and dilate it on the concave parts of boundary;
        B=bwboundaries(J);
        BX =B{1}(:, 2);
        BY =B{1}(:, 1);
        %expand the concave boundary and fill inside the new boundary
        k=convhull(BX,BY);
        FI = poly2mask(BX(k), BY(k),S(1) ,S(2)); %filled binary image
        % find the origin and radius of the pupil
        [o,r]=imfindcircles(FI,[10,50],'ObjectPolarity','bright');
        
        % show the frame with fitted circle on it and save it into current folder
        if doPlot
            figure,imshow(F);
            h=viscircles(o,r,'LineWidth',0.1);
            hold on;
            str=sprintf('frame %d, r=%f',i,r);
            title(str);
            filename=sprintf('frame %d',i);
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
end
% save the matrix of Radii as a text file
dlmwrite('Pupil Radii- fitted by circle.txt',R')
% plot the variation of the pupil radius and save it as a jpg figure.
if doPlot
    close all
    plot(R), hold on;
    title('Variation of Pupil Radius - fitted by circle')
    xlabel('frame number')
    ylabel('Pupil Radius/pixel')
    saveas(gcf,'Variation of Pupil Radius - fitted by circle','jpg');
end

end

