function clip = get_clip_info(vid, annos, videos, class_names)

annos_idx = find(ismember(annos.fileName, [videos{vid} '-cam-002']));
annos_fr_st = annos.startFrame(annos_idx);
annos_fr_ed = annos.endFrame(annos_idx);

n = 0;
for i = 1 : length(annos_idx)
  class = annos.activity{annos_idx(i)};
  label = find(ismember(class_names, class));
  if label < 2
    continue;
  end
  n = n + 1;
  clip(n).fr = [annos_fr_st(i) annos_fr_ed(i)];
  clip(n).label = label;
end
  
  
  