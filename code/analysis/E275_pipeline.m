% E275 pipeline

%%
% Read the eyetracker file
% b
subjects             = [1,2];

for suj=subjects
    eegfilename     = sprintf('s%02d',suj);
    suj             = sprintf('s%02d',suj);

    cfg             = eeg_etParams_E275('sujid',suj,...%'expfolder','/net/store/nbp/projects/EEG/E275/',...      % to run things in different environments
                                    'task_id','fv_touch',...
                                    'filename',eegfilename,...
                                    'event',[eegfilename '.vmrk'],...
                                    'trial_trig_eeg',{'S 96'},...
                                    'trial_trig_et',{'96'});      % experiment parameters 
                                
    load(sprintf('%s%seye',cfg.eyeanalysisfolder,suj))
    eyedata         = synchronEYEz(cfg, eyedata);   
    save([cfg.eyeanalysisfolder cfg.filename 'eye'],'eyedata')
    load(sprintf('%salleye%s',cfg.EDFfolder,suj))               % afterwards all will be iun eye file
    data            = struct_up('data',auxdata,2);
    stim            = struct_up('stim',stimdata,2);
    sample          = struct_up('sample',sampledata,2);
end
save([cfg.analysisfolder 'eyedata/alleyedata'],'data','stim')
save([cfg.analysisfolder 'eyedata/allsampledata'],'sample')