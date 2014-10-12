function cluster_tube_iterative
% Usage:
% Assign labels to the tubes via data-driven clustering

addPathVar;
maxnum = 50; % maximum number of clusters per class
iter_n = 2;
class_n = conf.class_n;

for iter_i = 1 : iter_n
    
  if iter_i == 1
    % initialize the tube labels via spectral clustering (use a large
    % number of clusters for the sake of consistency)  
    cluster_tube_ini(maxnum);
  else
    % Merge the similar clusters via discriminative clustering
    cluster_tube(maxnum, iter_i);
  end
  
  % train an SVM for each tube cluster
  for class_i = 1 : class_n
    train_tube_classifiers(class_i, iter_i);
  end
  
  maxnum = maxnum / 4;
  
end

% run the trained tube classifiers on all of the tubes
for i = 1 : length(videos)
  run_tube_classifiers(i, iter_n);
end
