function mask_feat = get_shape_feat(mask, scale)

% [row col] = find(mask == 1);
% y_min = min(row);
% x_min = min(col);
% y_max = max(row);
% x_max = max(col);
% h = y_max - y_min + 1; 
% w = x_max - x_min + 1;
% wh = max(w, h);

[h w] = size(mask);
wh = max(w,h);
mask_2 = logical(zeros(wh, wh));

if h > w
  x_st = round((h - w)/2) + 1;
  x_ed = x_st + w - 1;
  mask_2(:, x_st:x_ed) = mask;
else
  y_st = round((w - h)/2) + 1;
  y_ed = y_st + h - 1;
  mask_2(y_st:y_ed, :) = mask;
end
mask_feat = imresize(mask_2, [scale scale]);