function train_fg_models

addPathVar;
COMPT_FEAT = 1;
v_n = length(conf.videos);

if COMPT_FEAT
  [x y yv feat_idx] = load_positive_feature(conf);
  save('mat/fg_color_features.mat', 'x', 'y', 'yv', 'feat_idx');
else
  load('mat/fg_color_features.mat');
end

if COMPT_FEAT
  x_neg = load_negative_feature(conf);
  save('mat/bg_color_features.mat', 'x_neg');
else
  load('mat/bg_color_features.mat');
end

%%%%%%%%%%%%%%%%%%%%%%% train classifiers %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('************** classifier training *****************');
  
%%%%%%%%%%%%%%%%%%%%%% per video classifier %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for vi = 1 : v_n
  pos_idx = find(yv == vi);
  models{vi} = train_classifier(x(pos_idx, :), x_neg);
end

save('mat/fg_color_models.mat', 'models');

function [x y yv feat_idx] = load_positive_feature(conf)

%%%%%%%%%%%%%%%%%%%% positive features %%%%%%%%%%%%%%%%%%%%%%%%%
videos = conf.videos;
annos = conf.annos;
class_names = conf.class_names;
colordim = conf.colordim;

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

    x_tmp = zeros(seg_n, colordim);
    y_tmp = zeros(seg_n, 1);

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


function x_neg = load_negative_feature(conf)

%%%%%%%%%%%%%%%%%%%%%%% load negative features %%%%%%%%%%%%%%%%%%%%%%%%%%%%
videos = conf.videos;
colordim = conf.colordim;

x_neg = [];
v_n = length(videos);
skip = 1;
for vi = 1 : v_n

  load(['mat/segments/neg_seg_' videos{vi} '.mat']);

  n = 0;
  for i = 1 : skip : length(segs_neg)
    n = n + size(segs_neg(i).color, 1);
  end
  xi = zeros(n, colordim);
  k = 0;
  for i = 1 : skip : length(segs_neg)

    disp([int2str(vi) ':' int2str(i) ':' int2str(length(segs_neg))]);

    for j = 1 : size(segs_neg(i).color, 1)
      k = k + 1;
      colorfeat = segs_neg(i).color(j,:);
      colorfeat = colorfeat ./ (sum(colorfeat) + eps);
      xi(k, :) = colorfeat;
    end

  end

  clear segs_neg;

  x_neg = [x_neg; xi];

end 
