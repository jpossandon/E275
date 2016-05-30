% E275 pipeline

%%
% Read the eyetracker file
% b
oldsubjects             = [1:6];
addsubjects             = 7;
    
for s=addsubjects
    eegfilename     = sprintf('s%02d',s);
    suj             = sprintf('s%02d',s);

    if ismac    
        cfg             = eeg_etParams_E275('sujid',suj,'expfolder','/Users/jossando/trabajo/E275/'); % this is just to being able to do analysis at work and with my laptop
    else
        cfg             = eeg_etParams_E275('sujid',suj);
    end
    cfg             = eeg_etParams_E275(cfg,'sujid',suj,...%'expfolder','/net/store/nbp/projects/EEG/E275/',...      % to run things in different environments
                                    'task_id','fv_touch',...
                                    'filename',eegfilename,...
                                    'event',[eegfilename '.vmrk'],...
                                    'trial_trig_eeg',{'S 96'},...
                                    'trial_trig_et',{'96'});      % experiment parameters 
    if ~isempty(oldsubjects)
        load([cfg.analysisfolder 'eyedata/alleyedata'],'data','stim')
        load([cfg.analysisfolder 'eyedata/allsampledata'],'sample')
    end                            
    if ~ismember(s,oldsubjects)
        if s==1                         % fix for the first subject that did not have all triggers
            load([cfg.EDFfolder suj 'eye_noeeg.mat'])
        else
            load([cfg.EDFfolder suj 'eye_orig.mat'])
        end
           if s>5
               limt = 7;
           else
               limt =5;
           end
        auxstim             = eyedata.marks.value(strcmp(eyedata.marks.type,'ETtrigger'));
        auxstimtime         = eyedata.marks.time(strcmp(eyedata.marks.type,'ETtrigger'));
        auxstimtrial        = eyedata.marks.trial(strcmp(eyedata.marks.type,'ETtrigger'));
        stimdata.value      = auxstim(auxstim<limt & auxstim>0);  % take in account only stimulation start and only stimulation during the trial and not at the start (values 1,2,3 - left, right and bilateral respectively; value 10 is for stim stop and there is NaNs when there was nono stimulation during the complete trial)(initial stimulation is always at time 150 or 151)
        stimdata.time       = auxstimtime(auxstim<limt & auxstim>0); %
        stimdata.trial      = auxstimtrial(auxstim<limt & auxstim>0);
        stimdata.subject    = s*ones(1,length(stimdata.time));
        sampledata          = eyedata.samples;
        sampledata.subject  = s*ones(1,length(sampledata.time));
        data                = struct_up('data',eyedata.events,2);
        stim                = struct_up('stim',stimdata,2);
        sample              = struct_up('sample',sampledata,2);
        
          if s==1                         % fix for the first subject that did not have all triggers
            load([cfg.EDFfolder suj 'eye.mat'])
          end

        eyedata         = synchronEYEz(cfg, eyedata);
        save(sprintf('%s%seye',cfg.eyeanalysisfolder,suj),'eyedata')

    end
      clear stimdata sampledata eyedata
      save([cfg.analysisfolder 'eyedata/alleyedata'],'data','stim')
save([cfg.analysisfolder 'eyedata/allsampledata'],'sample')
end
