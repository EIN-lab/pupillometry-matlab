
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% processing of one frame %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% input the video
v=VideoReader('2017-05-15 pupil_crop.mp4');
% read one frame and conver it to gray image and apply a 3x3 median filter
% to reduce the noise
frame1=read(v,800);
frame1gray=medfilt2(rgb2gray(frame1));
S=size(frame1gray);


%segmentation of the pupil with funciton 'regionGrowing'
[P, J] = regionGrowing(frame1gray,[],20);
% opening operation and find the boundary of the binary image
EO=imopen(J,strel('disk',5,0));
B=bwboundaries(EO);
BX =B{1}(:, 2);
BY =B{1}(:, 1);
%expand the concave boundary and fill inside the new boundary
k=convhull(BX,BY);
% plot(BX(k),BY(k),'r');
F = poly2mask(BX(k), BY(k),S(1) ,S(2));


% find the parameters of ellipse which can be fitted to the pupil 
p=regionprops(F,'Centroid','MajorAxisLength','MinorAxisLength','Orientation','PixelList');
close;
PixList = p.PixelList;
x = p.Centroid(1);
y = p.Centroid(2);
a = p.MajorAxisLength/2;
b = p.MinorAxisLength/2;
angle = p.Orientation;
steps = 50;

% % show the ellipse on the image - method 1 - doesn't work very well
% figure,imshow(frame1);
% h=ellipse(a,b,angle,x,y,'r');

%  show the ellipse on the image - method 2
beta = angle * (pi / 180);
sinbeta = sin(beta);
cosbeta = cos(beta);
alpha = linspace(0, 360, steps)' .* (pi / 180);
sinalpha = sin(alpha);
cosalpha = cos(alpha);
X = x + (a * cosalpha * cosbeta - b * sinalpha * sinbeta);
Y = y + (a * cosalpha * sinbeta + b * sinalpha * cosbeta);

imshow(frame1);
hold on;
plot(X,Y,'r','LineWidth',0.2)
saveas(gcf,'frame100.jpg');
close;





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% processing of each 5th frame %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% input the video
v=VideoReader('2017-05-15 pupil_crop.mp4');

% select the seed point in one frame
figure,imshow(read(v,100));
s=ginput(1);
s=round([s(2),s(1),1]);;
close;


% processing of every 5th frame
for i=5:5:v.NumberofFrames
    F=read(v,i);
    F=medfilt2(rgb2gray(F));
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
    p=regionprops(FI,'Centroid','MajorAxisLength','MinorAxisLength','Orientation','PixelList');
    PixList = p.PixelList;
    x = p.Centroid(1);
    y = p.Centroid(2);
    a = p.MajorAxisLength/2;
    b = p.MinorAxisLength/2;
    angle = p.Orientation;
    steps = 50;
    
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
   
% matrix O (n*2) - coordinates of the pupil center, where n is the number of frame
% matrix R (n*2) - major- and minoraxes of the pupil
% theta (n*1) - tilting angels of the fitted ellipses
   O(i/5,:)=[x,y];
   R(i/5,:)=[a,b];
   theta(i/5)=angle;
end
