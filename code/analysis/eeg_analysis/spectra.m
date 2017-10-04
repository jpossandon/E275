clear
E275_params                                 % basic experimental parameters               % 
p.analysisname  = 'spectra';
%%
% subject configuration and data
 
if ismac 
run('/Users/jossando/trabajo/matlab/unfold/init_unfold.m')        
else
run('/Users/jpo/trabajo/matlab/unfold/init_unfold.m')   
end    
for tk = p.subj
    tk
%  for tk = p.subj;
% tk = str2num(getenv('SGE_TASK_ID'));
    if ismac    
        cfg_eeg             = eeg_etParams_E275('sujid',sprintf('s%02d',tk),...
            'expfolder','/Users/jossando/trabajo/E275/'); % this is just to being able to do analysis at work and with my laptop
    else
        cfg_eeg             = eeg_etParams_E275('sujid',sprintf('s%02d',tk),...
            'expfolder','/Users/jpo/trabajo/E275/');
    end
    
    filename                = sprintf('s%02d',tk);
    cfg_eeg                 = eeg_etParams_E275(cfg_eeg,...
                                            'filename',filename,...
                                            'EDFname',filename,...
                                            'event',[filename '.vmrk'],...
                                            'clean_name','final',...
                                            'analysisname',p.analysisname);    % single experiment/session parameters 
    load([cfg_eeg.eyeanalysisfolder cfg_eeg.filename 'eye.mat'])            % eyedata               
   
    % get relevant epochevents
    load([cfg_eeg.analysisfolder 'cleaning/' cfg_eeg.sujid '/' cfg_eeg.filename cfg_eeg.clean_name],'bad');
    [trl,events]  = define_event(cfg_eeg,eyedata,'ETtrigger',{'value','==96'},[0 8000]);
    epochevents             = [];
    epochevents.latency     = [events.time;events.time+4000];                       % fixation start, here the important thing is the ini pos
    epochevents.latency     = epochevents.latency(:)';
    rem = [];
    for e = 1:length(epochevents.latency)
        if any((epochevents.latency(e)>bad(:,1) & epochevents.latency(e)<bad(:,2)) |...
                (epochevents.latency(e)+4000>bad(:,1) & epochevents.latency(e)+4000<bad(:,2)))
            rem = [rem,e];
        end
    end
        epochevents.latency(rem)             = [];
    epochevents.type        = repmat({'seg'},1,length(epochevents.latency));
    [EEG,winrej] = getDataDeconv(cfg_eeg,epochevents,200);  
    EEGepoch = pop_epoch( EEG, {  'seg'  }, [0  2], 'newname', ' repochs', 'epochinfo', 'yes');
 
    for ch = 1:EEGepoch.nbchan
        [Pxx,F] = periodogram(squeeze(EEGepoch.data(ch,:,:)),[],200,EEG.srate,'power');
        spctM(ch,:) = mean(Pxx,2);
        spctSTD(ch,:) = std(Pxx,1,2);
    end
end