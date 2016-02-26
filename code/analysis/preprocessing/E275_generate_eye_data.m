% generate data experiment touch

subjects            = [1,2];
cfg.edfreadpath     = '/net/store/users/jossando/edfread/build/linux64/';
cfg.EDFfolder       = '/net/store/nbp/touch/data/';
cfg.eyes            = 'monoocular';

for s = subjects
    cfg.filename        = sprintf('s%02d',s);
    eyedata             = eyeread(cfg); 
    
    eegfilename         = sprintf('s%02d',s);
    suj                 = sprintf('s%02d',suj);

    cfg                 = eeg_etParams_E275('sujid',suj,'expfolder','/net/store/nbp/projects/EEG/E275/',...      % to run things in different environments
                                    'task_id','fv_touch',...
                                    'filename',eegfilename,...
                                    'event',[eegfilename '.vmrk'],...
                                    'trial_trig_eeg',{'S 96'},...
                                    'trial_trig_et',{'96'});      % experiment parameters 
                                
    eyedata             = synchronEYEz(cfg, eyedata);   
    save([cfg.eyeanalysisfolder cfg.filename 'eye'],'eyedata')
    
    auxdata             = eyedata.events;
    
    auxdata.block       = zeros(1,length(auxdata.start));
    auxdata.blockstart  = zeros(1,length(auxdata.start));
    auxdata.image       = zeros(1,length(auxdata.start));
    auxdata.stim        = zeros(1,length(auxdata.start));
    auxdata.latestim    = zeros(1,length(auxdata.start));
    
    % actual stimulations
    auxstim             = eyedata.marks.value(strcmp(eyedata.marks.type,'ETtrigger'));
    auxstimtime         = eyedata.marks.time(strcmp(eyedata.marks.type,'ETtrigger'));
    auxstimtrial        = eyedata.marks.trial(strcmp(eyedata.marks.type,'ETtrigger'));
    stimdata.value      = auxstim(auxstim<5 & auxstim>0);  % take in account only stimulation start and only stimulation during the trial and not at the start (values 1,2,3 - left, right and bilateral respectively; value 10 is for stim stop and there is NaNs when there was nono stimulation during the complete trial)(initial stimulation is always at time 150 or 151)
    stimdata.time       = auxstimtime(auxstim<5 & auxstim>0); %
    stimdata.trial      = auxstimtrial(auxstim<5 & auxstim>0);
    stimdata.subject    = s*ones(1,length(stimdata.trial));
    sampledata          = eyedata.samples;
    sampledata.subject  = s*ones(1,length(sampledata.time));
    for t = unique(eyedata.events.trial)
        % which block type (0 - uncrossed ; 1 - crossed)
        auxvalue        = eyedata.marks.value(strcmp(eyedata.marks.type,'block') & eyedata.marks.trial == t);
        auxdata.block(auxdata.trial == t) = auxvalue;
        % was block start (0 - no ; 1 - yes)
        auxvalue        = eyedata.marks.value(strcmp(eyedata.marks.type,'block_start') & eyedata.marks.trial == t);
        auxdata.blockstart(auxdata.trial == t) = auxvalue;
        % which image
        auxvalue        = eyedata.marks.value(strcmp(eyedata.marks.type,'image') & eyedata.marks.trial == t);
        auxdata.image(auxdata.trial == t) = auxvalue;
  
        % if there is stimulation during the trial (0 - no; 1 - yes) , as there can be more than one stimulation that information will be in the stimdata structure       
        if ~isempty(find(stimdata.trial==t))
            auxdata.latestim(auxdata.trial == t) = 1;
        end
    end
    auxdata.subject     = s*ones(1,length(auxdata.trial));
    data                = struct_up('data',auxdata,2);
    stim                = struct_up('stim',stimdata,2);
    sample              = struct_up('sample',sampledata,2);
      
end
     
save('/net/store/nbp/touch/data/alleyedata','data','stim')
save('/net/store/nbp/touch/data/allsampledata','sample')
    