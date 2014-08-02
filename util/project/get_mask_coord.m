function bbox = get_mask_coord(mask)

[row col] = find(mask == 1);
y_min = min(row);
x_min = min(col);
y_max = max(row);
x_max = max(col);

bbox(1) = x_min;
bbox(2) = y_min;
bbox(3) = x_max - x_min + 1;
bbox(4) = y_max - y_min + 1;