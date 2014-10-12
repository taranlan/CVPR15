function train_tube_classifiers(class_i, iter_i)

addPathVar;

load(['mat/tube_cluster_iter' int2str(iter_i) '.mat']);
load('mat/feature_dense.mat');

neg_idx = find(y ~= class_i);
clust_n = length(clustidx{class_i});
neg_feat = feat_al(neg_idx, :);  

models = [];
for j = 1 : clust_n
      
  disp(['class ' int2str(class_i) ' : cluster ' int2str(j)]);
  
  pos_idx = clustidx{class_i}{j}(:,end);
  pos_feat = feat_al(pos_idx, :);
    
  models{j} = train_classifier(pos_feat, neg_feat);
  
  clear pos_feat
    
end
  
clear neg_feat
    
save(['mat/segments/tube_classifiers_' int2str(class_i) '_iter' int2str(iter_i), '.mat'], 'models');

%%%%%%%%%%%%% run the classifiers on the positive examples %%%%%%%%%%%%%%%%
pos_idx = find(y == class_i);
pos_feat = feat_al(pos_idx, :);

feat_scores = zeros(clust_n, length(pos_idx)); 
for j = 1 : clust_n
  feat_scores(j, :) = (pos_feat * models{j}.w')';
end

clustidx_org = clustidx{class_i};
save(['mat/segments/tube_scores_' int2str(class_i) '_iter' int2str(iter_i), '.mat'], ...
      'feat_scores', 'clustidx_org', 'bbox_al', 'y', 'vc', 't');
    
