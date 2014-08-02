function mask = get_full_mask(mask_small, bbox, nr, nc)

mask = logical(zeros(nr, nc));
mask(bbox(2):bbox(2)+bbox(4)-1, bbox(1):bbox(1)+bbox(3)-1) = mask_small;
    