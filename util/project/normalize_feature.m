function feat_norm = normalize_feature(feat, feat_n)

featdim = size(feat, 2) / feat_n;

feat_norm = feat;
for i = 1 : feat_n
  feat_idx = (i-1) * featdim + 1 : i * featdim;
  feat_norm(:,feat_idx) = feat(:,feat_idx) ./ ...
                 (repmat(sum(feat(:,feat_idx), 2), [1 featdim]) + eps);
end