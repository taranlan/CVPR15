warning off

addpath(genpath('../util'));
PATHvideo = '/afs/cs/group/cvgl/rawdata/MPIData/labelled/';
PATHfeat = '/afs/cs/group/cvgl/rawdata/MPIData/segments/';
PATHregion = [PATHfeat 'regionProposals/']; % original region proposals
PATHflow = [PATHfeat 'flow/']; % optical flow

% video names
load('../data/video_names', 'videos');

conf.videos = videos;
%conf.imsize = [1224 1624];