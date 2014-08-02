function compute_multi_segments(vid)

% Usage: select the key region proposals by using the motion features

addPathVar;

videos = conf.videos; % video names

%%%%%%%%%%%%%%%%%%%%%%%% feature Paths %%%%%%%%%%%%%%%%%%%%%%%%
im_dir = [PATHvideo videos{vid} '/'];
region_dir = [PATHregion videos{vid} '/'];
flow_dir = [PATHflow videos{vid} '/'];
exp_dir = [PATHmask videos{vid} '/'];

if(~exist(exp_dir, 'dir'))
  mkdir(exp_dir);
end

tic;
select_multi_segments(exp_dir, im_dir, region_dir, flow_dir);
toc;
