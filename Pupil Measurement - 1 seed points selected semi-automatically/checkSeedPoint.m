function [s,sFormer] =checkSeedPoint(F,sFirst,sThres,sFormer)
% check or select a valid seed point whose gray value is lower than the
% sThres on image F.

s=[];
if impixel(F,sFirst(1),sFirst(2)) < sThres
    s=[sFirst(2),sFirst(1),1];
end
% If there is no valid seed point, the user have to select a new
% seed point for this frame
if isempty(s)
    if isempty(sFormer)
        imshow(F),hold on
        title('No valid seed point in this frame. Please select a new seed point');
        s=round(ginput(1));
        % check the gray value of the seed point
        while any(impixel(F,s(1),s(2)) > sThres)
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
        if impixel(F,sFormer(1),sFormer(2)) <= sThres
            s=[sFormer(2),sFormer(1),1];
        else
            hFig =imshow(F);
            hold on
            title('No valid seed point in this frame. Please select a new seed point');
            s=round(ginput(1));
            % check the gray value of the seed point
            while any(impixel(F,s(1),s(2))> sThres)
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

end
