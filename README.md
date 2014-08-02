CVPR15
======

Generate foreground segments for video frames

cd feature/
1. run compute_region_proposals.m to generate region proposals for every video frame
2. run compute_optical_flow.m to compute optical flow for every video frame

cd videoseg/
1. run compute_multi_segments.m to select the key region proposals for every frame based on the motion features
