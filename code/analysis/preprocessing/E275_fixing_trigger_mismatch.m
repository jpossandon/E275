% eyetracker files correction, when eeg trigger files do not match eyedata
load('/Users/jossando/trabajo/E275/data/s29/s29eye_orig_nochange.mat')
% first trial was not saved, this is marks 1:11
eyedata.marks = struct_elim(eyedata.marks,1:11,2,1)
eyedata.events = struct_elim(eyedata.events,find(eyedata.events.trial==1 | (eyedata.events.trial==2 & eyedata.events.start<-2000)),2,1)
eyedata.samples = struct_elim(eyedata.samples,find(eyedata.samples.trial==1 | (eyedata.samples.trial==2 & eyedata.samples.time<-2000)),2,1)

save('/Users/jossando/trabajo/E275/data/s29/s29eye_orig.mat','eyedata')


%%
% channelcorections

chan_cor.filestochange = {'s31'};
chan_cor.pre           = [1];
chan_cor.elim_chan = {[]};
chan_cor.correct_chan = {[1:63,75,76,64:74]};
save('S31_channels_corrections.mat','chan_cor')