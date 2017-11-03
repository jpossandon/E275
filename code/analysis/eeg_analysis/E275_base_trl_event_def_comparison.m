[trls.LU,events.LU]                = define_event(cfg_eeg,eyedata,'ETtrigger',{'value','==1'},p.times);            
[trls.RU,events.RU]                = define_event(cfg_eeg,eyedata,'ETtrigger',{'value','==2'},p.times);
if tk<6
[trls.LC,events.LC]                = define_event(cfg_eeg,eyedata,'ETtrigger',{'value','==3'},p.times);            
[trls.RC,events.RC]                = define_event(cfg_eeg,eyedata,'ETtrigger',{'value','==4'},p.times);            
else
[trls.LC,events.LC]                = define_event(cfg_eeg,eyedata,'ETtrigger',{'value','==5'},p.times);            
[trls.RC,events.RC]                = define_event(cfg_eeg,eyedata,'ETtrigger',{'value','==6'},p.times);            
end    
[trls.image,events.image]             = define_event(cfg_eeg,eyedata,'ETtrigger',{'value','==96'},p.times);  
[~,auxev]   = define_event(cfg_eeg,eyedata,'block_start',{'value','==1'},p.times);  
events.image.indxfirst = find(ismember(events.image.trial,auxev.trial));
trls.firstimage = trls.image(events.image.indxfirst,:)

[trls.fix,events.fix] = define_event(cfg_eeg,eyedata,1,{'&origstart','>0'},...
                p.times,{-2,1,'origstart','>0';-2,1,'dur','>500'}); 


p.trls_stim                    = {'LU','LC','RU','RC','image','firstimage','fix'};
