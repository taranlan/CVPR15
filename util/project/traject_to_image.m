function im_dense = traject_to_image(dense, nr, nc, fr_st, fr_ed)

%im_dense = zeros(nr, nc, feat_n, fr_ed-fr_st+1);  
% for i = fr_st : fr_ed
%   x = round(dense(i).x * nc);
%   y = round(dense(i).y * nr);
%   id = dense(i).id';
%   for j = 1:length(x)
%     im_dense(y(j), x(j), :, i-fr_st+1) = id(j, :);
%   end
% end

% im_dense = zeros(nr, nc);
% for i = fr_st : fr_ed
%   x = min(max(1, dense(i).track_x(:,1)), nc);
%   y = min(max(1, dense(i).track_y(:,1)), nr);
%   for j = 1:length(x)
%     im_dense(y(j), x(j)) = 1;
%   end
% end

im_dense = zeros(nr, nc);  
fr_ed = min(fr_ed, length(dense));
for i = fr_st : fr_ed
  x = min(nc, max(1, round(dense(i).x * nc)));
  y = min(nr, max(1, round(dense(i).y * nr)));
  for j = 1:length(x)
    im_dense(y(j), x(j)) = 1;
  end
end
