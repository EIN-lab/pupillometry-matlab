
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% processing of one frame %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% input the video
v=VideoReader('2017-05-15 pupil_crop.mp4');
% read one frame and conver it to gray image
frame1=read(v,100);
frame1gray=rgb2gray(frame1);

%segmentation of the pupil with funciton 'regionGrowing'
[P, J] = regionGrowing(frame1gray,[],20);
% find the center and radius of the pupil 
[o,r]=imfindcircles(J,[10,100],'ObjectPolarity','bright')
% show the circle on the gray image
figure,imshow(frame1gray)
h=viscircles(o,r,'LineWidth',0.001);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% processing of each 5th frame %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% input the video
v=VideoReader('2017-05-15 pupil_crop.mp4');

% select the seed point s in one frame
figure,imshow(read(v,100));
s=ginput(1);
s=round([s(2),s(1),1]);
close;


% processing of every 5th frame
for i=5:5:v.NumberofFrames
    F=read(v,i);
    F=rgb2gray(F);
    S=size(F);
    [P, J] = regionGrowing(F,s,20);
% opening operation and find the boundary of the binary image
    EO=imopen(J,strel('disk',5,0));
    B=bwboundaries(EO);
    BX =B{1}(:, 2);
    BY =B{1}(:, 1);
    %expand the concave boundary and fill inside the new boundary
    k=convhull(BX,BY);
    FI = poly2mask(BX(k), BY(k),S(1) ,S(2)); %filled binary image
% find the origin and radius of the pupil
    [o,r]=imfindcircles(FI,[10,50],'ObjectPolarity','bright');
    
% show the frame with fitted circle on it and save it into current folder
    figure,imshow(F);
    h=viscircles(o,r,'LineWidth',0.001);
    hold on;
    str=sprintf('frame %d, r=%f',i,r);
    title(str);
    filename=sprintf('frame %d',i);
    saveas(gcf,filename,'jpg');
    close;
   
% matrix O (n*2) - coordinates of the pupil center, where n is the number of frame
% matrix R (n*1) - radius of the pupil   
    if length(r)==2
        if r(1)>=r(2)
            O(i/5,:)=o(1,:);
            R(i/5)=r(1);
        else
            O(i/5,:)=o(2,:);
            R(i/5)=r(2);
        end
    else
        O(i/5,:)=o(1,:);
        R(i/5)=r(1);
    end
end
