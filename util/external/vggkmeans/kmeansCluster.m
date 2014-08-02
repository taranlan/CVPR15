clear;
clc;

addpath(genpath('/home/tianlan/code/toolbox'));
dataset_path = '/home/tianlan/dataset/tv-interaction/';
load([dataset_path 'videonames']);
 
%%%%%%%%%%%%%%%%%%%%% k-means clustering %%%%%%%%%%%%%%%%%%%%%%%%

opts = struct('maxiters', 1000, 'mindelta', eps, 'verbose', 1);
K = 2000;

if 1
 
X = [];
%for i = 1:length(video_names) - 100
for i = 1:length(video_names)
    
  i
    
  load(['mat/' video_names{i} '.mat']); 
  
  feat = data_flow.feat';
  
  np = round(size(feat, 2) * 0.1);
  rand_idx = unique(ceil(rand(1, np) * np) + 1);
  
  X = [X feat(:, rand_idx)];
  
end

[center, sse] = vgg_kmeans(X, K, opts);
save(['mat/kmeans_center_' int2str(K) '.mat'],'center');

end

%%%%%%%%%%%%%% assign the cluster idx to every instance %%%%%%%%%%%%%%%%%
load(['mat/kmeans_center_' int2str(K)]);

%for i = 1:length(video_names) - 100
for i = 1:length(video_names)
    
  i
    
  load(['mat/' video_names{i} '.mat']); 
  %center = center(4:end,:);
  
  [kmean_idx d] = vgg_nearest_neighbour(data_flow.feat', center);
  data_flow.feat_c = kmean_idx;
  
  save(['mat/' video_names{i} '.mat'], 'data_flow');
  
end
  