function model = train_classifier(x_pos, x_neg)
% Input
%   x: feature vectors of the segments
% 
% Output
%   model: the learned classifier
%
% Notes
%   We train the segment classifiers in parallel.
%   This function trains one segment classifier. 

pos_n = size(x_pos, 1);
neg_n = size(x_neg, 1);
label = [ones(pos_n, 1); -1*ones(neg_n, 1)];
feat = [x_pos; x_neg];
model = train(label, sparse(feat), '-s 4 -c 1000');
model.w = model.w(1,:);
