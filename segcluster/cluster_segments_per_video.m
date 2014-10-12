function cluster_segments_per_video(vid, num_clusters)
% Usage:
% Paste the segments into tubes via clustering 
% Generate multiple tubes for each video independently by varying the 
% clustering parameters

close all;

addPathVar;
videos = conf.videos;
annos = conf.annos;
class_names = conf.class_names;

IMSHOW = 0;

%%%%%%%%%%%%%%%% color histogram parameters %%%%%%%%%%%%%%%%%%
init_param_colorhist;

im_dir = [PATHvideo videos{vid} '/cam-002/'];
mask_dir = [PATHmask videos{vid} '/'];
d = dir([mask_dir '*.mat']);

seg_fr = zeros(1, length(d));
for i = 1 : length(d)
  seg_fr(i) = str2num(d(i).name(5:10));
end

clip = get_clip_info(vid, annos, videos, class_names);
  
cluster_seg = [];
for i = 1 : length(clip)
    
  disp([int2str(vid) ':' int2str(i) ':' int2str(length(clip))]);  
    
  fr_st = clip(i).fr(1);
  fr_ed = clip(i).fr(2);
  seg_idx = find(seg_fr >= fr_st & seg_fr <= fr_ed);
  
  if isempty(seg_idx)
    continue;
  end
  
  segs = struct('fr', [], 'mask_small', [], 'bbox', [], 'color', []);
  total_mask = 0;
  for j = 1 : length(seg_idx)
    
    segs(j).fr = seg_fr(seg_idx(j));
    imname = d(seg_idx(j)).name(1:end-4);
    segs(j).imname = imname;
    load([mask_dir imname '.mat']);
    
    %%%%%%%%%%%%%%%%%%% computer color features %%%%%%%%%%%%%%%%%%%%%%%%
    im = imread([im_dir imname]);
    [nr, nc, z] = size(im);
    [L,a,b] = RGB2Lab(double(im(:,:,1)), double(im(:,:,2)), double(im(:,:,3)));
       
    segs(j).bbox = zeros(length(masks), 4);
    segs(j).color = [];
    for k = 1 : length(masks)
      if isempty(masks(k).bbox)
        continue;
      end
      segs(j).bbox(k,:) = masks(k).bbox;
      segs(j).mask_small{k} = masks(k).mask_small;
      
      mask = get_full_mask(masks(k).mask_small, masks(k).bbox, nr, nc);
      color_hist = [histc(L(mask), LBinEdges); ...
                    histc(a(mask), abBinEdges); histc(b(mask), abBinEdges)];
      segs(j).color = [segs(j).color; color_hist'];          
    end
    
    total_mask = total_mask + length(masks);
    
  end
  
  % Compute multiple clusters (spatial-temporal segments) by varying the
  % parameters
  
  clustidx = [];
  
  if total_mask == 1
    clustidx{1} = [1 1];
    continue;
  end
  
  clust_n = max(2, min(num_clusters, round(total_mask/4)));

  n = 0;
    
  clustidx = cluster_key_segs(segs, clust_n, 0);
    
  if IMSHOW
    num = 0;  
    for k = 1 : length(clustidx)
      num = num + 1;
      for m = 1 : size(clustidx{k}, 1)
        p = clustidx{k}(m,1);
        q = clustidx{k}(m,2);    
        im = imread([im_dir segs(p).imname]);
        mask = get_full_mask(segs(p).mask_small{q}, segs(p).bbox(q,:), nr, nc);
  
        if (mod(num, 2) == 1)
          im(:,:,3) = mask * 255;
        else
          im(:,:,1) = mask * 255;
        end
    
        figure(1);
        imagesc(im); 
        pause(0.2);
      end
    end
    
  end
  
  fn = ['mat/segments/seg_video' int2str(vid) '_clip' int2str(i) '.mat'];    
  save(fn, 'segs', 'clustidx');
  
end
