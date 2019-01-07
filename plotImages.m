function plotImages(F, frameNum, folderPath)

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
   str=sprintf('frame %d, r=%f',frameNum,a);
   F=insertText(F,[1,1],str,'TextColor','r','BoxColor','w',...
       'FontSize',fontsize);
   imshow(F,'Border','tight', 'Parent', currAxes);
   hold on
   plot(s(2),s(1),'r+')
   plot(X,Y,'r','LineWidth',2.5)
   filename=sprintf('frame %d.jpg',frameNum);
   Iname=fullfile(folderPath,filename);
   Fsave=getframe(hFigVid);
   imwrite(Fsave.cdata,Iname);
   hold off

end
