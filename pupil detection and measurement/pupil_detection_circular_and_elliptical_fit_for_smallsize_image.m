clear all
clc
% input the video
v=VideoReader('2017-05-30-trial3_cropped.mp4');

% select the seed point s in one frame
F=read(v,100);
F=imresize(medfilt2(rgb2gray(F)),2);
figure,imshow(F);
s=round(ginput(1));
s=[s(2),s(1),1];
close;
% matrix O (n*2) - coordinates of the pupil center, where n is the number of frame
% matrix R (n*1) - radius of the pupil   
O=zeros(v.NumberofFrames/5,2);
R=zeros(v.NumberofFrames/5,1);
% processing of every 5th frame
for i=5:5:v.NumberofFrames
    F=read(v,i);
    F=imresize(medfilt2(rgb2gray(F)),2);
    S=size(F);
	% use regionGrowing to segment the pupil
	% P is the detected pupil boundary, and J is a binary image of the pupil
    [P, J] = regionGrowing(F,s,20);
    % opening operation and find the boundary of the binary image J
    B=bwboundaries(J);
    BX =B{1}(:, 2);
    BY =B{1}(:, 1);
    %expand the concave boundary and fill inside the new boundary
    k=convhull(BX,BY);
    FI = poly2mask(BX(k), BY(k),S(1) ,S(2)); %filled binary image
% find the origin and radius of the pupil
    [o,r]=imfindcircles(FI,[10,30],'ObjectPolarity','bright');
   
% if there are more than 1 fitted circle, use elliptical fit
    if length(r)>1
        p=regionprops(FI,'Centroid','MajorAxisLength','MinorAxisLength','Orientation','PixelList');
        PixList = p.PixelList;
        x = p.Centroid(1);
        y = p.Centroid(2);
        a = p.MajorAxisLength/2;
        b = p.MinorAxisLength/2;
        angle = p.Orientation;
        steps = 50;
        O(i/5,:)=[x,y];
        R(i/5)=a;
        theta(i/5)=angle;
        % show the frame with fitted ellipse on it and save the image into current
        % folder
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
        saveas(gcf,filename,'jpg');
        close;
% if there is only one fitted circle, 
% but its radius has big difference from the radius in the former frame , use elliptical fit 
    elseif length(r)==1 && abs(r-R((i/5)-1))>3
        p=regionprops(FI,'Centroid','MajorAxisLength','MinorAxisLength','Orientation','PixelList');
        PixList = p.PixelList;
        x = p.Centroid(1);
        y = p.Centroid(2);
        a = p.MajorAxisLength/2;
        b = p.MinorAxisLength/2;
        angle = p.Orientation;
        steps = 50;
        O(i/5,:)=[x,y];
        R(i/5)=a;
        theta(i/5)=angle;
        % show the frame with fitted ellipse on it and save the image into current
        % folder
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
        saveas(gcf,filename,'jpg');
        close;
    else
        O(i/5,:)=o
        R(i/5)=r(1);
        theta(i/5)=0;
        % show the frame with fitted circle on it and save it into current folder
        figure,imshow(F);
        h=viscircles(o,r,'LineWidth',0.001);
        hold on;
        str=sprintf('frame %d, r=%f',i,r);
        title(str);
        filename=sprintf('frame %d',i);
        saveas(gcf,filename,'jpg');
        close;
    end
end
