% E275 pipeline

% Read the eyetracker file
% b
suj             = 1;
eegfilename     = sprintf('VP00%d',suj);
cfg             = eeg_etParams_E275('sujid',suj,...
                                    'expfolder','/net/store/nbp/projects/EEG/E275/',...      % to run things in different environments
                                    'task_id','fv_touch',...
                                    'filename',sprintf('VP00%d',suj),...
                                    'event',sprintf('VP00%d.vmrk',suj),...
                                    'trial_trig_eeg','S 96',...
                                    'trial_trig_et','96');      % experiment parameters 
                                
eyedata         = eyeread(cfg); 
save([cfg.eyeanalysisfolder cfg.filename 'eye'],'eyedata')
                                