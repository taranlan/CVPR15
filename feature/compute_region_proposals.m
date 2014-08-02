function compute_region_proposals(vid)

addPathVar;

videos = conf.videos;

%%%%%%%%%%%%%%%%%%%%%%%% feature Paths %%%%%%%%%%%%%%%%%%%%%%%%
im_dir = [PATHvideo videos{vid} '/']; % path of video frames 
region_dir = [PATHregion videos{vid} '/']; % path of region proposals

d = dir([im_dir '*.jpg']);

skip_n = 5; 

for i = 1 : skip_n: length(d)
    
  disp([int2str(i) ':' int2str(length(d))]);
  
  imname = d(i).name; 
  
  [proposals superpixels image_data unary] = generate_proposals([im_dir imname]);
  
  fn = [region_dir imname '.mat'];
  save(fn, 'proposals', 'superpixels', 'unary');
  
end
