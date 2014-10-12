function hier_cluster_per_video
% Usage:
% Represent each video as a tree of tubes (spatio-temporal segments).
% A pool of tubes are given as input, the algorithm prunes, merges and 
% organizes the tubes into a tree. 

addPathVar;

videos = conf.videos;
annos = conf.annos;
class_names = conf.class_names;
nr = conf.imsize(1);
nc = conf.imsize(2);

IMSHOW = 0;
th = -1;

load('mat/fg_color_features.mat', 'x', 'feat_idx');
load('mat/fg_color_models.mat');

for vi = 1 : length(videos) 
      
  model = models{vi};
    
  clip = get_clip_info(vi, annos, videos, class_names);
  for ci = 1 : length(clip)
      
    disp([int2str(vi) ':' int2str(ci) ':' int2str(length(clip))]);
      
    % load the pool of tubes
    load(['mat/segments/seg_video' int2str(vi) '_clip' int2str(ci) '.mat']);
        
%%%%%%%%%%%%%%%%%%%%%% 1. Prune the pool of tubes %%%%%%%%%%%%%%%%%%%%%%%%%    
    % compute the fg scores for each cluster
    num = length(clustidx); 
    scores = zeros(1, num);
    for j = 1 : num % number of clusters in clip ci
      seg_idx = clustidx{j};
      pos_idx = [];
      for k = 1 : size(seg_idx, 1)
        pos_idx = [pos_idx; feat_idx{vi}{ci}{seg_idx(k,1)}(seg_idx(k,2))];
      end
      score_v = x(pos_idx, :) * model.w';
      scores(j) = mean(score_v);     
    end
      
    % remove the clusters correspond to background
    [val idx_sort] = sort(scores, 'descend');
    clustidx_sort = clustidx(idx_sort);
    idx_th = idx_sort(find(val > th));
    idx_sort = idx_sort(1:max(1, round(length(idx_sort)/3)));
    if length(idx_th) < length(idx_sort)
      idx_valid = idx_sort;
    else
      idx_valid = idx_th;
    end
    clustidx_prune = clustidx(idx_valid); 

    % compute the overlap scores between pairs of tubes
    % t_overlap: overlap score in time; s_overlap: overlap score in space
    [t_overlap s_overlap] = get_cluster_overlap(clustidx_prune, segs);

    % merge the heavily overlapped segments
    idx_rm = [];
    st = length(idx_valid); % start from the cluster that has the lowest score
    
    while st > 1
      idx_c = 1 : st - 1;
      if any(t_overlap(st, idx_c) > 2/3 & s_overlap(st, idx_c) > 0.9) 
        idx_rm = [idx_rm st];
      end
      st = st - 1;
    end
    
    clustidx_prune(idx_rm) = [];

%%%%%%%%%%%%% 2. Merge the tubes and organize them into a tree %%%%%%%%%%%%
    
    clustidx_tree = hier_cluster(segs, clustidx_prune, nr, nc);
%     if IMSHOW
%       im_dir = [PATHvideo videos{vi} '/cam-002/'];
%       vis_cluster_tree(segs, clustidx_tree, im_dir);
%     end
    
%%%%%%%%%%%%%%%%%%%%%%%%% 3. Trim the tree %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    treeidx = trim_cluster(segs, clustidx_tree);
    if IMSHOW
      im_dir = [PATHvideo videos{vi} '/cam-002/'];
      vis_cluster_tree(segs, treeidx, im_dir);
    end
    
    save(['mat/segments/seg_tree_video' int2str(vi) '_clip' ...
          int2str(ci) '.mat'], 'treeidx', 'segs');
    
    clear segs;
    clear treeidx;
    
  end
  
end

function vis_cluster(segs, clustidx, im_dir)

num = 0;
for i = 1 : length(clustidx)
  num = num + 1;
  if (mod(num, 2) == 1)
    c = 1;
  else
    c = 3;
  end
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
  
function vis_cluster_tree(segs, clustidx, im_dir)

leaf = find(clustidx.leaf == 1);
for l = 1 : length(leaf)
  i = leaf(l);
  vis_cluster_node(segs, clustidx.node{i}, im_dir, 2);
  parent = clustidx.parent(i);
  num = 0;
  while parent ~= 0
    num = num + 1;
    if mod(num, 2) == 1
      c = 1;
    else
      c = 3;
    end
    vis_cluster_node(segs, clustidx.node{parent}, im_dir, c);
    parent = clustidx.parent(parent);
  end
end

function clustidx_tree = hier_cluster(segs, clustidx, nr, nc)
% Usage: 
% construct the segmentation tree via agglomerative clustering

iter = 1;

clust_n = length(clustidx);
clustidx_tree.node = clustidx;
clustidx_tree.parent = zeros(1, clust_n);
clustidx_tree.leaf = ones(1, clust_n);
node_idx = 1 : clust_n;

while iter < 20
    
  % compute distance matrix
  %tic
  A = seg_dist(segs, clustidx, nr, nc);
  %toc
  [sim idx] = max(A(:));
  [idx1 idx2] = ind2sub([clust_n clust_n], idx);
  
  if sim < 1
    break;
  end
  
  % merge the selected clusters
  i0 = 1;
  j0 = 1;
  mi = clustidx{idx1}(:,1); % frame index
  mj = clustidx{idx2}(:,1); % frame index
  idx_new = [];
  
  while (i0 <= length(mi) || j0 <= length(mj))
    if j0 > length(mj) || (i0 <= length(mi) && mi(i0) < mj(j0))
      idx_new = [idx_new; clustidx{idx1}(i0,:)];
      i0 = i0 + 1;
    elseif i0 > length(mi) || mi(i0) > mj(j0)
      idx_new = [idx_new; clustidx{idx2}(j0,:)];
      j0 = j0 + 1;
    else
      idx_new = [idx_new; unique([clustidx{idx1}(i0,:); clustidx{idx2}(j0,:)], 'rows')];
      i0 = i0 + 1;
      j0 = j0 + 1;
    end
  end
  
  clustidx{idx1} = idx_new;
  clustidx{idx2} = [];
  
  % organize spatial-temporal segments into hierarchical structures  
  clustidx_tree.node{end+1} = idx_new; 
  n = length(clustidx_tree.node);
  clustidx_tree.parent(end+1) = 0;
  clustidx_tree.parent(node_idx(idx1)) = n;
  clustidx_tree.parent(node_idx(idx2)) = n;
  clustidx_tree.leaf(end+1) = 0;
  
  node_idx(idx1) = n;
  node_idx(idx2) = 0;
  
  iter = iter + 1;
  
  n = 0;
  for i = 1 : length(clustidx)
    if isempty(clustidx{i})
      continue;
    end
    n = n + 1;
  end
  
  if n <= 1
    break;
  end
  
end

function A = seg_dist(segs, clustidx, nr, nc)

clust_n = length(clustidx);
colordim = 69;

loc_feat = zeros(clust_n, 2);
color_feat = zeros(clust_n, colordim);
t_feat = cell(1, clust_n);
idx_rm = [];
for i = 1 : clust_n
  if isempty(clustidx{i})
    idx_rm(end+1) = i;
    continue;
  end
  seg_n = size(clustidx{i}, 1);
  loc_tmp = [];
  color_tmp = [];
  t_tmp = [];
  for j = 1 : seg_n
    m = clustidx{i}(j, 1);
    n = clustidx{i}(j, 2);
    loc_tmp = [loc_tmp; segs(m).bbox(n,1:2)];
    color_tmp = [color_tmp; segs(m).color(n,:)];
    t_tmp = [t_tmp; segs(m).fr];
  end
  loc_feat(i,:) = mean(loc_tmp, 1);
  color_feat(i,:) = mean(color_tmp, 1);
  t_feat{i} = unique(t_tmp);
end

t_dist = zeros(clust_n, clust_n);
for i = 1 : clust_n
  if isempty(clustidx{i})
    continue;
  end
  for j = 1 : clust_n
    if isempty(clustidx{j})
      continue;
    end
    t_union = unique([t_feat{i}; t_feat{j}]);
    t_len = max(t_union) - min(t_union) + 1;
    if t_len == 0
      t_dist(i,j) = 0;
    else
      t_dist(i,j) = 1 - length(t_union) / t_len;
    end
  end
end

loc_dist = slmetric_pw(loc_feat', loc_feat', 'chisq');
loc_mean = mean(mean(loc_dist));
loc_K = exp(-1/loc_mean*loc_dist);
color_dist = slmetric_pw(color_feat', color_feat', 'chisq');
color_mean = mean(mean(color_dist));
color_K = exp(-1/color_mean*color_dist);
t_mean = mean(mean(t_dist));
t_K = exp(-1/t_mean*t_dist);

% compute the similarities of bounding boxes after merging
size_K = zeros(clust_n, clust_n);
for i = 1 : clust_n
  if isempty(clustidx{i})
    continue;
  end
  mi = clustidx{i}(:,1); % frame index
  ni = clustidx{i}(:,2); % mask index
  for j = 1 : clust_n
    if i == j || isempty(clustidx{j})
      continue;
    end
    mj = clustidx{j}(:,1); % frame index
    nj = clustidx{j}(:,2); % mask index
    i0 = 1;
    j0 = 1;
    color_hists = [];
    size_feat = [];
    shape_feat = [];
    sp_feat = [];
    num = 0;
    
    while (i0 <= length(mi) || j0 <= length(mj))
      num = num + 1;
      if j0 > length(mj) || (i0 <= length(mi) && mi(i0) < mj(j0))
        size_feat(num,:) = segs(mi(i0)).bbox(ni(i0), 3:4) ./ [nc nr];
        i0 = i0 + 1;
      elseif i0 > length(mi) || mi(i0) > mj(j0)
        size_feat(num,:) = segs(mj(j0)).bbox(nj(j0), 3:4) ./ [nc nr];  
        j0 = j0 + 1;
      else
        bbox_i = segs(mi(i0)).bbox(ni(i0), :);
        bbox_j = segs(mj(j0)).bbox(nj(j0), :);
        x0 = min(bbox_i(1), bbox_j(1)); y0 = min(bbox_i(2), bbox_j(2));
        x1 = max(bbox_i(1)+bbox_i(3)-1, bbox_j(1)+bbox_j(3)-1);
        y1 = max(bbox_i(2)+bbox_i(4)-1, bbox_j(2)+bbox_j(4)-1);
        size_feat(num,:) = [x1-x0+1 y1-y0+1] ./ [nc nr];
        i0 = i0 + 1;
        j0 = j0 + 1;
      end
    end
    
    size_dist = slmetric_pw(size_feat', size_feat', 'chisq');
    size_mean = mean(mean(size_dist));
    size_K(i,j) = mean(mean(exp(-1/size_mean*size_dist)));
    
  end
  
end

A = loc_K + size_K + color_K + t_K;

for i = 1 : length(idx_rm)
  A(idx_rm(i),:) = 0;
  A(:,idx_rm(i)) = 0;
end
A(logical(diag(ones(1, clust_n),0))) = 0;

function seg_tree = trim_cluster(segs, clustidx)

node_n = length(clustidx.node);
relation = zeros(node_n, node_n, 2);

t_feat = zeros(node_n, 2);
loc_feat = zeros(node_n, 4);
for i = 1 : node_n
  if clustidx.leaf(i) == 1 && clustidx.parent(i) == 0
    continue;
  end
  
  t_al = clustidx.node{i}(:,1);
  t_u = unique(t_al);
  t_feat(i,:) = [t_u(1) t_u(end)];
  
  loc_tmp = [];
  for j = 1 : length(t_u)
    t = t_u(j);
    idx = find(t_al == t);
    
    bbox_tmp = [];
    for k = 1 : length(idx)
      s = clustidx.node{i}(idx(k), 2);
      bbox_tmp(k,:) = segs(t).bbox(s,:);
    end
    x0 = min(bbox_tmp(:,1));
    y0 = min(bbox_tmp(:,2));
    x1 = max(bbox_tmp(:,1) + bbox_tmp(:,3));
    y1 = max(bbox_tmp(:,2) + bbox_tmp(:,4));
    loc_tmp(j, :) = [x0 y0 x1 y1];
  end
  
  loc_feat(i,:) = mean(loc_tmp, 1);
end
   
rm_idx = [];
for i = 1 : node_n

  if clustidx.parent(i) == 0
    continue;
  end
  
  p = clustidx.parent(i); % parent node index
  
  % get the relations between node i and p
  % temporal relations
  ti_0 = t_feat(i, 1);
  ti_1 = t_feat(i, 2);
  ti_m = mean(t_feat(i,:));
  
  tp_0 = t_feat(p, 1);
  tp_1 = t_feat(p, 2);
  tp_m = mean(t_feat(p,:));
  
  if ti_m < tp_m && ti_1 < (tp_1+tp_m) / 2 % before
    relation(i, p, 2) = 1;
  elseif ti_m > tp_m && ti_0 > (tp_0+tp_m) / 2 % after
    relation(i, p, 2) = 2;
  else % co-occur
    relation(i, p, 2) = 0;
  end
  
  % spatial relations
  bbox_i = loc_feat(i, :);
  yi = (bbox_i(2) + bbox_i(4)) / 2;
    
  bbox_p = loc_feat(p, :);
  yp = (bbox_p(2) + bbox_p(4)) / 2;
  
  bbox_i(3:4) = bbox_i(3:4) - bbox_i(1:2) + 1;   
  bbox_p(3:4) = bbox_p(3:4) - bbox_p(1:2) + 1;
  
  s_overlap = overlapping(bbox_i, bbox_p); % intersection over union
  if s_overlap > 0.7 || abs(yi-yp) < 20 % overlap
    relation(i, p, 1) = 0;
  else
    if yi < yp   % below
      relation(i, p, 1) = 1;
    else         % above
      relation(i, p, 1) = 2;
    end
  end
  
  t_overlap = (min(tp_1, ti_1) - max(tp_0, ti_0)) / (max(tp_1, ti_1) - min(tp_0, ti_0));
  
  if t_overlap >= 0.8 && s_overlap >= 0.8 % remove the child node
    rm_idx(end+1) = i;
  end
  
end

relation(rm_idx, :, :) = [];
relation(:, rm_idx, :) = [];

for i = 1 : length(rm_idx)
  r = rm_idx(i);
  leaf = clustidx.leaf(r);
  parent = clustidx.parent(r);
  clustidx.node{r} = [];
  
  if leaf == 0 % the removed node is a parent node
    child_idx = find(clustidx.parent == r);
    clustidx.parent(child_idx) = parent;
  end
end

seg_tree = clustidx;
n = 0;
for i = 1 : length(clustidx.node)
  if isempty(clustidx.node{i})
    j = i - n;
    n = n + 1;
    seg_tree.node(j) = [];
    seg_tree.leaf(j) = [];
    seg_tree.parent(j) = [];
    idx = find(seg_tree.parent > j);
    seg_tree.parent(idx) = seg_tree.parent(idx) - 1;
  end
end

for i = 1 : length(seg_tree.leaf)
  idx = find(seg_tree.parent == i);
  if isempty(idx)
    seg_tree.leaf(i) = 1;
  else
    seg_tree.leaf(i) = 0;
  end
end
    
seg_tree.relation = relation;

function [t_overlap s_overlap] = get_cluster_overlap(clustidx, segs)

node_n = length(clustidx);

t_feat = cell(node_n, 1);
loc_feat = zeros(node_n, 4);
for i = 1 : node_n
  
  t_al = clustidx{i}(:,1);
  t_u = unique(t_al);
  t_feat{i} = t_u;
  
  loc_tmp = [];
  for j = 1 : length(t_u)
    t = t_u(j);
    idx = find(t_al == t);
    
    bbox_tmp = [];
    for k = 1 : length(idx)
      s = clustidx{i}(idx(k), 2);
      bbox_tmp(k,:) = segs(t).bbox(s,:);
    end
    x0 = min(bbox_tmp(:,1));
    y0 = min(bbox_tmp(:,2));
    x1 = max(bbox_tmp(:,1) + bbox_tmp(:,3));
    y1 = max(bbox_tmp(:,2) + bbox_tmp(:,4));
    loc_tmp(j, :) = [x0 y0 x1 y1];
  end
  
  loc_feat(i,:) = mean(loc_tmp, 1);
end
   
t_overlap = zeros(node_n, node_n);
s_overlap = zeros(node_n, node_n);
for i = 1 : node_n
  for j = 1 : node_n
      
    if i == j 
      continue;
    end
    
    t_overlap(i,j) = length(intersect(t_feat{i}, t_feat{j})) / length(union(t_feat{i}, t_feat{j}));
     
    % spatial relations
    bbox_i = loc_feat(i, :);
    bbox_j = loc_feat(j, :);
  
    bbox_i(3:4) = bbox_i(3:4) - bbox_i(1:2) + 1;   
    bbox_j(3:4) = bbox_j(3:4) - bbox_j(1:2) + 1;
  
    s_overlap(i,j) = overlapping(bbox_i, bbox_j); % intersection over union
    
  end
end
