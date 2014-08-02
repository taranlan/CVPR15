function seg_new = seg_dilate(seg, N)
        
se = strel('diamond',N);
seg_new = imdilate(logical(seg), se);