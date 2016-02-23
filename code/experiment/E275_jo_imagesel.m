%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Selection of images for E275
% Images are taken from NBP databases
%
% Jpo, 2.02.2016 Hamburg
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% cd ~/trabajo/E275/stimuli/new/                    % to get the images from the new or old set of images
% cd ~/trabajo/E275/stimuli/old/

folders         = {'new','jeffwall','crewdson','old'};
target_siz      = [1080,1920];                  % size Samsung Syncmaster P2370, BPN lab old EEG room
newim           = 1;
%%
for fn = 2:length(folders)

    cd(['~/trabajo/E275/stimuli/' folders{fn}])
    D                   = dir;

    for f = 4:length(D)
        im_old          = imread(D(f).name);
        im_sz           = size(im_old);
    
        if im_sz(2)/im_sz(1)==16/9                      % image has the same ratio, so ww might only need to change the scale
        
            im          = imresize(im_old,target_siz);
            tocrop      = 0;
        elseif im_sz(2)/im_sz(1)<16/9                   % ratio is smaller, resize to the correct horizontal dimension and then crop what is rest in the vertical
        
            im          = imresize(im_old,[im_sz(1)*target_siz(2)/im_sz(2),target_siz(2)]);
            aux_sz      = size(im);
            tocrop      = aux_sz(1)-target_siz(1);
            im          = im(floor(tocrop/2)+1:end-ceil(tocrop/2),:,:);
        
        elseif im_sz(2)/im_sz(1)>16/9 
            im          = imresize(im_old,[target_siz(1),im_sz(2)*target_siz(1)/im_sz(1)]);
            aux_sz      = size(im);
            tocrop      = aux_sz(2)-target_siz(2);
            im          = im(:,floor(tocrop/2)+1:end-ceil(tocrop/2),:);
        else
            display(sprintf('\nImage %s has a size of %dx%d and was not processed',im_sz(1),im_sz(2)))
            continue
        end
    
        fh = figure;

        set(gca,'Position',[0 0 1 1])
        imshow(im_old)

        fh2 = figure;
        set(fh2,'Position',[-3599 -362 1680 954])
        set(gca,'Position',[0 0 1 1])
        imshow(im)
        if input('To keep? (0-no,1-yes):')    
            e275_im(newim).oldname      = D(f).name;
            e275_im(newim).newname      = sprintf('image_%01d.jpg',newim);
            e275_im(newim).oldres       = im_sz;
            e275_im(newim).cropped      = tocrop;
            e275_im(newim).newres       = target_siz;
            imwrite(im, ['~/trabajo/E275/stimuli/possible/',...
                        e275_im(newim).newname],'jpeg')
            newim = newim + 1;
         end
        close(fh)
        close(fh2)
    end
end
save('~/trabajo/E275/stimuli/possible/E275_imagesel.mat','e275_im')
%%
