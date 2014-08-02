function flow_hist = seg_to_bow(im_dense, mask, K)

feat_n = size(im_dense, 3);
tdim = size(im_dense, 4);

im_dense_mask = im_dense .* repmat(mask, [1 1 feat_n, tdim]);
flow_hist = [];
for i = 1 : feat_n
  feat = im_dense_mask(:,:,i,:);
  feat = feat(:);
  feat = feat(feat~=0);
  if isempty(feat)
    %disp('empty feature');
    hist_tmp = zeros(K, 1);
  else
    hist_tmp = histc(feat, 1:K);
    if length(feat) == 1
      hist_tmp = hist_tmp';
    end
  end
  flow_hist = [flow_hist; hist_tmp];
end