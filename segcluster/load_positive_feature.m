function [x y yv feat_idx] = load_positive_feature(conf)

%%%%%%%%%%%%%%%%%%%% positive features %%%%%%%%%%%%%%%%%%%%%%%%%
videos = conf.videos;
annos = conf.annos;
class_names = conf.class_names;
featdim = conf.featdim;
%PATHdata = conf.PATHdata;

x = [];
y = [];
yv = [];
feat_idx = [];
v_n = length(videos);

num = 0;
for vi = 1 : v_n

  clip = get_clip_info(vi, annos, videos, class_names);

  x_c = [];
  y_c = [];  
  for ci = 1 : length(clip)
    
    load(['mat/segments/seg_video' int2str(vi) '_clip' int2str(ci) '.mat']);
    
    seg_n = 0;
    for i = 1 : length(segs)
      seg_n = seg_n + length(segs(i).mask_small);
    end
      
    x_tmp = zeros(seg_n, featdim);
    y_tmp = zeros(seg_n, 1);
    
    %feat_idx = [];
    k = 0;
    for i = 1 : length(segs)
      
      disp([int2str(vi) ':' int2str(i) ':' int2str(length(segs))]);
    
      for j = 1 : length(segs(i).mask_small)
        num = num + 1;
        k = k + 1;
        colorfeat = segs(i).color(j,:);
        colorfeat = colorfeat ./ (sum(colorfeat) + eps);
      
        x_tmp(k, :) = colorfeat;
        y_tmp(k) = clip(ci).label;
      
        feat_idx{vi}{ci}{i}(j) = num;
      end
      
    end
    
    x_c = [x_c; x_tmp];
    y_c = [y_c; y_tmp];
    
    clear segs;
    
  end
  
  x = [x; x_c];
  y = [y; y_c];
  yv = [yv; vi*ones(length(y_c), 1)];
  
end
