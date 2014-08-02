function select_multi_segments(expdir, imdir, regiondir, flowdir)

IMSHOW = 1;

d = dir([imdir '*.jpg']);
imname = d(1).name;
im = imread([imdir imname]); 
[nr, nc, z] = size(im);

skip_n = 5; 

for i = 1 : skip_n: length(d)
    
    disp(['compute region scores : ' int2str(i) ' : ' int2str(length(d))]);
 
    imname = d(i).name;    
    
    % load region proposals
    segname = [regiondir imname '.mat'];
    load(segname, 'proposals', 'superpixels', 'unary');    
    
    % load optical flow
    flowname = [flowdir imname '.mat'];
    load(flowname,'vx','vy');
    
    % if the image has been resized to compute the optical flow
    % vx = imresize(vx, 2);
    % vy = imresize(vy, 2);
    
    flow_mean = mean(vx(:).^2 + vy(:).^2);
     
    diffUnary = diff(unary,1,1);
    ind = find(diffUnary>0,1);
    proposals = proposals(1:ind);
    
    N = length(proposals);
    masks = struct('mask_small', [], 'bbox', []);      
    num = 0;
    for j = 1 : N    
        
        mask = ismember(superpixels, proposals{j});
        
        seg_size = sum(mask(:));
        
        % remove the segments that are too big or too small
        if (seg_size > nr*nc/3 || seg_size < nr*nc/200)
          continue;
        end
      
        % remove the segments whose motion is less than the average motion
        % of the image
        fg_inds = find(mask == 1);
        fg_mag = mean(vx(fg_inds).^2 + vy(fg_inds).^2);

        if fg_mag < flow_mean
          continue;
        end
        
        num = num + 1;
        
        bbox = get_mask_coord(mask);
        % crop the patch that bounds the foreground segment
        mask_small = mask(bbox(2):bbox(2)+bbox(4)-1, bbox(1):bbox(1)+bbox(3)-1);
        
        masks(num).mask_small = mask_small;
        masks(num).bbox = bbox; 
        
        if IMSHOW
          im = imread([imdir imname]);   
          im(:,:,1) = mask*255;
          imshow(im);
          pause(0.2);
        end
       
    end
    
    clear proposals
    save([expdir imname '.mat'], 'masks');

end
