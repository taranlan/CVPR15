clear;
clc;

addPathVar;

annos = conf.annos;
v_test = conf.v_test;
v_tr = conf.v_tr;

tr_n = 0;
tt_n = 0;

for vi = 1 : length(videos) 
  
  clip = get_clip_info(vi, annos, videos, class_names);
   
  for ci = 1 : length(clip)
       
    disp([int2str(vi) ':' int2str(ci) ':' int2str(length(clip))]);
    
    load(['mat/segments/seg_tree_video' int2str(vi) '_clip' int2str(ci) '.mat'], 'treeidx', 'h_to_class');
    load(['mat/segments/root_pretrain_video' int2str(vi) '_clip' int2str(ci) '.mat']);
    
    if ismember(vi, v_tr)
        
      tr_n = tr_n + 1;
      data_train(tr_n).y = clip(ci).label - 1;
      data_train(tr_n).root = root;
      data_train(tr_n).hscore = treeidx.hscore;
      data_train(tr_n).h = treeidx.h;
      data_train(tr_n).boxes = treeidx.boxes;
      data_train(tr_n).tree.parent = treeidx.parent;
      data_train(tr_n).tree.leaf = treeidx.leaf;
      data_train(tr_n).tree.rel_t = treeidx.relation(:,:,2);
      
    else
        
      tt_n = tt_n + 1;
      data_test(tt_n).y = clip(ci).label - 1;
      data_test(tt_n).root = root;
      data_test(tt_n).hscore = treeidx.hscore;
      data_test(tt_n).h = treeidx.h;
      data_test(tt_n).boxes = treeidx.boxes;
      data_test(tt_n).tree.parent = treeidx.parent;
      data_test(tt_n).tree.leaf = treeidx.leaf;
      data_test(tt_n).tree.rel_t = treeidx.relation(:,:,2);
      
    end
    
  end
  
end

save('mat/pretrain.mat', 'data_train', 'data_test', 'h_to_class');
