function x_neg = load_negative_feature(conf)

%%%%%%%%%%%%%%%%%%%%%%% load negative features %%%%%%%%%%%%%%%%%%%%%%%%%%%%
videos = conf.videos;
featdim = conf.featdim;
%PATHdata = conf.PATHdata;

x_neg = [];
%y_neg = [];
%for vi = 1 : v_n
v_n = length(videos);
skip = 1;
for vi = 1 : v_n
    
  load(['mat/segments/neg_seg_' videos{vi} '.mat']);
  %im_dir = [PATHvideo videos{vi} '/cam-002/'];  
  
  n = 0;
  for i = 1 : skip : length(segs_neg)
    n = n + size(segs_neg(i).color, 1);
  end
  xi = zeros(n, featdim);
  %yi = zeros(n, 1);
  k = 0;
  for i = 1 : skip : length(segs_neg)
      
    disp([int2str(vi) ':' int2str(i) ':' int2str(length(segs_neg))]);
      
%     fr = segs_neg(i).fr;
%     imname = [im_dir 'img_' sprintf('%.6d', fr) '.jpg'];
%     im = imread(imname);
        
    for j = 1 : size(segs_neg(i).color, 1)
      k = k + 1;
      %x_neg(m, :) = normalize_feature(segs_neg(i).flow(j, :), feat_n);
      %xi(m, :) = normalize_feature(segs_neg(i).color(j, :)/10^2, feat_n);
      %colorfeat = normalize_feature(segs_neg(i).color(j, :)/10^2, 1);
      colorfeat = segs_neg(i).color(j,:);
      colorfeat = colorfeat ./ (sum(colorfeat) + eps);
      
      %bbox = get_mask_coord(segs_neg(i).mask{j});
      %hogfeat = get_hog(im, bbox, fsize, sbin);
      %hogfeat = segs_neg(i).hog(j,:);
      
      %shapefeat = get_mask_small(segs_neg(i).mask{j}, sqrt(shapedim));
%       xi(k, :) = [colorfeat hogfeat];
      xi(k, :) = colorfeat;
      
      %x_neg(m, :) = segs_neg(i).color(j, :);
      %yi(k) = segs_neg(i).label;
    end
    
  end
  
  clear segs_neg;
  
  x_neg = [x_neg; xi];
  %y_neg = [y_neg; yi];
  
end