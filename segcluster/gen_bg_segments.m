function gen_bg_segments(vid)

addPathVar;

videos = conf.videos;

im_dir = [PATHvideo videos{vid} '/cam-002/'];  
mask_dir = [PATHmask videos{vid} '/'];
d = dir([mask_dir '*.mat']);

seg_fr = zeros(1, length(d));
for i = 1 : length(d)
  seg_fr(i) = str2num(d(i).name(5:10));
end

% negative patch size
cropsize = [300 300];

%%%%%%%%%%%%%%%% color histogram parameters %%%%%%%%%%%%%%%%%%
init_param_colorhist;

maxneg = 100; % number of negative images
cachesize = 12000; % number of negative patches
numneg = length(seg_fr);
maxneg = min(maxneg, numneg);
rndneg = floor(cachesize / maxneg); % number of negative examples per image

if numneg > maxneg
  rand_neg = randperm(numneg);
  rand_neg = rand_neg(1:maxneg);
else
  rand_neg = 1 : numneg;
end

for i = 1 : maxneg
    
  disp(['random negatives: ' int2str(i) ':' int2str(maxneg)]);
  j = rand_neg(i);
  fr = seg_fr(j);
  imname = d(j).name(1:end-4);
  im = imread([im_dir imname]);
  load([mask_dir imname '.mat']);
  
  [L,a,b] = RGB2Lab(double(im(:,:,1)), double(im(:,:,2)), double(im(:,:,3)));

  seg_n = length(masks);
  bbox_gt = [];
  for k = 1 : seg_n
    bbox_gt = [bbox_gt; masks(k).bbox];
  end 
  
  % generate random negatives
  num = 0;
  for k = 1 : rndneg
    x = random('unid', size(im,2)-cropsize(2)+1);
    y = random('unid', size(im,1)-cropsize(1)+1);
    bbox_rand = [x y cropsize(2) cropsize(1)];
    if ~isempty(bbox_gt)
      os = overlapping(bbox_rand, bbox_gt);
      if any(os >= 0.3)
        continue;
      end
    end
    num = num + 1;
    y_vec = y:y+cropsize(1)-1;
    x_vec = x:x+cropsize(2)-1;
    
    L0 = L(y_vec, x_vec);
    a0 = a(y_vec, x_vec);
    b0 = b(y_vec, x_vec);
    
    colorfeat = [histc(L0(:), LBinEdges); ...
                 histc(a0(:), abBinEdges); ...
                 histc(b0(:), abBinEdges)];
    colorfeat = colorfeat';
    
    if num == 1
      segs_neg(i).fr = fr;  
      segs_neg(i).color = colorfeat;
      segs_neg(i).bbox = bbox_rand;
    else
      segs_neg(i).color = [segs_neg(i).color; colorfeat];
      segs_neg(i).bbox = [segs_neg(i).bbox; bbox_rand];
    end  
    
  end
  
end

save(['mat/segments/neg_seg_' videos{vid} '.mat'], 'segs_neg', '-v7.3');

