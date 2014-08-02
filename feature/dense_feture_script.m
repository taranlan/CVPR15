clear;
clc;

addPathVar;

code_dir = '../../util/external/improved_trajectory_release/release/';
% dense_feature_dir: the path of the dense trajectory features

for i = 1:length(videos) 
    
  fn = ['scripts/dense_feature_script_' int2str(i)];
  
  fid = fopen(fn, 'w');
  str = ['./' code_dir 'DenseTrackStab ' PATHvideo videos{i} ' | gzip > ' dense_feature_dir videos{i} '.gz'];
  fprintf(fid, '%s\n', str);
  
  fclose(fid);
  
end

      





