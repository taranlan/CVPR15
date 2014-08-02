function compute_optical_flow(vid)

addPathVar;
IMSHOW = 1;

videos = conf.videos; % video names

%%%%%%%%%%%%%%%%%%%%%%%% feature Paths %%%%%%%%%%%%%%%%%%%%%%%%
im_dir = [PATHvideo videos{vid} '/'];
flow_dir = [PATHflow videos{vid} '/'];

if(~exist(flow_dir, 'dir'))
  mkdir(flow_dir);
end

d_im = dir([im_dir '*.jpg']);

skip_n = 5; 

for i = 1 : skip_n: length(d_im)-1
    
  disp([int2str(i) ':' int2str(length(d_im)-1)]); 
  fn = [flow_dir d_im(i+1).name '.mat'];
  
  imname1 = d_im(i).name;        
  imname2 = d_im(i+1).name;  
    
  im1 = double(imread([im_dir imname1]));
  im2 = double(imread([im_dir imname2]));
  
  % compute optical flow on resized image
  % im1 = imresize(im1, 0.5);
  % im2 = imresize(im2, 0.5);

  tic
  flow = mex_LDOF(im1,im2);
  toc
  
  vx = flow(:,:,1);
  vy = flow(:,:,2);
  
  % optical flow visualization
  if IMSHOW
    figure(1);
    subplot(1,2,1);
    imshow(uint8(im1));
    subplot(1,2,2);
    imshow(uint8(flowToColor(flow)));
    pause(0.5);
  end
  
  save(fn, 'vx', 'vy');
  
end
