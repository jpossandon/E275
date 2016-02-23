% E275 pipeline

%%
% Read the eyetracker file
% b
suj             = 2;
eegfilename     = sprintf('s%0d',suj);
suj             = sprintf('s%0d',suj);

cfg             = eeg_etParams_E275('sujid',suj,'expfolder','/net/store/nbp/projects/EEG/E275/',...      % to run things in different environments
                                    'task_id','fv_touch',...
                                    'filename',eegfilename,...
                                    'event',[eegfilename 'vmrk'],...
                                    'trial_trig_eeg',{'S 96'},...
                                    'trial_trig_et',{'96'});      % experiment parameters 
                                
eyedata         = eyeread(cfg); 
%save([cfg.eyeanalysisfolder cfg.filename 'eye'],'eyedata')
% load([cfg.eyeanalysisfolder cfg.filename 'eye'],'eyedata')
eyedata         = synchronEYEz(cfg, eyedata);   
save([cfg.eyeanalysisfolder cfg.filename 'eye'],'eyedata')