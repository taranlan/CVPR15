function pretrain_root_feature

addPathVar;

nr = conf.imsize(1);
nc = conf.imsize(2);

K = 4000;
annos = conf.annos;
v_tr = conf.v_tr;
v_test = conf.v_test;

%%%%%%%%%%%%%%%%%%%%%%%% train the bow model %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
x = [];
y = [];
for v_i = 1 : length(v_tr) 
    
  i = v_tr(v_i);
  
  % load the root features: BoW of dense trajectories only on the 
  % foreground segments
  load(['../baseline/mat/feature_tube_' int2str(i) '.mat']);
    
  x = [x; feat];
  y = [y; action-1];
  
end
  
model = train(y, sparse(x), '-s 4 -c 1000');

w = model.w;
label = unique(model.Label);
for i = 1:length(label)
  k = label(i);
  idx = find(model.Label == k);
  model.w(k,:) = w(idx, :);
end

save('mat/action_model.mat', 'model');

for vi = 1 : length(videos) 
  
  clip = get_clip_info(vi, annos, videos, class_names);
   
  for ci = 1 : length(clip)
       
    disp([int2str(vi) ':' int2str(ci) ':' int2str(length(clip))]);
    load(['mat/segments/seg_tree_video' int2str(vi) '_clip' int2str(ci) '.mat'], 'st_feat_raw');
    
    feat_c = sum(st_feat_raw, 1);
    feat_c = feat_c / (sum(feat_c) + eps); 
    
    root = feat_c * model.w';
    
    save(['mat/segments/root_pretrain_video' int2str(vi) '_clip' int2str(ci) '.mat'], 'root');
    
  end
  
end

