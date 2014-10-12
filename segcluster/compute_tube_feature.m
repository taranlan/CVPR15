function compute_tube_feature(vi)

addPathVar;

IMSHOW = 0;

videos = conf.videos;
annos = conf.annos;
class_names = conf.class_names;
K = 4000;
nr = conf.imsize(1);
nc = conf.imsize(2);
im_dir = [PATHvideo videos{vi} '/cam-002/'];

clip = get_clip_info(vi, annos, videos, class_names);

for ci = 1 : length(clip)
    
    disp([int2str(ci) ':' int2str(length(clip))]);
    
    load(['mat/segments/seg_tree_video' int2str(vi) '_clip' int2str(ci) '.mat']);
    videoname = [videos{vi} '-cam-002'];
    load([PATHdense videoname '_code_.mat']);
       
    node_n = length(treeidx.node);
    st_feat = zeros(node_n, 4*K);
    st_feat_raw = zeros(node_n, 4*K);
    
    for i = 1 : node_n
      ts = treeidx.node{i}(:,1);
      t_u = unique(ts);
      feat = zeros(1, 4*K);
      
      for j = 1 : length(t_u) % for all frames in a spatio-temporal segment
        t = t_u(j);
        fr = segs(t).fr;
        idx = find(ts == t);   
        im_dense = map_dense_image(dense, nr, nc, fr+5, fr+10, 4);
        for k = 1 : length(idx)
          s = treeidx.node{i}(idx(k), 2);
          mask_tmp = get_full_mask(segs(t).mask_small{s}, segs(t).bbox(s,:), nr, nc);
          if k == 1
            mask = mask_tmp;
          else
            mask = mask | mask_tmp;
          end
        end
        mask = seg_dilate(mask, 20);
        
        if IMSHOW
          imname = segs(t).imname;
          vis_dense_track(im_dense, mask, im_dir, imname);
        end
            
        hist_tmp = seg_to_bow(im_dense, mask, K);
        feat = feat + hist_tmp';
      end
      
      st_feat_raw(i, :) = feat; 
      st_feat(i,:) = feat ./ (sum(feat) + eps); 
    end
    
    save(['mat/segments/seg_tree_video' int2str(vi) '_clip' int2str(ci) '.mat'], 'segs', 'treeidx', 'st_feat', 'st_feat_raw');
    
end

function vis_dense_track(im_dense, mask, im_dir, imname)

im = imread([im_dir imname]);
im_dense_sum = sum(sum(im_dense, 4), 3);
im_dense_sum = (im_dense_sum > 0)*255;
im(:,:,1) = mask * 125;
im(:,:,3) = im_dense_sum;
imshow(im);
pause(0.2);
  
