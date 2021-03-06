function cluster_tube(maxnum, iter_i)

% maxnum: maximum number of clusters

addPathVar;

videos = conf.videos;
annos = conf.annos;
class_names = conf.class_names;
class_n = conf.class_n;
knn = 10;
top_n = 100;
nr = conf.imsize(1);
nc = conf.imsize(2);
IMSHOW = 1;

clustidx = [];
for c = 1 : class_n
    
  class_names{c+1}
    
  load(['mat/segments/tube_scores_' int2str(c) '_iter' int2str(iter_i-1), '.mat']);
  
  clust_n = length(clustidx_org);
  idx_sort = cell(1, clust_n);
  for i = 1 : clust_n
    [val idx] = sort(feat_scores(i, :), 'descend');
    idx_sort{i} = idx(1:min(top_n, round(length(idx)/5)));
    idx = clustidx_org{i}(:,end);
    bbox{i} = bbox_al(idx, :);
  end
    
  feat_dist = zeros(clust_n, clust_n);
  loc_dist = zeros(clust_n, clust_n);
  for i = 1 : clust_n
    for j = 1 : clust_n
      % distance measured by similarity of top activations
      feat_dist(i,j) = 1 - length(intersect(idx_sort{i}, idx_sort{j})) / top_n;
      dist_tmp = slmetric_pw(bbox{i}', bbox{j}', 'chisq');
      loc_dist(i,j) = (mean(min(dist_tmp, [], 1)) + mean(min(dist_tmp, [], 2))) / 2;
    end
  end
  feat_mean = mean(mean(feat_dist));
  feat_K = exp(-1/feat_mean*feat_dist);
     
  loc_mean = mean(mean(loc_dist));
  loc_K = exp(-1/loc_mean*loc_dist);  
  
  A = feat_K + loc_K;
  
  knn_1 = min(knn, clust_n / 2);
  % construct k-nn graph
  newA = zeros(size(A));
  for j = 1 : size(A,1)
    %disp([int2str(i) ':' int2str(size(A,1))]);
    [val,ind] = sort(A(j,:),'descend');
    newA(j,ind(1:knn_1)) = val(1:knn_1);
  end
  A = (newA+newA')/2;
  
  num_c = min(maxnum, round(clust_n/4));
  cluster_labels = mysc(A, num_c);

  num = 0;
  for j = 1 : num_c
  
    idx_j = find(cluster_labels == j);
    
    if isempty(idx_j)
      continue;
    end
    
    num = num + 1;
    
    clustidx{c}{num} = [];
    for k = 1 : length(idx_j)
      clustidx{c}{num} = [clustidx{c}{num}; clustidx_org{idx_j(k)}];
    end
    
    if IMSHOW
        
      vc_i = clustidx{c}{num}(:, 1:2);
      t_i = clustidx{c}{num}(:, 3);
        
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
skip = round(length(p_u) / 3);
for i = 1 : skip: length(p_u)
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
  
  I2 = segImage2(im2double(im), double(mask), 2);
   
  figure(1);
  imagesc(I2);
end

