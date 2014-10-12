function cluster_tube_ini(maxnum, conf)
% Usage: 
% Do spectral clustering to partition the segment instances into a large
% number of clusters. Each cluster is a spatiotemporal segment (tube)

% maxnum: maximum number of clusters

videos = conf.videos;
annos = conf.annos;
class_names = conf.class_names;
class_n = conf.class_n;
knn = 50;
nr = conf.imsize(1);
nc = conf.imsize(2);
IMSHOW = 0;

v_test = conf.v_test;
v_tr = conf.v_tr;

if 1
    
%%%%%%%%%%%%%%%%%% compute the features for clustering %%%%%%%%%%%%%%%%%%%%
feat_al = [];
bbox_al = [];
y = [];
vc = [];
t = [];
for i = 1 : length(v_tr)
    
   vi = v_tr(i); 
   clip = get_clip_info(vi, annos, videos, class_names);
   
   feat_clip = [];
   bbox_clip = [];
   for ci = 1 : length(clip)
       
     disp([int2str(vi) ':' int2str(ci) ':' int2str(length(clip))]);
     
     fn = ['mat/segments/seg_tree_video' int2str(vi) '_clip' int2str(ci) '.mat'];
     load(fn, 'st_feat', 'treeidx', 'segs');
     
     boxes = get_tube_location(treeidx.node, segs);
       
     n = size(st_feat, 1);
     feat_clip = [feat_clip; st_feat];
     bbox_clip = [bbox_clip; boxes];
     y = [y; (clip(ci).label-1) * ones(n, 1)]; % label
     vc = [vc; repmat([vi ci], [n 1])]; % video and clip index
     t = [t; (1:n)'];
     
     clear st_feat
     
   end
   
   feat_al = [feat_al; feat_clip];
   bbox_al = [bbox_al; bbox_clip];
   
end

save('mat/feature_dense.mat', 'feat_al', 'bbox_al', 'y', 'vc', 't', '-v7.3');

end

load('mat/feature_dense.mat');

clustidx = [];
for i = 1 : class_n
    
  idx = find(y == i);
  feat = feat_al(idx, :);
  feat_dist = slmetric_pw(feat', feat', 'intersectdis');
  feat_mean = mean(mean(feat_dist));
  dense_K = exp(-1/feat_mean*feat_dist);
  
  loc_feat = bbox_al(idx, :);
  loc_dist = slmetric_pw(loc_feat', loc_feat', 'chisq');
  loc_mean = mean(mean(loc_dist));
  loc_K = exp(-1/loc_mean*loc_dist);

  A = dense_K + loc_K;

  knn_1 = min(knn, round(length(idx) / 3));
  % construct k-nn graph
  newA = zeros(size(A));
  for j = 1 : size(A,1)
    [val,ind] = sort(A(j,:),'descend');
    newA(j,ind(1:knn_1)) = val(1:knn_1);
  end
  A = (newA+newA')/2;
  
  num_c = min(maxnum, round(length(idx)/5));
  cluster_labels = mysc(A, num_c);

  num = 0;
  for j = 1 : num_c
  
    idx_j = find(cluster_labels == j);
    
    if length(cluster_labels) > 10 && length(idx_j) <= 3
      continue;
    end
    num = num + 1;
    
    e_idx = idx(idx_j); % example index
    vc_i = vc(e_idx, :);
    t_i = t(e_idx);
      
    clustidx{i}{num} = [vc_i t_i e_idx];  
  
    if IMSHOW
      vc_u = unique(vc_i, 'rows');
      for k = 1 : size(vc_u, 1)
        vk = vc_u(k, 1); % video index
        ck = vc_u(k, 2); % clip index
        load(['mat/segments/seg_tree_video' int2str(vk) '_clip' ...
              int2str(ck) '.mat'], 'segs', 'treeidx');
        idx_k = find(ismember(vc_i, [vk ck], 'rows'));
        tk = t_i(idx_k); % tube index
        im_dir = [PATHvideo videos{vk} '/cam-002/'];
        vis_cluster(segs, treeidx.node(tk), im_dir);
      end
    end
    
  end
  
end  

save('mat/tube_cluster_iter1.mat', 'clustidx');


function vis_cluster(segs, clustidx, im_dir)

num = 0;
for i = 1 : length(clustidx)
  num = num + 1;
  c = mod(num, 3) + 1;
  vis_cluster_node(segs, clustidx{i}, im_dir, c)
end

function vis_cluster_node(segs, clustidx, im_dir, c)

p_al = clustidx(:,1);
p_u = unique(p_al);
for i = 1 : length(p_u)
  p = p_u(i);
  idx = find(p_al == p_u(i));
  im = imread([im_dir segs(p).imname]);
  [nr nc nz] = size(im);
    
  for j = 1 : length(idx)
    q = clustidx(idx(j), 2);
    mask_tmp = get_full_mask(segs(p).mask_small{q}, segs(p).bbox(q,:), nr, nc);
    if j == 1
      mask = mask_tmp;
    else
      mask = mask | mask_tmp;
    end
  end
  im(:,:,c) = mask * 255;
   
  figure(1);
  imagesc(im); 
  pause(0.2);
end

