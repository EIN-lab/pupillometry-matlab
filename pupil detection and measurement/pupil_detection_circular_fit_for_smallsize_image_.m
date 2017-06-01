
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% processing of one frame %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % input the video
% v=VideoReader('2017-05-30-trial1_cropped.mp4');
% % read one frame and conver it to gray image
% frame1=read(v,100);
% frame1gray=imresize(medfilt2(rgb2gray(frame1)),2);
% 
% %segmentation of the pupil with funciton 'regionGrowing'
% [P, J] = regionGrowing(frame1gray,[],20);
% % find the center and radius of the pupil 
% [o,r]=imfindcircles(J,[10,100],'ObjectPolarity','bright')
% % show the circle on the gray image
% figure,imshow(frame1gray)
% h=viscircles(o,r,'LineWidth',0.001);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% processing of every 5th frame %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% input the video
v=VideoReader('2017-05-30-trial3_cropped.mp4');

% select the seed point s in one frame
F=read(v,100);
F=imresize(medfilt2(rgb2gray(F)),2);
figure,imshow(F);
s=round(ginput(1));
s=[s(2),s(1),1];
close;


% processing of every 5th frame
for i=5:5:v.NumberofFrames
    F=read(v,i);
    F=imresize(medfilt2(rgb2gray(F)),2);
    S=size(F);
    [P, J] = regionGrowing(F,s,20);
% find the boundary of the binary image and dilate it on the concave parts of boundary;
    B=bwboundaries(J);
    BX =B{1}(:, 2);
    BY =B{1}(:, 1);
    %expand the concave boundary and fill inside the new boundary
    k=convhull(BX,BY);
    FI = poly2mask(BX(k), BY(k),S(1) ,S(2)); %filled binary image
% find the origin and radius of the pupil
    [o,r]=imfindcircles(FI,[10,30],'ObjectPolarity','bright');
    
% show the frame with fitted circle on it and save it into current folder
    figure,imshow(F);
    h=viscircles(o,r,'LineWidth',0.1);
    hold on;
    str=sprintf('frame %d, r=%f',i,r);
    title(str);
    filename=sprintf('frame %d',i);
    saveas(gcf,filename,'jpg');
    close;
   
% matrix O (n*2) - coordinates of the pupil center, where n is the number of frame
% matrix R (n*1) - radius of the pupil   
    if length(r)==2
        if abs(R(i/5)-r(1))>abs(R(i/5)-r(2))
            O(i/5,:)=o(2,:);
            R(i/5)=r(2);
        else
            O(i/5,:)=o(1,:);
            R(i/5)=r(1);
        end
    else
        O(i/5,:)=o(1,:);
        R(i/5)=r(1);
    end
end
