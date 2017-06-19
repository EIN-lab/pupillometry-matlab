function R=ellipticalFit(v,seedPoints,startFrame,frameInterval,pupilSize,thresVal,fileSavePath,doPlot)
% circular+elliptical fit algorithm for the input video

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
                % check the gray value of the seed point
                while any(impixel(F,s(1),s(2)) > 100)
                    warning(['The selected pixel is too bright!Please select another ', ...
                        'seed point inside the BLACK PART OF THE PUPIL!']);
                    hFig = imshow(F);
                    hold on
                    title('Please select another seed point inside the BLACK PART OF THE PUPIL!');
                    s=round(ginput(1));
                end
                sFormer=s;
                s=[s(2),s(1),1];
                close
            else
                if impixel(F,sFormer(1),sFormer(2)) <= 100
                    s=[sFormer(2),sFormer(1),1];
                else
                    hFig =imshow(F);
                    hold on
                    title('No valid seed point in this frame. Please select a new seed point');
                    s=round(ginput(1));
                    % check the gray value of the seed point
                    while any(impixel(F,s(1),s(2))> 100)
                        warning(['The selected pixel is too bright!Please select another ', ...
                            'seed point inside the BLACK PART OF THE PUPIL!']);
                        hFig = imshow(F);
                        hold on
                        title('Please select another seed point inside the BLACK PART OF THE PUPIL!');
                        s=round(ginput(1));
                    end
                    sFormer=s;
                    s=[s(2),s(1),1];
                    hold off
                    delete(hFig);
                end
            end
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
        % find the origin and radius of the pupil
        n=n+1;
        % if there are more than 1 fitted circle, use elliptical fit, or
        % there is only one fitted circle, but its radius has big
        % difference(0.2*rmin) from the radius in the former frame,
        % use elliptical fit
        
        p=regionprops(FI,'Centroid','MajorAxisLength','MinorAxisLength','Orientation','PixelList');
        PixList = p.PixelList;
        x = p.Centroid(1);
        y = p.Centroid(2);
        a = p.MajorAxisLength/2;
        b = p.MinorAxisLength/2;
        angle = p.Orientation;
        steps = 50;
        R(n)=a;
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
            figure,imshow(F);
            hold on;
            plot(s(2),s(1),'r+')
            plot(X,Y,'r','LineWidth',0.01)
            str=sprintf('frame %d, a=%f, b=%f',i,a,b);
            title(str);
            filename=sprintf('frame %d',i);
            Iname=fullfile(folderPath,filename);
            saveas(gcf,Iname,'jpg');
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
                % check the gray value of the seed point
                while any(impixel(F,s(1),s(2)) > 100)
                    warning(['The selected pixel is too bright!Please select another ', ...
                        'seed point inside the BLACK PART OF THE PUPIL!']);
                    hFig = imshow(F);
                    hold on
                    title('Please select another seed point inside the BLACK PART OF THE PUPIL!');
                    s=round(ginput(1));
                end
                sFormer=s;
                s=[s(2),s(1),1];
                close
            else
                if impixel(F,sFormer(1),sFormer(2)) <= 100
                    s=[sFormer(2),sFormer(1),1];
                else
                    hFig =imshow(F);
                    hold on
                    title('No valid seed point in this frame. Please select a new seed point');
                    s=round(ginput(1));
                    % check the gray value of the seed point
                    while any(impixel(F,s(1),s(2))> 100)
                        warning(['The selected pixel is too bright!Please select another ', ...
                            'seed point inside the BLACK PART OF THE PUPIL!']);
                        hFig = imshow(F);
                        hold on
                        title('Please select another seed point inside the BLACK PART OF THE PUPIL!');
                        s=round(ginput(1));
                    end
                    sFormer=s;
                    s=[s(2),s(1),1];
                    hold off
                    delete(hFig);
                end
            end
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
        % if there are more than 1 fitted circle, use elliptical fit, or
        % there is only one fitted circle, but its radius has big
        % difference (2.5) from the radius in the former frame,
        % use elliptical fit
        
        p=regionprops(FI,'Centroid','MajorAxisLength','MinorAxisLength','Orientation','PixelList');
        PixList = p.PixelList;
        x = p.Centroid(1);
        y = p.Centroid(2);
        a = p.MajorAxisLength/2;
        b = p.MinorAxisLength/2;
        angle = p.Orientation;
        steps = 50;
        R(n)=a;
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
            figure,imshow(F);
            hold on;
            plot(s(2),s(1),'r+')
            plot(X,Y,'r','LineWidth',0.01)
            str=sprintf('frame %d, a=%f, b=%f',i,a,b);
            title(str);
            filename=sprintf('frame %d',i);
            Iname=fullfile(folderPath,filename);
            saveas(gcf,Iname,'jpg');
            close;
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
    Pname = fullfile(folderPath,'Variation of Pupil Radius - fitted by ellipse' );
    saveas(gcf,Pname,'jpg');
end

end