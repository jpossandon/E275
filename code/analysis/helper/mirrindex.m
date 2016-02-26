function outputlabels = mirrindex(inputlabels,mirrchanfile) 
load(mirrchanfile)
[LIA,LOCB] = ismember(lower(mirror_chans.labels(2,:)),lower(inputlabels));
outputlabels = LOCB;
