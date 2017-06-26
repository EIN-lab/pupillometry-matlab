function R=ellipticalFit(v,sFirst,sThres,startFrame,frameInterval,pupilSize,thresVal,fileSavePath,doPlot)
% elliptical fit algorithm for the input video

% creat a new folder to save the radii text and the processed frames
[vpath,vname] = fileparts(v.Name);
mkdir(fileSavePath,vname);
folderPath=fullfile(fileSavePath,vname);
sFormer=[];
n=0;

if pupilSize > 20   % no need to resize the frames
    for i=startFrame:frameInterval:v.NumberofFrames
        message = strcat('processed video : ',v.name);
        progbar(i/v.NumberofFrames,'msg',message);
        F=read(v,i);
        F=medfilt2(rgb2gray(F));
        S=size(F);
        
        % select one of the input seed points which is located inside the black
        % part of the pupil
        [s,sFormer] = checkSeedPoint(F,sFirst,sThres,sFormer);
        
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
        
        % use elliptical fit        
        p=regionprops(FI,'Centroid','MajorAxisLength','MinorAxisLength','Orientation','PixelList');
        PixList = p.PixelList;
        x = p.Centroid(1);
        y = p.Centroid(2);
        a = p.MajorAxisLength/2;
        b = p.MinorAxisLength/2;
        angle = p.Orientation;
        steps = 50;
        R(n,:)=[i,a];
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
            figure,imshow(F,'Border','tight');
            hold on;
            plot(s(2),s(1),'r+')
            plot(X,Y,'r','LineWidth',2.5)
            str=sprintf('frame %d, r=%f',i,a);
            annotation('textbox',[0.05,0.85,0.1,0.1],'string',str,'Color','r','FontWeight','bold','LineStyle','none','FontSize',20);
            filename=sprintf('frame %d.jpg',i);
            Iname=fullfile(folderPath,filename);
            Fsave=getframe(gcf);
            imwrite(Fsave.cdata,Iname);
            hold off
            close;
        end
        
    end
    
else % size of the frame need to be doubled
    for i=startFrame:frameInterval:v.NumberofFrames
        message = strcat('processed video : ',v.name);
        progbar(i/v.NumberofFrames,'msg',message);
        F=read(v,i);
        F=imresize(medfilt2(rgb2gray(F)),2);
        S=size(F);
        
        % select one of the input seed points which is located inside the black
        % part of the pupil
        [s,sFormer] = checkSeedPoint(F,sFirst,sThres,sFormer);
        
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
        n=n+1;
        % use elliptical fit       
        p=regionprops(FI,'Centroid','MajorAxisLength','MinorAxisLength','Orientation','PixelList');
        PixList = p.PixelList;
        x = p.Centroid(1);
        y = p.Centroid(2);
        a = p.MajorAxisLength/2;
        b = p.MinorAxisLength/2;
        angle = p.Orientation;
        steps = 50;
        R(n,:)=[i,a]; 
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
            figure,imshow(F,'Border','tight');
            hold on;
            plot(s(2),s(1),'r+')
            plot(X,Y,'r','LineWidth',2.5)
            str=sprintf('frame %d, r=%f',i,a);
            annotation('textbox',[0.05,0.85,0.1,0.1],'string',str,'Color','r','FontWeight','bold','LineStyle','none','FontSize',10);
            filename=sprintf('frame %d.jpg',i);
            Iname=fullfile(folderPath,filename);
            Fsave=getframe(gcf);
            imwrite(Fsave.cdata,Iname);
            hold off
            close;
        end
        
    end
end

% save the matrix of Radii as a text file
Tname = fullfile(folderPath,'Pupil Radii- fitted by ellipse.txt');
dlmwrite(Tname,R,'newline','pc','delimiter','\t');

% plot the variation of the pupil radius and save it as a jpg figure.
if doPlot
    close all
    plot(R(:,1),R(:,2)), hold on;
    title('Variation of Pupil Radius - fitted by ellipse');
    xlabel('frame number');
    ylabel('Pupil Radius/pixel');
    Pname = fullfile(folderPath,'Variation of Pupil Radius - fitted by ellipse' );
    saveas(gcf,Pname,'jpg');
    hold off
    close
end

end