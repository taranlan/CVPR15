function [x0 y0 x1 y1] = bbox_large(bbox, pad_x, pad_y, nr, nc)

% pad_x = bbox(3) / 5;
% pad_y = bbox(4) / 5;

x0 = max(bbox(1)-pad_x, 1);
y0 = max(bbox(2)-pad_y, 1);
x1 = min(nc, x0 + bbox(3) + 2 * pad_x - 1);
y1 = min(nr, y0 + bbox(4) + 2 * pad_y - 1);