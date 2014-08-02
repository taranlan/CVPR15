function im_dense = map_dense_image(dense, nr, nc, fr_st, fr_ed, feat_n)

im_dense = zeros(nr, nc, feat_n, fr_ed-fr_st+1);  
fr_ed = min(fr_ed, length(dense));
for i = fr_st : fr_ed
  x = round(dense(i).x * nc);
  y = round(dense(i).y * nr);
  id = dense(i).id';
  for j = 1:length(x)
    im_dense(y(j), x(j), :, i-fr_st+1) = id(j, :);
  end
end
