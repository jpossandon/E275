function outputlabels = mirrindex(inputlabels,mirrchanfile) 
load(mirrchanfile)
if strfind(mirror_chans.labels{1},'E')
    [LIA,LOCB] = ismember(lower(strtok(mirror_chans.labels(2,:),'E')),lower(inputlabels));
else
    [LIA,LOCB] = ismember(lower(mirror_chans.labels(2,:)),lower(inputlabels));
end
outputlabels = LOCB;
