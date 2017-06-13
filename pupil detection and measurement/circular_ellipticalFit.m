function R=circular_ellipticalFit(v,s,startFrame,frameInterval,pupilSize,thresVal,fileSavePath,doPlot)
% circular+elliptical fit algorithm for the input video

[vpath,vname] = fileparts(v.Name);
mkdir(fileSavePath,vname);
folderPath=fullfile(fileSavePath,vname);

n=0;
if pupilSize > 20   % no need to resize the frames
    rmin = floor(pupilSize*0.4);
    if rmin <10
        rmin = 10;
    end
    rmax = rmin*3;
    for i=startFrame:frameInterval:v.NumberofFrames
        F=read(v,i);
        F=medfilt2(rgb2gray(F));
        S=size(F);
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
                (length(r)==1 && n==1 && abs(r-rmin)>(rmin*0.2)) ||...
                (length(r)==1 && n>1 && abs(r-R(n-1))>(rmin*0.2))
            
            p=regionprops(FI,'Centroid','MajorAxisLength','MinorAxisLength','Orientation','PixelList');
            PixList = p.PixelList;
            x = p.Centroid(1);
            y = p.Centroid(2);
            a = p.MajorAxisLength/2;
            b = p.MinorAxisLength/2;
            angle = p.Orientation;
            steps = 50;
            R(n)=a;
            % show the frame with fitted ellipse on it and save the image into current
            % folder
            if doPlot
                beta = angle * (pi / 180);
                sinbeta = sin(beta);
                cosbeta = cos(beta);
                alpha = linspace(0, 360, steps)' .* (pi / 180);
                sinalpha = sin(alpha);
                cosalpha = cos(alpha);
                X = x + (a * cosalpha * cosbeta - b * sinalpha * sinbeta);
                Y = y + (a * cosalpha * sinbeta + b * sinalpha * cosbeta);
                figure,imshow(F);
                hold on;
                plot(X,Y,'r','LineWidth',0.01)
                str=sprintf('frame %d, a=%f, b=%f',i,a,b);
                title(str);
                filename=sprintf('frame %d',i);
                Iname=fullfile(folderPath,filename);
                saveas(gcf,Iname,'jpg');
                close;
            end
            
        else
            R(n)=r(1);
            
            % show the frame with fitted circle on it and save it into current folder
            if doPlot
                figure,imshow(F);
                h=viscircles(o,r,'LineWidth',0.001);
                hold on;
                str=sprintf('frame %d, r=%f',i,r);
                title(str);
                filename=sprintf('frame %d',i);
                Iname=fullfile(folderPath,filename);
                saveas(gcf,Iname,'jpg');
                close;
            end
        end
    end
    
else % size of the frame need to be doubled
    rmin = 10;
    rmax = rmin*3;
    for i=startFrame:frameInterval:v.NumberofFrames
        F=read(v,i);
        F=imresize(medfilt2(rgb2gray(F)),2);
        S=size(F);
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
        % difference (2.5) from the radius in the former frame,
        % use elliptical fit
        if (length(r)>1) ||(length(r) == 0)||...
                (length(r)==1 && n==1 && abs(r-pupilSize/2)>2.5) ||...
                (length(r)==1 && n>1 && abs(r-R(n-1))>2.5)
           
            p=regionprops(FI,'Centroid','MajorAxisLength','MinorAxisLength','Orientation','PixelList');
            PixList = p.PixelList;
            x = p.Centroid(1);
            y = p.Centroid(2);
            a = p.MajorAxisLength/2;
            b = p.MinorAxisLength/2;
            angle = p.Orientation;
            steps = 50;
            R(n)=a;
            % show the frame with fitted ellipse on it and save the image into current
            % folder
            if doPlot
                beta = angle * (pi / 180);
                sinbeta = sin(beta);
                cosbeta = cos(beta);
                alpha = linspace(0, 360, steps)' .* (pi / 180);
                sinalpha = sin(alpha);
                cosalpha = cos(alpha);
                X = x + (a * cosalpha * cosbeta - b * sinalpha * sinbeta);
                Y = y + (a * cosalpha * sinbeta + b * sinalpha * cosbeta);
                figure,imshow(F);
                hold on;
                plot(X,Y,'r','LineWidth',0.01)
                str=sprintf('frame %d, a=%f, b=%f',i,a,b);
                title(str);
                filename=sprintf('frame %d',i);
                Iname=fullfile(folderPath,filename);
                saveas(gcf,Iname,'jpg');
                close;
            end
        else
            R(n)=r(1);
            % show the frame with fitted circle on it and save it into current folder
            if doPlot
                figure,imshow(F);
                h=viscircles(o,r,'LineWidth',0.001);
                hold on;
                str=sprintf('frame %d, r=%f',i,r);
                title(str);
                filename=sprintf('frame %d',i);
                Iname=fullfile(folderPath,filename);
                saveas(gcf,Iname,'jpg');
                close;
            end
        end
    end
end

% save the matrix of Radii as a text file
Tname = fullfile(folderPath,'Pupil Radii- fitted by ellipse and circle.txt');
dlmwrite(Tname,R)

% plot the variation of the pupil radius and save it as a jpg figure.
if doPlot
    close all
    plot(R), hold on;
    title('Variation of Pupil Radius - fitted by ellipse');
    xlabel('frame number');
    ylabel('Pupil Radius/pixel');
    Pname = fullfile(folderPath,'Variation of Pupil Radius - fitted by circle and ellipse' );
    saveas(gcf,Pname,'jpg');
end

end