function [s,sFormer,seedPoints,sThres,aveGVold] = checkSeedPoints(F,seedPoints,sThres,sFormer,aveGVold)
% check or select a valid seed point whose gray value is lower than the
% sThres on image F.

s=[];
aveGVnew = mean(mean(F));
sThres = sThres + (aveGVnew - aveGVold);
aveGVold = aveGVnew;

for j=1:size(seedPoints,1)
    val(j) = min(impixel(F,seedPoints(j,1),seedPoints(j,2)));
end
idx = val < sThres;

if any(idx)
    [~, sIdx] = min(val);
    s = [seedPoints(sIdx,2),seedPoints(sIdx,1),1];
end
% for j=1:size(seedPoints,1)
%     if any(impixel(F,seedPoints(j,1),seedPoints(j,2))) < sThres
%         s=[seedPoints(j,2),seedPoints(j,1),1];
%         break
%     end
% end
% If there is no valid seed point, the user have to select a new
% seed point for this frame
if isempty(s)
    if isempty(sFormer) || any( impixel(F,sFormer(1),sFormer(2)) > sThres)
        hFig = figure;
        hAxes = axes;
        imshow(F, 'Parent', hAxes)
        title('No valid seed point in this frame. Please select a new seed point inside the BLACK PART OF THE PUPIL.');
        try s=round(ginput(1));
        catch ME
            if (strcmp(ME.message,'Interrupted by figure deletion'))
                s=[];
                return
            else
                rethrow(ME)
            end
        end
        delete(hFig);
        %         % check the gray value of the seed point
        %     trials = 0;
        while any(impixel(F,s(1),s(2)) > sThres) % && trials < 1
            warning(['The selected pixel is too bright!Please select another ', ...
                'seed point inside the BLACK PART OF THE PUPIL!']);
            hFig = figure;
            hAxes = axes;
            imshow(F, 'Parent', hAxes)
            title('Please select another seed point inside the BLACK PART OF THE PUPIL!');
            try s=round(ginput(1));
            catch ME
                if (strcmp(ME.message,'Interrupted by figure deletion'))
                    s=[];
                    return
                else
                    rethrow(ME)
                end
            end
            delete(hFig);
            %         trials = trials + 1;
        end
    elseif ~isempty(sFormer) && any(impixel(F,sFormer(1),sFormer(2)) <= sThres)
        s=sFormer;
    end
    
%             sFormer=s;
    if ~isempty(s)
    seedPoints = [seedPoints;s(1),s(2)];
    sFormer=s;
    s=[s(2),s(1),1];
    end
    
    %     else
    %         if any(impixel(F,sFormer(1),sFormer(2)) <= sThres)
    %             s=[sFormer(2),sFormer(1),1];
    %         else
    %             hFig =imshow(F);
    %             title('No valid seed point in this frame. Please select a new seed point inside the BLACK PART OF THE PUPIL');
    %             s=round(ginput(1));
    %             % check the gray value of the seed point
    %             trials = 0;
    %             while any(impixel(F,s(1),s(2))> sThres)  && trials < 1
    %                 warning(['The selected pixel is too bright!Please select another ', ...
    %                     'seed point inside the BLACK PART OF THE PUPIL!']);
    %                 hFig = imshow(F);
    %                 title('Please select another seed point inside the BLACK PART OF THE PUPIL!');
    %                 s=round(ginput(1));
    %                 trials = trials + 1;
    %             end
    %             sFormer=s;
    %             s=[s(2),s(1),1];
    %             seedPoints = [seedPoints;s(2),s(1)];
    %             delete(hFig);
    %         end
end
end

