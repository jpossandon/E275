
load('/Users/jossando/trabajo/E275/data/s01/VP001eye','eyedata')
% this is for the behavioural analysis
s=1
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
    eyedata.events      = auxdata;
   % data                = struct_up('data',auxdata,2);
   % stim                = struct_up('stim',stimdata,2);
   % sample              = struct_up('sample',sampledata,2);
      save('/Users/jossando/trabajo/E275/data/s01/s01eye_noeeg','eyedata') 




%%
%this is for eeg
clear
load('/Users/jossando/trabajo/E275/data/s01/VP001eye','eyedata')


indxtrig = find(strcmp(eyedata.marks.type,'ETtrigger'));
trialstoelim = eyedata.marks.trial(indxtrig(find(diff(eyedata.marks.value(indxtrig))==0)+1));
for t = 1:length(trialstoelim)
    auxelim         = find(eyedata.events.trial==trialstoelim(end-t+1));
    auxelimsample   = find(eyedata.samples.trial==trialstoelim(end-t+1));
    auxelimmark     = find(eyedata.marks.trial==trialstoelim(end-t+1)); 
     
    eyedata.events.trial(eyedata.events.trial>trialstoelim(end-t+1))    =  eyedata.events.trial(eyedata.events.trial>trialstoelim(end-t+1))-1;
    eyedata.samples.trial(eyedata.samples.trial>trialstoelim(end-t+1))  =  eyedata.samples.trial(eyedata.samples.trial>trialstoelim(end-t+1))-1;
    eyedata.marks.trial(eyedata.marks.trial>trialstoelim(end-t+1))      =  eyedata.marks.trial(eyedata.marks.trial>trialstoelim(end-t+1))-1; 
    
    if ~isempty(auxelim)
        eyedata.events = struct_elim(eyedata.events,auxelim,2,1);
    end
    if ~isempty(auxelimsample)
         eyedata.samples = struct_elim(eyedata.samples,auxelimsample,2,1);
    end
    if ~isempty(auxelimmark)
         eyedata.marks = struct_elim(eyedata.marks,auxelimmark,2,1);
    end
end

s=1
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
    eyedata.events      = auxdata;
   % data                = struct_up('data',auxdata,2);
   % stim                = struct_up('stim',stimdata,2);
   % sample              = struct_up('sample',sampledata,2);
      save('/Users/jossando/trabajo/E275/data/s01/s01eye','eyedata') 
