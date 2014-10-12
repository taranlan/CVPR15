function run_tube_classifiers(vi, iter_i)

addPathVar;
annos = conf.annos;
class_n = conf.class_n;

K = 4000;
    
weights = [];
h_to_class = [];
for i = 1 : class_n
  load(['mat/segments/tube_classifiers_' int2str(i) '_iter' int2str(iter_i), '.mat']);
  clust_n = length(models);
  for j = 1 : clust_n
    h_to_class = [h_to_class; [i j]];
    weights = [weights; models{j}.w];
  end
end

clip = get_clip_info(vi, annos, videos, class_names);
   
for ci = 1 : length(clip)
       
  disp([int2str(vi) ':' int2str(ci) ':' int2str(length(clip))]);
 load(['mat/segments/seg_tree_video' int2str(vi) '_clip' int2str(ci) '.mat'], ...
       'segs', 'treeidx', 'st_feat', 'st_feat_raw');
    
  boxes = get_tube_location(treeidx.node, segs);
  treeidx.boxes = boxes; 
    
  treeidx.hscore = st_feat * weights';
  [val treeidx.h] = max(treeidx.hscore, [], 2);
    
  save(['mat/segments/seg_tree_video' int2str(vi) '_clip' int2str(ci) '.mat'], ...
        'segs', 'treeidx', 'st_feat', 'st_feat_raw', 'h_to_class');
    
end
  
