function cluster_seg = cluster_key_segs(segs, num_c, flag)

% flag: 1 - single cluster; 0 - multiple clusters

seg_n = length(segs);

color_hists = [];
shape_feat = [];
seg_ind = [];

num = 0;
for i = 1 : seg_n
  %disp([int2str(i) ':' int2str(seg_n)]);
    
  for j = 1 : length(segs(i).mask_small)
    num = num + 1;
    color_hists = [color_hists; segs(i).color(j,:)];
    shape_feat{num} = get_shape_feat(segs(i).mask_small{j}, 100);
    seg_ind(num, 1) = i;
    seg_ind(num, 2) = j;
  end
  
end

knn = min(10, num);
    
color_dist = slmetric_pw(color_hists', color_hists', 'chisq');
color_mean = mean(mean(color_dist));
color_K = exp(-1/color_mean*color_dist);
  
shape_dist = zeros(num, num);
for i = 1 : num
  for j = 1 : num
    if i == j
      continue;
    end
    overlap_ij = sum(sum(shape_feat{i} & shape_feat{j}));
    shape_dist(i,j) = 1 - overlap_ij / size(shape_feat{i}, 1)^2;
  end
end
shape_mean = mean(mean(shape_dist));
shape_K = exp(-1/shape_mean*shape_dist);

A = color_K + shape_K;

% construct k-nn graph
newA = zeros(size(A));
for i=1:size(A,1)
  [val,ind] = sort(A(i,:),'descend');
  newA(i,ind(1:knn)) = val(1:knn);
end
A = (newA+newA')/2;

if flag == 1
    
  [cluster_labels, V, D] = getSingleCluster(A, 1);  
  
  idx = find(cluster_labels == 1);
    
  cluster_seg = zeros(length(idx), 2);
  cluster_seg(:, 1) = seg_ind(idx, 1); % frame index
  cluster_seg(:, 2) = seg_ind(idx, 2); % seg index
    
else
    
  if num_c == num
    cluster_labels = 1:num;
  else
    cluster_labels = mysc(A, num_c);
  end

  cluster_seg = [];
  num = 0;
  for i = 1 : num_c
  
    idx = find(cluster_labels == i);

    if length(cluster_labels) > 10 && length(idx) < 2
      continue;
    end
    num = num + 1;
    cluster_seg{num} = zeros(length(idx), 2);
    cluster_seg{num}(:, 1) = seg_ind(idx, 1); % frame index
    cluster_seg{num}(:, 2) = seg_ind(idx, 2); % seg index
    
  end
  
end

