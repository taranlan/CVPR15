warning off

addpath(genpath('../util'));
PATHfeat = '/afs/cs/group/cvgl/rawdata/MPIData/segments/';
PATHvideo = '/afs/cs/group/cvgl/rawdata/MPIData/labelled/';
PATHmask = [PATHfeat 'fgmask/'];

load('../data/video_names');
load('../data/attributes_cooking');
conf.annos = annos_co;

v_test = [30:33, 19:23, 37];
v_tr = setdiff(1:44, v_test);
conf.v_tr = v_tr;
conf.v_test = v_test;

conf.videos = videos;
conf.class_names = class_names;
conf.imsize = [1224 1624];

conf.colordim = 23*3;
conf.class_n = 64;
